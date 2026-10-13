param(
    [Parameter(Position = 0)]
    [string]$Path,
    [switch]$ListRoots
)
# Policy: global_rules/runtime_code.md — source write gate. Read-only.
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')

function Write-GuardResult([bool]$Ok, [string]$Error, [bool]$Outside) {
    $payload = [ordered]@{ ok = $Ok }
    if ($Outside) { $payload['outside'] = $true }
    if ($Error) { $payload['error'] = $Error }
    $payload | ConvertTo-Json -Compress
    if ($Ok) { exit 0 }
    exit 2
}

function Get-SourceRoots {
    $roots = New-Object System.Collections.Generic.List[string]
    $cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
    if (Test-Path -LiteralPath $cursorPath) {
        $cursor = Get-FieldMap (Get-Content -LiteralPath $cursorPath -Raw -Encoding UTF8)
        if ($cursor -and $cursor['source_root']) { $roots.Add([string]$cursor['source_root']) }
    }
    $targets = Join-Path $WorkspaceRoot 'targets'
    if (Test-Path -LiteralPath $targets) {
        Get-ChildItem -LiteralPath $targets -Filter '*.json' -File | ForEach-Object {
            $obj = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($obj.workspace_path) { $roots.Add([string]$obj.workspace_path) }
        }
    }
    $uniq = New-Object System.Collections.Generic.List[string]
    foreach ($r in $roots) {
        if (-not $r) { continue }
        $full = [System.IO.Path]::GetFullPath($r)
        $seen = $false
        foreach ($u in $uniq) {
            if ($u.Equals($full, [System.StringComparison]::OrdinalIgnoreCase)) { $seen = $true; break }
        }
        if (-not $seen) { $uniq.Add($full) }
    }
    return $uniq
}

function Test-UnderRoot([string]$Full, [string]$Root) {
    $r = [System.IO.Path]::GetFullPath($Root)
    if ($Full.Equals($r, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    if (-not $r.EndsWith('\')) { $r = $r + '\' }
    return $Full.StartsWith($r, [System.StringComparison]::OrdinalIgnoreCase)
}

if ($ListRoots) {
    Get-SourceRoots | ForEach-Object { Write-Output $_ }
    exit 0
}
if (-not $Path) { Write-GuardResult $false 'path required' $false }

$full = $Path
if (-not [System.IO.Path]::IsPathRooted($full)) { $full = Join-Path (Get-Location) $full }
try { $full = [System.IO.Path]::GetFullPath($full) } catch { Write-GuardResult $false 'path invalid' $false }

$roots = @(Get-SourceRoots)
$inside = $false
foreach ($r in $roots) {
    if (Test-UnderRoot $full $r) { $inside = $true; break }
}
if (-not $inside) {
    if ($roots.Count -eq 0 -and -not (Test-UnderRoot $full $WorkspaceRoot)) {
        Write-GuardResult $false 'no source roots; refusing path outside workspace' $false
    }
    Write-GuardResult $true '' $true
}

$scopePath = Join-Path $WorkspaceRoot 'contracts\current_scope.json'
if (-not (Test-Path -LiteralPath $scopePath)) { Write-GuardResult $false 'missing current_scope.json' $false }
$scope = Get-Content -LiteralPath $scopePath -Raw -Encoding UTF8 | ConvertFrom-Json
$phase = [string]$scope.phase
$cursor = $null
$cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
if (Test-Path -LiteralPath $cursorPath) {
    $cursor = Get-FieldMap (Get-Content -LiteralPath $cursorPath -Raw -Encoding UTF8)
}
$status = ''
if ($cursor -and $cursor['task_status']) { $status = [string]$cursor['task_status'] }
if ($phase -eq 'idle' -or $status -eq 'idle') { Write-GuardResult $false 'live card is idle' $false }
if ($status -ne 'in_progress') { Write-GuardResult $false ('task_status ' + $status + ' does not allow source writes') $false }

$route = ''
if ($scope.PSObject.Properties.Name -contains 'route') { $route = [string]$scope.route }
$allowedPhase = ($phase -eq 'implement') -or ($phase -eq 'discovery' -and $route -eq 'fast')
if (-not $allowedPhase) { Write-GuardResult $false ('phase ' + $phase + ' does not allow source writes') $false }

if ($phase -eq 'implement') {
    $contractPath = Join-Path $WorkspaceRoot 'contracts\current.md'
    $contract = $null
    if (Test-Path -LiteralPath $contractPath) {
        $contract = Get-FieldMap (Get-Content -LiteralPath $contractPath -Raw -Encoding UTF8)
    }
    $cs = ''
    if ($contract -and $contract['contract_status']) { $cs = [string]$contract['contract_status'] }
    if ($cs -ne 'active') { Write-GuardResult $false 'contract must be active' $false }
}

$profileId = ''
if ($scope.PSObject.Properties.Name -contains 'profile_id' -and [string]$scope.profile_id -and [string]$scope.profile_id -ne 'none') {
    $profileId = [string]$scope.profile_id
} elseif ($cursor -and $cursor['active_profile'] -and [string]$cursor['active_profile'] -ne 'none') {
    $profileId = [string]$cursor['active_profile']
}
if ($profileId) {
    $pfPath = Join-Path $WorkspaceRoot ('profiles\' + $profileId + '.md')
    if (-not (Test-Path -LiteralPath $pfPath)) { Write-GuardResult $false ('missing profile ' + $profileId) $false }
    $pf = Get-FieldMap (Get-Content -LiteralPath $pfPath -Raw -Encoding UTF8)
    if ($pf -and [string]$pf['allowed_write'] -eq 'workspace_only') {
        Write-GuardResult $false 'profile allowed_write is workspace_only' $false
    }
}

$base = ''
if ($cursor -and $cursor['source_root']) { $base = [string]$cursor['source_root'] }
$tid = ''
if ($scope.PSObject.Properties.Name -contains 'target_id') { $tid = [string]$scope.target_id }
if ($tid -and $tid -ne 'none') {
    $tpath = Join-Path $WorkspaceRoot ('targets\' + $tid + '.json')
    if (-not (Test-Path -LiteralPath $tpath)) { Write-GuardResult $false ('missing target ' + $tid) $false }
    $target = Get-Content -LiteralPath $tpath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($target.workspace_path) { $base = [string]$target.workspace_path }
}
if (-not $base) { Write-GuardResult $false 'no workspace_path for write_paths' $false }

$writes = @()
if ($scope.PSObject.Properties.Name -contains 'write_paths' -and $null -ne $scope.write_paths) { $writes = @($scope.write_paths) }
foreach ($w in $writes) {
    if (-not $w) { continue }
    $candidate = [string]$w
    if (-not [System.IO.Path]::IsPathRooted($candidate)) { $candidate = Join-Path $base $candidate }
    try { $candidate = [System.IO.Path]::GetFullPath($candidate) } catch { continue }
    if ($candidate.Equals($full, [System.StringComparison]::OrdinalIgnoreCase)) { Write-GuardResult $true '' $false }
}
Write-GuardResult $false 'path not in write_paths' $false
