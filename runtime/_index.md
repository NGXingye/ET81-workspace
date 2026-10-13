> 最新修改时间：2026-10-13 16:40 UTC+8
> 版本号：2.19.0
> 文档状态：生效
> 读取等级：L1（新增或修改 runtime 下脚本前必读）

# 0. 职责定位

本文件登记 `runtime/` 内允许存在的脚本与 schema。未出现在本表中的 `.ps1` / `.py` **禁止存在**。

写法见 [`../global_rules/runtime_code.md`](../global_rules/runtime_code.md)。不得替代 [`../global_rules/code_governance.md`](../global_rules/code_governance.md) 的 SVN 授权规则。

# 1. 文件索引

- [`etctl.ps1`](./etctl.ps1)  
  职责：运行时调度入口（`check`、`status`、`packet`、`begin-implement`、`promote`、`interrupt`、`guard`、`idle`）。  
  副作用：无 SVN。`packet` 只读导出活卡工作令。`begin-implement` 只升活卡。`promote <task_id>` 仅 idle 时把候选写入活卡。`interrupt <task_id>` 把活卡勾进 candidates，新号升活卡。  
  入口：`powershell -File runtime/etctl.ps1 <command> [<task_id>]`
- [`begin-implement.ps1`](./begin-implement.ps1)  
  职责：把活卡升到 implement，再导出 packet。  
  副作用：写游标、`current.md`、`current_scope.json`。无 SVN。  
  非独立入口，由 `etctl.ps1 begin-implement` 调用。
- [`promote.ps1`](./promote.ps1)  
  职责：活卡 idle 时把候选写入活卡。带 `parent_task_id` 的包拒绝。`parked` 包按原阶段提回（含 implement）。提交计划还有未交笔则拒绝；每笔都已提交则先把 `commit_plan.json` 重置为空计划。  
  副作用：写游标、`current.md`、`current_scope.json`；可能重置提交计划；删除候选 JSON。无 SVN。  
  非独立入口，由 `etctl.ps1 promote` 调用。
- [`interrupt.ps1`](./interrupt.ps1)  
  职责：把活卡（discovery/awaiting_scope/implement/awaiting_verify）勾进 candidates，新号升活卡并写 `resume_task_id`。  
  副作用：写游标、`current.md`、`current_scope.json`、候选 JSON。无 SVN。  
  非独立入口，由 `etctl.ps1 interrupt` 调用。
- [`check-workspace.ps1`](./check-workspace.ps1)  
  职责：机检实现（文档、游标、契约、JSON 范围、候选包、脚本登记与体积）。  
  副作用：无。非独立入口，由 `etctl.ps1 check` 调用。
- [`check-helpers.ps1`](./check-helpers.ps1)  
  职责：机检函数库（版头、键值、行数、JSON、基线 Unity 版本、候选包）。  
  副作用：无。非独立入口，由 `check-workspace.ps1`、`begin-implement.ps1`、`promote.ps1`、`interrupt.ps1` dot-source。
- [`commit-units.py`](./commit-units.py)  
  职责：命令行列出每笔，输入编号回车提交，已提交变灰并留在窗口。`--unit` 只交点名的那一笔。未入库路径先 `svn add`，说明写入 UTF-8 文件再 `svn commit -F --encoding utf-8`。  
  副作用：可 `svn add` 并 `svn commit` 该笔路径。无 `--all`。`--dry-run` 不提交。  
  入口：双击仓库根目录 `commit.cmd`。模型用 `py -3 runtime/commit-units.py --unit <id>`。窗口里 `r` 重新读取计划，`v` 验证 `Unity/Assets/Scripts` 是否还有漏提交或已标注文件。
- [`idle.ps1`](./idle.ps1)  
  职责：把活卡收成空闲。scope、游标任务段、契约一次写回最小形态。已是空闲则不写文件。不写版本历史。不删提交计划、不删候选、不 svn、不 promote。有 `resume_task_id` 时打印后清掉。  
  非独立入口，由 `etctl.ps1 idle` 调用。
- [`guard.ps1`](./guard.ps1)  
  职责：源码写入门禁。`etctl guard <path>` 在写 `source_root` 或任一目标 `workspace_path` 下的文件前判定；不通过则退出码 2。不写文件、无 SVN。规则见 `global_rules/runtime_code.md`。  
  入口：`powershell -File runtime/etctl.ps1 guard <path>`。Cursor 钩子 `.cursor/hooks/guard-source.ps1` 在写工具和会改文件的 shell 前调用本脚本。
- [`check-commit-plan.py`](./check-commit-plan.py)  
  职责：用 `svn status --xml` 对照 `Unity/Assets/Scripts` 和提交计划。`--fill` 把与计划新增符号有交集的漏文件补进未提交笔，没有交集的写入 `omitted`。`--verify` 只提示，不改计划。  
  副作用：`--fill` 写 `contracts/commit_plan.json`。不 `svn commit`。  
  入口：`py -3 runtime/check-commit-plan.py --fill` 或 `--verify`。
- [`schema/target.schema.json`](./schema/target.schema.json)  
  职责：`targets/<id>.json` 的字段契约。
- [`schema/current_scope.schema.json`](./schema/current_scope.schema.json)  
  职责：活卡 scope 与候选分析包的字段契约（候选另需 `goal`）。
- [`schema/commit_plan.schema.json`](./schema/commit_plan.schema.json)  
  职责：`contracts/commit_plan.json` 的字段契约。笔数以 10 为参考；一笔最多 8 个 `.cs`。`omitted` 记录不纳入的 Scripts 改动。
- [`schema/map_entry.schema.json`](./schema/map_entry.schema.json)  
  职责：代码地图一行的字段契约（keyword/prefer/avoid/trust）。

# 2. 版本历史

- 2.19.0（2026-10-13）：提新活卡前，未交完的提交计划拒绝；交完则重置为空计划。
- 2.18.0（2026-10-13）：`idle` 不再给契约写版本历史。
- 2.17.0（2026-10-13）：登记 `idle.ps1`；`/harvests` 收口只跑 `etctl idle`。
- 2.16.0（2026-10-13）：登记 `guard.ps1`；源码写入前由 `etctl guard` 拦截。
- 2.15.0（2026-10-13）：登记 `check-commit-plan.py`；提交窗口可刷新和验证 Scripts。
