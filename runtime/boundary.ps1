# Non-entry. Dot-sourced after check-helpers.ps1 by check-workspace.ps1, begin-implement.ps1, sync-svn-ignores.ps1.
# Boundary data: target JSON and local_only, machine svn global-ignores, profile allowed_write prefix menu.
# Policy text lives in targets/_index.md and profiles/_index.md. No svn calls and no file writes here.

# Flip to $true to refuse write_paths outside profile prefixes (begin-implement error, check ERROR).
$script:ProfilePrefixStrict = $false
$script:SvnDefaultIgnores = @('*.o', '*.lo', '*.la', '*.al', '.libs', '*.so', '*.so.[0-9]*', '*.a', '*.pyc', '*.pyo', '__pycache__', '*.rej', '*~', '#*#', '.#*', '.*.swp', '.DS_Store', '[Tt]humbs.db')

function Test-TargetJson([hashtable]$State, [string]$Rel, $Obj, [string]$ExpectId) {
    if (-not (Test-RequiredJsonProps $State 'TARGET_JSON' $Rel $Obj @('target_id', 'display_name', 'workspace_path', 'vcs', 'editor'))) { return }
    if ([string]$Obj.target_id -ne $ExpectId) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' target_id must match file stem') }
    if (@('svn', 'git') -notcontains [string]$Obj.vcs -or @('unity', 'other') -notcontains [string]$Obj.editor) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' invalid vcs/editor') }
    foreach ($h in @($Obj.hook_tasks | Where-Object { $null -ne $_ })) {
        if ([string]$h.id -notmatch '^\d+$' -or -not [string]$h.for) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' hook_tasks need digit id and for') }
    }
    $ws = [string]$Obj.workspace_path
    if (-not (Test-Path -LiteralPath $ws)) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' workspace_path missing'); return }
    foreach ($p in @($Obj.local_only | Where-Object { $null -ne $_ })) {
        $s = [string]$p
        if (-not $s -or [System.IO.Path]::IsPathRooted($s) -or $s.Contains('*')) { Add-CheckError $State 'TARGET_JSON' ($Rel + ' local_only must be relative, no wildcards: ' + $s) }
        elseif (-not (Test-Path -LiteralPath (Join-Path $ws $s))) { Add-CheckWarning $State 'TARGET_JSON' ($Rel + ' local_only not on disk: ' + $s) }
    }
}

function Get-TargetObjects([string]$WorkspaceRoot) {
    $dir = Join-Path $WorkspaceRoot 'targets'
    if (-not (Test-Path -LiteralPath $dir)) { return }
    Get-ChildItem -LiteralPath $dir -Filter '*.json' -File | ForEach-Object { Get-JsonObject $_.FullName } | Where-Object { $_ }
}

function Get-LocalOnlyNames([string]$WorkspaceRoot) {
    # svn global-ignores matches names only: file or folder name, plus its Unity .meta.
    $names = New-Object System.Collections.Generic.List[string]
    foreach ($t in @(Get-TargetObjects $WorkspaceRoot)) {
        foreach ($p in @($t.local_only | Where-Object { $_ })) {
            $leaf = Split-Path -Leaf ([string]$p).TrimEnd('/', '\')
            foreach ($n in @($leaf, ($leaf + '.meta'))) { if (-not $names.Contains($n)) { $names.Add($n) } }
        }
    }
    return $names.ToArray()
}

function Get-SvnConfigPath { return (Join-Path $env:APPDATA 'Subversion\config') }

function Find-GlobalIgnores([string[]]$Lines) {
    # Only an uncommented global-ignores inside [miscellany] counts; none means svn defaults.
    $r = @{ Header = -1; Index = -1; Tokens = $script:SvnDefaultIgnores }
    $sec = ''
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\s*\[([^\]]+)\]') { $sec = $Matches[1]; if ($sec -eq 'miscellany') { $r.Header = $i }; continue }
        if ($sec -eq 'miscellany' -and $Lines[$i] -match '^global-ignores\s*=(.*)$') {
            $r.Index = $i
            $r.Tokens = @($Matches[1].Trim() -split '\s+' | Where-Object { $_ })
            break
        }
    }
    return $r
}

function Test-IgnoreDrift([hashtable]$State, [string]$WorkspaceRoot) {
    $names = @(Get-LocalOnlyNames $WorkspaceRoot)
    if ($names.Count -eq 0) { return }
    $path = Get-SvnConfigPath
    $have = $script:SvnDefaultIgnores
    if (Test-Path -LiteralPath $path) { $have = (Find-GlobalIgnores ([System.IO.File]::ReadAllLines($path))).Tokens }
    $miss = @($names | Where-Object { $have -cnotcontains $_ })
    if ($miss.Count -gt 0) { Add-CheckWarning $State 'IGNORE_DRIFT' ('svn global-ignores missing ' + ($miss -join ' ') + '; run etctl sync-ignores') }
}

function Resolve-BoundaryPath([string]$Path, [string]$Base) {
    $p = $Path.Trim()
    $isDir = $p -match '[\\/]$'
    if (-not [System.IO.Path]::IsPathRooted($p)) { $p = Join-Path $Base $p }
    $full = [System.IO.Path]::GetFullPath($p).TrimEnd('\')
    if ($isDir) { $full += '\' }
    return $full
}

function Get-WritesOutsideProfile([string]$WorkspaceRoot, $Scope, [string]$ProfileId) {
    # Relative entries resolve against the scope target workspace_path; absolute ones cover other projects.
    $pf = Join-Path $WorkspaceRoot ('profiles/' + $ProfileId + '.md')
    $target = Get-JsonObject (Join-Path $WorkspaceRoot ('targets/' + [string]$Scope.target_id + '.json'))
    if (-not $ProfileId -or -not (Test-Path -LiteralPath $pf) -or -not $target) { return }
    $menu = [string](Get-FieldMap (Get-Content -LiteralPath $pf -Raw -Encoding UTF8))['allowed_write']
    if (-not $menu -or $menu -eq 'workspace_only') { return }
    $base = [string]$target.workspace_path
    $prefixes = @($menu -split ';' | Where-Object { $_.Trim() } | ForEach-Object { Resolve-BoundaryPath $_ $base })
    foreach ($w in @($Scope.write_paths | Where-Object { $_ })) {
        $full = Resolve-BoundaryPath ([string]$w) $base
        $hit = @($prefixes | Where-Object { $full.Equals($_, [System.StringComparison]::OrdinalIgnoreCase) -or ($_.EndsWith('\') -and $full.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase)) })
        if ($hit.Count -eq 0) { [string]$w }
    }
}

function Test-ProfileMenu([hashtable]$State, [string]$WorkspaceRoot, $Scope, [string]$ProfileId) {
    $out = @(Get-WritesOutsideProfile $WorkspaceRoot $Scope $ProfileId)
    if ($out.Count -eq 0) { return }
    $msg = 'write_paths outside profiles/' + $ProfileId + '.md allowed_write: ' + ($out -join '; ')
    if ($script:ProfilePrefixStrict) { Add-CheckError $State 'PROFILE_MENU' $msg } else { Add-CheckWarning $State 'PROFILE_MENU' $msg }
}
