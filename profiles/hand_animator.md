> 最新修改时间：2026-11-12 12:22 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/hand_animator.md）

# 0. 职责定位

本文件只保存模块 `hand_animator` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/trunk.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/hand_animator.md`](../standards/hand_animator.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`hand_animator`
- `module_name`：手部攻击状态机
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/Demo/Unit/`

# 2. 版本历史

- 1.0.0（2026-11-12）：t066 登记。角色左右手攻击武器的四套主状态机，只写这一目录。
