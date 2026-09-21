> 最新修改时间：2026-09-17 17:40 UTC+8
> 版本号：1.5.0
> 文档状态：生效
> 读取等级：L1（改 workspace 运行时或 trunk C# 前必读）

# 0. 职责定位

本文件是代码读写的**全局门禁**。约束控制面运行时与 trunk C# 的读、写、SVN 更新/提交边界。

不写 C# 命名、重构手法、业务文件行数；那些等第一个真实模块对着白名单源码再补。放置与验证见 [`../standards/trunk/target.json`](../standards/trunk/target.json)；路由见 [`../standards/catalog.json`](../standards/catalog.json) 与 `standards/<editor>/modules/`。

# 1. 两棵树与工作副本

| 树 | 根 | 允许的代码 | 版本 |
|---|---|---|---|
| 控制面运行时 | `ET81-workspace/runtime/` | 已登记的 `.ps1`/`.py` 与 schema | Git |
| 游戏源码 | `project_cursor.md` 的 `source_root` | 契约白名单内的 C# 等 | SVN |

禁止混用：workspace 不复制 C#；trunk 不堆治理脚本；未登记脚本禁止存在。阶段、路径、证据只写 `contracts/current_scope.json` 与 `targets/*.json`，不写入游标键值。

**默认** `source_root` 为 `C:\myProject\trunk`，`source_root_mode` 为 `normal`，直接改这一份。  
**第二工作副本**（另检出的目录）仅当用户**明确要求**时启用：写入 `isolated_source_root`，并把 `source_root` 指过去，`source_root_mode` 为 `isolated`。用户未点名则不得自行 checkout 或切换。

# 2. 读写真序

无契约或 `idle` 时：禁止改任何代码，禁止新增运行时文件。`discovery` 默认只写 `current_scope.json` 与本单 `workspace_writes` 中的分析文档。`route=fast` 且用户明确授权时，可按 `plan` 改活卡 `write_paths`（契约可保持 discovery）。其它改 trunk 必须 `active`。

写之前：

1. discovery 或改 runtime：读本文件与当前契约、`current_scope.json`、模块配置（若有）。`/implement` 以 `etctl begin-implement` 的 stdout 为准，不要为开工重读本文件。
2. `/implement` 或 `phase=implement` 时先 `powershell -File runtime/etctl.ps1 begin-implement`；失败则停止。`route=fast` 且用户已授权则跳过 begin-implement。首次只按 `plan` 改 `write_paths`，禁止通读 `read_paths`。测不过保持 implement，此时才读 `read_paths`；邻接追加须写入 scope 后再改。禁止对目标工程全树 Glob/Grep。禁止读 runtime 源码。
3. 运行时：只打开 `runtime/_index.md` 已登记文件。
4. 仅当 `write_paths` 非空、`allowed_write` 不是 `workspace_only`，且契约为 `active` 或（`route=fast` 且用户已授权）时，按 §3 对 `write_paths` 做 `svn update`；失败则停止。其它 discovery 禁止 svn update。
5. 再改文件。
6. `powershell -File runtime/etctl.ps1 check`。
7. 同步地图、`runtime/_index.md` 或 `targets/`（若路径/脚本/目标集合变了）。
8. 不提交。等用户本机验证通过，并**明确授权提交**后才可按 §3 提交。

C# 细规未定时：只改白名单内现有文件或按基线放置新建；禁止顺手重构白名单外文件。

# 3. SVN 更新与授权提交

他人可能每天提交。改 trunk 前必须把**本单允许写的路径**更新到最新，不要默认对整个 trunk 做一次全树 `svn update`（资源与 Library 体积大）。

| 步骤 | 规则 |
|---|---|
| 更新 | 对契约/配置的 `allowed_write` 目录或文件执行 `svn update` |
| 更新失败 | 冲突、锁定、阻碍、网络错误：立即 `blocked`，停止改码。禁止自行 revert 他人文件或 `--accept` 覆盖 |
| 状态 | 动手前看 scoped `svn status`；白名单内已有不明改动则停下问用户 |
| 提交默认 | **禁止** `svn commit` / `svn add`（除非本步被授权） |
| 授权提交 | 仅当用户已完成本机运行验证，并明确说提交/commit 本单时 |
| 提交范围 | 只 add/commit 白名单内本单改动（新建 `.cs` 若已有同名 `.meta` 且在同一白名单目录，可纳入） |
| 说明 | 简体中文，1–2 句写**原因**；带 `task_id` 与模块；不写文件清单（SVN 自带） |
| 说明禁 | 空消息、`update`、`fix`、粘贴 diff、把计划写成已验证 |

提交说明形态：`[task_id][module_id] 一句话原因。`  
例：`[t001][ui] 修复页签切换后红点仍显示已读数据。`

授权提交仍须先 scoped status：出现白名单外改动则只提交范围内文件，或停下由用户处理。禁止 `--force`。已提交的撤销由用户做反向合并；Agent 默认不 `svn merge`。

# 4. 创建、删除与工具登记

**trunk C#**

- 新建：只放 `Unity/Assets/Scripts/{Model,Hotfix,ModelView,HotfixView}/...`；禁止在 `DotNet/Model` 或 `DotNet/Hotfix` 新建 `.cs`。
- 禁止手改 `Model/Generate/`。
- 删除、移动、跨模块改名：须写进契约；未写则不做。默认仍在当前 `source_root` 执行，不自动切第二副本。
- 新建后提醒用户（或授权提交时）`svn add`。

**workspace 运行时**

- 只允许 `runtime/` 下、且已写入 [`../runtime/_index.md`](../runtime/_index.md) 的脚本。
- **未登记 = 禁止存在**（含根目录、`local/`、一次性 `fix.py`）。
- 先改索引再加文件。写法见 [`runtime_code.md`](./runtime_code.md)。默认不得改 trunk C#、不得读 trunk Markdown、不得 `revert`/`commit`/`cleanup`。
- C# 命名/重构/行数门禁：推迟，不在本文件展开。

# 5. 违规处置

| 违规 | 只允许 |
|---|---|
| 全树扫描 / 白名单外修改 | 停下；不 revert 他人改动；报告路径等用户 |
| `svn update` 失败 | `blocked`；不继续写；不自行解冲突 |
| 未授权提交 | 不 commit；把说明草稿交给用户 |
| 未登记脚本 | 删除或移出仓库；先补索引再实现 |
| 想用第二副本 | 用户未明确要求则继续改 trunk |
| 需要 C# 细规 | 标 `unverified` 或问用户；不编造命名法 |

机检：`runtime/etctl.ps1 check`。脚本集合与索引不一致则失败。

# 6. 版本历史

- 1.5.0（2026-09-17）：fast 授权后可在 discovery 改 write_paths 并 scoped svn update。
- 1.4.0（2026-09-16）：首次 implement 按 plan 改，不通读 read_paths。
- 1.3.0（2026-09-16）：implement 先 `begin-implement`；禁止为开工重读本文件。
- 1.2.0（2026-09-14）：implement 先 packet；测不过局部返工，满 3 轮 blocked。
- 1.1.2（2026-09-12）：svn update 仅限 active 且 write_paths 非空。
