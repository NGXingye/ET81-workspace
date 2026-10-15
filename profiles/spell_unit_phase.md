> 最新修改时间：2026-10-15 10:40 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/ballistic.md）

# 0. 职责定位

本文件只保存模块 `spell_unit_phase` 的机器门禁（`allowed_write` 等键），由 `runtime/guard.ps1`、`begin-implement` 读取。怎么运转、坑和验证见 [`standards/ballistic.md`](../standards/ballistic.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`spell_unit_phase`
- `module_name`：弹体二阶段
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/Hotfix/Share/Module/Spell/; Unity/Assets/Scripts/Hotfix/Share/Module/Unit/SpellUnit/; Unity/Assets/Scripts/Model/Share/Module/Spell/; Unity/Assets/Scripts/HotfixView/Client/Demo/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/Hotfix/Share/Module/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/Hotfix/Share/Module/Unit/SpellUnit/; C:/myProject/BridgeEditor/Assets/ScriptsET/Model/Share/Module/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/HotfixView/Client/Demo/Spell/`
- `extra_forbidden`：`Unity/Assets/Config/AI/50_ai.asset; Unity/Assets/Scripts/Model/Generate/; Unity/Assets/Config/Spell/2000175-正步炸弹鸟-炸弹小鸟/200017501.asset; Unity/Assets/Config/Spell/2000175-正步炸弹鸟-炸弹小鸟/200017504.asset`

# 2. 版本历史

- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/ballistic.md；本文件只留门禁键。
- 1.0.0（2026-10-09）：t032 harvest。进度摘下与寿命结束；禁改共用 AI 与这两份行为树。
