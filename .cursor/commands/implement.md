> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.10.0
> 文档状态：生效
> 读取等级：L2（用户发出 /implement 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/implement` 时执行。`route=fast` 的小改走分析包 + 用户同意，不必本口令。

本对话已有分析包或 packet 时：不要重读游标、契约、冷启动、蓝图。直接跑命令。

拒绝并留在当前阶段：无活任务；任务只在 `contracts/candidates/`（先 `etctl promote`）；`write_paths` 或 `plan` 为空；goal/目标已变未重写包；只改表（改走 `/harvests`）；`implement_round` 已 3 且 `blocked`。

禁止读取：`global_rules/`、`project_pipeline.md`、`contracts/_template*`、`runtime/*.ps1` 源码、`runtime/schema/`、`profiles/`（门禁由脚本读）、`targets/*.json`、`archive/`。不要手改契约/游标/scope 来开工。禁止重开 discovery。

# 1. 查卡（每轮必做）

触发：每一轮改代码之前；以及本轮出现报错、测不过、用户补了新需求或新现象时，当场再做一次。

1. 用需求、报错信息、类名里的词对 [`cards/_index.md`](../../cards/_index.md) 的关键词，命中 1–2 张卡，读该卡 `# 0` 与 `# 2`。
2. 扫 [`cards/pitfalls.md`](../../cards/pitfalls.md) 的「场景触发」，命中再读该条规则。
3. 回复里用一行写明：`查卡：<卡名>#2「条目要点」; pitfalls P0x` ；都没命中写 `查卡：未命中=未知领域`。
4. 用上的条目追加进 scope 的 `knowledge_used`（如 `skill_sync#2 SVN 范围`、`pitfalls#P05`）；未命中或卡里说错了的点追加进 `knowledge_gap`（一句话）。这两项只追加，不删，供收割使用。
5. 卡里的规则与本单 `plan` 冲突时停手说明，不要默默二选一。

# 2. 执行

`powershell -File runtime/etctl.ps1 begin-implement`。失败则停。只消费 stdout。

- 首次（`implement_round` 为 1 且无 `verify_feedback`）：先完成 §1，再按 `plan` 改 `write_paths`。只打开这些文件核对后改。禁止通读 `read_paths`、禁止重推改法、禁止把本单扩成 `plan` 未写的重构。文件与 plan 明显不符则停手。
- 测不过：保持 implement，追加 `verify_feedback`，`implement_round+1`；先按新现象重做 §1，再读 `read_paths` 并思考。可把与现有 `write_paths` 同目录或被其直接引用的文件追加进包。满 3 轮 `blocked`。

对 `write_paths` scoped `svn update`，基准见 [`AGENTS.md`](../../AGENTS.md)。禁止读编辑器 md。`etctl check` 后请用户验证。不要自动 harvest，不要 `svn commit`。

# 3. 版本历史

- 1.10.0（2026-10-14）：每轮与遇错时强制查卡；记录 `knowledge_used` / `knowledge_gap`。
- 1.9.0（2026-10-13）：svn 基准改链到 `AGENTS.md`。
- 1.8.0（2026-10-12）：update 后以拉下的提交为基准，本地未提交改动往上靠。
- 1.7.0（2026-10-09）：只改表改走 `/harvests`。
- 1.6.0（2026-09-23）：禁止把本单扩成 plan 未写的重构。