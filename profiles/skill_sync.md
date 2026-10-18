> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.3.0
> 文档状态：草案
> 读取等级：L2（脚本读取门禁；人和模型读 standards/skill_sync.md）

# 0. 职责定位

本文件只保存模块 `skill_sync` 的门禁键。`allowed_write` 是目录前缀菜单（相对 `target_id` 的 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告；实际可写以活卡 `write_paths` 为准（guard）。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在卡片。怎么运转、坑和验证见 [`standards/skill_sync.md`](../standards/skill_sync.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`skill_sync`
- `module_name`：技能输出同步
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/EditorTools/; Assets/Scripts/App/Comm/Battle/Scripts/TimelineTracks/Battle/PlayAnimation/; C:/myProject/BridgeEditor/Assets/Scripts/Editor/`

# 2. 版本历史

- 1.3.0（2026-10-18）：`allowed_write` 收成 EditorTools、PlayAnimation、Bridge Editor 三个前缀；删 `allowed_read`、`extra_forbidden`（禁改文件移入卡片）；更正脚本读取说明。
- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/skill_sync.md；本文件只留门禁键。
- 1.0.8（2026-10-14）：改 Key 列入可写。
- 1.0.7（2026-10-14）：发射页采样与预览列入可写。
- 1.0.6（2026-10-13）：发射页公共弹道初始化列入可写。
