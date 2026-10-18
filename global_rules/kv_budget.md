> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：2.1.0
> 文档状态：生效
> 读取等级：L1（改游标、模块配置或开工契约的键值项时必读）

# 0. 职责定位

只约束三种文件里 ``- `name`：`value` `` 键值行的最小集与上限（列表值用分号分隔）。章节布局见 [`md_governance.md`](./md_governance.md)；其它文件与 JSON 不设键值预算。

# 1. 通则

最小必要必须始终存在；条件项触发才写；可选项缺省即继承，禁止写 `none` 凑数；同一事实只留一处。超限按序处置：删缺省可选项 → 删未触发条件项 → 删与别处重复的键 → 收窄本单范围。禁止抬上限、禁止把键写成标题。改完跑 `runtime/etctl.ps1 check`。

# 2. 游标 `project_cursor.md`（上限 14，空闲正好 11）

- 必要：`workspace_root`、`trunk_markdown_access`、`init_baseline_status`、`source_root`、`source_root_mode`、`version_control`、`task_id`、`task_status`（idle / in_progress / blocked / awaiting_approval）、`active_profile`、`contract_ref`、`blocked`。
- 条件：`isolated_source_root`（isolated 时）；`blocker_reason`、`blocker_owner`（blocked 时）。
- 空闲时 `task_id`、`active_profile`、`contract_ref` 为 `none` 且无条件项。不写目标、验收、白名单。

# 3. 模块门禁 `profiles/<id>.md`（正好 4 项）

- 必要：`module_id`、`module_name`、`profile_status`（draft / active）、`allowed_write`（目录前缀菜单，相对目标 `workspace_path`，跨工程写绝对路径；`workspace_only` 表示禁写源码）。
- 不设可选键：禁区与本地专用写 `targets/<id>.json`，禁改的具体文件、风险与行为写进 `standards/<模块>.md`。

# 4. 开工契约 `contracts/current.md`（上限 10）

- 空闲 2 项：`task_id`=`none`、`contract_status`=`idle`。
- 发现至少 3 项：`task_id`、`contract_status`=`discovery`、`goal`。
- 开工至少 6 项：`task_id`、`contract_status`=`active`、`goal`、`profile_ref`、`source_root_mode`、`acceptance`。
- 可选：`allowed_write`（本单更窄时）、`workspace_writes`、`out_of_scope`、`unblock`。阶段、路径、证据只写 `current_scope.json`；不写进度。

# 5. 版本历史

- 2.1.0（2026-10-18）：模块门禁只留 4 个键，`allowed_write` 为目录前缀菜单。
- 2.0.0（2026-10-15）：压缩为要点；`extra_risk` 移除。
- 1.5.0（2026-09-17）：discovery 默认禁改 trunk；fast 授权例外。