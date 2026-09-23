> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：2.9.0
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

- **调度**：`etctl.ps1` 只解析子命令并调用已登记入口，不内嵌机检政策或 SVN 步骤。`packet` 只读导出工作令，不写文件、不做 `svn update`。`begin-implement` 把活卡升到 implement 后打印 packet，无 SVN。`promote` 仅当活卡 idle 时把候选包写入活卡，无 SVN。
- **一事一入口**：机检与将来的 SVN 预检不得写进同一脚本。
- **数据位置**：活卡范围 → `contracts/current_scope.json`；未开工分析 → `contracts/candidates/<task_id>.json`（最多 2）；编辑目标 → `targets/<id>.json`；长期知识 → `standards/`；schema → `runtime/schema/`。
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
- implement 必须先跑 `etctl begin-implement`；失败则不得改源码。已是 implement 时该命令幂等，只导出 packet。`route=fast` 且用户明确授权时不跑 begin-implement，按 `plan` 改 `write_paths`。首次只按 `plan` 改 `write_paths`，禁止通读 `read_paths`。缺 `read_paths` 时等于 `write_paths`；缺 `implement_round` 时视为 1。从 `awaiting_verify` 再进入时 `implement_round+1`。禁止为开工手改契约/游标/scope，禁止读 runtime 脚本源码。
- 用户测失败：保持 implement，追加 `verify_feedback`，`implement_round+1`。此时才读 `read_paths` 并思考。可追加与现有 `write_paths` 同目录或被其直接引用的路径。禁止改 `goal`/`target_id`/`scope_revision`。满 3 轮仍失败则 `blocked`，不自动 discovery。

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

- 2.9.0（2026-09-23）：interrupt 可勾住 implement；promote 按原阶段提回。
- 2.8.0（2026-09-23）：`etctl interrupt` 热插队；带 parent 的包不能 promote。
- 2.7.0（2026-09-17）：fast 跳过 /implement，不跳过分析包与用户授权。
- 2.6.0（2026-09-17）：候选分析包最多 2；`etctl promote`；implement 只对活卡。
- 2.5.1（2026-09-17）：plan 由分析模型提炼，禁止用户手填。
