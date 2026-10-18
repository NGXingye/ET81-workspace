param([switch]$DryRun)
# Non-entry. Invoked by etctl.ps1 sync-ignores. Adds every target local_only name (and its .meta) to the
# machine svn global-ignores, which svn CLI and TortoiseSVN both read. Keeps existing tokens, backs up first. No svn calls.
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot
. (Join-Path $RuntimeRoot 'check-helpers.ps1')
. (Join-Path $RuntimeRoot 'boundary.ps1')

$path = Get-SvnConfigPath
if (-not (Test-Path -LiteralPath $path)) { throw ('missing ' + $path + '; run any svn command once to create it') }
$text = [System.IO.File]::ReadAllText($path)
$nl = "`n"
if ($text.Contains("`r`n")) { $nl = "`r`n" }
$lines = [System.Collections.Generic.List[string]]::new()
[void]$lines.AddRange([string[]]($text -split "`r?`n", -1))
$found = Find-GlobalIgnores $lines.ToArray()
$tokens = @($found.Tokens)
$add = @(Get-LocalOnlyNames $WorkspaceRoot | Where-Object { $tokens -cnotcontains $_ })
if ($add.Count -eq 0) { Write-Output ('in sync: ' + $path); exit 0 }
$newLine = 'global-ignores = ' + (($tokens + $add) -join ' ')
Write-Output ('add: ' + ($add -join ' '))
if ($found.Index -ge 0) { Write-Output ('- ' + $lines[$found.Index]) }
Write-Output ('+ ' + $newLine)
if ($DryRun) { Write-Output 'dry run, not written'; exit 0 }

if ($found.Index -ge 0) { $lines[$found.Index] = $newLine }
elseif ($found.Header -ge 0) { $lines.Insert($found.Header + 1, $newLine) }
else { $lines.Add('[miscellany]'); $lines.Add($newLine) }
$backup = $path + '.bak-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
Copy-Item -LiteralPath $path -Destination $backup
[System.IO.File]::WriteAllText($path, ($lines -join $nl), (New-Object System.Text.UTF8Encoding $false))
Write-Output ('written: ' + $path)
Write-Output ('backup: ' + $backup)
exit 0
