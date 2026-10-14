> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 cards/yiui_joystick.md）

# 0. 职责定位

本文件只保存模块 `yiui_joystick` 的机器门禁（`allowed_write` 等键），由 `runtime/guard.ps1`、`begin-implement` 读取。怎么运转、坑和验证见 [`cards/yiui_joystick.md`](../cards/yiui_joystick.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`yiui_joystick`
- `module_name`：YIUI摇杆
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/Panel_JoystickComponentSystem.cs; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/LeftJoystickHitArea.cs; Unity/Assets/Scripts/ModelView/Client/Module/GM/EGMType.cs; Unity/Assets/Scripts/HotfixView/Client/Module/GM/GM_Command_JoystickRange.cs`
- `extra_forbidden`：`Unity/Assets/3party/Comm/Joystick/; Unity/Assets/Plugins/YIUIFramework/; Unity/Assets/Res/`

# 2. 版本历史

- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/yiui_joystick.md；本文件只留门禁键。
- 1.0.3（2026-09-28）：t026 harvest；扇形命中，禁区仍不改 zFrame。
- 1.0.2（2026-09-24）：放开 Gizmos 页签与左摇杆范围开关。
- 1.0.1（2026-09-24）：红区组件改到 ModelView。热更程序集不能声明实例字段。
- 1.0.0（2026-09-24）：t025 开工；左摇杆红区命中，绿区动态摇杆不改。
