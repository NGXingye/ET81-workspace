> 最新修改时间：2026-09-16 15:55 UTC+8
> 版本号：1.3.0
> 文档状态：生效
> 读取等级：L2（active_profile 为 climbing_tower 时读取）

# 0. 职责定位

本文件是爬塔 UI 模块配置。只改 ClimbingTower 业务四件套与已放开的 Main 任务栏手写文件，不改 YIUI 插件与 Res。分页与任务栏计数见 `standards/trunk/modules/climbing_tower.json`。

# 1. 模块字段

- `module_id`：`climbing_tower`
- `module_name`：爬塔
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/ModelView/Client/YIUIGen/ClimbingTower/; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/ClimbingTowerTaskTracingCellComponentSystem.cs; Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/MainPanelComponentSystem.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/ClimbingTowerTaskTracingCellComponent.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/MainPanelComponent.cs`
- `extra_forbidden`：`Unity/Assets/Plugins/YIUIFramework/; Unity/Assets/Res/`
- `assemblies`：`ModelView; HotfixView`
- `validation`：`unity_editor`
- `extra_risk`：`*Gen 只许用户点「生成」；任务栏计数事实见 climbing_tower.json`

# 2. 版本历史

- 1.3.0（2026-09-16）：t008 harvest；任务栏事实指向模块 JSON。
- 1.2.0（2026-09-16）：t008 任务栏计数；放开 Main 面板与 TracingCell 手写文件。
- 1.1.0（2026-09-16）：t007 harvest 后标 active；分页事实指向模块 JSON。
- 1.0.0（2026-09-15）：t007 爬塔单关分页；Gen 只许用户点「生成」覆盖，禁止手改。
