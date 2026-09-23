> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L2（用户发出 /interrupt 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/interrupt` 时执行。不走冷启动。用户本轮授权即可按 `plan` 改插队 `write_paths`。

已 harvest 任务的 trivial 热修：新号写 `contracts/candidates/<new>.json`（复制 `_template_interrupt.json`），再跑 `etctl interrupt <new>`。禁止复用 parent 号。只凭用户给出的主力号；禁止读 `contracts/current.md`、`current_scope.json`、主力 `write_paths`。

拒绝并留在当前阶段：活卡 idle（改走 `etctl promote`）；活卡已是 blocked / harvest；已在插队；候选将超过 2；`write_paths` 不是 1–2 或越出 parent 的 `task_outcomes.changed_paths`；与主力写集重叠。

禁止读取：`project_pipeline.md`、`global_rules/`、runtime 源码、活卡内容。本对话已有分析包则不要重写。

执行：`powershell -File runtime/etctl.ps1 interrupt <task_id>`。失败则停。只消费 stdout。成功后按本包 `plan` 改 `write_paths`。禁止 svn commit。用户确认主力窗口已停。

# 1. 版本历史

- 1.1.0（2026-09-23）：可勾住 implement/awaiting_verify；不读活卡。
- 1.0.0（2026-09-23）：热插队升活卡；主力勾进 candidates。
