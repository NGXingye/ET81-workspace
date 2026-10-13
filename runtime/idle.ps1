# Non-entry. Invoked by etctl.ps1 idle. Resets the live card. No SVN.
param()
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')

function Write-IdleError([string]$Msg) {
    [ordered]@{ ok = $false; error = $Msg } | ConvertTo-Json -Compress:$false
    exit 1
}
function Read-Utf8([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { Write-IdleError ('missing ' + $Path) }
    return [System.IO.File]::ReadAllText($Path)
}
function Write-Utf8([string]$Path, [string]$Text) {
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}
function Get-Stamp {
    $tz = [TimeZoneInfo]::FindSystemTimeZoneById('China Standard Time')
    $t = [TimeZoneInfo]::ConvertTimeFromUtc([datetime]::UtcNow, $tz)
    return ($t.ToString('yyyy-MM-dd HH:mm') + ' UTC+8')
}
function Get-Nl([string]$Text) {
    if ($Text.Contains("`r`n")) { return "`r`n" }
    return "`n"
}
function Split-Lines([string]$Text) {
    $lines = [System.Collections.Generic.List[string]]::new()
    [void]$lines.AddRange([string[]]($Text -split "`r?`n", -1))
    return ,$lines
}
function Set-HeaderTime([string]$Text, [string]$Stamp) {
    $nl = Get-Nl $Text
    $lines = Split-Lines $Text
    if ($lines.Count -gt 0 -and $lines[0] -match [regex]::Escape($script:HdrTime)) {
        $lines[0] = '> ' + $script:HdrTime + $Stamp
    }
    return ($lines -join $nl)
}
function Set-MdField([string]$Text, [string]$Name, [string]$Value) {
    $bt = $script:HelperBt
    $prefix = '- ' + $bt + $Name + $bt + $script:HelperColon
    $newLine = $prefix + $bt + $Value + $bt
    $nl = Get-Nl $Text
    $lines = Split-Lines $Text
    $found = $false
    $lastField = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].StartsWith('- ' + $bt)) { $lastField = $i }
        if ($lines[$i].StartsWith($prefix)) { $lines[$i] = $newLine; $found = $true }
    }
    if (-not $found) {
        if ($lastField -lt 0) { Write-IdleError ('cannot insert field ' + $Name) }
        $lines.Insert($lastField + 1, $newLine)
    }
    return ($lines -join $nl)
}
function Remove-MdField([string]$Text, [string]$Name) {
    $bt = $script:HelperBt
    $prefix = '- ' + $bt + $Name + $bt + $script:HelperColon
    $nl = Get-Nl $Text
    $lines = Split-Lines $Text
    $kept = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $lines) {
        if (-not $line.StartsWith($prefix)) { $kept.Add($line) }
    }
    return ($kept -join $nl)
}
function Test-ScopeIdle($Scope) {
    if (-not $Scope) { return $false }
    if ([string]$Scope.phase -ne 'idle') { return $false }
    if ([string]$Scope.task_id -ne 'none') { return $false }
    if ([int]$Scope.scope_revision -ne 0) { return $false }
    $ban = @('intent', 'size', 'route', 'edit_ops', 'target_id', 'profile_id', 'seed_paths', 'read_paths', 'write_paths', 'editor_md_paths', 'evidence', 'risks', 'uncertain', 'validation', 'plan', 'goal', 'implement_round', 'verify_feedback', 'parent_task_id', 'resume_task_id', 'parked', 'parked_by')
    foreach ($p in $Scope.PSObject.Properties.Name) {
        if ($ban -contains $p) { return $false }
    }
    return $true
}

$scopePath = Join-Path $WorkspaceRoot 'contracts\current_scope.json'
$contractPath = Join-Path $WorkspaceRoot 'contracts\current.md'
$cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
$scope = $null
if (Test-Path -LiteralPath $scopePath) {
    $scope = Get-Content -LiteralPath $scopePath -Raw -Encoding UTF8 | ConvertFrom-Json
}
$contract = Get-FieldMap (Read-Utf8 $contractPath)
$cursor = Get-FieldMap (Read-Utf8 $cursorPath)
$resume = ''
if ($scope -and $scope.PSObject.Properties.Name -contains 'resume_task_id') { $resume = [string]$scope.resume_task_id }

$cursorIdle = ([string]$cursor['task_status'] -eq 'idle' -and [string]$cursor['task_id'] -eq 'none' -and [string]$cursor['active_profile'] -eq 'none' -and [string]$cursor['contract_ref'] -eq 'none' -and [string]$cursor['blocked'] -eq 'false' -and -not $cursor.Contains('blocker_reason') -and -not $cursor.Contains('blocker_owner') -and -not $cursor.Contains('isolated_source_root'))
$contractIdle = ([string]$contract['contract_status'] -eq 'idle' -and [string]$contract['task_id'] -eq 'none' -and $contract.Count -eq 2)
if ((Test-ScopeIdle $scope) -and $cursorIdle -and $contractIdle) {
    [ordered]@{ ok = $true; already_idle = $true } | ConvertTo-Json -Compress:$false
    exit 0
}

$stamp = Get-Stamp
$contractText = Read-Utf8 $contractPath
foreach ($name in @($contract.Keys)) {
    if ($name -ne 'task_id' -and $name -ne 'contract_status') { $contractText = Remove-MdField $contractText $name }
}
$contractText = Set-MdField $contractText 'task_id' 'none'
$contractText = Set-MdField $contractText 'contract_status' 'idle'
$contractText = Set-HeaderTime $contractText $stamp

$cursorText = Read-Utf8 $cursorPath
foreach ($name in @('blocker_reason', 'blocker_owner', 'isolated_source_root')) {
    $cursorText = Remove-MdField $cursorText $name
}
$cursorText = Set-MdField $cursorText 'task_id' 'none'
$cursorText = Set-MdField $cursorText 'task_status' 'idle'
$cursorText = Set-MdField $cursorText 'active_profile' 'none'
$cursorText = Set-MdField $cursorText 'contract_ref' 'none'
$cursorText = Set-MdField $cursorText 'blocked' 'false'
$cursorText = Set-HeaderTime $cursorText $stamp

$scopeJson = "{`r`n  `"task_id`": `"none`",`r`n  `"phase`": `"idle`",`r`n  `"scope_revision`": 0`r`n}`r`n"
Write-Utf8 $contractPath $contractText
Write-Utf8 $cursorPath $cursorText
Write-Utf8 $scopePath $scopeJson

$payload = [ordered]@{ ok = $true; already_idle = $false }
if ($resume) { $payload['resume_task_id'] = $resume }
$payload | ConvertTo-Json -Compress:$false
exit 0
