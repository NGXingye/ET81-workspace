$ErrorActionPreference = 'Stop'
$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$GuardFile = Join-Path $WorkspaceRoot 'runtime\guard.ps1'

function Read-HookStdin {
    $stream = [Console]::OpenStandardInput()
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $reader = New-Object System.IO.StreamReader($stream, $utf8, $true)
    $text = $reader.ReadToEnd()
    if ($text.Length -gt 0 -and [int]$text[0] -eq 0xFEFF) { return $text.Substring(1) }
    return $text
}

function Write-Hook([string]$Permission, [string]$Message) {
    $payload = [ordered]@{ permission = $Permission }
    if ($Message) {
        $payload['user_message'] = $Message
        $payload['agent_message'] = $Message
    }
    $json = $payload | ConvertTo-Json -Compress
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $bytes = $utf8.GetBytes($json)
    $stdout = [Console]::OpenStandardOutput()
    $stdout.Write($bytes, 0, $bytes.Length)
    $stdout.Flush()
    exit 0
}

function Invoke-Guard([string]$Target) {
    $out = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $GuardFile -Path $Target 2>&1 | Out-String
    return @{ Code = $LASTEXITCODE; Out = $out.Trim() }
}

function Get-GuardError([string]$Text) {
    try {
        $o = $Text | ConvertFrom-Json
        if ($o.error) { return [string]$o.error }
    } catch { }
    if ($Text) { return $Text }
    return 'source write refused'
}

function Test-UnderRoot([string]$Full, [string]$Root) {
    try { $f = [System.IO.Path]::GetFullPath($Full) } catch { return $false }
    $r = [System.IO.Path]::GetFullPath($Root)
    if ($f.Equals($r, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if (-not $r.EndsWith('\')) { $r = $r + '\' }
    return $f.StartsWith($r, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-Roots {
    $lines = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $GuardFile -ListRoots 2>&1
    $roots = New-Object System.Collections.Generic.List[string]
    foreach ($line in @($lines)) {
        $t = ([string]$line).Trim()
        if ($t -and $t -notmatch '^(ok|error|Exception|Category|\+|At )') { $roots.Add($t) }
    }
    return $roots
}

function Add-Unique([System.Collections.Generic.List[string]]$List, [string]$Value) {
    if (-not $Value) { return }
    foreach ($u in $List) {
        if ($u.Equals($Value, [System.StringComparison]::OrdinalIgnoreCase)) { return }
    }
    $List.Add($Value)
}

function Resolve-Candidate([string]$Token, [string]$Cwd) {
    $t = $Token.Trim().Trim('"').Trim("'").Trim('`').TrimEnd('\', '/')
    if (-not $t -or $t.StartsWith('-')) { return $null }
    if ($t -match '^[A-Za-z]:\\') {
        try { return [System.IO.Path]::GetFullPath($t) } catch { return $null }
    }
    if ($t.StartsWith('\\')) { return $null }
    try { return [System.IO.Path]::GetFullPath((Join-Path $Cwd $t)) } catch { return $null }
}

function Get-ShellCandidates([string]$Command, [string]$Cwd) {
    $found = New-Object System.Collections.Generic.List[string]
    $abs = [regex]'[A-Za-z]:\\[^\s"''<>|*?\r\n]+'
    foreach ($m in $abs.Matches($Command)) {
        $v = $m.Value.Trim().TrimEnd(')', ',', ';', '&', '|')
        Add-Unique $found (Resolve-Candidate $v $Cwd)
    }
    $named = [regex]'(?i)(?:-Path|-LiteralPath|-Destination|-DestinationPath)\s+((?:"[^"]+")|(?:''[^'']+'')|(?:\S+))'
    foreach ($m in $named.Matches($Command)) {
        Add-Unique $found (Resolve-Candidate $m.Groups[1].Value $Cwd)
    }
    $redir = [regex]'(?:^|[^0-9])>>?\s+((?:"[^"]+")|(?:''[^'']+'')|(?:\S+))'
    foreach ($m in $redir.Matches($Command)) {
        Add-Unique $found (Resolve-Candidate $m.Groups[1].Value $Cwd)
    }
    if ($Command -match '(?i)^\s*(Set-Content|Add-Content|Out-File|New-Item|Remove-Item|Move-Item|Copy-Item|Rename-Item|del|erase|mkdir|rmdir|ni|ri|rm|copy|move|ren)\s+(\S+)') {
        Add-Unique $found (Resolve-Candidate $Matches[2] $Cwd)
    }
    return $found
}

function Test-ShellWrite([string]$Command) {
    if ($Command -match '(?i)(^|[;&|`(]\s*)(Set-Content|Add-Content|Out-File|Tee-Object|New-Item|Remove-Item|Move-Item|Copy-Item|Rename-Item|Clear-Content|mkdir|rmdir)\b') { return $true }
    if ($Command -match '(?i)(^|[;&|`(]\s*)(del|erase|rd|ren|move|copy|ni|ri|rm)\b') { return $true }
    if ($Command -match '(?i)\b(py|python)\b' -and $Command -match '(?i)(\bopen\s*\(|\.write_text\s*\(|\.write_bytes\s*\()') { return $true }
    if ($Command -match '(?:^|[^0-9])>>?\s+\S') { return $true }
    return $false
}

function Refuse-IfDenied([string]$Target) {
    $r = Invoke-Guard $Target
    if ($r.Code -eq 0) { return }
    $err = Get-GuardError $r.Out
    Write-Hook 'deny' ('source write refused: ' + $err + ' (' + $Target + ')')
}

try {
    $raw = Read-HookStdin
    if (-not $raw) { Write-Hook 'allow' '' }
    $ev = $raw | ConvertFrom-Json
    $name = [string]$ev.hook_event_name
    if ($name -eq 'beforeShellExecution') {
        $command = [string]$ev.command
        $cwd = [string]$ev.cwd
        if (-not $cwd) { $cwd = $WorkspaceRoot }
        if (-not (Test-ShellWrite $command)) { Write-Hook 'allow' '' }
        $roots = @(Get-Roots)
        $cwdInside = $false
        foreach ($root in $roots) { if (Test-UnderRoot $cwd $root) { $cwdInside = $true; break } }
        $mentions = $false
        foreach ($root in $roots) {
            if ($command.IndexOf($root, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { $mentions = $true; break }
        }
        $candidates = @(Get-ShellCandidates $command $cwd)
        $checked = 0
        foreach ($c in $candidates) {
            $inRoot = $false
            foreach ($root in $roots) { if (Test-UnderRoot $c $root) { $inRoot = $true; break } }
            if ($inRoot) { $checked++; Refuse-IfDenied $c }
        }
        if ($checked -eq 0 -and ($mentions -or $cwdInside)) {
            Write-Hook 'deny' 'source write refused: could not isolate the source path'
        }
        Write-Hook 'allow' ''
    }

    $tool = [string]$ev.tool_name
    $writeTools = @('Write', 'StrReplace', 'Edit', 'Delete', 'EditNotebook', 'ApplyPatch')
    if ($writeTools -notcontains $tool) { Write-Hook 'allow' '' }
    $inputObj = $null
    if ($ev.PSObject.Properties.Name -contains 'tool_input') { $inputObj = $ev.tool_input }
    elseif ($ev.PSObject.Properties.Name -contains 'arguments') { $inputObj = $ev.arguments }
    $paths = New-Object System.Collections.Generic.List[string]
    $keys = @('path', 'file_path', 'target_file', 'target_notebook', 'filePath', 'notebook_path')
    if ($inputObj) {
        foreach ($k in $keys) {
            if ($inputObj.PSObject.Properties.Name -contains $k -and $inputObj.$k) { Add-Unique $paths ([string]$inputObj.$k) }
        }
        if ($inputObj.PSObject.Properties.Name -contains 'edits') {
            foreach ($e in @($inputObj.edits)) {
                if ($e -and $e.PSObject.Properties.Name -contains 'path' -and $e.path) { Add-Unique $paths ([string]$e.path) }
            }
        }
    }
    if ($paths.Count -eq 0) { Write-Hook 'deny' ('source write refused: ' + $tool + ' missing path') }
    foreach ($p in $paths) {
        $abs = $p
        if (-not [System.IO.Path]::IsPathRooted($abs)) { $abs = Join-Path $WorkspaceRoot $abs }
        Refuse-IfDenied $abs
    }
    Write-Hook 'allow' ''
} catch {
    $blob = ''
    if ($raw) { $blob = [string]$raw }
    if ($blob -match '(?i)C:\\myProject\\(trunk|SkillEditor|BridgeEditor|ActionEditor)\\') {
        Write-Hook 'deny' ('source write refused: guard hook error: ' + $_.Exception.Message)
    }
    Write-Hook 'allow' ''
}
