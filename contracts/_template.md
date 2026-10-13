> 最新修改时间：2026-10-13 15:20 UTC+8
> 版本号：1.12.0
> 文档状态：草案
> 读取等级：L2（重置 current.md 时对照）

# 0. 职责定位

本文件是开工契约的键值形状。预算见 [`../global_rules/kv_budget.md`](../global_rules/kv_budget.md) §4。口令见 `.cursor/commands/`。复制到 `current.md` 时只保留有信息量的键。

# 1. 形状

空闲（2 项）：

- `task_id`：`none`
- `contract_status`：`idle`

发现（最少 3 项）：

- `task_id`：`t001`
- `contract_status`：`discovery`
- `goal`：`（一句话）`

开工（最少 6 项）：

- `task_id`：`t001`
- `contract_status`：`active`
- `goal`：`（一句话）`
- `profile_ref`：`profiles/<id>.md`
- `source_root_mode`：`normal`
- `acceptance`：`机检通过; scoped svn 未越界`

可选（有信息才写）：`allowed_write`、`workspace_writes`、`out_of_scope`、`unblock`。

分析包复制 [`_template_scope.json`](./_template_scope.json)。热插队复制 [`_template_interrupt.json`](./_template_interrupt.json)。

# 2. 版本历史

- 1.12.0（2026-10-13）：删去口令与拆分规则，改链到口令文件。
- 1.11.0（2026-10-09）：`/harvest` 不停卡；`/harvests` 才收回空闲。
- 1.10.0（2026-09-23）：Trunk 大文件加行为，分析拆组件。
- 1.9.0（2026-09-23）：插队可勾住 implement；不读活卡。
- 1.8.0（2026-09-23）：热插队模板；经 `etctl interrupt`。
