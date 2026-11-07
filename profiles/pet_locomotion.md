> 最新修改时间：2026-10-27 22:55 UTC+8
> 版本号：1.0.1
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/monster_ai.md）

# 0. 职责定位

本文件只保存模块 `pet_locomotion` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/trunk.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/monster_ai.md`](../standards/monster_ai.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`pet_locomotion`
- `module_name`：宠物跟随动画
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/HotfixView/Client/Demo/Unit/; Unity/Assets/Scripts/Hotfix/Server/Demo/Map/Spell/BT/AI/`

# 2. 版本历史

- 1.0.1（2026-10-27）：t049 加上宠物攻击行为树目录，回人闩和换目标。
- 1.0.0（2026-10-27）：t049 登记。客户端宠物起步补偿，只写运动表现解析这一目录。
