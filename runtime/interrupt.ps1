# Non-entry. Invoked by etctl.ps1 interrupt. Parks live card, promotes interrupt packet. No SVN.
param([Parameter(Mandatory = $true)][string]$TaskId)
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')

function Write-InterruptError([string]$Msg) {
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
        if ($lastField -lt 0) { Write-InterruptError ('cannot insert field ' + $Name) }
        $lines.Insert($lastField + 1, $newLine)
    }
    return ($lines -join $nl)
}
function Convert-ScopeJson($Ordered) {
    $json = $Ordered | ConvertTo-Json -Compress:$false -Depth 8
    $json = [regex]::Replace($json, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]('0x' + $m.Groups[1].Value) })
    return ($json.TrimEnd() + "`n")
}
function Convert-FromObj($Obj, [string[]]$Skip) {
    $o = [ordered]@{}
    foreach ($p in $Obj.PSObject.Properties) {
        if ($Skip -contains $p.Name) { continue }
        $o[$p.Name] = $p.Value
    }
    return $o
}
function Test-PathHarvested([string]$Write, [object[]]$Set) {
    $wn = ($Write -replace '\\', '/')
    foreach ($h in $Set) {
        $hn = ([string]$h -replace '\\', '/')
        if ($wn -eq $hn) { return $true }
        if ($hn -and $wn.EndsWith('/' + $hn.TrimStart('/'))) { return $true }
        if ($wn -and $hn.EndsWith('/' + $wn.TrimStart('/'))) { return $true }
    }
    return $false
}

if ([string]::IsNullOrWhiteSpace($TaskId) -or $TaskId -eq 'none') { Write-InterruptError 'task_id required' }
$candPath = Join-Path $WorkspaceRoot ('contracts/candidates/' + $TaskId + '.json')
if (-not (Test-Path -LiteralPath $candPath)) { Write-InterruptError ('missing candidates/' + $TaskId + '.json') }

$contractPath = Join-Path $WorkspaceRoot 'contracts/current.md'
$scopePath = Join-Path $WorkspaceRoot 'contracts/current_scope.json'
$cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
$contract = Get-FieldMap (Read-Utf8 $contractPath)
$scope = Get-Content -LiteralPath $scopePath -Raw -Encoding UTF8 | ConvertFrom-Json
$liveId = [string]$contract['task_id']
$livePhase = [string]$scope.phase
if ($liveId -eq 'none' -or [string]$contract['contract_status'] -eq 'idle' -or $livePhase -eq 'idle') {
    Write-InterruptError 'no live card to interrupt'
}
if (@('discovery', 'awaiting_scope', 'implement', 'awaiting_verify') -notcontains $livePhase) {
    Write-InterruptError ('cannot interrupt phase ' + $livePhase)
}
if ($scope.PSObject.Properties.Name -contains 'parent_task_id' -or $scope.PSObject.Properties.Name -contains 'resume_task_id') {
    Write-InterruptError 'already interrupting'
}

$cand = Get-Content -LiteralPath $candPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ([string]$cand.task_id -ne $TaskId) { Write-InterruptError 'candidate task_id mismatch file' }
if (@('discovery', 'awaiting_scope') -notcontains [string]$cand.phase) { Write-InterruptError 'candidate phase cannot interrupt' }
$goal = [string]$cand.goal
if (-not $goal) { Write-InterruptError 'candidate goal required' }
if ([string]$cand.size -ne 'trivial' -or [string]$cand.route -ne 'fast' -or @('bug', 'feature') -notcontains [string]$cand.intent) {
    Write-InterruptError 'interrupt must be trivial fast bug/feature'
}
$ops = @($cand.edit_ops)
if ($ops.Count -eq 0 -or ($ops | Where-Object { $_ -ne 'in_place' })) { Write-InterruptError 'interrupt edit_ops must be in_place only' }
$writes = @()
if ($cand.PSObject.Properties.Name -contains 'write_paths') { $writes = @($cand.write_paths) }
if ($writes.Count -lt 1 -or $writes.Count -gt 2) { Write-InterruptError 'interrupt write_paths must be 1..2' }
$planN = 0
if ($cand.PSObject.Properties.Name -contains 'plan' -and $null -ne $cand.plan) { $planN = @($cand.plan).Count }
if ($planN -eq 0) { Write-InterruptError 'interrupt plan required' }
$parentId = ''
if ($cand.PSObject.Properties.Name -contains 'parent_task_id') { $parentId = [string]$cand.parent_task_id }
if (-not $parentId -or $parentId -eq 'none') { Write-InterruptError 'parent_task_id required' }
if ($parentId -eq $TaskId) { Write-InterruptError 'must not reuse parent number' }
if ($parentId -eq $liveId) { Write-InterruptError 'parent cannot be the live card' }

$outcomesPath = Join-Path $WorkspaceRoot 'standards/records/task_outcomes.jsonl'
if (-not (Test-Path -LiteralPath $outcomesPath)) { Write-InterruptError 'missing task_outcomes.jsonl' }
$parentRec = $null
foreach ($line in (Get-Content -LiteralPath $outcomesPath -Encoding UTF8)) {
    if (-not $line.Trim()) { continue }
    $row = $line | ConvertFrom-Json
    if ([string]$row.task_id -eq $parentId) { $parentRec = $row }
}
if (-not $parentRec) { Write-InterruptError ('parent ' + $parentId + ' not harvested') }
$harvested = @()
if ($parentRec.PSObject.Properties.Name -contains 'changed_paths') { $harvested = @($parentRec.changed_paths) }
if ($harvested.Count -eq 0) { Write-InterruptError ('parent ' + $parentId + ' has no changed_paths') }
foreach ($w in $writes) {
    if (-not (Test-PathHarvested $w $harvested)) { Write-InterruptError ('write_paths not in parent changed_paths: ' + $w) }
}
$targets = @()
if ($parentRec.PSObject.Properties.Name -contains 'changed_targets') { $targets = @($parentRec.changed_targets) }
$tid = [string]$cand.target_id
if ($targets.Count -eq 0 -or -not $tid -or ($targets -notcontains $tid)) { Write-InterruptError 'target_id must match parent changed_targets' }

$liveWrites = @()
if ($scope.PSObject.Properties.Name -contains 'write_paths') { $liveWrites = @($scope.write_paths) }
foreach ($w in $writes) {
    if ($liveWrites.Count -gt 0 -and (Test-PathHarvested $w $liveWrites)) { Write-InterruptError ('write overlap with live ' + $liveId) }
}

$parkPath = Join-Path $WorkspaceRoot ('contracts/candidates/' + $liveId + '.json')
if (Test-Path -LiteralPath $parkPath) { Write-InterruptError ('park dest exists candidates/' + $liveId + '.json') }
$candDir = Join-Path $WorkspaceRoot 'contracts/candidates'
$others = @(Get-ChildItem -LiteralPath $candDir -Filter '*.json' -File | Where-Object { $_.BaseName -ne $TaskId })
if (($others.Count + 1) -gt 2) { Write-InterruptError 'candidates would exceed 2 after park' }

$liveGoal = [string]$contract['goal']
if (-not $liveGoal) { Write-InterruptError 'live goal missing' }

$stamp = Get-Stamp
$park = Convert-FromObj $scope @('goal', 'parked', 'parked_by', 'parent_task_id', 'resume_task_id')
$park['goal'] = $liveGoal
$park['parked'] = $true
$park['parked_by'] = $TaskId
Write-Utf8 $parkPath (Convert-ScopeJson $park)

$live = Convert-FromObj $cand @('goal', 'parked', 'parked_by', 'implement_round', 'verify_feedback', 'resume_task_id')
$live['resume_task_id'] = $liveId
Write-Utf8 $scopePath (Convert-ScopeJson $live)

$contractText = Read-Utf8 $contractPath
$contractText = Set-MdField $contractText 'task_id' $TaskId
$contractText = Set-MdField $contractText 'contract_status' 'discovery'
$contractText = Set-MdField $contractText 'goal' $goal
$contractText = Set-HeaderTime $contractText $stamp
Write-Utf8 $contractPath $contractText

$cursorStatus = 'in_progress'
if ([string]$cand.phase -eq 'awaiting_scope') { $cursorStatus = 'awaiting_approval' }
$profileId = 'none'
if ($cand.profile_id) { $profileId = [string]$cand.profile_id }
$cursorText = Read-Utf8 $cursorPath
$cursorText = Set-MdField $cursorText 'task_id' $TaskId
$cursorText = Set-MdField $cursorText 'task_status' $cursorStatus
$cursorText = Set-MdField $cursorText 'active_profile' $profileId
$cursorText = Set-MdField $cursorText 'contract_ref' 'contracts/current.md'
$cursorText = Set-MdField $cursorText 'blocked' 'false'
$srcTid = 'trunk'
if ($cand.target_id) { $srcTid = [string]$cand.target_id }
$targetPath = Join-Path $WorkspaceRoot ('targets/' + $srcTid + '.json')
if (Test-Path -LiteralPath $targetPath) {
    $tgt = Get-Content -LiteralPath $targetPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ([string]$tgt.workspace_path) { $cursorText = Set-MdField $cursorText 'source_root' ([string]$tgt.workspace_path) }
}
$cursorText = Set-HeaderTime $cursorText $stamp
Write-Utf8 $cursorPath $cursorText

Remove-Item -LiteralPath $candPath
[ordered]@{ ok = $true; task_id = $TaskId; parked = $liveId; parent_task_id = $parentId; phase = [string]$cand.phase } | ConvertTo-Json -Compress:$false
exit 0
