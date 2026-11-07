> 最新修改时间：2026-11-07 19:55 UTC+8
> 版本号：1.0.100
> 文档状态：生效
> 读取等级：L0（当游标 contract_ref 指向本文件时读取）
# 0. 职责定位

本文件是唯一活开卡契约：阶段、路径、验证写在 `current_scope.json`。不写长文在本文件；不写版本历史；进度不写在本文件。活卡可追写 `acceptance`（分号非空）；每一条指向 `validation`；证据记录在 `current_scope.json` 的 `evidence`。取值变化更新版本号。
# 1. 契约字段

- `task_id`：`none`
- `contract_status`：`idle`
