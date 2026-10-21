> 最新修改时间：2026-10-17 11:54 UTC+8
> 版本号：1.0.64
> 文档状态：生效
> 读取等级：L0（仅当游标 contract_ref 指向本文件时读取）

# 0. 职责定位

本文件是唯一活开工契约。阶段、路径与证据在 `current_scope.json`，不写进本文件。不写版本历史。进度不写在本文件。补活卡不再追加 `acceptance`（保持非空，可一句指向 `validation`），记录写 `current_scope.json` 的 `evidence`；取值变化不升版本号。

# 1. 契约字段

- `task_id`：`none`
- `contract_status`：`idle`
