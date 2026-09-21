> 最新修改时间：2026-09-17 17:40 UTC+8
> 版本号：1.5.0
> 文档状态：生效
> 读取等级：L2（用户发出 /implement 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/implement` 时执行。`route=fast` 的小改走分析包 + 用户同意，不必本口令。

本对话已有分析包或 packet 时：不要重读游标、契约、冷启动、蓝图。直接跑命令。

拒绝并留在当前阶段：无活任务；任务只在 `contracts/candidates/`（先 `etctl promote`）；`write_paths` 或 `plan` 为空；goal/目标已变未重写包；只改表（改走 `/harvest`）；`implement_round` 已 3 且 `blocked`。

禁止读取：`global_rules/`、`project_pipeline.md`、`contracts/_template*`、`runtime/*.ps1` 源码、`runtime/schema/`、`standards/catalog.json`、`profiles/`、`targets/*.json`。不要手改契约/游标/scope 来开工。禁止重开 discovery。

执行：`powershell -File runtime/etctl.ps1 begin-implement`。失败则停。只消费 stdout。

- 首次（`implement_round` 为 1 且无 `verify_feedback`）：按 `plan` 改 `write_paths`。只打开这些文件核对后改。禁止通读 `read_paths`、禁止重推改法。文件与 plan 明显不符则停手。
- 测不过：保持 implement，追加 `verify_feedback`，`implement_round+1`；此时才读 `read_paths` 并思考。可把与现有 `write_paths` 同目录或被其直接引用的文件追加进包。满 3 轮 `blocked`。

对 `write_paths` scoped `svn update`。禁止读编辑器 md。`etctl check` 后请用户验证。不要自动 harvest，不要 `svn commit`。

# 1. 版本历史

- 1.5.0（2026-09-17）：fast 小改不必本口令。
- 1.4.0（2026-09-17）：候选包须先 promote；`/implement` 只对活卡。
- 1.3.0（2026-09-16）：首次按 plan 改；测不过才读 read_paths。
- 1.2.0（2026-09-16）：暖会话直接跑命令；测不过局部返工写入口令。
- 1.1.0（2026-09-16）：开工改走 `etctl begin-implement`。
