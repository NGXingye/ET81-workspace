> 最新修改时间：2026-11-09 10:30 UTC+8
> 版本号：2.9.0
> 文档状态：生效
> 读取等级：L2（用户发出 /harvests 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/harvests` 时执行。这是全量收口：提炼知识、记收口账、写提交计划、收回 idle。不走冷启动。不必先 `/implement`。

正路：同窗口，你已验证（fast 小改、`/implement` 之后、或只收分析且你点名）。

拒绝并留在当前阶段：`idle`；刚改编辑器源码且尚未验证（除非你明确只收分析）；仍 `blocked` 且未选择收口。「无新增知识」不是拒绝理由，照常记账收口。

禁止读取：`global_rules/`、runtime 源码、discovery 读序。本对话已有证据则不要重读游标。新窗口仅当 `phase` 为 `awaiting_verify`，或 `route=fast` 且你点名，或你点名只收分析时，只读游标与 `current_scope.json`。

# 1. 执行

1. **知识**：按 [`harvest.md`](./harvest.md) §1 处理 `standards/` 的模块卡。本单 `/harvest` 已收过的不重复；无新增就不改卡。改了模块卡或 `_index` 关键词/跨模块坑时，按 harvest.md §1 热更 `_index` §4（滚动 ≤5）。
2. **收口账** `standards/records/task_outcomes.jsonl`：占用账 + interrupt 父足迹索引（不是知识库）。一个 `task_id` 一行，已有则换掉该行，不改其它行。只写四字段：`task_id`、`changed_targets`、`changed_paths`、`recorded_at`。`changed_paths` 只记本单动过的**源码/配置**路径（供 interrupt 校验 `write_paths` ⊆ 父足迹）；不记控制面路径（`standards/`、`profiles/`、`targets/`、`contracts/`、`runtime/`、`.cursor/`、`global_rules/` 及 `project_cursor.md` / `AGENTS.md` 等工作区控制文件）。过滤后可为 `[]`，行仍保留占号。不写 `intent`/`promoted`/`discarded` 等旧字段；知识只进模块卡。路径条数不硬截断（约 >20 时可自检是否范围过大，不拒绝收口）。
3. **提交计划**：写计划前按 SVN 仓库身份和仓库相对路径认同源文件，不按本地路径重复列单。同一改动只安排一处提交；源头已提交、外链副本只是版本落后时，只提示同步，不再列一笔。外链副本若还有额外本地改动，先辨明，不直接忽略，也不自动 update、revert 或覆盖。有可交脚本时，收回 idle 前按 [`contracts/_template_commit_plan.json`](../../contracts/_template_commit_plan.json) 覆盖写**活动槽** `contracts/commit_plan.json`，不沿用文件里已有的 status。准备提交的只写入活动计划。还留在本地的，直接改 `held_commit_plan.json`：同一目标且同一件事则更新该模块的路径和现状，不新开；换目标或另一件事才新开模块。不要把留下的先写进计划。这一单全部还不交，才 `etctl hold-plan`（同编号合并路径并保留原阻碍，再清空活动槽）。held 不提交、不整份还原。同一文件里兼有要交和要留的改动时，整文件留在模块，不写入活动计划。窗口只检查正在交的那一笔：路径还在模块里就先确认，因为提交会带上该文件的全部本地改动；成功后才划掉正好对上的文件，失败不改 held。非交互 `--unit` 遇重叠要加 `--extract`。目录项成功后不自动拆开。笔数以 10 为参考，按内容浮动。一笔最多 8 个 `.cs`；`.meta` 跟着对应脚本，不计入。单独行为只有一个脚本时保持一笔。同一行为的 `.cs` 与 `.meta` 同笔。`summary` 是本单总任务。每笔 `hook_task` 从该笔 `workspace_path` 对应的 `targets` JSON 的 `hook_tasks` 里选；目标没有这份清单就留空。`paths` 相对 `workspace_path`。没有可交脚本则不写该文件。写完后运行 `py -3 runtime/check-commit-plan.py --fill`。它只看 `Unity/Assets/Scripts` 的 `svn status`。和计划新增符号有交集的漏文件补进未提交笔；满 8 个 `.cs` 就新开一笔。模块路径按工作区匹配。和计划新增符号没有交集的暂留文件视同已覆盖；有交集的不补进计划、不写入 `omitted`，列为「暂留相交，需决定」，`--verify` 因此不通过。目标 `local_only` 静默跳过。活动 `omitted` 只留真排除。
4. 不 `svn commit`，不运行 `commit-units.py`。
5. 以上写完，且用户没有再要补的内容：`powershell -File runtime/etctl.ps1 idle`。不手改游标、契约、scope。`--fill` 失败或用户还要补时先不要调用；下一轮补完 `standards/` 或 `commit_plan.json` 后再调用。脚本不删提交计划、不 svn、不 promote。
6. stdout 有 `resume_task_id` 时再 `powershell -File runtime/etctl.ps1 promote <resume_task_id>`。失败则停并报告候选仍在。还有未提交笔时 promote 会拒绝。promote 按勾住时的原阶段提回（含 implement）。
7. idle 之后还能改什么，见 [`AGENTS.md`](../../AGENTS.md)。

# 2. 版本历史

- 2.9.0（2026-11-09）：hold 同编号合并并保留阻碍；重叠成功后才核销；符号相交只报告。
- 2.8.0（2026-11-07）：留下的工作直接改 held 模块；整单不交才 hold-plan。
- 2.7.0（2026-11-07）：held 改为按模块的本地未交索引，不再直接提交或整份还原。
- 2.6.0（2026-11-07）：写计划前按 SVN 仓库认同源，外链落后只提示同步。
- 2.5.0（2026-11-05）：知识步半行指针：改模块卡/`_index` 时热更 `_index` §4（滚动 ≤5）。
