> 最新修改时间：2026-10-13 16:40 UTC+8
> 版本号：2.15.0
> 文档状态：生效
> 读取等级：L1（新增或修改 `runtime/` 脚本或 schema 前必读）

# 0. 职责定位

本文件是控制面运行时的写法与命名规范。登记与副作用见 [`../runtime/_index.md`](../runtime/_index.md)；准不准碰 SVN/trunk 见 [`code_governance.md`](./code_governance.md)。

替代已删除的 `tools_code.md`。政策只写在 Markdown；路径、阶段、证据只写 JSON。

# 1. 目录与命名

| 种类 | 规则 | 例 |
|---|---|---|
| 目录 | 小写英文；集合用复数 | `runtime/`、`targets/`、`contracts/` |
| 入口脚本 | kebab-case；唯一调度名固定 `etctl.ps1` | `runtime/etctl.ps1` |
| 实现脚本 | kebab-case 动词-名词 | `check-workspace.ps1` |
| 非入口库 | kebab-case；索引标明非独立入口 | `check-helpers.ps1` |
| JSON 数据 | snake_case；与职责同名 | `current_scope.json`、`trunk.json` |
| JSON 字段 | snake_case | `scope_revision`、`read_paths` |
| schema | `<stem>.schema.json`，放 `runtime/schema/` | `current_scope.schema.json` |

禁止：`final`/`new`/`v2`、日期归档、空 `lib/`、未登记脚本、把同一事实写成 MD 键值又写成 JSON。

# 2. 架构

- **调度**：`etctl.ps1` 只解析子命令并调用已登记入口，不内嵌机检政策或 SVN 步骤。`packet` 只读导出工作令，不写文件、不做 `svn update`。`begin-implement` 把活卡升到 implement 后打印 packet，无 SVN。`promote` 仅当活卡 idle 时把候选包写入活卡，无 SVN。提交计划还有未交笔则拒绝；每笔都已提交则先把计划重置为空。`guard` 只读判定，不写文件。
- **收回空闲**：`etctl idle`。把 scope、游标任务段、契约收成空闲最小形态；游标不改 `source_root`。已是空闲则不写文件。不写版本历史，不升版本号。不删 `commit_plan.json`、不删候选、不 svn、不 promote。scope 里的 `resume_task_id` 打印后清掉。任何非空闲阶段都可调用。
- **源码拦截**：`etctl guard <path>`。路径不在游标 `source_root` 与任一 `targets/*.json` 的 `workspace_path` 之下则放行。在其下必须同时满足：`phase` 与 `task_status` 都不是 `idle`，且 `task_status` 为 `in_progress`；`phase=implement` 且契约 `active`，或 `phase=discovery` 且 `route=fast`；路径与 `write_paths` 某一项是同一文件（相对路径相对该目标 `workspace_path`，无目标则相对 `source_root`）；活动 profile 的 `allowed_write` 不是 `workspace_only`。否则退出码 2。`.cursor/hooks.json` 在写文件工具和会改文件的 shell 之前调用它。
- **一事一入口**：机检与将来的 SVN 预检不得写进同一脚本。
- **数据位置**：活卡范围 → `contracts/current_scope.json`；未开工分析 → `contracts/candidates/<task_id>.json`（最多 2）；提交计划 → `contracts/commit_plan.json`；编辑目标 → `targets/<id>.json`；长期知识 → `standards/`；schema → `runtime/schema/`。
- **共享解析**：仅当两个入口都要用时，才允许已登记的非入口文件。禁止为尚未存在的命令先建空框架。
- 入口只编排：参数 → 调用检查/读写 JSON → 退出码。

# 3. 方法与 JSON

- `$ErrorActionPreference = 'Stop'`。外部命令非 0 必须停。
- 机检用错误/警告列表。禁止本地数据库或隐藏状态文件。
- 路径只从 `$PSScriptRoot` 推 workspace，从游标读 `source_root`。
- JSON 必须能被 `ConvertFrom-Json` 解析，并符合对应 schema 的必填字段。
- `phase` 取值：`idle` / `discovery` / `awaiting_scope` / `implement` / `awaiting_verify` / `harvest` / `blocked`。
- 分析包（phase≠idle）必须有 `intent`/`size`/`route`。discovery 允许 `unknown`/`unset`；进入 `awaiting_scope` 后必须解析完毕。
- 游标 `task_status` 必须与 phase 对齐：idle；discovery/implement/harvest→`in_progress`；awaiting_scope/awaiting_verify→`awaiting_approval`；blocked→`blocked`。
- `edit_ops`：`in_place` / `add_file` / `delete` / `move`。删除与移动必须写进契约，禁止快路径。
- 快路径 `route=fast` 仅当 size=trivial、intent 为 bug 或 feature、edit_ops 只有 in_place、write_paths≤2。跳过 `awaiting_scope` 与 `/implement`；不跳过分析包、用户授权、用户验证、`etctl check`。契约可保持 discovery。候选包即使 fast 也不能改 trunk。重构、首次无模块探索禁止快路径。
- `allowed_write` 为 `workspace_only` 时禁止改编辑器源码。
- `editor_md_paths`：discovery 允许读的目标编辑器 Markdown，必须是已点名路径。implement 忽略该字段。
- `plan`：分析模型提炼的改法，一行一项，指向 `write_paths`，不粘贴源码。`evidence.note` 写用户关键信息与观察结论。禁止让用户手填。进入 `awaiting_scope` 或 `route=fast` 且 `write_paths` 非空时 `plan` 必填。
- `implement` 的执行步骤见 [`.cursor/commands/implement.md`](../.cursor/commands/implement.md)。缺 `read_paths` 时等于 `write_paths`；缺 `implement_round` 时视为 1。

# 4. 体积与处置

物理行：软上限 180，硬上限 250。超硬上限不得抬上限或把文件改成 L2 规避。

| 违规 | 只允许 |
|---|---|
| 超 250 行 | 删重复 → 按职责拆成已登记脚本 → 先改 `_index.md` |
| 政策与脚本双写 | 删脚本里的政策，留 MD |
| 路径列表写入 MD 键值 | 改写入对应 JSON |
| 未登记 `.ps1/.py` | 删除或先登记再留 |
| 机检 `TOOL_LINE_MAX` / `TOOL_UNREG` | 按上表处理后重跑 `runtime/etctl.ps1 check` |

# 5. 版本历史

- 2.15.0（2026-10-13）：提新活卡时未交完的提交计划拒绝，交完则重置。
- 2.14.0（2026-10-13）：`etctl idle` 不再给契约写版本历史。
- 2.13.0（2026-10-13）：implement 执行步骤改链到 `/implement`。
- 2.12.0（2026-10-13）：`etctl idle` 一次收回空闲；不手改游标、契约、scope。
- 2.11.0（2026-10-13）：`etctl guard` 拦截源码树写入；不在 `write_paths` 或阶段不许写则拒绝。
