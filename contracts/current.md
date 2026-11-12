> 最新修改时间：2026-11-12 14:57 UTC+8
> 版本号：1.0.113
> 文档状态：生效
> 读取等级：L0（当游标 contract_ref 指向本文件时读取）
# 0. 职责定位

本文件是唯一活开卡契约：阶段、路径、验证写在 `current_scope.json`。不写长文在本文件；不写版本历史；进度不写在本文件。活卡可追写 `acceptance`（分号非空）；每一条指向 `validation`；证据记录在 `current_scope.json` 的 `evidence`。取值变化更新版本号。
# 1. 契约字段

- `task_id`：`t065`
- `contract_status`：`active`
- `goal`：`2000182 出手姿势等待留下的 Attack 由施法路径自己落下，返回协程不处理该状态。GM 服务器节点行显示单位 UState，便于核对 AI 状态。`
- `profile_ref`：`profiles/spell_unit_phase.md`
- `source_root_mode`：`normal`
- `acceptance`：`2000182 主 Buff 拆掉或施法令牌取消后，服务器上 Attack 为假，返回能转向并朝出生点移动。; GM 头顶服务器节点行在返回时若 Attack 仍在，同一行能看见攻击。追击中的转向锁不改。`
