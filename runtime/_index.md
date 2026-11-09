> 最新修改时间：2026-11-09 14:25 UTC+8
> 版本号：2.30.0
> 文档状态：生效
> 读取等级：L1（新增或修改 runtime 下脚本前必读）

# 0. 职责定位

本文件登记 `runtime/` 内允许存在的脚本与 schema。未出现在本表中的 `.ps1` / `.py` **禁止存在**。

写法见 [`../global_rules/runtime_code.md`](../global_rules/runtime_code.md)。不得替代 [`../global_rules/code_governance.md`](../global_rules/code_governance.md) 的 SVN 授权规则。

# 1. 文件索引

- [`etctl.ps1`](./etctl.ps1)  
  职责：运行时调度入口（`check`、`status`、`packet`、`begin-implement`、`promote`、`interrupt`、`guard`、`idle`、`sync-ignores`、`hold-plan`、`restore-plan`、`next-id`）。  
  副作用：不调 svn；`sync-ignores` 只写本机 svn 配置（先备份）。`packet` 只读导出活卡工作令。`begin-implement` 只升活卡。`promote <task_id>` 仅 idle 时把候选写入活卡。`interrupt <task_id>` 把活卡勾进 candidates，新号升活卡。这两条和 `idle` 写完后重写候选索引的候选行。  
  入口：`powershell -File runtime/etctl.ps1 <command> [<task_id>]`
- [`begin-implement.ps1`](./begin-implement.ps1)  
  职责：把活卡升到 implement，再导出 packet。`write_paths` 越出 profile `allowed_write` 前缀时警告。  
  副作用：写游标、`current.md`、`current_scope.json`。无 SVN。  
  非独立入口，由 `etctl.ps1 begin-implement` 调用。
- [`promote.ps1`](./promote.ps1)  
  职责：活卡 idle 时把候选写入活卡。带 `parent_task_id` 的包拒绝。`parked` 包按原阶段提回（含 implement）。**活动槽** `commit_plan.json` 还有未交笔则拒绝（可先 `etctl hold-plan` 暂留）；每笔都已提交则先把活动槽重置为空。`held_commit_plan.json` **不挡** promote。  
  副作用：写游标、`current.md`、`current_scope.json`、候选索引候选行；可能重置提交计划；删除候选 JSON。无 SVN。  
  非独立入口，由 `etctl.ps1 promote` 调用。
- [`interrupt.ps1`](./interrupt.ps1)  
  职责：把活卡（discovery/awaiting_scope/implement/awaiting_verify）勾进 candidates，新号升活卡并写 `resume_task_id`。  
  副作用：写游标、`current.md`、`current_scope.json`、候选 JSON、候选索引候选行。无 SVN。  
  非独立入口，由 `etctl.ps1 interrupt` 调用。
- [`candidate-index.ps1`](./candidate-index.ps1)  
  职责：按候选目录里的 JSON 和游标 `task_id` 重写 `contracts/candidates/_index.md` 的候选行与版头时间。不升版本号。摘要取 `goal` 第一句，勾回的包带「勾回」。  
  副作用：写该索引。无 SVN。  
  非独立入口，由 `promote.ps1`、`interrupt.ps1`、`idle.ps1` dot-source。`.cursor/hooks/sync-candidate-index.ps1` 在候选 JSON 写入或删除后调用。机检调用其中的对照函数。
- [`check-workspace.ps1`](./check-workspace.ps1)  
  职责：机检实现（文档、游标、契约、JSON 范围、候选包、知识索引、脚本登记与体积）。知识索引检查：`standards/_index.md` 的链接都存在，且每个 `profiles/<id>.md` 都被某张 `standards/<模块>.md` 点名。边界：目标 `local_only` 不在本机 svn global-ignores 里（`IGNORE_DRIFT`）、`write_paths` 越出 profile 前缀（`PROFILE_MENU`）时警告。  
  副作用：无。非独立入口，由 `etctl.ps1 check` 调用。
- [`check-helpers.ps1`](./check-helpers.ps1)  
  职责：机检函数库（版头、键值、行数、JSON、基线 Unity 版本（读 `standards/framework.md`）、候选包、知识索引）。  
  副作用：无。非独立入口，由 `check-workspace.ps1`、`begin-implement.ps1`、`promote.ps1`、`interrupt.ps1` dot-source。
- [`boundary.ps1`](./boundary.ps1)  
  职责：边界函数库（目标 JSON 与 `local_only` 校验、本地专用名单、本机 svn `global-ignores` 解析、profile 前缀菜单比对）。`$script:ProfilePrefixStrict` 改为 `$true` 则越出前缀由警告变为拒绝。  
  副作用：无。非独立入口，由 `check-workspace.ps1`、`begin-implement.ps1`、`sync-svn-ignores.ps1` dot-source。
- [`sync-svn-ignores.ps1`](./sync-svn-ignores.ps1)  
  职责：把所有目标 `local_only` 的文件名或目录名（连同 `.meta`）补进本机 `%APPDATA%\Subversion\config` 的 `global-ignores`（TortoiseSVN 同读）；已有记号保留，只补缺的。`-DryRun` 只打印差异。  
  副作用：写该配置，写前备份为 `config.bak-<时间>`。不调 svn。  
  非独立入口，由 `etctl.ps1 sync-ignores [-DryRun]` 调用。
- [`hold-plan.ps1`](./hold-plan.ps1)  
  职责：`hold` 把活动槽未交笔按目标合并进同编号模块（路径取并集，保留原阻碍）并清空活动槽。未登记目标按工作副本目录名分开编号，不共用 `unknown`。同一路径已在别的模块则拒绝。`restore` 不把索引还原成提交计划。  
  副作用：只写两个计划 JSON。无 SVN。  
  非独立入口，由 `etctl.ps1 hold-plan` / `restore-plan` 调用。
- [`next-id.ps1`](./next-id.ps1)  
  职责：只读算出下一活卡号。占用集 = `task_outcomes` ∪ 活卡（游标/契约/scope）∪ 候选文件名 ∪ `commit_plan` 的 `task_id` ∪ held 模块 `source_task`（跳过 `none`）；取 `t`+数字最大号 +1，三位补零。  
  副作用：无。非独立入口，由 `etctl.ps1 next-id` 调用。
- [`commit-units.py`](./commit-units.py)  
  职责：命令行列出每笔，输入编号回车提交，已提交变灰并留在窗口。`--unit` 只交点名的那一笔。`--held` 直接拒绝。路径命中目标 `local_only`（含 `.meta`）直接拒绝；未入库路径遇 svn `I` 拒绝，否则先 `svn add`。只检查正在交的那一笔是否还在 held：窗口确认后才提交，成功后划掉正好对上的文件；非交互遇重叠须 `--extract`。失败不改 held。说明写入 UTF-8 文件再 `svn commit -F --encoding utf-8`。  
  副作用：可 `svn add` 并 `svn commit` 该笔路径。无 `--all`。`--dry-run` 不提交、不核销。  
  入口：双击仓库根目录 `commit.cmd`。模型用 `py -3 runtime/commit-units.py --unit <id>`。窗口里 `r` 重新读取计划，`v` 验证 `Unity/Assets/Scripts` 是否还有漏提交或已标注文件。
- [`idle.ps1`](./idle.ps1)  
  职责：把活卡收成空闲。scope、游标任务段、契约一次写回最小形态。已是空闲则不写文件。不写版本历史。不删提交计划、不删候选、不 svn、不 promote。有 `resume_task_id` 时打印后清掉。收成空闲后重写候选索引的候选行。收口账超过 125 行时删最旧的行留 100 行，活卡、`current.md` 与候选包（`task_id`/`parent_task_id`/`resume_task_id`）引用的号不删。  
  非独立入口，由 `etctl.ps1 idle` 调用。
- [`guard.ps1`](./guard.ps1)  
  职责：源码写入门禁。`etctl guard <path>` 在写 `source_root` 或任一目标 `workspace_path` 下的文件前判定；不通过则退出码 2。不写文件、无 SVN。规则见 `global_rules/runtime_code.md`。  
  入口：`powershell -File runtime/etctl.ps1 guard <path>`。Cursor 钩子 `.cursor/hooks/guard-source.ps1` 在写工具和会改文件的 shell 前调用本脚本。
- [`check-commit-plan.py`](./check-commit-plan.py)  
  职责：用 `svn status --xml` 对照 `Unity/Assets/Scripts` 和提交计划。`--fill` 把与计划新增符号有交集、且不在 held 的漏文件补进未提交笔，没有交集的写入 `omitted`。held 按工作区匹配：无交集视同已覆盖，有交集不补进、不写入 `omitted`。`--fill` 与 `--verify` 遇到「暂留相交」退出码都为 1。  
  副作用：`--fill` 写 `contracts/commit_plan.json`。不 `svn commit`。  
  入口：`py -3 runtime/check-commit-plan.py --fill` 或 `--verify`。
- [`held_paths.py`](./held_paths.py)  
  职责：按工作区匹配 held 模块路径。目录项覆盖其下文件。`strike` 只划掉正好对上的文件，目录项保留并提示改成剩余文件列表。  
  副作用：`strike` 写 `contracts/held_commit_plan.json`。无 SVN。  
  非独立入口，由 `commit-units.py` 与 `check-commit-plan.py` 调用。
- [`schema/target.schema.json`](./schema/target.schema.json)  
  职责：`targets/<id>.json` 的字段契约。
- [`schema/current_scope.schema.json`](./schema/current_scope.schema.json)  
  职责：活卡 scope 与候选分析包的字段契约（候选另需 `goal`）。
- [`schema/commit_plan.schema.json`](./schema/commit_plan.schema.json)  
  职责：活动槽 `contracts/commit_plan.json` 的字段契约。笔数以 10 为参考；一笔最多 8 个 `.cs`。`omitted` 记录不纳入的 Scripts 改动。
- [`schema/held_work.schema.json`](./schema/held_work.schema.json)  
  职责：`contracts/held_commit_plan.json` 的字段契约。按模块记本地未交工作，不记提交状态。

# 2. 版本历史

- 2.30.0（2026-11-09）：未登记工作副本分开编号；`--fill` 遇暂留相交退出码 1；`--dry-run` 不核销。
- 2.29.0（2026-11-09）：hold 合并保留阻碍；提交成功后才核销；符号相交只报告。新增 `held_paths.py`。
- 2.28.0（2026-11-07）：held 改为模块索引；`hold` 合入模块；`restore` 与 `--held` 不再当提交槽。
- 2.26.0（2026-10-28）：新增 `hold-plan`/`restore-plan` 与 `held_commit_plan.json`；promote 只拦活动槽；commit-units 支持 `--held`。
- 2.25.0（2026-10-18）：新增 `boundary.ps1`、`sync-svn-ignores.ps1`（`etctl sync-ignores`）；commit-units 按 `local_only` 拒绝；机检与 begin-implement 加边界警告。

