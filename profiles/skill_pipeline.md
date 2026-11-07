> 最新修改时间：2026-11-06 22:37 UTC+8
> 版本号：1.4.0
> 文档状态：草案
> 读取等级：L2（脚本读取门禁；人和模型读 standards/skill_pipeline.md）

# 0. 职责定位

本文件只保存模块 `skill_pipeline` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/skill_pipeline.md`](../standards/skill_pipeline.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`skill_pipeline`
- `module_name`：技能编辑器本地管线
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/EditorTools/; C:/myProject/BridgeEditor/Assets/Scripts/Editor/; Assets/3party/Comm/FunPlugin/Editor/EffectColliderData.cs; C:/myProject/BridgeEditor/Assets/3party/Comm/FunPlugin/Editor/EffectColliderData.cs; C:/myProject/BridgeEditor/Assets/ScriptsET/Model/Share/Module/Spell/LaunchPointConfig.cs; C:/myProject/trunk/Unity/Assets/Scripts/Model/Share/Module/Spell/LaunchPointConfig.cs; C:/myProject/trunk/Unity/Assets/Scripts/Hotfix/Share/Module/Unit/SpellUnit/BuffSensorSystem.Pose.cs; C:/myProject/trunk/Unity/Assets/Scripts/Hotfix/Share/Module/Unit/SpellUnit/SpellUnitFollowLaunchPointHelper.cs; C:/myProject/trunk/Unity/Assets/Scripts/Hotfix/Share/Module/Unit/Equip/DamageShapeHelper.cs; C:/myProject/trunk/Unity/Assets/Scripts/Hotfix/Share/Module/Unit/Equip/DamageShapeHelper.Prepared.cs`

# 2. 版本历史

- 1.4.0（2026-11-06）：t058 写入挂点上方向：放行两份 EffectColliderData、Bridge 与 trunk 的 LaunchPointConfig，以及 BuffSensor 姿态、跟随挂点和伤害形状。
- 1.3.0（2026-10-18）：`allowed_write` 收成 EditorTools 与 Bridge Editor 两个前缀；删 `allowed_read`、`extra_forbidden`（禁改文件移入卡片）；更正脚本读取说明。
- 1.2.0（2026-10-18）：去掉 svn add / svn commit 记号，本地专用改以 svn 忽略为准；更正脚本读取说明。
- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/skill_pipeline.md；本文件只留门禁键。
- 1.0.3（2026-09-29）：t027 中途 harvest：构建可替换 playable；写 SkillSync/Headless/SpellConversion；禁改 ControlColliderCS 源码（只反射导出）；禁 {prefab}_colliderdata 当技能挂点。
