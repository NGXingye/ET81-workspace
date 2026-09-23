> 最新修改时间：2026-09-23 10:40 UTC+8
> 版本号：1.1.0
> 文档状态：活动
> 读取等级：L0（每次冷启动必读、任务状态变更时更新）

# 0. 职责定位

本文件是任务游标的唯一权威，只保存当前状态与引用。键值预算见 `global_rules/kv_budget.md` §2。章节布局见 `global_rules/md_governance.md` §2。

取值变化只改本文件时间和字段值，不升版本号。

# 1. 工作区指针

- `workspace_root`：`C:\myProject\ET81-workspace`
- `trunk_markdown_access`：`frozen`
- `init_baseline_status`：`completed`

# 2. 源码工作副本

- `source_root`：`C:\myProject\trunk`
- `source_root_mode`：`normal`
- `version_control`：`svn`

# 3. 当前任务

- `task_id`：`none`
- `task_status`：`idle`
- `active_profile`：`none`
- `contract_ref`：`none`
- `blocked`：`false`

# 4. 版本历史

- 1.1.0（2026-09-07）：改为 11 项最小字段；路径与验收移出游标；增加 `contract_ref`。
- 1.0.0（2026-09-07）：初始化完成并冻结 trunk Markdown。
