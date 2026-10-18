> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.7.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/climbing_tower.md）

# 0. 职责定位

本文件只保存模块 `climbing_tower` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/climbing_tower.md`](../standards/climbing_tower.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`climbing_tower`
- `module_name`：爬塔
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/; Unity/Assets/Scripts/Hotfix/Server/Demo/Map/Tower/; Unity/Assets/Scripts/Hotfix/Server/Module/Unit/; Unity/Assets/Scripts/HotfixView/Client/RedDot/; Unity/Assets/Scripts/HotfixView/Client/Module/GM/; Unity/Assets/Scripts/ModelView/Client/Module/GM/; Unity/Assets/Scripts/Model/Share/Module/ServerGM/; Unity/Assets/Scripts/Hotfix/Server/Module/ServerGM/; Unity/Assets/Scripts/Editor/GM/`

# 2. 版本历史

- 1.7.0（2026-10-18）：`allowed_write` 收成目录前缀菜单；删 `extra_forbidden`（YIUIFramework 移入 trunk 禁区，Res 已在）、`assemblies`、`validation`；更正脚本读取说明。
- 1.6.0（2026-10-14）：行为事实与风险提示移入 cards/climbing_tower.md；本文件只留门禁键。
- 1.5.0（2026-09-24）：t024 harvest；放开爬塔 GM 页签、ServerGM、编辑器抽屉。
- 1.4.0（2026-09-24）：t022 harvest；放开服务端 Tower、PlayerSaveData 记账、红点三闸。
- 1.3.0（2026-09-16）：t008 harvest；任务栏事实指向模块 JSON。
