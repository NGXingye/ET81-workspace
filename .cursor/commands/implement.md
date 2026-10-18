> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.18.0
> 文档状态：生效
> 读取等级：L2（用户发出 /implement 时由 Cursor 注入）

# 0. 职责定位

仅当用户在本轮发出 `/implement` 时执行。`route=fast` 的小改走分析包 + 用户同意，不必本口令。

本对话已有分析包或 packet 时：不要重读游标、契约、冷启动、蓝图。直接跑命令。

拒绝并留在当前阶段：无活任务；任务只在 `contracts/candidates/`（先 `etctl promote`）；`write_paths` 或 `plan` 为空；goal、target 或 profile 要变（换目标：新开候选，`/harvests` → idle → promote）；只改表（改走 `/harvests`）；`implement_round` 已 3 且 `blocked`。promote 后范围只在 `current_scope.json`（候选文件已删）；scope 只有 `task_id`、`phase`、`scope_revision` 三键是空闲形态，不是被重置。

禁止读取：`global_rules/`、`contracts/_template*`、`runtime/*.ps1` 源码、`runtime/schema/`、`profiles/`（门禁由脚本读）、`targets/*.json`。不要手改契约/游标/scope 来开工（补活卡除外，见下）。禁止重开 discovery。

补活卡（同一 goal 下用户细化或补充需求，阶段为 discovery / implement / awaiting_verify）：活卡是合法执行的平台，冷启动建立后增量推进，不因需求细化而重置重写。直接改 `current_scope.json` 与 `current.md`，只追加：`plan`、`validation` 与 `current.md` 的 `acceptance` 加项，被新需求推翻的旧项原地改；`write_paths` 加项须用户本轮同意（guard 实时读它，加上即可写源码）；加完跑 `etctl check`，报 `PROFILE_MENU` 说明越出 profile 前缀，放宽 profile 须用户同意，由 `/harvest` 改。每次 `scope_revision` +1，并在 `evidence` 追加 `{"path": "user", "note": "amend rN：<用户需求摘要>", "status": "observed"}`（N 为新修订号）。不覆盖 goal、target、profile；不在 `current.md` 写自由文本（idle 会保留）；不升 `current.md` 版本号。`implement_round` 不因细化重置；plan 原本没有的新需求可重置为 1。goal、target 或 profile 要变就是换目标，走新任务。

# 1. 查卡（按需）

查法：用需求、报错、类名里的词对 [`standards/_index.md`](../../standards/_index.md) 的关键词，读命中卡（1–2 张）的「坑和不变量」，再扫该文末「跨模块的坑」。

何时查（卡已在本对话上下文里就不重读）：

1. 开工时读一次。
2. 出现已读卡没覆盖的模块或关键词时。
3. 同一个问题失败两次时。

优先级：源码、编译结果和用户运行验证高于卡片。卡片是过去踩坑的提示，不是结论。两者冲突时按实际情况走，并在回复或 `verify_feedback` 里把该条标为「疑似过时」；任务中途不改 `standards/`。卡里规则与 `plan` 冲突时停手说明。没命中就当未知领域，谨慎核对源码。

同一思路失败两次：先列出它依赖了哪些卡片条目或假设，逐条对照源码核实，再继续；不要沿同一方向接着打补丁。
# 2. SVN 新鲜度

范围：只对路径做 `svn update`——白名单、`read_paths`、`write_paths`、报错堆栈命中的文件。status 为 `?`、`I` 的本地路径与 `add_file` 新文件不做 update，不算失败。禁止整树 update；不碰 `Library/`、`Res/`、`Bundles/`。基准见 [`AGENTS.md`](../../AGENTS.md)。

何时 update：

1. 开工：保持现有做法，对 `write_paths` 白名单 scoped update。
2. 中途小范围 update 后再分析：行为与别人描述或最新版本对不上；切换到另一个模块或报错出现新文件；连续两次「对不上」的失败。
3. 本单自己改出来的编译错误：默认不 update，先修自己的改动。

Trunk 上动手分析前先做廉价检查：对关键文件 `svn status` 加 `svn log -l 3`（或 `svn info`）。有近期相关提交就先 update 再分析。

没有 update 就下结论时，回复里明确写「基于本地 WC，未对齐最新 SVN」。
# 3. 执行

`powershell -File runtime/etctl.ps1 begin-implement`。失败则停。只消费 stdout。

- 首次（`implement_round` 为 1 且无 `verify_feedback`）：先查卡（见 §1），再按 `plan` 改 `write_paths`。只打开这些文件核对后改。禁止通读 `read_paths`、禁止重推改法、禁止把本单扩成 `plan` 未写的重构。文件与 plan 明显不符则停手。
- 开工核对 `plan`：本地工具代码是否写了拆 / 合 / 不动及理由（信号见 [`code_structure.md`](../../standards/code_structure.md)，按需查卡）；技能流水线任务末行是否写了本次让 [`skill_spec.md`](../../standards/skill_spec.md) 前进哪一步、是否新增约定或补丁。缺了不拒绝、不为此改 `plan`，在开工回复里补一句判断；新增补丁由 `/harvest` 登记。
- 测不过：保持 implement，追加 `verify_feedback`，`implement_round+1`；按 §1 的触发条件决定是否再查卡，再读 `read_paths` 并思考。可把与现有 `write_paths` 同目录或被其直接引用的文件追加进包。满 3 轮 `blocked`。

按 §2 做 scoped `svn update`。禁止读编辑器 md。`etctl check` 后请用户验证。不要自动 harvest，不要 `svn commit`。

# 4. 版本历史

- 1.18.0（2026-10-18）：补活卡加 `write_paths` 后用机检核对 profile 前缀。
- 1.17.0（2026-10-18）：plan 要求改为开工核对、缺了不拒绝；结构规则改读 `code_structure` 卡；`?`、`I` 路径与新文件不 update；说明 promote 后范围位置。
- 1.16.0（2026-10-17）：新增补活卡：同一 goal 下增量追加并记 amend；换目标走新任务。
- 1.15.0（2026-10-17）：技能流水线任务的 plan 说明规格进度与新增补丁，补丁登记进 skill_spec。
- 1.14.0（2026-10-16）：本地工具代码按 code_governance 处理，plan 写明拆 / 合 / 不动及理由。