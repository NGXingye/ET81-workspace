# Non-entry. Invoked by etctl.ps1 next-id. Read-only. No SVN.
# Occupancy = outcomes ∪ live ∪ candidate stems ∪ commit_plan ∪ held_commit_plan (skip none).
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')

function Add-Occupied([hashtable]$Set, [string]$Id) {
    if (-not $Id -or $Id -eq 'none') { return }
    if ($Id -match '^t\d+$') { $Set[$Id] = 1 }
}

$occupied = @{}

$outcomesPath = Join-Path $WorkspaceRoot 'standards/records/task_outcomes.jsonl'
if (Test-Path -LiteralPath $outcomesPath) {
    foreach ($line in (Get-Content -LiteralPath $outcomesPath -Encoding UTF8)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            $o = $line | ConvertFrom-Json
            Add-Occupied $occupied ([string]$o.task_id)
        } catch { }
    }
}

$cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
if (Test-Path -LiteralPath $cursorPath) {
    $cursor = Get-FieldMap ([System.IO.File]::ReadAllText($cursorPath))
    Add-Occupied $occupied ([string]$cursor['task_id'])
}

$scopePath = Join-Path $WorkspaceRoot 'contracts/current_scope.json'
if (Test-Path -LiteralPath $scopePath) {
    try {
        $scope = Get-Content -LiteralPath $scopePath -Raw -Encoding UTF8 | ConvertFrom-Json
        Add-Occupied $occupied ([string]$scope.task_id)
    } catch { }
}

$contractPath = Join-Path $WorkspaceRoot 'contracts/current.md'
if (Test-Path -LiteralPath $contractPath) {
    $cf = Get-FieldMap ([System.IO.File]::ReadAllText($contractPath))
    Add-Occupied $occupied ([string]$cf['task_id'])
}

$candDir = Join-Path $WorkspaceRoot 'contracts/candidates'
if (Test-Path -LiteralPath $candDir) {
    Get-ChildItem -LiteralPath $candDir -Filter '*.json' -File | ForEach-Object {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        Add-Occupied $occupied $stem
        try {
            $c = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            Add-Occupied $occupied ([string]$c.task_id)
        } catch { }
    }
}

foreach ($rel in @('contracts/commit_plan.json', 'contracts/held_commit_plan.json')) {
    $p = Join-Path $WorkspaceRoot $rel
    if (-not (Test-Path -LiteralPath $p)) { continue }
    try {
        $plan = Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json
        Add-Occupied $occupied ([string]$plan.task_id)
    } catch { }
}

$max = 0
foreach ($id in @($occupied.Keys)) {
    if ($id -match '^t(\d+)$') {
        $n = [int]$Matches[1]
        if ($n -gt $max) { $max = $n }
    }
}
$next = $max + 1
$tid = 't' + $next.ToString('000')
[ordered]@{ ok = $true; task_id = $tid; max_occupied = $max } | ConvertTo-Json -Compress:$false
exit 0