> 最新修改时间：2026-10-09 21:06 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L2（active_profile 为 spell_unit_phase 时读取）

# 0. 职责定位

本文件是弹体二阶段门禁。只改轨迹摘下、同一发续命与客端寿命特效。Trunk 与 BridgeEditor 的 ScriptsET 成对改。不改 `50_ai`，不改 AnimatorParamHelper，不整份覆盖 `200017501` / `200017504`。

# 1. 模块字段

- `module_id`：`spell_unit_phase`
- `module_name`：弹体二阶段
- `profile_status`：`active`
- `allowed_write`：`Unity/Assets/Scripts/Hotfix/Share/Module/Spell/; Unity/Assets/Scripts/Hotfix/Share/Module/Unit/SpellUnit/; Unity/Assets/Scripts/Model/Share/Module/Spell/; Unity/Assets/Scripts/HotfixView/Client/Demo/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/Hotfix/Share/Module/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/Hotfix/Share/Module/Unit/SpellUnit/; C:/myProject/BridgeEditor/Assets/ScriptsET/Model/Share/Module/Spell/; C:/myProject/BridgeEditor/Assets/ScriptsET/HotfixView/Client/Demo/Spell/`
- `extra_forbidden`：`Unity/Assets/Config/AI/50_ai.asset; Unity/Assets/Scripts/Model/Generate/; Unity/Assets/Config/Spell/2000175-正步炸弹鸟-炸弹小鸟/200017501.asset; Unity/Assets/Config/Spell/2000175-正步炸弹鸟-炸弹小鸟/200017504.asset`

# 2. 版本历史

- 1.0.0（2026-10-09）：t032 harvest。进度摘下与寿命结束；禁改共用 AI 与这两份行为树。
