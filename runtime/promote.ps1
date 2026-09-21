# Non-entry. Invoked by etctl.ps1 promote. Live card must be idle. No SVN.
param([Parameter(Mandatory = $true)][string]$TaskId)
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')

function Write-PromoteError([string]$Msg) {
    [ordered]@{ ok = $false; error = $Msg } | ConvertTo-Json -Compress:$false
    exit 1
}

function Read-Utf8([string]$Path) { return [System.IO.File]::ReadAllText($Path) }
function Write-Utf8([string]$Path, [string]$Text) {
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}
function Get-Stamp {
    $tz = [TimeZoneInfo]::FindSystemTimeZoneById('China Standard Time')
    $t = [TimeZoneInfo]::ConvertTimeFromUtc([datetime]::UtcNow, $tz)
    return ($t.ToString('yyyy-MM-dd HH:mm') + ' UTC+8')
}
function Set-HeaderTime([string]$Text, [string]$Stamp) {
    $hdr = $script:HdrTime
    $nl = "`n"
    if ($Text.Contains("`r`n")) { $nl = "`r`n" }
    $lines = [System.Collections.Generic.List[string]]::new()
    [void]$lines.AddRange([string[]]($Text -split "`r?`n", -1))
    if ($lines.Count -gt 0 -and $lines[0] -match [regex]::Escape($hdr)) { $lines[0] = '> ' + $hdr + $Stamp }
    return ($lines -join $nl)
}
function Set-MdField([string]$Text, [string]$Name, [string]$Value) {
    $bt = $script:HelperBt
    $colon = $script:HelperColon
    $prefix = '- ' + $bt + $Name + $bt + $colon
    $newLine = $prefix + $bt + $Value + $bt
    $nl = "`n"
    if ($Text.Contains("`r`n")) { $nl = "`r`n" }
    $lines = [System.Collections.Generic.List[string]]::new()
    [void]$lines.AddRange([string[]]($Text -split "`r?`n", -1))
    $found = $false
    $lastField = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].StartsWith('- ' + $bt)) { $lastField = $i }
        if ($lines[$i].StartsWith($prefix)) { $lines[$i] = $newLine; $found = $true }
    }
    if (-not $found) {
        if ($lastField -lt 0) { Write-PromoteError ('cannot insert field ' + $Name) }
        $lines.Insert($lastField + 1, $newLine)
    }
    return ($lines -join $nl)
}

if ([string]::IsNullOrWhiteSpace($TaskId) -or $TaskId -eq 'none') { Write-PromoteError 'task_id required' }
$candPath = Join-Path $WorkspaceRoot ('contracts/candidates/' + $TaskId + '.json')
if (-not (Test-Path -LiteralPath $candPath)) { Write-PromoteError ('missing candidates/' + $TaskId + '.json') }

$contract = Get-FieldMap (Read-Utf8 (Join-Path $WorkspaceRoot 'contracts/current.md'))
$scope = Get-Content -LiteralPath (Join-Path $WorkspaceRoot 'contracts/current_scope.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ([string]$contract['contract_status'] -ne 'idle' -or [string]$scope.phase -ne 'idle') {
    Write-PromoteError 'live card not idle; harvest first'
}

$cand = Get-Content -LiteralPath $candPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ([string]$cand.task_id -ne $TaskId) { Write-PromoteError 'candidate task_id mismatch file' }
$phase = [string]$cand.phase
if (@('discovery', 'awaiting_scope') -notcontains $phase) { Write-PromoteError ('candidate phase cannot promote: ' + $phase) }
$goal = [string]$cand.goal
if (-not $goal) { Write-PromoteError 'candidate goal required' }

$stamp = Get-Stamp
$scopeOut = [ordered]@{}
foreach ($p in $cand.PSObject.Properties) {
    if ($p.Name -eq 'goal') { continue }
    $scopeOut[$p.Name] = $p.Value
}
$scopeJson = $scopeOut | ConvertTo-Json -Compress:$false -Depth 8
$scopeJson = [regex]::Replace($scopeJson, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]('0x' + $m.Groups[1].Value) })
Write-Utf8 (Join-Path $WorkspaceRoot 'contracts/current_scope.json') ($scopeJson.TrimEnd() + "`n")

$contractText = Read-Utf8 (Join-Path $WorkspaceRoot 'contracts/current.md')
$contractText = Set-MdField $contractText 'task_id' $TaskId
$contractText = Set-MdField $contractText 'contract_status' 'discovery'
$contractText = Set-MdField $contractText 'goal' $goal
$contractText = Set-HeaderTime $contractText $stamp
Write-Utf8 (Join-Path $WorkspaceRoot 'contracts/current.md') $contractText

$cursorStatus = 'in_progress'
if ($phase -eq 'awaiting_scope') { $cursorStatus = 'awaiting_approval' }
$profileId = 'none'
if ($cand.profile_id) { $profileId = [string]$cand.profile_id }
$cursorText = Read-Utf8 (Join-Path $WorkspaceRoot 'project_cursor.md')
$cursorText = Set-MdField $cursorText 'task_id' $TaskId
$cursorText = Set-MdField $cursorText 'task_status' $cursorStatus
$cursorText = Set-MdField $cursorText 'active_profile' $profileId
$cursorText = Set-MdField $cursorText 'contract_ref' 'contracts/current.md'
$cursorText = Set-MdField $cursorText 'blocked' 'false'
$cursorText = Set-HeaderTime $cursorText $stamp
Write-Utf8 (Join-Path $WorkspaceRoot 'project_cursor.md') $cursorText

Remove-Item -LiteralPath $candPath
[ordered]@{ ok = $true; task_id = $TaskId; phase = $phase } | ConvertTo-Json -Compress:$false
exit 0
