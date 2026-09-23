> 最新修改时间：2026-09-23 11:20 UTC+8
> 版本号：1.6.0
> 文档状态：生效
> 读取等级：L1（活卡占用时停放分析包前读取）

# 0. 职责定位

本目录停放未开工分析包，最多 2 个 JSON。不是第二张活契约，不能 `/implement`，即使 `route=fast` 也不能改 trunk。活卡 idle 且用户点名后，由 `etctl promote <task_id>` 写入活卡。热插队时 `etctl interrupt` 把主力勾进本目录（`parked`，可含 implement），新号升活卡。

# 1. 文件索引

当前 1 个候选：[`t019.json`](./t019.json)（提交日志补 `task:15`/`task:32`）。活卡 idle，可 promote。

分析模型在活卡非 idle 时写入 `<task_id>.json`（复制 `../_template_scope.json` 加 `goal`；热插队复制 `../_template_interrupt.json`）。未 park 的 `phase` 仅为 `discovery` 或 `awaiting_scope`。最多 2 个。

# 2. 版本历史

- 1.6.0（2026-09-23）：parked 可含 implement；回来原阶段。
- 1.5.0（2026-09-23）：热插队 park；模板 `_template_interrupt.json`。
- 1.4.7（2026-09-22）：停放 t019（svn 提交日志过 pre-commit hook）。
- 1.4.6（2026-09-22）：t016 harvest，候选仍空。
- 1.4.5（2026-09-22）：t016 已 promote，候选清空。
