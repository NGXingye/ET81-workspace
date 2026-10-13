> 最新修改时间：2026-10-13 16:40 UTC+8
> 版本号：1.10.0
> 文档状态：生效
> 读取等级：L2（用户发出 /harvests 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/harvests` 时执行。这是全量收口。不走冷启动。不必先 `/implement`。

正路：同窗口，你已验证（fast 小改、`/implement` 之后、或只收分析且你点名）。

拒绝并留在当前阶段：`idle`；无可沉淀事实；刚改编辑器源码且尚未验证（除非你明确只收分析）；仍 `blocked` 且未选择收口。

禁止读取：`project_pipeline.md`、`global_rules/`、runtime 源码、catalog 整库、discovery 读序。本对话已有证据则不要重读游标。新窗口仅当 `phase` 为 `awaiting_verify`，或 `route=fast` 且你点名，或你点名只收分析时，只读游标与 `current_scope.json`。

执行：

- `standards/`：本单模块 JSON、必要时 catalog 命中行。`records/task_outcomes.jsonl` 只在这里写：一个 `task_id` 一行，已有则换掉该行，不改其它行。只写 `task_id`、`changed_targets`、`changed_paths`、`recorded_at`。`changed_paths` 记本单动过的全部路径。旧行保持原字段。
- `profiles/`：无则从 `_template.md` 复制并登记 `_index.md`；已有则仅当 `allowed_write`/禁区变了才改。不把行为事实写入 profile。
- 有可交脚本时，收回 idle 前按 [`contracts/_template_commit_plan.json`](../../contracts/_template_commit_plan.json) 覆盖写 `contracts/commit_plan.json`，不沿用文件里已有的 status。笔数以 10 为参考，按内容浮动。一笔最多 8 个 `.cs`；`.meta` 跟着对应脚本，不计入。单独行为只有一个脚本时保持一笔。同一行为的 `.cs` 与 `.meta` 同笔。`summary` 是本单总任务。每笔 `hook_task` 从该笔 `workspace_path` 对应的 `targets` JSON 的 `hook_tasks` 里选；目标没有这份清单就留空。`paths` 相对 `workspace_path`。没有可交脚本则不写该文件。写完后运行 `py -3 runtime/check-commit-plan.py --fill`。它只看 `Unity/Assets/Scripts` 的 `svn status`。和计划新增符号有交集的漏文件补进未提交笔；满 8 个 `.cs` 就新开一笔。没有交集的写入 `omitted`，不提交。
- 不 `svn commit`，不运行 `commit-units.py`。
- 分类写完，且用户没有再要补的内容：`powershell -File runtime/etctl.ps1 idle`。不手改游标、契约、scope，不写版本历史。进度已在 `standards/records/task_outcomes.jsonl`。`--fill` 失败或用户还要补事实时先不要调用；下一轮补完 `standards/` 或 `commit_plan.json` 后再调用。脚本不删提交计划、不 svn、不 promote。
- stdout 有 `resume_task_id` 时再 `powershell -File runtime/etctl.ps1 promote <resume_task_id>`。失败则停并报告候选仍在。还有未提交笔时 promote 会拒绝。promote 按勾住时的原阶段提回（含 implement）。
- idle 之后还能改什么，见 [`AGENTS.md`](../../AGENTS.md)。

# 1. 版本历史

- 1.10.0（2026-10-13）：写计划覆盖本单，不沿用上一单状态。
- 1.9.0（2026-10-13）：提交钩子号改从目标的 `hook_tasks` 读取。
- 1.8.0（2026-10-13）：收口账一个号一行，只写四个字段。
- 1.7.0（2026-10-13）：收口不再给契约写版本历史。
- 1.6.0（2026-10-13）：idle 之后的改动权限改链到 `AGENTS.md`。
