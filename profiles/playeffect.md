> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.3.0
> 文档状态：草案
> 读取等级：L2（脚本读取门禁；人和模型读 standards/ballistic.md）

# 0. 职责定位

本文件只保存模块 `playeffect` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/ballistic.md`](../standards/ballistic.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`playeffect`
- `module_name`：技能特效弹道
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/Battle/behaviac_generated/types/Effect/; Assets/Scripts/App/Comm/Config/; Assets/Scripts/App/Comm/Battle/BallisticPreview/; Assets/Scripts/App/Comm/EditorTools/`

# 2. 版本历史

- 1.3.0（2026-10-18）：删 `allowed_read`；`allowed_write` 作目录前缀菜单；更正脚本读取说明。
- 1.2.0（2026-10-14）：行为事实与风险提示移入 cards/ballistic.md；本文件只留门禁键。
- 1.1.0（2026-09-17）：t003 弹道轨迹编辑器；EditorTools 整目录可写。t002 Play 预览不作为作者入口。
- 1.0.0（2026-09-17）：t002 轨迹预览分析补模块；discovery 已有 write_paths 时不得再留 none。
