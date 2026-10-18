> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L2（脚本读取门禁；人和模型读 standards/control.md）

# 0. 职责定位

本文件只保存模块 `control` 的门禁键。`allowed_write` 为 `workspace_only`：guard 拒绝一切源码写入，控制面任务只改本工作区。怎么运转、坑和验证见 [`standards/control.md`](../standards/control.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`control`
- `module_name`：控制面
- `profile_status`：`active`
- `allowed_write`：`workspace_only`

# 2. 版本历史

- 1.2.0（2026-10-18）：更正脚本读取说明。
- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/control.md；本文件只留门禁键。
- 1.0.0（2026-09-12）：登记控制面任务配置；`workspace_only` 表示禁止写 trunk。
