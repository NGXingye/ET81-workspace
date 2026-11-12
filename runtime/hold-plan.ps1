# Non-entry. Invoked by etctl.ps1 hold-plan / restore-plan. No SVN.
# hold merges pending units into the same module id and keeps its blocker. restore does not rebuild a commit plan.
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
function Read-Json([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { Write-HoldError ('missing ' + $Path) }
    return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json)
}
function Json-Str([string]$Text) {
    if ($null -eq $Text) { $Text = '' }
    $Text = $Text.Replace('\', '\\').Replace('"', '\"').Replace("`r", '').Replace("`n", '\n').Replace("`t", '\t')
    return '"' + $Text + '"'
}
function Format-EmptyPlan {
    return "{`n  `"task_id`": `"none`",`n  `"summary`": `"`",`n  `"units`": []`n}`n"
}
function Workspace-Key([string]$Workspace) {
    return ([string]$Workspace).Replace('/', '\').Trim().TrimEnd('\').ToLowerInvariant()
}
function Get-TargetId([string]$Workspace) {
    $want = Workspace-Key $Workspace
    $dir = Join-Path $WorkspaceRoot 'targets'
    foreach ($file in (Get-ChildItem -LiteralPath $dir -Filter '*.json' -File)) {
        $target = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ((Workspace-Key ([string]$target.workspace_path)) -eq $want) { return [string]$target.target_id }
    }
    return 'unknown'
}
function Read-Modules($Held) {
    if ($Held.PSObject.Properties.Name -contains 'task_id' -and -not ($Held.PSObject.Properties.Name -contains 'modules')) {
        Write-HoldError 'held file is still a commit plan; migrate it before hold'
    }
    $list = New-Object System.Collections.Generic.List[object]
    $mods = @()
    if ($Held.PSObject.Properties.Name -contains 'modules' -and $null -ne $Held.modules) { $mods = @($Held.modules) }
    foreach ($m in $mods) {
        if (-not $m) { continue }
        $paths = @()
        if ($m.paths) { $paths = @($m.paths | ForEach-Object { [string]$_ }) }
        $list.Add([ordered]@{
            id = [string]$m.id
            target_id = [string]$m.target_id
            workspace_path = [string]$m.workspace_path
            paths = $paths
            intent = [string]$m.intent
            blocker = [string]$m.blocker
            source_task = [string]$m.source_task
        })
    }
    return ,$list
}
function Format-Held($Modules) {
    $blocks = New-Object System.Collections.Generic.List[string]
    foreach ($m in $Modules) {
        $pathLines = @($m.paths | ForEach-Object { '        ' + (Json-Str $_) })
        $pathBody = if ($pathLines.Count -eq 0) { '' } else { ($pathLines -join ",`n") + "`n      " }
        $blocks.Add(@"
    {
      "id": $(Json-Str $m.id),
      "target_id": $(Json-Str $m.target_id),
      "workspace_path": $(Json-Str $m.workspace_path),
      "paths": [
$pathBody],
      "intent": $(Json-Str $m.intent),
      "blocker": $(Json-Str $m.blocker),
      "source_task": $(Json-Str $m.source_task)
    }
"@)
    }
    $body = if ($blocks.Count -eq 0) { '' } else { ($blocks -join ",`n") + "`n" }
    return "{`n  `"modules`": [`n$body  ]`n}`n"
}
function Path-Key([string]$Workspace, [string]$Rel) {
    $rel = ([string]$Rel).Replace('\', '/').Trim().ToLowerInvariant()
    return ((Workspace-Key $Workspace) + '|' + $rel)
}
function Add-UniquePath($List, [string]$Workspace, [string]$Rel) {
    if (-not $Rel) { return }
    $key = Path-Key $Workspace $Rel
    foreach ($got in $List) { if ((Path-Key $Workspace ([string]$got)) -eq $key) { return } }
    $List.Add($Rel)
}
function Get-LocalOnly([string]$Workspace) {
    $want = Workspace-Key $Workspace
    $dir = Join-Path $WorkspaceRoot 'targets'
    foreach ($file in (Get-ChildItem -LiteralPath $dir -Filter '*.json' -File)) {
        $target = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        if ((Workspace-Key ([string]$target.workspace_path)) -ne $want) { continue }
        $list = @()
        if ($target.local_only) { $list = @($target.local_only | ForEach-Object { ([string]$_).Replace('\', '/').ToLowerInvariant() }) }
        return ,$list
    }
    return ,@()
}
function Test-LocalOnly([string]$Workspace, [string]$Rel) {
    $key = ([string]$Rel).Replace('\', '/').Trim().ToLowerInvariant()
    foreach ($entry in (Get-LocalOnly $Workspace)) {
        $base = $entry.TrimEnd('/')
        if ($key -eq $base -or $key -eq ($base + '.meta')) { return $true }
        if ($entry.EndsWith('/') -and $key.StartsWith($entry)) { return $true }
    }
    return $false
}
function New-ModuleId([string]$TaskId, [string]$TargetId, [string]$Workspace, $Modules) {
    if ($TargetId -and $TargetId -ne 'unknown') { return $TaskId + '-' + $TargetId }
    $leaf = [System.IO.Path]::GetFileName($Workspace.TrimEnd('\', '/'))
    $leaf = ([regex]::Replace([string]$leaf, '[^A-Za-z0-9_-]', '')).ToLowerInvariant()
    if (-not $leaf) { $leaf = 'ws' }
    $base = $TaskId + '-unknown-' + $leaf
    $id = $base
    $n = 2
    $want = Workspace-Key $Workspace
    while ($true) {
        $clash = $false
        foreach ($m in $Modules) {
            if ([string]$m.id -eq $id -and (Workspace-Key ([string]$m.workspace_path)) -ne $want) { $clash = $true }
        }
        if (-not $clash) { return $id }
        $id = $base + '-' + $n
        $n++
    }
}

if ($Action -eq 'restore') {
    Write-HoldError 'held is a module index, not a commit plan; write commit_plan for the slice to commit, and remove those paths only after svn success'
}

$activePath = Join-Path $WorkspaceRoot 'contracts/commit_plan.json'
$heldPath = Join-Path $WorkspaceRoot 'contracts/held_commit_plan.json'
$active = Read-Json $activePath
$held = Read-Json $heldPath
$units = @()
if ($active.PSObject.Properties.Name -contains 'units' -and $null -ne $active.units) { $units = @($active.units) }
$pending = @($units | Where-Object { $_ -and [string]$_.status -ne 'committed' })
if ($pending.Count -eq 0) { Write-HoldError 'active commit plan has no pending units; nothing to hold' }
$taskId = [string]$active.task_id
if (-not $taskId -or $taskId -eq 'none') { Write-HoldError 'active commit plan needs a task_id' }
$modules = Read-Modules $held
$summary = [string]$active.summary
$groups = @{}
foreach ($u in $pending) {
    $ws = Workspace-Key ([string]$u.workspace_path)
    if (-not $groups.ContainsKey($ws)) { $groups[$ws] = New-Object System.Collections.Generic.List[object] }
    $groups[$ws].Add($u)
}
$ids = New-Object System.Collections.Generic.List[string]
foreach ($ws in @($groups.Keys)) {
    $tid = Get-TargetId $ws
    $id = New-ModuleId $taskId $tid $ws $modules
    if ($tid -ne 'unknown') {
        foreach ($m in $modules) {
            if ([string]$m.id -eq $id -and (Workspace-Key ([string]$m.workspace_path)) -ne (Workspace-Key $ws)) {
                Write-HoldError ('held module ' + $id + ' belongs to another workspace')
            }
        }
    }
    $paths = New-Object System.Collections.Generic.List[string]
    $titles = New-Object System.Collections.Generic.List[string]
    foreach ($u in $groups[$ws]) {
        $titles.Add([string]$u.title)
        foreach ($rel in @($u.paths)) {
            $text = [string]$rel
            if ($text -and -not (Test-LocalOnly $ws $text) -and -not $paths.Contains($text)) { $paths.Add($text) }
        }
    }
    if ($paths.Count -eq 0) { continue }
    $keys = @{}
    foreach ($rel in $paths) { $keys[(Path-Key $ws $rel)] = $true }
    foreach ($m in $modules) {
        $same = ([string]$m.id -eq $id) -and ((Workspace-Key ([string]$m.workspace_path)) -eq (Workspace-Key $ws))
        if ($same) { continue }
        foreach ($rel in @($m.paths)) {
            if ($keys.ContainsKey((Path-Key ([string]$m.workspace_path) ([string]$rel)))) {
                Write-HoldError ('path overlap with held module ' + $m.id + ': ' + $rel)
            }
        }
    }
    $merged = New-Object System.Collections.Generic.List[string]
    $blocker = ''
    $source = $taskId
    $workspace = $ws
    $intent = $summary
    if ($titles.Count -gt 0) { $intent = $summary + '；' + ($titles -join '；') }
    $at = -1
    for ($i = 0; $i -lt $modules.Count; $i++) {
        if ([string]$modules[$i].id -ne $id) { continue }
        if ((Workspace-Key ([string]$modules[$i].workspace_path)) -ne (Workspace-Key $ws)) { continue }
        $old = $modules[$i]
        $at = $i
        $workspace = [string]$old.workspace_path
        foreach ($rel in @($old.paths)) {
            if (Test-LocalOnly ([string]$old.workspace_path) ([string]$rel)) { continue }
            Add-UniquePath $merged ([string]$old.workspace_path) ([string]$rel)
        }
        if ([string]$old.blocker) { $blocker = [string]$old.blocker }
        if ([string]$old.intent) { $intent = [string]$old.intent }
        if ([string]$old.source_task) { $source = [string]$old.source_task }
        break
    }
    foreach ($rel in $paths) { Add-UniquePath $merged $ws ([string]$rel) }
    if ($merged.Count -eq 0) {
        if ($at -ge 0) { $modules.RemoveAt($at) }
        continue
    }
    if ($at -ge 0) {
        foreach ($title in $titles) {
            if ($title -and $intent.IndexOf([string]$title) -lt 0) { $intent = $intent + '；' + [string]$title }
        }
        if ($summary -and $intent.IndexOf($summary) -lt 0) { $intent = $intent + '；' + $summary }
    }
    $fresh = [ordered]@{
        id = $id
        target_id = $tid
        workspace_path = $workspace
        paths = @($merged)
        intent = $intent
        blocker = $blocker
        source_task = $source
    }
    if ($at -ge 0) { $modules[$at] = $fresh } else { $modules.Add($fresh) }
    $ids.Add($id)
}
Write-Utf8 $heldPath (Format-Held $modules)
Write-Utf8 $activePath (Format-EmptyPlan)
[ordered]@{ ok = $true; action = 'hold'; source_task = $taskId; modules = @($ids) } | ConvertTo-Json -Compress:$false
exit 0
