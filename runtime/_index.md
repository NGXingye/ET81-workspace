> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：2.9.0
> 文档状态：生效
> 读取等级：L1（新增或修改 runtime 下脚本前必读）

# 0. 职责定位

本文件登记 `runtime/` 内允许存在的脚本与 schema。未出现在本表中的 `.ps1` / `.py` **禁止存在**。

写法见 [`../global_rules/runtime_code.md`](../global_rules/runtime_code.md)。不得替代 [`../global_rules/code_governance.md`](../global_rules/code_governance.md) 的 SVN 授权规则。

# 1. 文件索引

- [`etctl.ps1`](./etctl.ps1)  
  职责：运行时调度入口（`check`、`status`、`packet`、`begin-implement`、`promote`、`interrupt`）。  
  副作用：无 SVN。`packet` 只读导出活卡工作令。`begin-implement` 只升活卡。`promote <task_id>` 仅 idle 时把候选写入活卡。`interrupt <task_id>` 把活卡勾进 candidates，新号升活卡。  
  入口：`powershell -File runtime/etctl.ps1 <command> [<task_id>]`
- [`begin-implement.ps1`](./begin-implement.ps1)  
  职责：把活卡升到 implement，再导出 packet。  
  副作用：写游标、`current.md`、`current_scope.json`。无 SVN。  
  非独立入口，由 `etctl.ps1 begin-implement` 调用。
- [`promote.ps1`](./promote.ps1)  
  职责：活卡 idle 时把候选写入活卡。带 `parent_task_id` 的包拒绝。`parked` 包按原阶段提回（含 implement）。  
  副作用：写游标、`current.md`、`current_scope.json`；删除候选 JSON。无 SVN。  
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
- [`schema/current_scope.schema.json`](./schema/current_scope.schema.json)  
  职责：活卡 scope 与候选分析包的字段契约（候选另需 `goal`）。
- [`schema/target.schema.json`](./schema/target.schema.json)  
  职责：`targets/<id>.json` 的字段契约。
- [`schema/map_entry.schema.json`](./schema/map_entry.schema.json)  
  职责：代码地图一行的字段契约（keyword/prefer/avoid/trust）。

# 2. 版本历史

- 2.9.0（2026-09-23）：interrupt 可勾住 implement；promote 恢复原阶段。
- 2.8.0（2026-09-23）：登记 `interrupt.ps1`；热插队勾住主力。
- 2.7.0（2026-09-21）：promote 按 target 设 source_root；Unity 版本文件兼容无 Unity/ 的编辑器。
- 2.6.0（2026-09-17）：登记 `promote.ps1`；候选包最多 2。
- 2.5.0（2026-09-16）：packet 导出 plan/evidence；plan 为空则失败。
