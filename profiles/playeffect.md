> 最新修改时间：2026-09-17 23:40 UTC+8
> 版本号：1.1.0
> 文档状态：草案
> 读取等级：L2（active_profile 为 playeffect 时读取）

# 0. 职责定位

本文件是 SkillEditor PlayEffect / Directional 弹道模块配置。弹道公式与 `BallisticConfig` 对齐；编辑入口是「弹道轨迹编辑器」，不把 Play 选中 Clip 当主作者流。

# 1. 模块字段

- `module_id`：`playeffect`
- `module_name`：技能特效弹道
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/Battle/behaviac_generated/types/Effect/; Assets/Scripts/App/Comm/Config/; Assets/Scripts/App/Comm/Battle/BallisticPreview/; Assets/Scripts/App/Comm/EditorTools/`
- `allowed_read`：`Assets/Scripts/App/Comm/Battle/; Assets/Scripts/App/Comm/Config/; Assets/Scripts/App/Comm/EditorTools/`

# 2. 版本历史

- 1.1.0（2026-09-17）：t003 弹道轨迹编辑器；EditorTools 整目录可写。t002 Play 预览不作为作者入口。
- 1.0.0（2026-09-17）：t002 轨迹预览分析补模块；discovery 已有 write_paths 时不得再留 none。
