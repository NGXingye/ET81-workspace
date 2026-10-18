> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.4.0
> 文档状态：草案
> 读取等级：L2（复制为本模块配置后读取）

# 0. 职责定位

本文件是模块配置模板。只填门禁键。预算见 [`../global_rules/kv_budget.md`](../global_rules/kv_budget.md) §3。何时新建见 [`.cursor/commands/harvest.md`](../.cursor/commands/harvest.md)。

# 1. 键（只有 4 项）

- `module_id`：`（与文件名一致）`
- `module_name`：`（中文名）`
- `profile_status`：`draft`
- `allowed_write`：`（目录前缀菜单，相对目标 workspace_path，跨工程写绝对路径，分号分隔；控制面写 workspace_only）`

# 2. 版本历史

- 1.4.0（2026-10-18）：只留 4 个键；`allowed_write` 改为目录前缀菜单；删可选键。
- 1.3.0（2026-10-14）：`extra_risk` 不再使用，风险写进对应卡片 `# 2`。
- 1.2.0（2026-10-13）：收口说明改链到 `/harvest`。
- 1.1.2（2026-09-16）：只填门禁键；事实写 standards。
- 1.1.1（2026-09-12）：discovery 不建配置；harvest 时才复制。
