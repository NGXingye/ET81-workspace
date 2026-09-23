> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：1.9.0
> 文档状态：草案
> 读取等级：L2（重置 current.md 时对照）

# 0. 职责定位

本文件是开工契约模板。复制结构到 `current.md` 时只保留有信息量的键值项。完整预算见 `global_rules/kv_budget.md` §4。

# 1. 空闲形态（最小 2 项）

- `task_id`：`none`
- `contract_status`：`idle`

# 2. 发现与开工

发现形态（最小 3 项，允许无模块）：

- `task_id`：`t001`
- `contract_status`：`discovery`
- `goal`：`（一句话）`

开工形态（最小 6 项）：

- `task_id`：`t001`
- `contract_status`：`active`
- `goal`：`（一句话）`
- `profile_ref`：`profiles/<id>.md`
- `source_root_mode`：`normal`
- `acceptance`：`机检通过; scoped svn 未越界`

可选（有信息才写，计入上限 10）：`allowed_write`、`workspace_writes`、`out_of_scope`、`unblock`。

分析包复制 [`_template_scope.json`](./_template_scope.json)，idle 时只保留 `task_id`/`phase`/`scope_revision`。`editor_md_paths` 仅 discovery 需要读编辑器 md 时填写。`write_paths` 非空进入 `awaiting_scope` 或 `route=fast` 时必须有 `plan`。`route=fast` 且用户明确同意时按 `plan` 改 `write_paths`，契约保持 discovery，不必 `/implement`。热插队复制 [`_template_interrupt.json`](./_template_interrupt.json)，经 `etctl interrupt` 升活卡；可勾住 implement；禁止复用 parent 号；插队不读活卡。

implement 不另存任务包；模型执行 `powershell -File runtime/etctl.ps1 begin-implement`。首次按 `plan` 改。测不过保持 implement：追加 `verify_feedback`，`implement_round+1`（1–3）；满 3 轮改为 `blocked`。`/harvest` 不必先 `/implement`。

# 3. 结束

稳定知识：行为事实回写 `standards/`；模块门禁回写 `profiles/`（无则新建，已有则仅白名单/禁区有变才改）。然后把 `current.md` 恢复为空闲形态，并把 `current_scope.json` 恢复为 `task_id=none`、`phase=idle`、`scope_revision=0`。不要另存日期文件。

# 4. 版本历史

- 1.9.0（2026-09-23）：插队可勾住 implement；不读活卡。
- 1.8.0（2026-09-23）：热插队模板；经 `etctl interrupt`。
- 1.7.0（2026-09-17）：fast 用户授权即可改；harvest 不必先 implement。
- 1.6.0（2026-09-16）：分析包 `plan` 必填才能开工。
- 1.5.0（2026-09-16）：结束时分写 standards 事实与 profiles 门禁。
