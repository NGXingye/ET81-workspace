> 最新修改时间：2026-09-07 15:15 UTC+8
> 版本号：1.0.0
> 文档状态：草案
> 读取等级：L2（重置 current.md 时对照）

# 0. 职责定位

本文件是开工契约模板。复制结构到 `current.md` 时只保留有信息量的键值项。完整预算见 `global_rules/kv_budget.md` §4。

# 1. 空闲形态（最小 2 项）

- `task_id`：`none`
- `contract_status`：`idle`

# 2. 开工形态（最小 6 项）

- `task_id`：`t001`
- `contract_status`：`active`
- `goal`：`（一句话）`
- `profile_ref`：`profiles/<id>.md`
- `source_root_mode`：`normal`
- `acceptance`：`机检通过; scoped svn 未越界`

可选（有信息才写，计入上限 10）：`allowed_write`、`workspace_writes`、`out_of_scope`、`unblock`。

# 3. 结束

稳定知识回写 `standards/` 或模块配置后，把 `current.md` 恢复为空闲形态。不要另存日期文件。

# 4. 版本历史

- 1.0.0（2026-09-07）：建立空闲/开工两种最小形态。
