> 最新修改时间：2026-09-07 16:55 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L1（路径发现或登记变更时读取）

# 0. 职责定位

本文件是 ET81-workspace 受管理文档的唯一导航表，只登记本 workspace 内文件的位置和读取时机。

任务状态只写入 `project_cursor.md`。

# 1. 读取等级

- **L0**：每次冷启动（`AGENTS.md`、`project_cursor.md`；契约仅当被引用）。
- **L1**：查找文档、改 Markdown 结构或字段时。
- **L2**：执行模块任务或对照模板时。

# 2. 根目录控制文件

- [`AGENTS.md`](./AGENTS.md) — L0；最高规范权威。
- `.cursor/rules/et81-cold-start.mdc` — 冷启动读序与写序。
- [`project_cursor.md`](./project_cursor.md) — L0；任务游标。
- [`project_index.md`](./project_index.md) — L1；本文档。
- [`active.code-workspace`](./active.code-workspace) — 多根工作区入口。

# 3. 受管理目录

- [`global_rules/_index.md`](./global_rules/_index.md) — 文档法、键值预算、代码门禁、工具写法。
- [`contracts/_index.md`](./contracts/_index.md) — 唯一活开工契约。
- [`profiles/_index.md`](./profiles/_index.md) — 模块配置。
- [`standards/_index.md`](./standards/_index.md) — 框架基线、代码地图与初始化审计。
- [`tools/_index.md`](./tools/_index.md) — 已登记辅助脚本；未登记禁止存在。

# 4. 登记规则

新增受管理 Markdown 时必须符合 `global_rules/md_governance.md`，并在最近一级 `_index.md` 登记。不登记 trunk 路径。

# 5. 版本历史

- 1.2.0（2026-09-07）：登记 `tools/_index.md` 与代码门禁。
- 1.1.0（2026-09-07）：登记 `global_rules/` 与 `contracts/`。
- 1.0.0（2026-09-07）：建立文档导航首版。
