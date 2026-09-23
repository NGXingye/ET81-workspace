param(
    [Parameter(Position = 0)]
    [ValidateSet('check', 'status', 'packet', 'begin-implement', 'promote', 'interrupt')]
    [string]$Command = 'check',
    [Parameter(Position = 1)]
    [string]$TaskId,
    [switch]$Strict
)
$ErrorActionPreference = 'Stop'
$RuntimeRoot = $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $RuntimeRoot

function Get-MdFields([string]$Rel) {
    $path = Join-Path $WorkspaceRoot $Rel
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    . (Join-Path $RuntimeRoot 'check-helpers.ps1')
    return Get-FieldMap (Get-Content -LiteralPath $path -Raw -Encoding UTF8)
}

function Get-JsonFile([string]$Rel) {
    $path = Join-Path $WorkspaceRoot $Rel
    if (-not (Test-Path -LiteralPath $path)) { return $null }
    return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json)
}

function Write-PacketError([string]$Msg) {
    [ordered]@{ ok = $false; error = $Msg } | ConvertTo-Json -Compress:$false
    exit 1
}

switch ($Command) {
    'check' {
        $check = Join-Path $RuntimeRoot 'check-workspace.ps1'
        if ($Strict) { & $check -Strict } else { & $check }
        exit $LASTEXITCODE
    }
    'status' {
        $cursor = Get-MdFields 'project_cursor.md'
        $contract = Get-MdFields 'contracts/current.md'
        $scope = Get-JsonFile 'contracts/current_scope.json'
        $payload = [ordered]@{
            workspace_root  = $WorkspaceRoot
            task_id         = $(if ($cursor) { $cursor['task_id'] } else { $null })
            task_status     = $(if ($cursor) { $cursor['task_status'] } else { $null })
            contract_status = $(if ($contract) { $contract['contract_status'] } else { $null })
            active_profile  = $(if ($cursor) { $cursor['active_profile'] } else { $null })
            phase           = $(if ($scope) { $scope.phase } else { $null })
            scope_revision  = $(if ($scope) { $scope.scope_revision } else { $null })
            target_id       = $(if ($scope) { $scope.target_id } else { $null })
            intent          = $(if ($scope) { $scope.intent } else { $null })
            size            = $(if ($scope) { $scope.size } else { $null })
            route           = $(if ($scope) { $scope.route } else { $null })
        }
        $cands = @()
        $candDir = Join-Path $WorkspaceRoot 'contracts/candidates'
        if (Test-Path -LiteralPath $candDir) {
            Get-ChildItem -LiteralPath $candDir -Filter '*.json' -File | ForEach-Object {
                $o = Get-JsonFile ('contracts/candidates/' + $_.Name)
                if ($o) {
                    $cands += [ordered]@{
                        task_id = [string]$o.task_id
                        phase   = [string]$o.phase
                        goal    = $(if ($o.goal) { [string]$o.goal } else { '' })
                    }
                }
            }
        }
        $payload['candidates'] = $cands
        $payload | ConvertTo-Json -Compress:$false -Depth 5
        exit 0
    }
    'packet' {
        $contract = Get-MdFields 'contracts/current.md'
        $scope = Get-JsonFile 'contracts/current_scope.json'
        if (-not $contract -or -not $scope) { Write-PacketError 'missing current.md or current_scope.json' }
        if ([string]$contract['contract_status'] -ne 'active') { Write-PacketError 'contract must be active' }
        if ([string]$scope.phase -ne 'implement') { Write-PacketError 'phase must be implement' }
        $writes = @($scope.write_paths)
        if ($writes.Count -eq 0) { Write-PacketError 'write_paths empty' }
        $plan = @()
        if ($scope.PSObject.Properties.Name -contains 'plan' -and $null -ne $scope.plan) { $plan = @($scope.plan) }
        if ($plan.Count -eq 0) { Write-PacketError 'plan empty; discovery must write change steps' }
        $tid = [string]$scope.target_id
        if (-not $tid -or $tid -eq 'none') { Write-PacketError 'target_id required' }
        $target = Get-JsonFile ('targets/' + $tid + '.json')
        if (-not $target) { Write-PacketError ('missing targets/' + $tid + '.json') }
        $ops = @($scope.edit_ops)
        $valid = @($scope.validation)
        $reads = @($scope.read_paths)
        if ($reads.Count -eq 0) { $reads = $writes }
        $round = 1
        if ($scope.PSObject.Properties.Name -contains 'implement_round') { $round = [int]$scope.implement_round }
        if ($round -lt 1) { $round = 1 }
        if ($round -gt 3) { Write-PacketError 'implement_round max 3; set phase blocked' }
        $fb = @()
        if ($scope.PSObject.Properties.Name -contains 'verify_feedback') { $fb = @($scope.verify_feedback) }
        $forbidden = @()
        if ($target.PSObject.Properties.Name -contains 'forbidden') { $forbidden = @($target.forbidden) }
        $payload = [ordered]@{
            ok               = $true
            task_id          = [string]$scope.task_id
            goal             = [string]$contract['goal']
            target_id        = $tid
            workspace_path   = [string]$target.workspace_path
            vcs              = [string]$target.vcs
            forbidden        = $forbidden
            profile_id       = $(if ($scope.profile_id) { [string]$scope.profile_id } else { 'none' })
            intent           = [string]$scope.intent
            size             = [string]$scope.size
            scope_revision   = [int]$scope.scope_revision
            implement_round  = $round
            edit_ops         = $ops
            read_paths       = $reads
            write_paths      = $writes
            plan             = $plan
            validation       = $valid
            verify_feedback  = $fb
            acceptance       = $(if ($contract['acceptance']) { [string]$contract['acceptance'] } else { '' })
        }
        if ($contract['out_of_scope']) { $payload['out_of_scope'] = [string]$contract['out_of_scope'] }
        $ev = @()
        if ($scope.PSObject.Properties.Name -contains 'evidence') { $ev = @($scope.evidence) }
        if ($ev.Count -gt 0) { $payload['evidence'] = $ev }
        $payload | ConvertTo-Json -Compress:$false -Depth 6
        exit 0
    }
    'begin-implement' {
        & (Join-Path $RuntimeRoot 'begin-implement.ps1')
        exit $LASTEXITCODE
    }
    'promote' {
        if (-not $TaskId) {
            [ordered]@{ ok = $false; error = 'task_id required' } | ConvertTo-Json -Compress:$false
            exit 1
        }
        & (Join-Path $RuntimeRoot 'promote.ps1') -TaskId $TaskId
        exit $LASTEXITCODE
    }
    'interrupt' {
        if (-not $TaskId) {
            [ordered]@{ ok = $false; error = 'task_id required' } | ConvertTo-Json -Compress:$false
            exit 1
        }
        & (Join-Path $RuntimeRoot 'interrupt.ps1') -TaskId $TaskId
        exit $LASTEXITCODE
    }
}
