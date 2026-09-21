> 最新修改时间：2026-09-17 10:20 UTC+8
> 版本号：1.8.0
> 文档状态：生效
> 读取等级：L1（路径发现或登记变更时读取）

# 0. 职责定位

本文件是 ET81-workspace 受管理文档的唯一导航表，只登记本 workspace 内文件的位置和读取时机。

任务状态只写入 `project_cursor.md`。活卡范围只写入 `contracts/current_scope.json`。未开工分析写入 `contracts/candidates/`（最多 2）。

# 1. 读取等级

- **L0**：Always Apply `AGENTS.md`。无本任务上下文才读游标；契约与 scope 仅当被引用。
- **L1**：查找文档、改 Markdown 结构或字段时。
- **L2**：对照模板；`project_pipeline.md` 给人看，Agent 不为开工/收口打开。

# 2. 根目录控制文件

- [`AGENTS.md`](./AGENTS.md) — L0；最高规范权威。
- `.cursor/rules/et81-cold-start.mdc` — 无本任务上下文时的冷启动读序。
- `.cursor/commands/implement.md`、`.cursor/commands/harvest.md` — 阶段升级口令。
- [`project_pipeline.md`](./project_pipeline.md) — L2；用户管线蓝图；Agent 暖会话不读。
- [`project_cursor.md`](./project_cursor.md) — L0；任务游标。
- [`project_index.md`](./project_index.md) — L1；本文档。
- [`active.code-workspace`](./active.code-workspace) — 多根工作区入口。

# 3. 受管理目录

- [`global_rules/_index.md`](./global_rules/_index.md) — 文档法、键值预算、代码门禁、运行时写法。
- [`contracts/_index.md`](./contracts/_index.md) — 唯一活开工契约、scope JSON、最多 2 个候选分析包。
- [`profiles/_index.md`](./profiles/_index.md) — 模块长期门禁；行为事实在 `standards/`。
- [`targets/_index.md`](./targets/_index.md) — 编辑目标 JSON。
- [`standards/_index.md`](./standards/_index.md) — 按编辑器分区的模型事实库。
- [`runtime/_index.md`](./runtime/_index.md) — 已登记运行时脚本与 schema；未登记脚本禁止存在。

# 4. 登记规则

新增受管理 Markdown 或 JSON 数据时必须符合 `global_rules/md_governance.md`，并在最近一级 `_index.md` 登记。不登记 trunk 路径。

# 5. 版本历史

- 1.8.0（2026-09-17）：登记候选分析包。
- 1.7.0（2026-09-16）：profiles 标为门禁；事实在 standards。
- 1.6.0（2026-09-16）：冷启动仅无上下文；蓝图标明给人看。
- 1.5.0（2026-09-15）：登记 `/implement`、`/harvest` 命令文件。
- 1.4.0（2026-09-14）：登记 `project_pipeline.md`。
