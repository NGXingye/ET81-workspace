> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/ballistic.md）

# 0. 职责定位

本文件只保存模块 `spell_unit_phase` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/ballistic.md`](../standards/ballistic.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`spell_unit_phase`
- `module_name`：弹体二阶段
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/Hotfix/Share/Module/Spell/; Unity/Assets/Scripts/Hotfix/Share/Module/Unit/SpellUnit/; Unity/Assets/Scripts/Model/Share/Module/Spell/; Unity/Assets/Scripts/HotfixView/Client/Demo/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/Hotfix/Share/Module/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/Hotfix/Share/Module/Unit/SpellUnit/; C:/myProject/BridgeEditor/Assets/ScriptsET/Model/Share/Module/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/HotfixView/Client/Demo/Spell/`

# 2. 版本历史

- 1.2.0（2026-10-18）：删 `extra_forbidden`（50_ai 与两份行为树移入 ballistic 卡，Generate 已在 trunk 禁区）；更正脚本读取说明。
- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/ballistic.md；本文件只留门禁键。
- 1.0.0（2026-10-09）：t032 harvest。进度摘下与寿命结束；禁改共用 AI 与这两份行为树。
