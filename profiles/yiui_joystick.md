> 最新修改时间：2026-09-28 10:31 UTC+8
> 版本号：1.0.3
> 文档状态：生效
> 读取等级：L2（active_profile 为 yiui_joystick 时读取）

# 0. 职责定位

本文件是 YIUI 摇杆模块配置。只改 Main 里摇杆手写系统、扇形命中与 Gizmos 开关。不改 `zFrame` 摇杆源码、YIUI 插件与 Res。

# 1. 模块字段

- `module_id`：`yiui_joystick`
- `module_name`：YIUI摇杆
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/Panel_JoystickComponentSystem.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/LeftJoystickHitArea.cs; Unity/Assets/Scripts/ModelView/Client/Module/GM/EGMType.cs; Unity/Assets/Scripts/HotfixView/Client/Module/GM/GM_Command_JoystickRange.cs`
- `extra_forbidden`：`Unity/Assets/3party/Comm/Joystick/; Unity/Assets/Plugins/YIUIFramework/; Unity/Assets/Res/`

# 2. 版本历史

- 1.0.3（2026-09-28）：t026 harvest；扇形命中，禁区仍不改 zFrame。
- 1.0.2（2026-09-24）：放开 Gizmos 页签与左摇杆范围开关。
- 1.0.1（2026-09-24）：红区组件改到 ModelView。热更程序集不能声明实例字段。
- 1.0.0（2026-09-24）：t025 开工；左摇杆红区命中，绿区动态摇杆不改。
