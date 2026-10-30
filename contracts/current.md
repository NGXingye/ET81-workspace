> 最新修改时间：2026-10-30 21:36 UTC+8
> 版本号：1.0.75
> 文档状态：生效
> 读取等级：L0（当游标 contract_ref 指向本文件时读取）
# 0. 职责定位

本文件是唯一活开卡契约：阶段、路径、验证写在 `current_scope.json`。不写长文在本文件；不写版本历史；进度不写在本文件。活卡可追写 `acceptance`（分号非空）；每一条指向 `validation`；证据记录在 `current_scope.json` 的 `evidence`。取值变化更新版本号。
# 1. 契约字段

- `task_id`：`t051`
- `contract_status`：`active`
- `goal`：打开技能管线不再因磁盘上没有的缓存弹道号报错。接入骨骼挂点与不变区挂点分开；接入特效挂点写入转出的阶段。发射页按阶段或事件显示对应槽。阶段碰撞断言对准接入轨迹时刻。
- `profile_ref`：`profiles/skill_pipeline.md`
- `source_root_mode`：`normal`
- `acceptance`：按 current_scope.json 的 validation 逐条验收。
