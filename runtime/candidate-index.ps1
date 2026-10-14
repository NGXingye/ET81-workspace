# Non-entry. Dot-source after check-helpers.ps1. No SVN.
$script:CandNow = ([string][char]0x5F53) + [char]0x524D
$script:CandUnit = ([string][char]0x4E2A) + [char]0x5019 + [char]0x9009
$script:CandLive = ([string][char]0x6D3B) + [char]0x5361
$script:CandPark = ([string][char]0x52FE) + [char]0x56DE
$script:CandStop = [string][char]0x3002
$script:CandComma = [string][char]0xFF0C
$script:CandSemi = [string][char]0xFF1B
$script:CandOpen = [string][char]0xFF08
$script:CandClose = [string][char]0xFF09

function Get-CandidateGloss($Obj) {
    $goal = ''
    if ($Obj -and $Obj.PSObject.Properties.Name -contains 'goal') { $goal = [string]$Obj.goal }
    $goal = ($goal -replace '[\r\n]+', ' ').Trim()
    $period = $goal.IndexOf($script:CandStop)
    if ($period -gt 0) { $goal = $goal.Substring(0, $period) }
    $goal = ($goal -replace '[`\[\]]', '').Trim()
    if (-not $goal) { $goal = [string]$Obj.task_id }
    if ($goal.Length -gt 80) { $goal = $goal.Substring(0, 80).Trim() }
    $parked = ($Obj -and $Obj.PSObject.Properties.Name -contains 'parked' -and [bool]$Obj.parked)
    if ($parked) { $goal = $goal + $script:CandComma + $script:CandPark }
    return $goal
}

function Get-CandidateIndexLine([string]$WorkspaceRoot) {
    $cursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
    $cursor = Get-FieldMap ([System.IO.File]::ReadAllText($cursorPath))
    $live = [string]$cursor['task_id']
    if (-not $live) { $live = 'none' }
    $dir = Join-Path $WorkspaceRoot 'contracts/candidates'
    $files = @()
    if (Test-Path -LiteralPath $dir) {
        $files = @(Get-ChildItem -LiteralPath $dir -Filter '*.json' -File | Sort-Object Name)
    }
    if ($files.Count -eq 0) {
        return ($script:CandNow + ' 0 ' + $script:CandUnit + $script:CandStop + $script:CandLive + ' ' + $live + $script:CandStop)
    }
    $bt = $script:HelperBt
    $parts = New-Object System.Collections.Generic.List[string]
    foreach ($f in $files) {
        $gloss = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        try {
            $obj = [System.IO.File]::ReadAllText($f.FullName) | ConvertFrom-Json
            $gloss = Get-CandidateGloss $obj
        } catch { }
        [void]$parts.Add('[' + $bt + $f.Name + $bt + '](./' + $f.Name + ')' + $script:CandOpen + $gloss + $script:CandClose)
    }
    return ($script:CandNow + ' ' + $files.Count + ' ' + $script:CandUnit + $script:HelperColon + ($parts -join $script:CandSemi) + $script:CandStop + $script:CandLive + ' ' + $live + $script:CandStop)
}

function Update-CandidateIndex([string]$WorkspaceRoot, [string]$Stamp) {
    $indexPath = Join-Path $WorkspaceRoot 'contracts/candidates/_index.md'
    if (-not (Test-Path -LiteralPath $indexPath)) { throw 'missing contracts/candidates/_index.md' }
    $text = [System.IO.File]::ReadAllText($indexPath)
    $nl = "`n"
    if ($text.Contains("`r`n")) { $nl = "`r`n" }
    $lines = [System.Collections.Generic.List[string]]::new()
    [void]$lines.AddRange([string[]]($text -split "`r?`n", -1))
    $want = Get-CandidateIndexLine $WorkspaceRoot
    $found = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].StartsWith($script:CandNow) -and $lines[$i].Contains($script:CandUnit)) {
            $lines[$i] = $want
            $found = $true
            break
        }
    }
    if (-not $found) { throw 'candidates/_index.md missing listing line' }
    if ($lines.Count -gt 0 -and $lines[0] -match [regex]::Escape($script:HdrTime)) {
        $lines[0] = '> ' + $script:HdrTime + $Stamp
    }
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($indexPath, ($lines -join $nl), $enc)
}

function Test-CandidateIndex([hashtable]$State, [string]$WorkspaceRoot, [string]$LiveTaskId) {
    $indexPath = Join-Path $WorkspaceRoot 'contracts/candidates/_index.md'
    if (-not (Test-Path -LiteralPath $indexPath)) { return }
    $text = [System.IO.File]::ReadAllText($indexPath)
    $listing = $null
    foreach ($line in ($text -split "`r?`n")) {
        if ($line.StartsWith($script:CandNow) -and $line.Contains($script:CandUnit)) { $listing = $line; break }
    }
    if (-not $listing) {
        Add-CheckError $State 'CANDIDATE' 'candidates/_index.md missing listing line'
        return
    }
    $wantLive = $LiveTaskId
    if (-not $wantLive) { $wantLive = 'none' }
    $tail = $script:CandLive + ' ' + $wantLive + $script:CandStop
    if (-not $listing.EndsWith($tail)) {
        Add-CheckError $State 'CANDIDATE' ('candidates/_index.md live card must be ' + $wantLive)
    }
    $onDisk = @{}
    $dir = Join-Path $WorkspaceRoot 'contracts/candidates'
    if (Test-Path -LiteralPath $dir) {
        Get-ChildItem -LiteralPath $dir -Filter '*.json' -File | ForEach-Object { $onDisk[$_.Name] = $true }
    }
    $listed = @{}
    [regex]::Matches($listing, '\]\(\./([^)]+\.json)\)') | ForEach-Object { $listed[$_.Groups[1].Value] = $true }
    foreach ($name in @($onDisk.Keys)) {
        if (-not $listed.Contains($name)) { Add-CheckError $State 'CANDIDATE' ('candidates/_index.md missing ' + $name) }
    }
    foreach ($name in @($listed.Keys)) {
        if (-not $onDisk.Contains($name)) { Add-CheckError $State 'CANDIDATE' ('candidates/_index.md lists missing ' + $name) }
    }
}
