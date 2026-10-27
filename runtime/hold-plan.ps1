# Non-entry. Invoked by etctl.ps1 hold-plan / restore-plan. No SVN.
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('hold', 'restore')]
    [string]$Action
)
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot

function Write-HoldError([string]$Msg) {
    [ordered]@{ ok = $false; error = $Msg } | ConvertTo-Json -Compress:$false
    exit 1
}
function Write-Utf8([string]$Path, [string]$Text) {
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}
function Read-Plan([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { Write-HoldError ('missing ' + $Path) }
    return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
}
function Test-PlanVacant($Plan) {
    $units = @()
    if ($Plan.PSObject.Properties.Name -contains 'units' -and $null -ne $Plan.units) { $units = @($Plan.units) }
    if ($units.Count -eq 0 -and [string]$Plan.task_id -eq 'none') { return $true }
    foreach ($u in $units) {
        if ([string]$u.status -ne 'committed') { return $false }
    }
    return $true
}
function Get-PendingPathKeys($Plan) {
    $keys = New-Object System.Collections.Generic.List[string]
    $units = @()
    if ($Plan.PSObject.Properties.Name -contains 'units' -and $null -ne $Plan.units) { $units = @($Plan.units) }
    foreach ($u in $units) {
        if ([string]$u.status -eq 'committed') { continue }
        $ws = [string]$u.workspace_path
        foreach ($rel in @($u.paths)) {
            $norm = ($rel -replace '\\', '/').ToLowerInvariant()
            $keys.Add(($ws.TrimEnd('\', '/') + '|' + $norm))
        }
    }
    return ,$keys
}
function Test-PathOverlap($PlanA, $PlanB) {
    $set = @{}
    foreach ($k in (Get-PendingPathKeys $PlanA)) { $set[$k] = $true }
    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($k in (Get-PendingPathKeys $PlanB)) {
        if ($set.ContainsKey($k)) { $hits.Add($k) }
    }
    return ,$hits
}
function Format-EmptyPlan {
    return "{`n  `"task_id`": `"none`",`n  `"summary`": `"`",`n  `"units`": []`n}`n"
}
function Format-PlanJson($Plan) {
    $json = $Plan | ConvertTo-Json -Compress:$false -Depth 8
    $json = [regex]::Replace($json, '\\u([0-9a-fA-F]{4})', { param($m) [char][int]('0x' + $m.Groups[1].Value) })
    return ($json.TrimEnd() + "`n")
}

$activePath = Join-Path $WorkspaceRoot 'contracts/commit_plan.json'
$heldPath = Join-Path $WorkspaceRoot 'contracts/held_commit_plan.json'
$active = Read-Plan $activePath
$held = Read-Plan $heldPath

if ($Action -eq 'hold') {
    if (Test-PlanVacant $active) { Write-HoldError 'active commit plan is empty; nothing to hold' }
    if (-not (Test-PlanVacant $held)) {
        Write-HoldError ('held slot occupied by ' + [string]$held.task_id + '; restore or commit held first')
    }
    $overlap = Test-PathOverlap $active $held
    if ($overlap.Count -gt 0) { Write-HoldError ('path overlap with held: ' + ($overlap -join ', ')) }
    Write-Utf8 $heldPath (Format-PlanJson $active)
    Write-Utf8 $activePath (Format-EmptyPlan)
    $pending = @()
    foreach ($u in @($active.units)) {
        if ([string]$u.status -ne 'committed') { $pending += [string]$u.id }
    }
    [ordered]@{
        ok = $true
        action = 'hold'
        held_task_id = [string]$active.task_id
        pending_units = $pending
    } | ConvertTo-Json -Compress:$false
    exit 0
}

if (Test-PlanVacant $held) { Write-HoldError 'held commit plan is empty; nothing to restore' }
if (-not (Test-PlanVacant $active)) {
    Write-HoldError ('active slot occupied by ' + [string]$active.task_id + '; commit or hold active first')
}
$overlap = Test-PathOverlap $active $held
if ($overlap.Count -gt 0) { Write-HoldError ('path overlap with active: ' + ($overlap -join ', ')) }
Write-Utf8 $activePath (Format-PlanJson $held)
Write-Utf8 $heldPath (Format-EmptyPlan)
[ordered]@{
    ok = $true
    action = 'restore'
    active_task_id = [string]$held.task_id
} | ConvertTo-Json -Compress:$false
exit 0
