# Non-entry helper. Dot-sourced by check-workspace.ps1 only.
$script:HelperBt = [char]96
$script:HelperColon = [char]0xFF1A
$script:HelperFieldPrefix = '- ' + $script:HelperBt
$script:HdrTime = ([string][char]0x6700) + [char]0x65B0 + [char]0x4FEE + [char]0x6539 + [char]0x65F6 + [char]0x95F4 + [char]0xFF1A
$script:HdrVer = ([string][char]0x7248) + [char]0x672C + [char]0x53F7 + [char]0xFF1A
$script:HdrStatus = ([string][char]0x6587) + [char]0x6863 + [char]0x72B6 + [char]0x6001 + [char]0xFF1A
$script:HdrLevel = ([string][char]0x8BFB) + [char]0x53D6 + [char]0x7B49 + [char]0x7EA7 + [char]0xFF1A
$script:H0Duty = '0. ' + ([string][char]0x804C) + [char]0x8D23 + [char]0x5B9A + [char]0x4F4D
$script:HHist = ([string][char]0x7248) + [char]0x672C + [char]0x5386 + [char]0x53F2
$script:UnityEditorLabel = 'Unity ' + ([string][char]0x7F16) + [char]0x8F91 + [char]0x5668

function New-CheckState {
    return @{ Errors = @(); Warnings = @() }
}

function Add-CheckError([hashtable]$State, [string]$Code, [string]$Message) {
    $State.Errors += ($Code + ': ' + $Message)
}

function Add-CheckWarning([hashtable]$State, [string]$Code, [string]$Message) {
    $State.Warnings += ($Code + ': ' + $Message)
}

function Get-PhysicalLineCount([string]$Content) {
    $lines = $Content -split "`r?`n"
    $n = $lines.Count
    if ($n -gt 0 -and [string]::IsNullOrEmpty($lines[$n - 1])) { $n-- }
    return $n
}

function Get-FieldMap([string]$Content) {
    $fields = [ordered]@{}
    foreach ($line in ($Content -split "`r?`n")) {
        if (-not $line.StartsWith($script:HelperFieldPrefix)) { continue }
        $body = $line.Substring(2).Trim()
        $idx = $body.IndexOf($script:HelperColon)
        if ($idx -lt 0) { continue }
        $namePart = $body.Substring(0, $idx).Trim($script:HelperBt).Trim()
        $valuePart = $body.Substring($idx + 1).Trim($script:HelperBt).Trim()
        if ($namePart) { $fields[$namePart] = $valuePart }
    }
    return $fields
}

function Get-BaselineUnityVersion([string]$WorkspaceRoot) {
    $path = Join-Path $WorkspaceRoot 'standards/framework_baseline.md'
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $pattern = [regex]::Escape($script:UnityEditorLabel) + '\s*\|\s*`?([0-9]+\.[0-9]+\.[0-9]+f[0-9]+c[0-9]+)`?'
    if ($text -match $pattern) { return $Matches[1] }
    return $null
}

function Test-FieldBudget([hashtable]$State, [string]$Rel, $Map, [string[]]$MinNames, [int]$MaxCount) {
    foreach ($name in $MinNames) {
        if (-not $Map.Contains($name)) { Add-CheckError $State 'FIELD_MIN' ($Rel + ' missing ' + $name) }
    }
    if ($Map.Count -gt $MaxCount) {
        Add-CheckError $State 'FIELD_MAX' ($Rel + ' field count ' + $Map.Count + ' > ' + $MaxCount + '; follow kv_budget.md section 1 remedy, do not raise cap')
    }
}

function Test-MarkdownShape([hashtable]$State, [string]$Rel, [string]$Content) {
    $lines = $Content -split "`r?`n"
    if ($lines.Count -lt 4) {
        Add-CheckError $State 'MD_HEADER' ($Rel + ' missing 4-line header')
        return
    }
    if ($lines[0] -notmatch [regex]::Escape($script:HdrTime)) { Add-CheckError $State 'MD_HEADER' ($Rel + ' missing time header') }
    if ($lines[1] -notmatch [regex]::Escape($script:HdrVer)) { Add-CheckError $State 'MD_HEADER' ($Rel + ' missing version header') }
    if ($lines[2] -notmatch [regex]::Escape($script:HdrStatus)) { Add-CheckError $State 'MD_HEADER' ($Rel + ' missing status header') }
    if ($lines[3] -notmatch [regex]::Escape($script:HdrLevel)) { Add-CheckError $State 'MD_HEADER' ($Rel + ' missing read-level header') }

    $h1 = @()
    foreach ($line in $lines) {
        if ($line.StartsWith('# ')) { $h1 += $line.Substring(2).Trim() }
    }
    if ($h1.Count -eq 0) {
        Add-CheckError $State 'MD_H1' ($Rel + ' no H1')
    } else {
        if ($h1[0] -notlike ($script:H0Duty + '*')) { Add-CheckError $State 'MD_H0' ($Rel + ' first H1 must be duty section') }
        if ($h1[-1] -notmatch [regex]::Escape($script:HHist)) { Add-CheckError $State 'MD_HIST' ($Rel + ' last H1 must be history') }
        if ($h1.Count -lt 2) { Add-CheckError $State 'MD_H1_MIN' ($Rel + ' need duty and history H1') }
        if ($h1.Count -gt 8) { Add-CheckError $State 'MD_H1_MAX' ($Rel + ' H1 count ' + $h1.Count + ' > 8; follow md_governance.md section 2 remedy, do not raise cap') }
    }

    $histCount = 0
    $inHist = $false
    $histH1 = '^# .+' + [regex]::Escape($script:HHist)
    foreach ($line in $lines) {
        if ($line -match $histH1) { $inHist = $true; continue }
        if ($inHist -and $line -match '^# ') { $inHist = $false }
        if ($inHist -and $line -match '^- \d+\.\d+\.\d+') { $histCount++ }
    }
    if ($histCount -gt 5) { Add-CheckError $State 'MD_HIST_CAP' ($Rel + ' version history > 5: ' + $histCount) }

    $level = 'L1'
    if ($lines[3] -match '(L[0-2])') { $level = $Matches[1] }
    else { Add-CheckWarning $State 'MD_LEVEL' ($Rel + ' header has no L0/L1/L2; default L1 caps') }

    $phys = Get-PhysicalLineCount $Content
    $soft = 180; $hard = 250
    if ($level -eq 'L0') { $soft = 80; $hard = 120 }
    elseif ($level -eq 'L2') { $soft = 350; $hard = 500 }
    if ($phys -gt $hard) {
        Add-CheckError $State 'MD_LINE_MAX' ($Rel + ' ' + $phys + ' lines > ' + $level + ' hard ' + $hard + '; follow md_governance.md section 2 remedy, do not lower read level')
    } elseif ($phys -gt $soft) {
        Add-CheckWarning $State 'MD_LINE_SOFT' ($Rel + ' ' + $phys + ' lines > ' + $level + ' soft ' + $soft)
    }
}

function Test-ToolFileSize([hashtable]$State, [string]$Rel, [string]$Content) {
    $phys = Get-PhysicalLineCount $Content
    if ($phys -gt 250) {
        Add-CheckError $State 'TOOL_LINE_MAX' ($Rel + ' ' + $phys + ' lines > 250; follow tools_code.md section 4, do not raise cap')
    } elseif ($phys -gt 180) {
        Add-CheckWarning $State 'TOOL_LINE_SOFT' ($Rel + ' ' + $phys + ' lines > 180')
    }
}
