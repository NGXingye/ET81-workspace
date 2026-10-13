> 最新修改时间：2026-10-13 15:46 UTC+8
> 版本号：1.7.0
> 文档状态：生效
> 读取等级：L2（用户发出 /harvest 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/harvest` 时执行。这是中途收割。不走冷启动。不必先 `/implement`。不停卡。

正路：同窗口，你已验证（fast 小改、`/implement` 之后、或只收分析且你点名）。

拒绝并留在当前阶段：`idle`；无可沉淀事实；刚改编辑器源码且尚未验证（除非你明确只收分析）；仍 `blocked` 且未选择收口。

禁止读取：`project_pipeline.md`、`global_rules/`、runtime 源码、catalog 整库、discovery 读序。本对话已有证据则不要重读游标。新窗口仅当 `phase` 为 `awaiting_verify`，或 `route=fast` 且你点名，或你点名只收分析时，只读游标与 `current_scope.json`。

执行：

- `standards/`：本单模块 JSON、必要时 catalog 命中行。不写 `records/task_outcomes.jsonl`。
- `profiles/`：无则从 `_template.md` 复制并登记 `_index.md`；已有则仅当 `allowed_write`/禁区变了才改。不把行为事实写入 profile。
- 不改 `task_id`、阶段、`write_paths`、游标。不收回 idle。不 `promote`。不 `svn commit`。
- 全量收口用 `/harvests`。

# 1. 版本历史

- 1.7.0（2026-10-13）：中途收割不写收口账。
- 1.6.0（2026-10-09）：改为中途收割，不停卡。
- 1.5.0（2026-09-23）：resume promote 恢复原阶段。
- 1.4.0（2026-09-23）：热插队收口后 promote `resume_task_id`。
- 1.3.0（2026-09-17）：不必先 `/implement`；fast 验证后可收口。
