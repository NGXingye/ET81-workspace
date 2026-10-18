> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L1（控制面自身任务时读取）

# 0. 速览

> 速览：控制面任务只改本工作区（规范、口令、卡片、runtime 脚本），不碰任何源码树。
> 最大风险：改了脚本或字段却没同步登记与机检，导致钩子拦截失效或开工失败。
> 做对的标准：`powershell -File runtime/etctl.ps1 check` 无 ERROR，`etctl guard` 对源码路径仍按 write_paths 判定。
>
> 门禁：`profiles/control.md`

# 1. 怎么运转

口令（`.cursor/commands/`）→ `runtime/etctl.ps1` 子命令 → 写游标 / 契约 / scope；`.cursor/hooks.json` 在写工具和 shell 前调 `.cursor/hooks/guard-source.ps1` → `runtime/guard.ps1`。知识层：`standards/<模块>.md`（人和模型读）；门禁层：`profiles/<id>.md`（脚本读 `allowed_write`）。

# 2. 坑和不变量

- `runtime/` 下脚本必须登记在 `runtime/_index.md`，否则机检报错；新增 scope 字段要同时改 schema、`check-helpers.ps1` 允许列表、`idle.ps1` 的空闲禁用列表。
- `profiles/<id>.md` 只有 4 个键。`allowed_write` 为 `workspace_only` 时 guard 拒绝一切源码写入；否则是目录前缀菜单，`write_paths` 越出时 `begin-implement` 与机检警告 `PROFILE_MENU`（`runtime/boundary.ps1` 的 `$script:ProfilePrefixStrict` 改成拒绝）。`begin-implement` 要求 `profiles/<profile_id>.md` 存在。
- 本地专用写目标 `local_only`，改完跑 `etctl sync-ignores`；机检 `IGNORE_DRIFT` 表示本机 svn 忽略没跟上。
- 受管理 md 必须四行版头、`# 0. 职责定位` 开头、版本历史收尾且最多 5 条；游标、活契约、候选索引不写历史。
- 改 md 前先看 `global_rules/md_governance.md`；改键值看 `kv_budget.md`。

# 3. 怎么验证

`etctl check` 无 ERROR；有脚本改动时再对一个源码路径跑 `etctl guard <path>`，确认空闲时被拒。
