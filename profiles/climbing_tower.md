> 最新修改时间：2026-10-15 10:40 UTC+8
> 版本号：1.6.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/climbing_tower.md）

# 0. 职责定位

本文件只保存模块 `climbing_tower` 的机器门禁（`allowed_write` 等键），由 `runtime/guard.ps1`、`begin-implement` 读取。怎么运转、坑和验证见 [`standards/climbing_tower.md`](../standards/climbing_tower.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`climbing_tower`
- `module_name`：爬塔
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/ClimbingTowerTaskTracingCellComponentSystem.cs; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/MainPanelComponentSystem.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/ClimbingTowerTaskTracingCellComponent.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/MainPanelComponent.cs; Unity/Assets/Scripts/Hotfix/Server/Demo/Map/Tower/; Unity/Assets/Scripts/Hotfix/Server/Module/Unit/PlayerSaveDataComponentSystem.cs; Unity/Assets/Scripts/HotfixView/Client/RedDot/TowerUnlockRedDotHelper.cs; Unity/Assets/Scripts/HotfixView/Client/Module/GM/; Unity/Assets/Scripts/ModelView/Client/Module/GM/EGMType.cs; Unity/Assets/Scripts/Model/Share/Module/ServerGM/; Unity/Assets/Scripts/Hotfix/Server/Module/ServerGM/; Unity/Assets/Scripts/Editor/GM/GMEditorParamDrawers.cs`
- `extra_forbidden`：`Unity/Assets/Plugins/YIUIFramework/; Unity/Assets/Res/`
- `assemblies`：`ModelView; HotfixView; Hotfix; Model`
- `validation`：`unity_editor`

# 2. 版本历史

- 1.6.0（2026-10-14）：行为事实与风险提示移入 cards/climbing_tower.md；本文件只留门禁键。
- 1.5.0（2026-09-24）：t024 harvest；放开爬塔 GM 页签、ServerGM、编辑器抽屉。
- 1.4.0（2026-09-24）：t022 harvest；放开服务端 Tower、PlayerSaveData 记账、红点三闸。
- 1.3.0（2026-09-16）：t008 harvest；任务栏事实指向模块 JSON。
- 1.2.0（2026-09-16）：t008 任务栏计数；放开 Main 面板与 TracingCell 手写文件。
