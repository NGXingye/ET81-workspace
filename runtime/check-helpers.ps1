# Non-entry helper. Dot-sourced by check-workspace.ps1 and etctl.ps1 status.
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

function New-CheckState { return @{ Errors = @(); Warnings = @() } }
function Add-CheckError([hashtable]$State, [string]$Code, [string]$Message) { $State.Errors += ($Code + ': ' + $Message) }
function Add-CheckWarning([hashtable]$State, [string]$Code, [string]$Message) { $State.Warnings += ($Code + ': ' + $Message) }

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
    $pattern = [regex]::Escape($script:UnityEditorLabel) + '\s*\|\s*`?([0-9]+\.[0-9]+\.[0-9]+f[0-9]+(?:c[0-9]+)?)`?'
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
        Add-CheckError $State 'TOOL_LINE_MAX' ($Rel + ' ' + $phys + ' lines > 250; follow runtime_code.md section 4, do not raise cap')
    } elseif ($phys -gt 180) {
        Add-CheckWarning $State 'TOOL_LINE_SOFT' ($Rel + ' ' + $phys + ' lines > 180')
    }
}

function Get-JsonObject([string]$Path) {
    try { return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json) }
    catch { return $null }
}

function Test-RequiredJsonProps([hashtable]$State, [string]$Code, [string]$Rel, $Obj, [string[]]$Names) {
    if ($null -eq $Obj) { Add-CheckError $State $Code ($Rel + ' invalid json'); return $false }
    foreach ($name in $Names) {
        if ($Obj.PSObject.Properties.Name -notcontains $name) { Add-CheckError $State $Code ($Rel + ' missing ' + $name) }
    }
    return $true
}

function Test-CurrentScopeJson([hashtable]$State, [string]$Rel, $Obj, $ContractFields, [string]$WorkspaceRoot) {
    if (-not (Test-RequiredJsonProps $State 'SCOPE_JSON' $Rel $Obj @('task_id', 'phase', 'scope_revision'))) { return }
    $allowed = @('task_id', 'phase', 'scope_revision', 'intent', 'size', 'route', 'edit_ops', 'target_id', 'profile_id', 'seed_paths', 'read_paths', 'write_paths', 'editor_md_paths', 'evidence', 'risks', 'uncertain', 'validation', 'plan', 'goal', 'implement_round', 'verify_feedback', 'parent_task_id', 'resume_task_id', 'parked', 'parked_by')
    foreach ($p in $Obj.PSObject.Properties.Name) {
        if ($allowed -notcontains $p) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' unknown field ' + $p) }
    }
    $phase = [string]$Obj.phase
    if (@('idle', 'discovery', 'awaiting_scope', 'implement', 'awaiting_verify', 'harvest', 'blocked') -notcontains $phase) {
        Add-CheckError $State 'SCOPE_JSON' ($Rel + ' invalid phase ' + $phase)
    }
    if ($ContractFields) {
        if ([string]$Obj.task_id -ne $ContractFields['task_id']) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' task_id mismatch contract') }
        $cStatus = $ContractFields['contract_status']
        if ($cStatus -eq 'idle' -and $phase -ne 'idle') { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' phase must be idle when contract idle') }
        if ($cStatus -eq 'discovery' -and @('discovery', 'awaiting_scope', 'blocked') -notcontains $phase) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' discovery contract phase mismatch') }
        if ($cStatus -eq 'active' -and @('implement', 'awaiting_verify', 'harvest', 'blocked') -notcontains $phase) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' active contract cannot stay in analysis') }
        if ($Obj.PSObject.Properties.Name -contains 'goal') { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' goal belongs on current.md not live scope') }
    }
    if ($phase -eq 'idle') {
        if ([int]$Obj.scope_revision -ne 0) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' idle scope_revision must be 0') }
        foreach ($extra in @('intent', 'size', 'route', 'edit_ops', 'seed_paths', 'read_paths', 'write_paths', 'editor_md_paths', 'evidence', 'risks', 'uncertain', 'validation', 'plan', 'goal', 'implement_round', 'verify_feedback', 'parent_task_id', 'resume_task_id', 'parked', 'parked_by')) {
            if ($Obj.PSObject.Properties.Name -contains $extra) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' idle must omit ' + $extra) }
        }
        return
    }
    foreach ($name in @('intent', 'size', 'route')) {
        if ($Obj.PSObject.Properties.Name -notcontains $name) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' missing ' + $name) }
    }
    if (@('awaiting_scope', 'implement', 'awaiting_verify', 'harvest') -contains $phase) {
        if (@('unknown', '') -contains [string]$Obj.intent) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' intent must be resolved') }
        if (@('unknown', '') -contains [string]$Obj.size) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' size must be resolved') }
        if (@('unset', '') -contains [string]$Obj.route) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' route must be set') }
        $writesN = @($Obj.write_paths).Count
        $planN = 0
        if ($Obj.PSObject.Properties.Name -contains 'plan' -and $null -ne $Obj.plan) { $planN = @($Obj.plan).Count }
        if ($writesN -gt 0 -and $planN -eq 0) {
            Add-CheckError $State 'SCOPE_JSON' ($Rel + ' plan required when write_paths set')
        }
    }
    if ([string]$Obj.route -eq 'fast') {
        if ([string]$Obj.size -ne 'trivial' -or @('bug', 'feature') -notcontains [string]$Obj.intent) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' fast route needs trivial bug/feature') }
        $ops = @($Obj.edit_ops)
        if ($ops.Count -eq 0 -or ($ops | Where-Object { $_ -ne 'in_place' }) -or @($Obj.write_paths).Count -gt 2) {
            Add-CheckError $State 'SCOPE_JSON' ($Rel + ' fast route in_place only, write_paths max 2')
        }
        $planNFast = 0
        if ($Obj.PSObject.Properties.Name -contains 'plan' -and $null -ne $Obj.plan) { $planNFast = @($Obj.plan).Count }
        if (@($Obj.write_paths).Count -gt 0 -and $planNFast -eq 0) {
            Add-CheckError $State 'SCOPE_JSON' ($Rel + ' fast route plan required')
        }
    }
    $tid = [string]$Obj.target_id
    if ($WorkspaceRoot -and $tid -and $tid -ne 'none' -and -not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot ('targets/' + $tid + '.json')))) {
        Add-CheckError $State 'SCOPE_JSON' ($Rel + ' missing target targets/' + $tid + '.json')
    }
    if ($Obj.PSObject.Properties.Name -contains 'implement_round') {
        $r = [int]$Obj.implement_round
        if ($r -lt 1 -or $r -gt 3) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' implement_round must be 1..3') }
        if (@('implement', 'awaiting_verify', 'blocked', 'harvest') -notcontains $phase) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' implement_round only after implement') }
    }
    $hasParent = ($Obj.PSObject.Properties.Name -contains 'parent_task_id' -and [string]$Obj.parent_task_id)
    $hasResume = ($Obj.PSObject.Properties.Name -contains 'resume_task_id' -and [string]$Obj.resume_task_id)
    if ($hasParent) {
        if ([string]$Obj.parent_task_id -eq [string]$Obj.task_id) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' must not reuse parent_task_id') }
        if ([string]$Obj.size -ne 'trivial' -or [string]$Obj.route -ne 'fast') { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' interrupt must be trivial fast') }
        $wn = @($Obj.write_paths).Count
        if ($wn -lt 1 -or $wn -gt 2) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' interrupt write_paths must be 1..2') }
        if ($ContractFields) {
            if (-not $hasResume) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' live interrupt needs resume_task_id') }
            elseif ([string]$Obj.resume_task_id -eq [string]$Obj.task_id) { Add-CheckError $State 'SCOPE_JSON' ($Rel + ' resume_task_id must not be self') }
        } elseif ($hasResume) {
            Add-CheckError $State 'SCOPE_JSON' ($Rel + ' candidate must not have resume_task_id')
        }
    } elseif ($hasResume) {
        Add-CheckError $State 'SCOPE_JSON' ($Rel + ' resume_task_id requires parent_task_id')
    }
    if ($ContractFields -and $Obj.PSObject.Properties.Name -contains 'parked') {
        Add-CheckError $State 'SCOPE_JSON' ($Rel + ' parked not on live card')
    }
}

function Test-CandidateJson([hashtable]$State, [string]$Rel, $Obj, [string]$ExpectId, [string]$LiveTaskId, [string]$WorkspaceRoot) {
    if (-not (Test-RequiredJsonProps $State 'CANDIDATE' $Rel $Obj @('task_id', 'phase', 'scope_revision', 'goal'))) { return }
    if (-not [string]$Obj.goal) { Add-CheckError $State 'CANDIDATE' ($Rel + ' goal required') }
    if ([string]$Obj.task_id -ne $ExpectId) { Add-CheckError $State 'CANDIDATE' ($Rel + ' task_id must match file stem') }
    $parked = ($Obj.PSObject.Properties.Name -contains 'parked' -and [bool]$Obj.parked)
    $okPh = @('discovery', 'awaiting_scope')
    if ($parked) { $okPh = @('discovery', 'awaiting_scope', 'implement', 'awaiting_verify') }
    if ($okPh -notcontains [string]$Obj.phase) { Add-CheckError $State 'CANDIDATE' ($Rel + ' invalid candidate phase') }
    if ($LiveTaskId -and $LiveTaskId -ne 'none' -and [string]$Obj.task_id -eq $LiveTaskId) {
        Add-CheckError $State 'CANDIDATE' ($Rel + ' task_id duplicates live card')
    }
    if (-not $parked -and $Obj.PSObject.Properties.Name -contains 'implement_round') {
        Add-CheckError $State 'CANDIDATE' ($Rel + ' must not have implement_round')
    }
    if ($parked) {
        if (-not [string]$Obj.parked_by) { Add-CheckError $State 'CANDIDATE' ($Rel + ' parked requires parked_by') }
        if ($Obj.PSObject.Properties.Name -contains 'parent_task_id') { Add-CheckError $State 'CANDIDATE' ($Rel + ' parked must not have parent_task_id') }
    }
    Test-CurrentScopeJson $State $Rel $Obj $null $WorkspaceRoot
}

function Test-TargetJson([hashtable]$State, [string]$Rel, $Obj, [string]$ExpectId) {
    if (-not (Test-RequiredJsonProps $State 'TARGET_JSON' $Rel $Obj @('target_id', 'display_name', 'workspace_path', 'vcs', 'editor'))) { return }
    if ([string]$Obj.target_id -ne $ExpectId) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' target_id must match file stem') }
    if (@('svn', 'git') -notcontains [string]$Obj.vcs -or @('unity', 'other') -notcontains [string]$Obj.editor) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' invalid vcs/editor') }
    if (-not (Test-Path -LiteralPath ([string]$Obj.workspace_path))) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' workspace_path missing') }
}

function Test-StandardsCatalog([hashtable]$State, [string]$WorkspaceRoot) {
    $rel = 'standards/catalog.json'; $path = Join-Path $WorkspaceRoot $rel
    if (-not (Test-Path -LiteralPath $path)) { Add-CheckError $State 'STANDARDS' $rel; return }
    $cat = Get-JsonObject $path
    if (-not $cat -or -not $cat.entries) { Add-CheckError $State 'STANDARDS' ($rel + ' missing entries'); return }
    foreach ($ed in @($cat.editors)) {
        $tid = [string]$ed.id
        if (-not (Test-Path -LiteralPath ([string]$ed.workspace_path))) { Add-CheckError $State 'STANDARDS' ($rel + ' editor path missing ' + $tid) }
        if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot ('standards/' + $tid + '/target.json')))) { Add-CheckError $State 'STANDARDS' ($rel + ' missing standards/' + $tid + '/target.json') }
    }
    foreach ($e in @($cat.entries)) { foreach ($load in @($e.load)) { if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot ($load -replace '/', '\')))) { Add-CheckError $State 'STANDARDS' ($rel + ' load missing ' + $load) } } }
}
