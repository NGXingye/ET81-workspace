> 最新修改时间：2026-10-14 23:00 UTC+8
> 版本号：1.6.26
> 文档状态：生效
> 读取等级：L1（活卡占用时停放分析包前读取）

# 0. 职责定位

本目录停放未开工分析包，最多 2 个 JSON。不是第二张活契约，不能 `/implement`，即使 `route=fast` 也不能改 trunk。活卡 idle 且用户点名后，由 `etctl promote <task_id>` 写入活卡。热插队时 `etctl interrupt` 把主力勾进本目录（`parked`，可含 implement），新号升活卡。候选行不手改：写入或删除本目录 JSON 后由钩子重写；`promote`、`interrupt`、`idle` 也会重写。机检对照文件名和活卡号。

# 1. 文件索引

当前 1 个候选：[`t036.json`](./t036.json)（一份技能只留一份 colliderdata，碰撞盒与发射点采样按发射物一一对应）。活卡 none。

分析模型在活卡非 idle 时只写入 `<task_id>.json`（复制 `../_template_scope.json` 加 `goal`；热插队复制 `../_template_interrupt.json`），不改候选行。未 park 的 `phase` 仅为 `discovery` 或 `awaiting_scope`。最多 2 个。不写版本历史。进度不写在本文件。
