> 最新修改时间：2026-09-14 15:40 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L1（查找或新增编辑目标时读取）

# 0. 职责定位

本文件登记可被任务选中的编辑目标。每个目标一个 JSON，字段契约见 `runtime/schema/target.schema.json`。`target_id` 与磁盘目录名一致。知识在 `standards/<target_id>/`。

# 1. 文件索引

- [`trunk.json`](./trunk.json) — `C:\myProject\trunk`
- [`SkillEditor.json`](./SkillEditor.json) — `C:\myProject\SkillEditor`
- [`BridgeEditor.json`](./BridgeEditor.json) — `C:\myProject\BridgeEditor`
- [`ActionEditor.json`](./ActionEditor.json) — `C:\myProject\ActionEditor`

读取时机：`current_scope.json` 的 `target_id` 对应该文件。

# 2. 版本历史

- 1.2.0（2026-09-14）：登记四个已核验编辑器；删除虚构 `monster_editor`；`unity_trunk` 改名为 `trunk`。
- 1.1.0（2026-09-14）：曾误登记 `monster_editor`（已删除）。
- 1.0.0（2026-09-12）：登记第一个目标。
