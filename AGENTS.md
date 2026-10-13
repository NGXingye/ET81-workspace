> 最新修改时间：2026-10-13 15:20 UTC+8
> 版本号：1.26.0
> 文档状态：生效
> 读取等级：L0（每次冷启动必读；正文只保留硬约束）

# 0. 职责定位

本文件只保留每轮都适用的不变量。口令步骤只写在 `.cursor/commands/`。冷启动读序只写在 `.cursor/rules/et81-cold-start.mdc`。已有本任务上下文时不要重读冷启动、蓝图、模板、`global_rules/`、schema、runtime 源码。

# 1. 不变量

1. 同时只有一张活卡：`contracts/current.md` 与 `contracts/current_scope.json`。未开工分析最多 2 份，放在 `contracts/candidates/`，不能改源码。
2. 无契约不改源码，不新建权威 Markdown。`route=fast` 且用户明确同意时，可按 `plan` 改活卡 `write_paths`。其它改源码必须本轮 `/implement`。源码树写入由钩子拦截。卡 idle 后仍可改已有 `standards/` 与 `contracts/commit_plan.json`。
3. 改源码前对白名单路径 `svn update`。以拉下的提交为基准，把本地未提交改动改上去；对不齐则停下说明。
4. 未经明确授权不 `svn commit`。一次只提交一笔，只经 `runtime/commit-units.py`。

# 2. 工作区

固定在 `C:\myProject\ET81-workspace`。这里只保存规范、模块配置、代码地图、游标与当前契约，不复制 Unity 源码或编辑器文档。改哪棵树以游标 `source_root` 或 `begin-implement` / `packet` 的 `workspace_path` 为准。第二工作副本仅当用户明确要求时启用。`runtime/` 未在 `runtime/_index.md` 登记的脚本禁止存在。

# 3. 读写

1. 未读真实源码或工程配置时标记 `unverified`，不得把文档写成已实现。
2. 禁止对目标工程全树搜索。禁止读 `Library/`、`Unity/Assets/Res/`、`Unity/Bundles/`、`Bin/`、`obj/`、`*.log` 与大型二进制。禁止手改 `Model/Generate/`。
3. 已登记编辑器 Markdown 默认不读、不改、不复制进本工作区。
4. 规范以本工作区为准；运行事实以源码和编译结果为准。冲突时标 `blocked`。新的稳定知识只写本工作区唯一对应文件。

# 4. 版本历史

- 1.26.0（2026-10-13）：口令步骤改由 `.cursor/commands/` 独占；本文只留不变量。
- 1.25.0（2026-10-13）：`/harvests` 收口只跑 `etctl idle`；idle 后仍可改 standards 与提交计划。
- 1.24.0（2026-10-13）：源码树写入由钩子跑 `etctl guard`，不通过则拒绝。
- 1.23.0（2026-10-13）：提交计划写完后对照 Scripts 查漏；窗口可刷新和验证。
- 1.22.0（2026-10-13）：提交笔数为软参考；一笔最多 8 个 `.cs`。
