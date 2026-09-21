# Non-entry. Invoked by etctl.ps1 begin-implement. Writes cursor/contract/scope then prints packet. No SVN.
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')

function Write-BeginError([string]$Msg) {
    [ordered]@{ ok = $false; error = $Msg } | ConvertTo-Json -Compress:$false
    exit 1
}

function Read-Utf8([string]$Path) {
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

function Set-HeaderTime([string]$Text, [string]$Stamp) {
    $hdr = $script:HdrTime
    $nl = "`n"
    if ($Text.Contains("`r`n")) { $nl = "`r`n" }
    $lines = [System.Collections.Generic.List[string]]::new()
    [void]$lines.AddRange([string[]]($Text -split "`r?`n", -1))
    if ($lines.Count -gt 0 -and $lines[0] -match [regex]::Escape($hdr)) {
        $lines[0] = '> ' + $hdr + $Stamp
    }
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
        if ($lastField -lt 0) { Write-BeginError ('cannot insert field ' + $Name) }
        $lines.Insert($lastField + 1, $newLine)
    }
    return ($lines -join $nl)
}

function Set-ScopeImplement([string]$Text, [int]$Round) {
    $text = [regex]::Replace($Text, '"phase"\s*:\s*"[^"]*"', '"phase": "implement"')
    if ($text -match '"implement_round"') {
        return [regex]::Replace($text, '"implement_round"\s*:\s*\d+', '"implement_round": ' + $Round)
    }
    return [regex]::Replace($text, '("phase": "implement",)(\r?\n)', ('$1$2  "implement_round": ' + $Round + ',$2'))
}

$cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
$contractPath = Join-Path $WorkspaceRoot 'contracts/current.md'
$scopePath = Join-Path $WorkspaceRoot 'contracts/current_scope.json'
if (-not (Test-Path -LiteralPath $cursorPath) -or -not (Test-Path -LiteralPath $contractPath) -or -not (Test-Path -LiteralPath $scopePath)) {
    Write-BeginError 'missing project_cursor.md, current.md, or current_scope.json'
}

$cursor = Get-FieldMap (Read-Utf8 $cursorPath)
$contract = Get-FieldMap (Read-Utf8 $contractPath)
$scope = Get-Content -LiteralPath $scopePath -Raw -Encoding UTF8 | ConvertFrom-Json
$cStatus = [string]$contract['contract_status']
$phase = [string]$scope.phase
if ($cStatus -eq 'idle' -or $phase -eq 'idle') { Write-BeginError 'no live task; stay idle' }
if (@('harvest', 'blocked') -contains $phase) { Write-BeginError ('phase is ' + $phase + '; stay') }
if (@('discovery', 'awaiting_scope', 'implement', 'awaiting_verify') -notcontains $phase) {
    Write-BeginError ('phase cannot enter implement: ' + $phase)
}
$writes = @($scope.write_paths)
if ($writes.Count -eq 0) { Write-BeginError 'write_paths empty; analysis packet not ready' }
$planN = 0
if ($scope.PSObject.Properties.Name -contains 'plan' -and $null -ne $scope.plan) { $planN = @($scope.plan).Count }
if ($planN -eq 0) { Write-BeginError 'plan empty; discovery must write change steps' }
$tid = [string]$scope.target_id
if (-not $tid -or $tid -eq 'none') { Write-BeginError 'target_id required' }
if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot ('targets/' + $tid + '.json')))) {
    Write-BeginError ('missing targets/' + $tid + '.json')
}

$round = 1
if ($scope.PSObject.Properties.Name -contains 'implement_round') { $round = [int]$scope.implement_round }
if ($round -lt 1) { $round = 1 }
if ($phase -eq 'awaiting_verify') { $round = $round + 1 }
elseif ($phase -in @('discovery', 'awaiting_scope') -and $scope.PSObject.Properties.Name -notcontains 'implement_round') { $round = 1 }
if ($round -gt 3) { Write-BeginError 'implement_round max 3; set phase blocked' }

$needWrite = -not (
    $cStatus -eq 'active' -and
    $phase -eq 'implement' -and
    [string]$cursor['task_status'] -eq 'in_progress'
)

if ($needWrite) {
    $stamp = Get-Stamp
    $profileId = [string]$scope.profile_id
    if (-not $profileId -or $profileId -eq 'none') { $profileId = [string]$cursor['active_profile'] }
    if (-not $profileId -or $profileId -eq 'none') { Write-BeginError 'profile_id required to activate' }
    $pref = 'profiles/' + $profileId + '.md'
    if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot $pref))) { Write-BeginError ('missing ' + $pref) }

    $mode = [string]$contract['source_root_mode']
    if (-not $mode) { $mode = [string]$cursor['source_root_mode'] }
    if (-not $mode) { $mode = 'normal' }

    $accept = [string]$contract['acceptance']
    if (-not $accept) {
        $valid = @($scope.validation)
        if ($valid.Count -eq 0) { Write-BeginError 'validation empty; cannot derive acceptance' }
        $accept = ($valid -join '; ')
    }

    $scopeText = Set-ScopeImplement (Read-Utf8 $scopePath) $round
    Write-Utf8 $scopePath $scopeText

    $contractText = Read-Utf8 $contractPath
    $contractText = Set-MdField $contractText 'contract_status' 'active'
    $contractText = Set-MdField $contractText 'profile_ref' $pref
    $contractText = Set-MdField $contractText 'source_root_mode' $mode
    $contractText = Set-MdField $contractText 'acceptance' $accept
    $contractText = Set-HeaderTime $contractText $stamp
    Write-Utf8 $contractPath $contractText

    $cursorText = Read-Utf8 $cursorPath
    $cursorText = Set-MdField $cursorText 'task_status' 'in_progress'
    $cursorText = Set-MdField $cursorText 'blocked' 'false'
    $cursorText = Set-HeaderTime $cursorText $stamp
    Write-Utf8 $cursorPath $cursorText
}

& (Join-Path $RuntimeRoot 'etctl.ps1') packet
exit $LASTEXITCODE
