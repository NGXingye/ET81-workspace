> 最新修改时间：2026-11-07 19:55 UTC+8
> 版本号：1.6.31
> 文档状态：生效
> 读取等级：L1（活卡占用时停写发现卡前读取）

# 0. 职责定位

本目录停放未激活的发现卡，最多 2 份 JSON。不是第二张活契约，不能 /implement，即使 route=fast 也不能改 trunk。活卡 idle 后用户明确说再 etctl promote <task_id> 写入活卡。插队时 etctl interrupt 把插队卡放本目录（parked）再和 implement。新卡和活卡候选项不复刻；写完或删除本目录 JSON 后成功再写 promote/interrupt/idle，也不得写本目录外文件和活卡号。

新号只来自 `etctl next-id`（占用集：收口账 ∪ 活卡 ∪ 候选文件名 ∪ 活动/暂留提交计划的 task_id），禁止用对话上下文猜号。

# 1. 文件清单

当前 0 个候选。活卡 none。

发现模板在活卡已 idle 时只写成 `<task_id>.json`，复制 `../_template_scope.json` 填 goal；插队卡复制 `../_template_interrupt.json`。未 park 的 phase 应为 discovery 或 awaiting_scope。最多 2 条。不写版本历史；进度不写在本文件。
