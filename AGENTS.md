> 最新修改时间：2026-09-07 17:35 UTC+8
> 版本号：1.4.0
> 文档状态：生效
> 读取等级：L0（每次冷启动必读；正文只保留硬约束）

# 0. 职责定位

本文件是 ET81-workspace 的最高规范权威。Cursor 会把它作为 Always Apply 注入每一轮，因此只保留不可违反的短约束。

冷启动读序：`.cursor/rules/et81-cold-start.mdc`。文档导航：`project_index.md`。任务状态：`project_cursor.md`。章节布局：`global_rules/md_governance.md`。键值预算：`global_rules/kv_budget.md`。代码门禁：`global_rules/code_governance.md`。工具写法：`global_rules/tools_code.md`。

# 1. 工作区

固定在 `C:\myProject\ET81-workspace`。本 workspace 只保存规范、模块配置、代码地图、游标与当前契约，不复制 Unity 源码或 trunk 文档。

源码工作副本默认：`C:\myProject\trunk`（SVN），直接改这一份。第二工作副本仅当用户明确要求时启用。`tools/` 未在 `tools/_index.md` 登记的脚本禁止存在。

# 2. trunk Markdown 门禁

1. trunk 内 `AGENTS.md`、`Documents/**/*.md` 及其他 Markdown：初始化冻结后默认禁止读取、修改、维护。
2. 只有用户针对具体文件和明确目的授权时才可临时访问；任务结束恢复 `frozen`，并在 `standards/source_import_record.md` 登记。
3. 禁止把 trunk 文档当作冷启动依赖；禁止在 workspace 内保留副本或链接依赖。

# 3. 强制安全

1. 未读取真实源码或工程配置时标记 `unverified`；不得把计划或文档描述写成已实现。
2. 禁止对 `source_root` 做全树 Glob / Grep / `Get-ChildItem -Recurse`；只按活动模块配置、契约或 `standards/source_code_map.md` 打开目标路径。
3. 禁止读取 `Unity/Library/`、`Unity/Assets/Res/`、`Unity/Bundles/`、`Bin/`、`obj/`、`*.log` 及大型二进制资源。
4. 禁止手改 `Model/Generate/`；禁止覆盖、回退或提交白名单外的未知 SVN 改动。改 trunk 前对白名单路径 `svn update`，失败则停止。未经用户验证并明确授权，禁止 `svn commit`。
5. 规范权威在 workspace；运行事实以源码、`ProjectSettings`、`.asmdef`、`.csproj` 和编译结果为准。冲突时标记 `blocked`，不得自动读 trunk 文档裁决。
6. 无开工契约（`contract_ref` 为 `none`）时禁止改源码、禁止新建权威 Markdown。
7. 新发现的稳定知识只写 workspace 唯一对应文件；回馈 trunk 须单独任务且用户批准。

# 4. 版本历史

- 1.4.0（2026-09-07）：挂接工具写法 `tools_code.md`。
- 1.3.0（2026-09-07）：默认只改 trunk；第二副本须用户点名；未登记工具禁止；SVN 先更新后授权提交。
- 1.2.0（2026-09-07）：区分章节布局与键值预算；指针改为 kv_budget.md。
- 1.1.0（2026-09-07）：挂接文档法与字段预算；无契约禁止写。
- 1.0.0（2026-09-07）：建立硬约束与 trunk Markdown 冻结门禁。
