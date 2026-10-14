$ErrorActionPreference = 'Stop'
$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Read-HookStdin {
    $stream = [Console]::OpenStandardInput()
    $utf8 = New-Object System.Text.UTF8Encoding $false
    $reader = New-Object System.IO.StreamReader($stream, $utf8, $true)
    $text = $reader.ReadToEnd()
    if ($text.Length -gt 0 -and [int]$text[0] -eq 0xFEFF) { return $text.Substring(1) }
    return $text
}

function Test-CandidateJsonPath([string]$Path) {
    if (-not $Path) { return $false }
    $n = ($Path.Trim().Trim('"').Trim("'") -replace '\\', '/')
    return $n -match '(?i)(^|/)contracts/candidates/[^/]+\.json$'
}

function Add-Unique([System.Collections.Generic.List[string]]$List, [string]$Value) {
    if (-not $Value) { return }
    foreach ($u in $List) {
        if ($u.Equals($Value, [System.StringComparison]::OrdinalIgnoreCase)) { return }
    }
    $List.Add($Value)
}

function Add-InputPaths([System.Collections.Generic.List[string]]$List, $InputObj) {
    if (-not $InputObj) { return }
    foreach ($k in @('path', 'file_path', 'filePath', 'target_file')) {
        if ($InputObj.PSObject.Properties.Name -contains $k -and $InputObj.$k) { Add-Unique $List ([string]$InputObj.$k) }
    }
    if ($InputObj.PSObject.Properties.Name -contains 'edits') {
        foreach ($e in @($InputObj.edits)) {
            if ($e -and $e.PSObject.Properties.Name -contains 'path' -and $e.path) { Add-Unique $List ([string]$e.path) }
        }
    }
}

try {
    $raw = Read-HookStdin
    if (-not $raw) { exit 0 }
    $ev = $raw | ConvertFrom-Json
    $paths = New-Object System.Collections.Generic.List[string]
    foreach ($k in @('file_path', 'filePath', 'path')) {
        if ($ev.PSObject.Properties.Name -contains $k -and $ev.$k) { Add-Unique $paths ([string]$ev.$k) }
    }
    if ($ev.PSObject.Properties.Name -contains 'tool_input') { Add-InputPaths $paths $ev.tool_input }
    if ($ev.PSObject.Properties.Name -contains 'arguments') { Add-InputPaths $paths $ev.arguments }
    $hit = $false
    foreach ($p in $paths) {
        if (Test-CandidateJsonPath $p) { $hit = $true; break }
    }
    if (-not $hit -and $ev.PSObject.Properties.Name -contains 'command' -and $ev.command) {
        $cmd = [string]$ev.command
        if ($cmd -match '(?i)contracts[/\\]candidates[/\\][^\s"''<>|*?]+\.json') { $hit = $true }
    }
    if (-not $hit) { exit 0 }
    . (Join-Path $WorkspaceRoot 'runtime\check-helpers.ps1')
    . (Join-Path $WorkspaceRoot 'runtime\candidate-index.ps1')
    $tz = [TimeZoneInfo]::FindSystemTimeZoneById('China Standard Time')
    $t = [TimeZoneInfo]::ConvertTimeFromUtc([datetime]::UtcNow, $tz)
    $stamp = $t.ToString('yyyy-MM-dd HH:mm') + ' UTC+8'
    Update-CandidateIndex $WorkspaceRoot $stamp
    exit 0
} catch {
    exit 0
}
