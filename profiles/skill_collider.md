> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.1.0
> 文档状态：草案
> 读取等级：L2（脚本读取门禁；人和模型读 cards/skill_pipeline.md）

# 0. 职责定位

本文件只保存模块 `skill_collider` 的机器门禁（`allowed_write` 等键），由 `runtime/guard.ps1`、`begin-implement` 读取。怎么运转、坑和验证见 [`cards/skill_pipeline.md`](../cards/skill_pipeline.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`skill_collider`
- `module_name`：技能碰撞体导出
- `profile_status`：`draft`
- `allowed_write`：`Assets/Editor/SkillEditor/ControlColliderCS.cs; Assets/Editor/SkillEditor/SkillEditor2.cs`
- `allowed_read`：`Assets/Editor/SkillEditor/; Assets/3party/Comm/FunPlugin/Editor/EffectColliderData.cs; Assets/Scripts/App/Comm/Battle/SkillDataBase.cs`

# 2. 版本历史

- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/skill_pipeline.md；本文件只留门禁键。
- 1.0.0（2026-09-21）：t012 导出碰撞体空数据与错误骨架分析。
