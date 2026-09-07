> 最新修改时间：2026-09-07 16:55 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L1（改游标、模块配置或开工契约的键值项时必读）

# 0. 职责定位

本文件只约束三种文件内部的**键值项**的最小集、条件项、可选项和硬上限。键值项长成下面这样，不是一级标题。

本文件**不是**章节标题规范。`# 0` / `# 1` / `# 2` 属于每个 md 自己的章节布局，规则在 [`md_governance.md`](./md_governance.md) §2。不要把键值名写成一级标题，也不要给每个知识文档编一份「字段表」。

# 1. 通则

1. **最小必要**：无该项则无法冷启动或无法判定写权限的，必须始终存在。
2. **条件项**：仅当触发条件成立时才出现；计入上限，不计入最小集。
3. **可选项**：缺省等于「继承默认」；写了就必须有信息量，禁止填 `none` 占位凑数。
4. **硬上限**：键值行数不得超过该类上限。违规时按下面处置表，禁止扩上限。
5. **机检行**格式固定为：

```text
- `name`：`value`
```

列表型值用分号分隔。
6. 默认禁止项写在 `AGENTS.md` / `framework_baseline.md`，模块配置与契约不要重复抄，除非收窄或放宽。

**违规处置（必须按序，禁止跳到抬上限或重写三种文件）：**

| 违规 | 只允许这样做 |
|---|---|
| 超过该类上限 | ① 删除等于缺省的可选项（含 `none` 占位）→ ② 删除未触发的条件项 → ③ 删除与另一文件重复的键（长期路径只留配置；本单收窄才留在契约；游标只留引用）→ ④ 仍超则收窄本单范围，不新增第二种游标/契约。禁止抬上限、禁止把键写成 H1 |
| 缺少最小必要 | 只补缺失的必要键，不补可选项凑数 |
| `idle` 却多写 | 游标回到 11 项；契约回到 2 项；删掉条件项 |
| 同一事实写了两处 | 留下 `kv_budget.md` 规定的那一处，另一处删除 |
| 机检 `FIELD_MAX` / `FIELD_MIN` / `FIELD_DUP` / `FIELD_IDLE` | 按上表改完后重跑 `tools/check-workspace.ps1` |

# 2. 游标 `project_cursor.md`

只回答「现在怎样」。不写目标、验收、白名单正文。

**最小必要（11）**

| 键 | 取值 |
|---|---|
| `workspace_root` | 本控制面绝对路径 |
| `trunk_markdown_access` | `frozen` 或用户授权后的临时态 |
| `init_baseline_status` | `completed` / 其他初始化态 |
| `source_root` | 当前 SVN 工作副本 |
| `source_root_mode` | `normal` / `isolated` |
| `version_control` | `svn` |
| `task_id` | 空闲为 `none` |
| `task_status` | `idle` / `in_progress` / `blocked` / `awaiting_approval` |
| `active_profile` | 空闲为 `none`，否则为 `module_id` |
| `contract_ref` | 空闲为 `none`，开工为 `contracts/current.md` |
| `blocked` | `true` / `false` |

**条件项（触发才写）**

| 键 | 条件 |
|---|---|
| `isolated_source_root` | `source_root_mode` 为 `isolated`（仅用户明确要求第二工作副本时） |
| `blocker_reason` | `blocked` 为 `true` |
| `blocker_owner` | `blocked` 为 `true` |

**可选项**：无。路径列表、验收一律不放游标。

**上限：14**。空闲时正好 11 行。

**互斥**：`task_status` 为 `idle` 时，`task_id`、`active_profile`、`contract_ref` 必须为 `none`，且不得出现条件项。

# 3. 模块配置 `profiles/<id>.md`

只回答「这个模块平时能碰什么」。不写单次任务目标。

**最小必要（4）**

| 键 | 说明 |
|---|---|
| `module_id` | 与文件名一致 |
| `module_name` | 中文名 |
| `profile_status` | `draft` / `active` |
| `allowed_write` | 相对 `source_root` 的长期可写路径，分号分隔 |

**可选（缺省可省）**

| 键 | 缺省 | 何时才写 |
|---|---|---|
| `allowed_read` | 等于 `allowed_write` | 读范围明显宽于写时 |
| `extra_forbidden` | 继承全局禁止 | 本模块额外禁止或例外放行 |
| `assemblies` | 由路径推断 | 跨层且需要显式提醒时 |
| `validation` | 按层默认：View 走 Unity，Share/Server 走 dotnet | 本模块有额外门禁时 |
| `extra_risk` | 继承全局高风险条件 | 本模块有额外升级条件时 |
| `workspace_folders` | 等于 `allowed_read` 的顶层目录 | 与允许读不一致、需单独挂载时 |

**上限：10**。不要为「看起来完整」把缺省项写成 `none`。

# 4. 开工契约 `contracts/current.md`

同一时刻最多一张活卡。只回答「这一单做什么、怎样算完」。结束即恢复空闲，不另存归档文件。

**空闲最小（2）**

| 键 | 取值 |
|---|---|
| `task_id` | `none` |
| `contract_status` | `idle` |

**开工最小（6）**

| 键 | 说明 |
|---|---|
| `task_id` | 短稳定 ID，如 `t001` |
| `contract_status` | `active` |
| `goal` | 一句话目标 |
| `profile_ref` | `profiles/<id>.md` |
| `source_root_mode` | `normal` / `isolated` |
| `acceptance` | 完成条件，分号分隔 |

**可选（缺省可省）**

| 键 | 缺省 | 何时才写 |
|---|---|---|
| `allowed_write` | 等于模块配置的 `allowed_write` | 本单需要更窄时 |
| `workspace_writes` | 仅游标 + 契约自身 | 还要改地图/标准/配置时列出 |
| `out_of_scope` | 无额外排除 | 需要防止顺手重构时 |
| `unblock` | 无 | 当前 `blocked` 时写解阻条件 |

**上限：10**。空闲时 2 行；开工时至少 6 行，最多 10 行。

禁止在契约里重复抄模块长期白名单，除非本单收窄。禁止写进度日记。

# 5. 其他文类

- `AGENTS.md`、索引、`md_governance.md`、`standards/`：**只用章节布局**，不设键值预算。
- `source_import_record.md`：表结构固定，按行追加，无键值上限。

# 6. 版本历史

- 1.2.0（2026-09-07）：键值违规必须按处置表处理；章节指针改为 md_governance §2。
- 1.1.0（2026-09-07）：正名为键值预算；声明不是 `# N` 章节规范。由 `field_schema.md` 迁入。
- 1.0.0（2026-09-07）：建立最小必要 + 条件/可选 + 硬上限。
