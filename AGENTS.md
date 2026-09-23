> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：1.16.0
> 文档状态：生效
> 读取等级：L0（每次冷启动必读；正文只保留硬约束）

# 0. 职责定位

本文件是 ET81-workspace 的最高规范权威。Cursor 会把它作为 Always Apply 注入每一轮，因此只保留不可违反的短约束。

本对话已有本 `task_id` 时：禁止再打开冷启动、蓝图、`global_rules/`、模板、schema、runtime 源码；同窗口换阶段只跑口令。无本任务上下文时按 `.cursor/rules/et81-cold-start.mdc`。`/implement` 只对活卡跑 `etctl begin-implement`。`route=fast` 且用户明确同意改时，按 `plan` 改活卡 `write_paths`，不必 `/implement`。活卡非 idle 时新分析写入 `contracts/candidates/<task_id>.json`（最多 2），禁止改 current。idle 后用户点名候选则 `etctl promote <task_id>`。热插队：新号候选 + `etctl interrupt <id>`；禁止复用 parent 号；可勾住 implement/awaiting_verify（用户确认主力窗口已停）；插队模型不读活卡，只凭号；禁止 blocked/harvest 中插队；热 harvest 后 promote `resume_task_id` 原阶段。`/harvest` 不走冷启动、不必先 `/implement`；事实写 `standards/`，门禁有变才写 `profiles/`，然后 idle。

# 1. 工作区

固定在 `C:\myProject\ET81-workspace`。本 workspace 只保存规范、模块配置、代码地图、游标与当前契约，不复制 Unity 源码或编辑器文档。

默认源码根：`C:\myProject\trunk`（SVN）。改哪棵树以 `etctl begin-implement` / `packet` 的 `workspace_path` 或游标 `source_root` 为准。第二工作副本仅当用户明确要求时启用。`runtime/` 未在 `runtime/_index.md` 登记的脚本禁止存在。活卡阶段与路径只写 `contracts/current_scope.json`；未开工分析可写 `contracts/candidates/`（最多 2）。

# 2. 编辑器 Markdown 门禁

1. 已登记编辑器内 Markdown 默认禁止读取、修改、维护；禁止冷启动依赖；禁止复制进 workspace。
2. `discovery` 仅当 catalog 未覆盖该事实时，可读 `editor_md_paths` 中的文件（用户点名、seed 或 catalog 明示）。禁止全树搜 md。任务结束登记 `standards/audit/source_import_record.md`。
3. `implement` 禁止读编辑器 md 改结论。先 `etctl begin-implement`，只消费 stdout。首次按 `plan` 改 `write_paths`，禁止通读 `read_paths`、禁止重开分析。测不过才读 `read_paths`；满 3 轮 `blocked`。`route=fast` 同窗按 `plan` 改 `write_paths`，不跑 begin-implement。

# 3. 强制安全

1. 未读取真实源码或工程配置时标记 `unverified`；不得把计划或文档描述写成已实现。
2. 禁止对目标工程做全树 Glob / Grep / `Get-ChildItem -Recurse`。首次 implement 与 `route=fast` 只打开 `write_paths` 与 `plan`/`evidence` 点名的文件；测不过后才打开 `read_paths`。其它阶段只按 catalog 命中、`editor_md_paths`、模块配置、契约或遗留 `source_code_map.md`。
3. 禁止读取 `Library/`、`Unity/Assets/Res/`、`Unity/Bundles/`、`Bin/`、`obj/`、`*.log` 及大型二进制资源。
4. 禁止手改 `Model/Generate/`；禁止覆盖、回退或提交白名单外的未知 SVN 改动。改源码前对白名单路径 `svn update`，失败则停止。未经用户验证并明确授权，禁止 `svn commit`。
5. 规范权威在 workspace；运行事实以源码、`ProjectSettings`、`.asmdef`、`.csproj` 和编译结果为准。冲突时标记 `blocked`，不得用编辑器文档裁决。
6. 无契约禁止改源码、禁止新建权威 Markdown。`discovery` 默认只写分析包 JSON。`route=fast` 且用户明确授权时，可按 `plan` 改活卡 `write_paths`（契约可保持 discovery）。其它改编辑器源码必须契约 `active`（`/implement`）。
7. 新发现的稳定知识只写 workspace 唯一对应文件；回馈编辑器文档须单独任务且用户批准。
8. 进入 `implement` 仅当本轮 `/implement`（`route=fast` 且用户明确同意改除外）。进入 `harvest` 仅当本轮 `/harvest`，不必先 `/implement`。口语对 normal 不够；对 fast「改吧」视为授权。分析包不可用则拒绝并留在当前阶段。候选包不能改 trunk。

# 4. 版本历史

- 1.16.0（2026-09-23）：implement 中可插队；回来原阶段；插队不读活卡。
- 1.15.0（2026-09-23）：热插队新号；harvest 后 promote resume。
- 1.14.0（2026-09-17）：fast 小改用户授权即可改；harvest 不必先 implement。
- 1.13.0（2026-09-17）：候选分析包最多 2；`/implement` 只对活卡。
- 1.12.0（2026-09-16）：分析包写 plan；首次 implement 按 plan 改，不重开分析。
