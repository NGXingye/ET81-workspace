param([switch]$Strict)
$ErrorActionPreference = 'Stop'
$WorkspaceRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'check-helpers.ps1')
$State = New-CheckState

$RequiredFiles = @(
    'AGENTS.md', 'project_index.md', 'project_pipeline.md', 'project_cursor.md',
    'global_rules/_index.md', 'global_rules/md_governance.md', 'global_rules/kv_budget.md',
    'global_rules/code_governance.md', 'global_rules/runtime_code.md',
    'contracts/_index.md', 'contracts/_template.md', 'contracts/_template_scope.json',
    'contracts/_template_interrupt.json',
    'contracts/current.md', 'contracts/current_scope.json', 'contracts/candidates/_index.md',
    'profiles/_index.md', 'profiles/_template.md', 'profiles/control.md',
    'standards/_index.md', 'standards/catalog.json', 'standards/framework_baseline.md',
    'standards/source_code_map.md', 'standards/audit/source_import_record.md',
    'standards/trunk/target.json', 'standards/trunk/modules/monster_ai.json',
    'standards/trunk/modules/root_motion.json',
    'standards/SkillEditor/target.json', 'standards/BridgeEditor/target.json',
    'standards/ActionEditor/target.json', 'standards/integrations/_index.md',
    'standards/records/task_outcomes.jsonl',
    'runtime/_index.md', 'runtime/etctl.ps1', 'runtime/check-helpers.ps1',
    'runtime/check-workspace.ps1', 'runtime/begin-implement.ps1', 'runtime/promote.ps1',
    'runtime/interrupt.ps1',
    'runtime/schema/current_scope.schema.json',
    'runtime/schema/target.schema.json', 'runtime/schema/map_entry.schema.json',
    'targets/_index.md', 'targets/trunk.json', 'targets/SkillEditor.json',
    'targets/BridgeEditor.json', 'targets/ActionEditor.json',
    'active.code-workspace', '.cursor/rules/et81-cold-start.mdc'
)
foreach ($rel in $RequiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $WorkspaceRoot $rel))) {
        Add-CheckError $State 'MISSING' $rel
    }
}

Get-ChildItem -LiteralPath $WorkspaceRoot -Recurse -Filter '*.md' -File | ForEach-Object {
    $rel = $_.FullName.Substring($WorkspaceRoot.Length).TrimStart('\', '/').Replace('\', '/')
    if ($rel -like '.git/*') { return }
    Test-MarkdownShape $State $rel (Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8)
}

$cursorFields = $null
$CursorPath = Join-Path $WorkspaceRoot 'project_cursor.md'
if (Test-Path -LiteralPath $CursorPath) {
    $cursorFields = Get-FieldMap (Get-Content -LiteralPath $CursorPath -Raw -Encoding UTF8)
    Test-FieldBudget $State 'project_cursor.md' $cursorFields @(
        'workspace_root', 'trunk_markdown_access', 'init_baseline_status',
        'source_root', 'source_root_mode', 'version_control',
        'task_id', 'task_status', 'active_profile', 'contract_ref', 'blocked'
    ) 14
    foreach ($banned in @('allowed_write', 'allowed_read', 'allowed_write_paths', 'allowed_read_paths', 'acceptance', 'goal')) {
        if ($cursorFields.Contains($banned)) { Add-CheckError $State 'FIELD_DUP' ('project_cursor.md must not contain ' + $banned) }
    }
    if ($cursorFields['trunk_markdown_access'] -ne 'frozen') {
        Add-CheckError $State 'TRUNK_ACCESS' $cursorFields['trunk_markdown_access']
    }
    $sourceRoot = $cursorFields['source_root']
    if ([string]::IsNullOrWhiteSpace($sourceRoot)) { Add-CheckError $State 'SOURCE_ROOT' 'empty' }
    elseif (-not (Test-Path -LiteralPath $sourceRoot)) { Add-CheckError $State 'SOURCE_ROOT' $sourceRoot }
    else {
        $versionFile = Join-Path $sourceRoot 'Unity/ProjectSettings/ProjectVersion.txt'
        $flatVersion = Join-Path $sourceRoot 'ProjectSettings/ProjectVersion.txt'
        if (-not (Test-Path -LiteralPath $versionFile) -and (Test-Path -LiteralPath $flatVersion)) { $versionFile = $flatVersion }
        $expect = Get-BaselineUnityVersion $WorkspaceRoot
        if (-not (Test-Path -LiteralPath $versionFile)) { Add-CheckError $State 'UNITY_VERSION' $versionFile }
        elseif (-not $expect) { Add-CheckWarning $State 'UNITY_VERSION' 'baseline has no Unity version' }
        elseif ((Get-Content -LiteralPath $versionFile -Raw -Encoding UTF8) -notmatch [regex]::Escape($expect)) {
            Add-CheckWarning $State 'UNITY_VERSION' ('ProjectVersion.txt does not match baseline ' + $expect)
        }
    }
    $idle = ($cursorFields['task_status'] -eq 'idle')
    if ($idle) {
        foreach ($k in @('task_id', 'active_profile', 'contract_ref')) {
            if ($cursorFields[$k] -ne 'none') { Add-CheckError $State 'IDLE' ($k + ' must be none when idle') }
        }
        foreach ($k in @('isolated_source_root', 'blocker_reason', 'blocker_owner')) {
            if ($cursorFields.Contains($k)) { Add-CheckError $State 'IDLE' ($k + ' must be omitted when idle') }
        }
    } else {
        if ($cursorFields['contract_ref'] -ne 'contracts/current.md') {
            Add-CheckError $State 'CONTRACT_REF' $cursorFields['contract_ref']
        }
        if ($cursorFields['blocked'] -eq 'true') {
            if (-not $cursorFields.Contains('blocker_reason')) { Add-CheckError $State 'FIELD_MIN' 'blocker_reason required when blocked' }
            if (-not $cursorFields.Contains('blocker_owner')) { Add-CheckError $State 'FIELD_MIN' 'blocker_owner required when blocked' }
        }
        if ($cursorFields['source_root_mode'] -eq 'isolated' -and -not $cursorFields.Contains('isolated_source_root')) {
            Add-CheckError $State 'FIELD_MIN' 'isolated_source_root required when isolated'
        }
    }
}

$ContractPath = Join-Path $WorkspaceRoot 'contracts/current.md'
if (Test-Path -LiteralPath $ContractPath) {
    $cf = Get-FieldMap (Get-Content -LiteralPath $ContractPath -Raw -Encoding UTF8)
    Test-FieldBudget $State 'contracts/current.md' $cf @('task_id', 'contract_status') 10
    $cStatus = $cf['contract_status']
    if ($cStatus -eq 'idle') {
        if ($cf.Count -ne 2) { Add-CheckError $State 'FIELD_IDLE' ('contracts/current.md idle must have exactly 2 fields, got ' + $cf.Count) }
        if ($cursorFields -and ($cursorFields['task_status'] -ne 'idle')) { Add-CheckError $State 'CONTRACT' 'cursor not idle but contract is idle' }
    } elseif ($cStatus -eq 'discovery') {
        Test-FieldBudget $State 'contracts/current.md' $cf @('task_id', 'contract_status', 'goal') 10
        if ($cursorFields -and ($cursorFields['task_status'] -eq 'idle')) { Add-CheckError $State 'CONTRACT' 'cursor idle but contract is discovery' }
    } elseif ($cStatus -eq 'active') {
        Test-FieldBudget $State 'contracts/current.md' $cf @('task_id', 'contract_status', 'goal', 'profile_ref', 'source_root_mode', 'acceptance') 10
        if ($cursorFields -and ($cursorFields['task_status'] -eq 'idle')) { Add-CheckError $State 'CONTRACT' 'cursor idle but contract is active' }
        if ($cursorFields -and $cursorFields['active_profile'] -eq 'none') {
            Add-CheckError $State 'PROFILE' 'active_profile required when contract is active'
        }
    } else { Add-CheckError $State 'CONTRACT' ('unknown contract_status ' + $cStatus) }
    if ($cursorFields -and $cursorFields['active_profile'] -ne 'none') {
        $profilePath = Join-Path $WorkspaceRoot ('profiles/' + $cursorFields['active_profile'] + '.md')
        if (-not (Test-Path -LiteralPath $profilePath)) { Add-CheckError $State 'PROFILE' $cursorFields['active_profile'] }
    }

    $scopeObj = $null
    $scopePath = Join-Path $WorkspaceRoot 'contracts/current_scope.json'
    if (Test-Path -LiteralPath $scopePath) {
        $scopeObj = Get-JsonObject $scopePath
        Test-CurrentScopeJson $State 'contracts/current_scope.json' $scopeObj $cf $WorkspaceRoot
    }
    if ($cursorFields -and $scopeObj) {
        $phaseMap = @{
            idle            = 'idle'
            discovery       = 'in_progress'
            implement       = 'in_progress'
            harvest         = 'in_progress'
            awaiting_scope  = 'awaiting_approval'
            awaiting_verify = 'awaiting_approval'
            blocked         = 'blocked'
        }
        $expectStatus = $phaseMap[[string]$scopeObj.phase]
        if ($expectStatus -and $cursorFields['task_status'] -ne $expectStatus) {
            Add-CheckError $State 'PHASE' ('task_status=' + $cursorFields['task_status'] + ' mismatches phase=' + $scopeObj.phase)
        }
        $tid = [string]$scopeObj.target_id
        if ([string]$cursorFields['source_root_mode'] -ne 'isolated' -and $tid -and $tid -ne 'none' -and [string]$scopeObj.phase -ne 'idle') {
            $tObj = Get-JsonObject (Join-Path $WorkspaceRoot ('targets/' + $tid + '.json'))
            if ($tObj -and [string]$tObj.workspace_path) {
                $want = [IO.Path]::GetFullPath([string]$tObj.workspace_path).TrimEnd('\')
                $have = [IO.Path]::GetFullPath([string]$cursorFields['source_root']).TrimEnd('\')
                if ($want -ne $have) { Add-CheckError $State 'SOURCE_ROOT' ('must equal targets/' + $tid + '.json workspace_path') }
            }
        }
    }
}

Test-StandardsCatalog $State $WorkspaceRoot

$candDir = Join-Path $WorkspaceRoot 'contracts/candidates'
if (Test-Path -LiteralPath $candDir) {
    $candFiles = @(Get-ChildItem -LiteralPath $candDir -Filter '*.json' -File)
    if ($candFiles.Count -gt 2) { Add-CheckError $State 'CANDIDATE' ('max 2 files, got ' + $candFiles.Count) }
    $liveTid = 'none'
    $liveObj = $null
    $livePath = Join-Path $WorkspaceRoot 'contracts/current_scope.json'
    if (Test-Path -LiteralPath $livePath) {
        $liveObj = Get-JsonObject $livePath
        if ($liveObj) { $liveTid = [string]$liveObj.task_id }
    }
    $parentHits = 0
    if ($liveObj -and $liveObj.PSObject.Properties.Name -contains 'parent_task_id' -and [string]$liveObj.parent_task_id) { $parentHits++ }
    foreach ($f in $candFiles) {
        $rel = 'contracts/candidates/' + $f.Name
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        $candObj = Get-JsonObject $f.FullName
        Test-CandidateJson $State $rel $candObj $stem $liveTid $WorkspaceRoot
        if ($candObj -and $candObj.PSObject.Properties.Name -contains 'parent_task_id' -and [string]$candObj.parent_task_id) { $parentHits++ }
    }
    if ($parentHits -gt 1) { Add-CheckError $State 'CANDIDATE' 'at most one interrupt packet' }
}

$targetsDir = Join-Path $WorkspaceRoot 'targets'
if (Test-Path -LiteralPath $targetsDir) {
    Get-ChildItem -LiteralPath $targetsDir -Filter '*.json' -File | ForEach-Object {
        $rel = 'targets/' + $_.Name
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        Test-TargetJson $State $rel (Get-JsonObject $_.FullName) $stem
    }
}

Get-ChildItem -LiteralPath (Join-Path $WorkspaceRoot 'profiles') -Filter '*.md' -File | Where-Object {
    $_.Name -ne '_index.md' -and $_.Name -ne '_template.md'
} | ForEach-Object {
    $pf = Get-FieldMap (Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8)
    Test-FieldBudget $State ('profiles/' + $_.Name) $pf @('module_id', 'module_name', 'profile_status', 'allowed_write') 10
}

if (Test-Path -LiteralPath (Join-Path $WorkspaceRoot 'tools')) {
    Add-CheckError $State 'DIR_STALE' 'tools/ must not exist; use runtime/'
}

$runtimeDir = Join-Path $WorkspaceRoot 'runtime'
$registered = @{}
$runtimeIndexPath = Join-Path $runtimeDir '_index.md'
if (Test-Path -LiteralPath $runtimeIndexPath) {
    [regex]::Matches((Get-Content -LiteralPath $runtimeIndexPath -Raw -Encoding UTF8), '\[[^\]]*\]\(([^)]+\.(ps1|py))\)') | ForEach-Object {
        $registered[([System.IO.Path]::GetFileName($_.Groups[1].Value))] = $true
    }
}
if (Test-Path -LiteralPath $runtimeDir) {
    Get-ChildItem -LiteralPath $runtimeDir -Recurse -File | Where-Object { $_.Extension -match '^\.(ps1|py)$' } | ForEach-Object {
        $rel = $_.FullName.Substring($WorkspaceRoot.Length).TrimStart('\', '/').Replace('\', '/')
        if (-not $registered.Contains($_.Name)) { Add-CheckError $State 'TOOL_UNREG' ($rel + ' not listed in runtime/_index.md') }
        Test-ToolFileSize $State $rel (Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8)
    }
}
Get-ChildItem -LiteralPath $WorkspaceRoot -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '^\.(ps1|py)$' } | ForEach-Object {
    Add-CheckError $State 'TOOL_UNREG' ($_.Name + ' must live under runtime/ and be indexed')
}

Write-Host ('ET81 runtime check @ ' + $WorkspaceRoot)
Write-Host ('Errors: ' + $State.Errors.Count + ' Warnings: ' + $State.Warnings.Count)
$State.Warnings | ForEach-Object { Write-Host ('WARN  ' + $_) }
$State.Errors | ForEach-Object { Write-Host ('ERROR ' + $_) }
if ($State.Errors.Count -gt 0) { exit 1 }
if ($Strict -and $State.Warnings.Count -gt 0) { exit 2 }
exit 0
