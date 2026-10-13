> 最新修改时间：2026-09-24 16:10 UTC+8
> 版本号：1.5.0
> 文档状态：生效
> 读取等级：L2（active_profile 为 climbing_tower 时读取）

# 0. 职责定位

本文件是爬塔 UI 模块配置。只改 ClimbingTower 业务四件套、已放开的 Main 任务栏手写文件、三闸辅助、红点、服务端 Tower 记账，以及爬塔 GM / 编辑器抽屉。不改 YIUI 插件与 Res。分页、任务栏、三闸与 GM 事实见 `standards/trunk/modules/climbing_tower.json`。

# 1. 模块字段

- `module_id`：`climbing_tower`
- `module_name`：爬塔
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/ClimbingTowerTaskTracingCellComponentSystem.cs; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/MainPanelComponentSystem.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/ClimbingTowerTaskTracingCellComponent.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/MainPanelComponent.cs; Unity/Assets/Scripts/Hotfix/Server/Demo/Map/Tower/; Unity/Assets/Scripts/Hotfix/Server/Module/Unit/PlayerSaveDataComponentSystem.cs; Unity/Assets/Scripts/HotfixView/Client/RedDot/TowerUnlockRedDotHelper.cs; Unity/Assets/Scripts/HotfixView/Client/Module/GM/; Unity/Assets/Scripts/ModelView/Client/Module/GM/EGMType.cs; Unity/Assets/Scripts/Model/Share/Module/ServerGM/; Unity/Assets/Scripts/Hotfix/Server/Module/ServerGM/; Unity/Assets/Scripts/Editor/GM/GMEditorParamDrawers.cs`
- `extra_forbidden`：`Unity/Assets/Plugins/YIUIFramework/; Unity/Assets/Res/`
- `assemblies`：`ModelView; HotfixView; Hotfix; Model`
- `validation`：`unity_editor`
- `extra_risk`：`*Gen 只许用户点「生成」；行为事实见 climbing_tower.json；ServerGM 目录只加爬塔命令，禁止顺手改其它 GM`

# 2. 版本历史

- 1.5.0（2026-09-24）：t024 harvest；放开爬塔 GM 页签、ServerGM、编辑器抽屉。
- 1.4.0（2026-09-24）：t022 harvest；放开服务端 Tower、PlayerSaveData 记账、红点三闸。
- 1.3.0（2026-09-16）：t008 harvest；任务栏事实指向模块 JSON。
- 1.2.0（2026-09-16）：t008 任务栏计数；放开 Main 面板与 TracingCell 手写文件。
- 1.1.0（2026-09-16）：t007 harvest 后标 active；分页事实指向模块 JSON。
