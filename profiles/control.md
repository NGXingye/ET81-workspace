> 最新修改时间：2026-09-12 16:45 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L2（控制面自身任务时读取）

# 0. 职责定位

本文件是控制面模块配置。只改 workspace 规范与运行时，不改 trunk 源码。

# 1. 模块字段

- `module_id`：`control`
- `module_name`：控制面
- `profile_status`：`active`
- `allowed_write`：`workspace_only`

# 2. 版本历史

- 1.0.0（2026-09-12）：登记控制面任务配置；`workspace_only` 表示禁止写 trunk。
