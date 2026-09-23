> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：1.10.0
> 文档状态：生效
> 读取等级：L2（仅用户了解流程；Agent 禁止为开工或收口打开）

# 0. 职责定位

本文件是给**用户**看的管线蓝图。Agent 硬约束在 `AGENTS.md`。任务状态只看 `project_cursor.md`。Agent 暖会话与 `/implement` `/harvest` 回合不要打开本文。

# 1. 流程

```text
你提需求 / 问题
        │
        ▼
   discovery     必须写出分析包（含 plan）
        │
        ├─ 模型标 route=fast，你同意 ──► 改 write_paths（不必 /implement）
        │                                      │
        │                                      ▼
        │                                   你验证 ──► /harvest ──► idle
        │
        ├─ 需要你看范围 ──► awaiting_scope
        │                      ├─ /implement ──► implement ──► 你验证
        │                      │                      ├─ 通过 ──► /harvest
        │                      │                      └─ 失败 ──► 仍 implement
        │                      ├─ 你改配置/表 ──► 验证后 /harvest
        │                      └─ 目标变了 ──► 你明确说才退回 discovery
        └─ 继续提问 ──► 留在 discovery
```

继续提问默认留在 discovery。normal 改码必须 `/implement`；口语不够。`route=fast` 且你明确同意时，「改吧」即可改活卡 `write_paths`。`/harvest` 不必先 `/implement`。活卡占用时新分析写入 `contracts/candidates/`（最多 2），不能改 trunk；idle 后点名 `etctl promote <task_id>`。热插队用新号 + `etctl interrupt`，可勾住 implement；harvest 后按原阶段 promote 主力。`/harvest` 回写 `standards/`（模型事实）与 `profiles/`（门禁有变才改）。未授权不 `svn commit`。

# 2. 分析怎么读事实

1. 本控制面 `catalog.json` 命中的 JSON。
2. 仍缺：`editor_md_paths` 里点名的编辑器 md。
3. 仍缺：seed / 模块路由的代码入口。

分析模型从你的需求和读过的代码提炼要点、结论，写入 `evidence.note` 与 `plan`（一行一项改法，不粘贴源码）。你看范围，不手填分析包。`route=fast` 或首次 `/implement` 都按 plan 改，不再全量读代码推设计。

# 3. 改代码与测不过

`route=fast`：分析包已写、你明确同意后，模型对 `write_paths` scoped `svn update` 再按 `plan` 改，不跑 `begin-implement`。你验证后 `/harvest`。

normal：同意后你打 `/implement`。模型先跑：

`powershell -File runtime/etctl.ps1 begin-implement`

该命令把契约升为 `active`、阶段改为 `implement`、游标改为 `in_progress`，并打印工作令（含 `plan`）。不要手改这三份文件来开工，不要读 runtime 源码。首次按 `plan` 改 `write_paths`。

- 没按包改：同一包再改 `write_paths`。
- 按包改了仍失败：留在 implement，此时才读 `read_paths`，可把邻接文件追加进 `write_paths`。`implement_round` +1，把报错追加进 `verify_feedback`。不改 `goal`/`target_id`，不加 `scope_revision`。
- 同一包最多 3 轮。仍失败 → `blocked`，停手。继续局部、授权路径、或退回分析，由你选。

权威包是 `current_scope.json`。`write_paths` 非空时必须有 `plan`。缺 `read_paths` 时等于 `write_paths`。缺 `implement_round` 时视为 1。`begin-implement` 从 `awaiting_verify` 再进入时自动 +1。

# 4. 版本历史

- 1.10.0（2026-09-23）：插队可勾住 implement；回来原阶段。
- 1.9.0（2026-09-23）：热插队新号；harvest 后 promote 被勾住的主力。
- 1.8.0（2026-09-17）：fast 小改你同意即可改；harvest 不必先 implement。
- 1.7.0（2026-09-17）：候选分析包最多 2；implement 只对活卡。
- 1.6.1（2026-09-17）：标明 plan 由分析模型提炼，用户不手填。
