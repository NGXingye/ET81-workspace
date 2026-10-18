> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.4.0
> 文档状态：生效
> 读取等级：L1（查找或新增编辑目标时读取）

# 0. 职责定位

本文件登记可被任务选中的编辑目标。每个目标一个 JSON，字段契约见 `runtime/schema/target.schema.json`。`target_id` 与磁盘目录名一致。知识在 `standards/`（框架与编辑器工程见 `standards/framework.md`）。走提交计划的目标才写 `hook_tasks`。本地专用（不提交）路径写 `local_only`：相对 `workspace_path`，`/` 结尾为目录，Unity `.meta` 随附；`etctl sync-ignores` 把名字同步进本机 svn 忽略，`commit-units.py` 直接按它拒绝。

# 1. 文件索引

- [`trunk.json`](./trunk.json) — `C:\myProject\trunk`
- [`SkillEditor.json`](./SkillEditor.json) — `C:\myProject\SkillEditor`
- [`BridgeEditor.json`](./BridgeEditor.json) — `C:\myProject\BridgeEditor`
- [`ActionEditor.json`](./ActionEditor.json) — `C:\myProject\ActionEditor`

读取时机：`current_scope.json` 的 `target_id` 对应该文件。

# 2. 版本历史

- 1.4.0（2026-10-18）：新增 `local_only`；SkillEditor、BridgeEditor 登记钩子号 15；trunk 禁区加 YIUIFramework。
- 1.3.1（2026-10-14）：知识位置改链到 `cards/`。
- 1.3.0（2026-10-13）：Trunk 登记提交钩子号。
- 1.2.0（2026-09-14）：登记四个已核验编辑器；删除虚构 `monster_editor`；`unity_trunk` 改名为 `trunk`。
- 1.1.0（2026-09-14）：曾误登记 `monster_editor`（已删除）。
