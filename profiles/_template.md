> 最新修改时间：2026-09-07 15:15 UTC+8
> 版本号：1.1.0
> 文档状态：草案
> 读取等级：L2（复制为本模块配置后读取）

# 0. 职责定位

本文件是模块配置模板。复制为 `profiles/<module_id>.md` 后只保留有信息量的键值项。预算见 `global_rules/kv_budget.md` §3。

# 1. 最小必要（必须 4 项）

- `module_id`：`（与文件名一致）`
- `module_name`：`（中文名）`
- `profile_status`：`draft`
- `allowed_write`：`（相对 source_root 的路径，分号分隔）`

# 2. 可选（缺省可整节删除）

仅当不等于缺省时才写，总数不得超过 10：

- `allowed_read`：读范围宽于写时才写
- `extra_forbidden`：相对全局禁止的额外禁止或例外
- `assemblies`：跨层且需要显式提醒
- `validation`：超出「View→Unity / Share·Server→dotnet」时
- `extra_risk`：超出全局高风险条件时
- `workspace_folders`：与允许读的顶层目录不一致时

# 3. 版本历史

- 1.1.0（2026-09-07）：改为最小 4 字段 + 可选省略，上限 10。
- 1.0.0（2026-09-07）：首版完整清单式模板。
