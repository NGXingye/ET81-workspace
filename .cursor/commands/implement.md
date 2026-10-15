> 最新修改时间：2026-10-15 12:05 UTC+8
> 版本号：1.12.0
> 文档状态：生效
> 读取等级：L2（用户发出 /implement 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/implement` 时执行。`route=fast` 的小改走分析包 + 用户同意，不必本口令。

本对话已有分析包或 packet 时：不要重读游标、契约、冷启动、蓝图。直接跑命令。

拒绝并留在当前阶段：无活任务；任务只在 `contracts/candidates/`（先 `etctl promote`）；`write_paths` 或 `plan` 为空；goal/目标已变未重写包；只改表（改走 `/harvests`）；`implement_round` 已 3 且 `blocked`。

禁止读取：`global_rules/`、`contracts/_template*`、`runtime/*.ps1` 源码、`runtime/schema/`、`profiles/`（门禁由脚本读）、`targets/*.json`。不要手改契约/游标/scope 来开工。禁止重开 discovery。

# 1. 查卡（按需）

查法：用需求、报错、类名里的词对 [`standards/_index.md`](../../standards/_index.md) 的关键词，读命中卡（1–2 张）的「坑和不变量」，再扫该文末「跨模块的坑」。

何时查（卡已在本对话上下文里就不重读）：

1. 开工时读一次。
2. 出现已读卡没覆盖的模块或关键词时。
3. 同一个问题失败两次时。

优先级：源码、编译结果和用户运行验证高于卡片。卡片是过去踩坑的提示，不是结论。两者冲突时按实际情况走，并在回复或 `verify_feedback` 里把该条标为「疑似过时」；任务中途不改 `standards/`。卡里规则与 `plan` 冲突时停手说明。没命中就当未知领域，谨慎核对源码。

同一思路失败两次：先列出它依赖了哪些卡片条目或假设，逐条对照源码核实，再继续；不要沿同一方向接着打补丁。
# 2. 执行

`powershell -File runtime/etctl.ps1 begin-implement`。失败则停。只消费 stdout。

- 首次（`implement_round` 为 1 且无 `verify_feedback`）：先查卡（见 §1），再按 `plan` 改 `write_paths`。只打开这些文件核对后改。禁止通读 `read_paths`、禁止重推改法、禁止把本单扩成 `plan` 未写的重构。文件与 plan 明显不符则停手。
- 测不过：保持 implement，追加 `verify_feedback`，`implement_round+1`；按 §1 的触发条件决定是否再查卡，再读 `read_paths` 并思考。可把与现有 `write_paths` 同目录或被其直接引用的文件追加进包。满 3 轮 `blocked`。

对 `write_paths` scoped `svn update`，基准见 [`AGENTS.md`](../../AGENTS.md)。禁止读编辑器 md。`etctl check` 后请用户验证。不要自动 harvest，不要 `svn commit`。

# 3. 版本历史

- 1.12.0（2026-10-15）：查卡改为按需三种触发；源码与运行验证优先，冲突标疑似过时；同一思路失败两次先核实所依赖的卡片假设。
- 1.11.0（2026-10-15）：查卡改读 `standards/`；不再记录字段、不强制固定回复行。
- 1.10.0（2026-10-14）：每轮与遇错时强制查卡。
- 1.9.0（2026-10-13）：svn 基准改链到 `AGENTS.md`。
- 1.8.0（2026-10-12）：update 后以拉下的提交为基准，本地未提交改动往上靠。