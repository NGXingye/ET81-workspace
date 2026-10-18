> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/yiui_joystick.md）

# 0. 职责定位

本文件只保存模块 `yiui_joystick` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/yiui_joystick.md`](../standards/yiui_joystick.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`yiui_joystick`
- `module_name`：YIUI摇杆
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/YIUISystem/Main/; Unity/Assets/Scripts/ModelView/Client/YIUIComponent/Main/; Unity/Assets/Scripts/ModelView/Client/Module/GM/; Unity/Assets/Scripts/HotfixView/Client/Module/GM/`

# 2. 版本历史

- 1.2.0（2026-10-18）：`allowed_write` 收成目录前缀；删 `extra_forbidden`（zFrame 摇杆移入卡片，YIUIFramework 移入 trunk 禁区）；更正脚本读取说明。
- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/yiui_joystick.md；本文件只留门禁键。
- 1.0.3（2026-09-28）：t026 harvest；扇形命中，禁区仍不改 zFrame。
- 1.0.2（2026-09-24）：放开 Gizmos 页签与左摇杆范围开关。
- 1.0.1（2026-09-24）：红区组件改到 ModelView。热更程序集不能声明实例字段。
