> 最新修改时间：2026-09-21 11:25 UTC+8
> 版本号：1.0.0
> 文档状态：草案
> 读取等级：L2（active_profile 为 skill_collider 时读取）

# 0. 职责定位

本文件是 SkillEditor 碰撞体导出模块配置。只改导出与变体路由，不改烘焙导入与弹道预览。

# 1. 模块字段

- `module_id`：`skill_collider`
- `module_name`：技能碰撞体导出
- `profile_status`：`draft`
- `allowed_write`：`Assets/Editor/SkillEditor/ControlColliderCS.cs; Assets/Editor/SkillEditor/SkillEditor2.cs`
- `allowed_read`：`Assets/Editor/SkillEditor/; Assets/3party/Comm/FunPlugin/Editor/EffectColliderData.cs; Assets/Scripts/App/Comm/Battle/SkillDataBase.cs`

# 2. 版本历史

- 1.0.0（2026-09-21）：t012 导出碰撞体空数据与错误骨架分析。
