> 最新修改时间：2026-11-11 14:45 UTC+8
> 版本号：1.16.0
> 文档状态：生效
> 读取等级：L1（路径发现或登记变更时读取）

# 0. 职责定位

本文件是 ET81-workspace 受管理文档的唯一导航表，只登记本 workspace 内文件的位置和读取时机。

任务状态只写入 `project_cursor.md`。活卡范围只写入 `contracts/current_scope.json`。未开工分析写入 `contracts/candidates/`（最多 2）。活动提交计划与本地未交模块索引在 `contracts/`，细则见该目录索引。

# 1. 读取等级

- **L0**：Always Apply `AGENTS.md`。无本任务上下文才读游标；契约与 scope 仅当被引用。
- **L1**：查找文档、改 Markdown 结构或字段时。
- **L2**：对照模板；§5 用户流程图给人看，Agent 不为开工/收口打开。

# 2. 根目录控制文件

- [`AGENTS.md`](./AGENTS.md) — L0；最高规范权威。
- `.cursor/rules/et81-cold-start.mdc` — 无本任务上下文时的冷启动读序。
- `.cursor/commands/implement.md`、`.cursor/commands/harvest.md`、`.cursor/commands/harvests.md`、`.cursor/commands/interrupt.md` — 阶段升级口令。
- [`project_cursor.md`](./project_cursor.md) — L0；任务游标。
- [`project_index.md`](./project_index.md) — L1；本文档。
- [`active.code-workspace`](./active.code-workspace) — 多根工作区入口。
- [`commit.cmd`](./commit.cmd) — 双击打开提交窗口。逻辑在 `runtime/commit-units.py`。
- `.cursor/hooks.json` — 写源码前调用 `runtime/guard.ps1`；候选 JSON 变更后同步候选索引。

# 3. 受管理目录

- [`global_rules/_index.md`](./global_rules/_index.md) — 文档法、键值预算、代码门禁、运行时写法。
- [`contracts/_index.md`](./contracts/_index.md) — 唯一活卡与 scope、最多 2 个候选分析包、活动提交计划 `commit_plan.json`。`held_commit_plan.json` 只收不在 `local_only`、且这轮不交的文件。
- [`profiles/_index.md`](./profiles/_index.md) — 模块写入门禁（脚本读）；行为知识在 `standards/`。
- [`targets/_index.md`](./targets/_index.md) — 编辑目标 JSON。提交工单号在 `hook_tasks`，不提交的路径在 `local_only`。
- [`standards/_index.md`](./standards/_index.md) — 模块知识卡（关键词路由 + 跨模块的坑）、收口账与 trunk 文档授权审计。
- [`runtime/_index.md`](./runtime/_index.md) — 已登记运行时脚本与 schema；未登记脚本禁止存在。调度入口 `runtime/etctl.ps1`（`check`、`next-id`、`promote`、`interrupt`、`begin-implement`、`idle`、`hold-plan`、`guard`）。

# 4. 登记规则

新增受管理 Markdown 或 JSON 数据时必须符合 `global_rules/md_governance.md`，并在最近一级 `_index.md` 登记。不登记 trunk 路径。新任务号只经 `etctl next-id`。

# 5. 用户流程图

给人看，不重复硬约束；口令步骤见 `.cursor/commands/`。

```text
你提需求 / 问题
        │
        ▼
  新号只经 etctl next-id
        │
        ▼
   discovery     必须写出分析包（含 plan）
        │
        ├─ 活卡被占且不是本卡 ──► 候选（最多 2）；idle 后你点名才 promote
        │
        ├─ 模型标 route=fast，你同意 ──► 改 write_paths（不必 /implement）
        │                                      │
        │                                      ▼
        │                                   你验证 ──► /harvest 不停卡
        │                                              /harvests ──► idle
        │
        ├─ 需要你看范围 ──► awaiting_scope
        │                      ├─ /implement ──► implement ──► 你验证
        │                      │                      ├─ 通过 ──► /harvest 不停卡；/harvests ──► idle
        │                      │                      └─ 失败 ──► 仍 implement
        │                      ├─ 你改配置/表 ──► 验证后 /harvests
        │                      └─ 目标或门禁变了 ──► 新开候选，不在本卡里换
        ├─ 要插队 ──► /interrupt（原卡勾回候选）
        └─ 继续提问 ──► 留在 discovery
```

知识：每轮改代码前和遇到报错 / 新需求时，模型先查 `standards/` 的模块卡；`/harvest` 只把新的、可迁移的经验写进卡，不记账、不收回 idle。`/harvests` 才记账、写活动提交计划并收回 idle。准备交的进 `commit_plan.json`；不在 `local_only`、这轮又不交的，才改 `held_commit_plan.json`；整单都不交才 `etctl hold-plan`。授权后用 `commit.cmd` 一笔一笔交。idle 之后仍可改 `standards/`、活动提交计划和 held。

# 6. 版本历史

- 1.16.0（2026-11-11）：held 不收 local_only，只收这轮不交、以后还能交的文件。
- 1.15.0（2026-11-09）：补上活动提交计划、held 模块索引、etctl 与收口后的提交窗口。
- 1.14.0（2026-10-15）：并入用户流程图（原 project_pipeline.md）；知识卡收回 `standards/`。
- 1.13.0（2026-10-14）：登记 `cards/` 知识层与 `archive/`；profiles 降为脚本门禁。
- 1.12.0（2026-10-13）：登记 `.cursor/hooks.json` 源码写入拦截。
