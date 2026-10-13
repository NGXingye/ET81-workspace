> 最新修改时间：2026-10-13 15:55 UTC+8
> 版本号：1.12.0
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

写权限、svn 基准和提交笔数见 [`AGENTS.md`](../AGENTS.md)。开工步骤见 [`.cursor/commands/implement.md`](../.cursor/commands/implement.md)。本文件只写 trunk 与 runtime 的读写顺序。

写之前：

1. discovery 或改 runtime：读本文件与当前契约、`current_scope.json`、模块配置（若有）。`/implement` 以 `etctl begin-implement` 的 stdout 为准，不要为开工重读本文件。
2. 改源码按 [`.cursor/commands/implement.md`](../.cursor/commands/implement.md)。禁止对目标工程全树搜索。禁止读 runtime 源码。
3. 运行时：只打开 `runtime/_index.md` 已登记文件。
4. 仅当 `write_paths` 非空、`allowed_write` 不是 `workspace_only`，且契约为 `active` 或（`route=fast` 且用户已授权）时，按 §3 对 `write_paths` 做 `svn update`；失败则停止。其它 discovery 禁止 svn update。
5. 再改文件。源码树内的写入须通过 `etctl guard <path>`（规则在 `runtime_code.md`）。Cursor 钩子会代跑，不通过则写不进去。
6. `powershell -File runtime/etctl.ps1 check`。
7. 同步地图、`runtime/_index.md` 或 `targets/`（若路径/脚本/目标集合变了）。
8. 不提交。等用户本机验证通过，并**明确授权提交**后才可按 §3 提交。

C# 细规未定时：只改白名单内现有文件或按基线放置新建；禁止顺手重构白名单外文件。

# 3. SVN 更新与授权提交

他人可能每天提交。改 trunk 前必须把**本单允许写的路径**更新到最新，不要默认对整个 trunk 做一次全树 `svn update`（资源与 Library 体积大）。

| 步骤 | 规则 |
|---|---|
| 更新 | 对契约/配置的 `allowed_write` 目录或文件执行 `svn update` |
| 更新成功 | 重读文件。基准见 [`AGENTS.md`](../AGENTS.md)。对不齐则停下说明，不改那份提交 |
| 更新失败 | 冲突、锁定、阻碍、网络错误：立即 `blocked`，停止改码。禁止自行 revert 他人文件或 `--accept` 覆盖 |
| 状态 | 动手前看 scoped `svn status`；白名单内已有不明改动则停下问用户 |
| 提交默认 | **禁止** `svn commit` / `svn add`（除非本步被授权） |
| 授权提交 | 仅当用户已完成本机运行验证，并明确说提交/commit 本单时 |
| 提交范围 | 只 add/commit 白名单内本单改动（新建 `.cs` 若已有同名 `.meta` 且在同一白名单目录，可纳入） |
| 说明 | 一行：`task:<数字> <总任务>；<这一笔>`。`commit-units.py` 先 `svn add` 该笔未入库路径，再写入 UTF-8 文件，`svn commit -F --encoding utf-8` |
| 完整性 | `check-commit-plan.py` 只看 `Unity/Assets/Scripts`。与计划新增符号相交则补进未提交笔，否则写入 `omitted`。提交窗口 `v` 再提示漏提交和已标注。不因此提交 |
| 说明禁 | 控制台 `-m`、空消息、`update`、`fix`、粘贴 diff、一次提交多笔 |

`task:` 后的数字取该目标 `hook_tasks` 里的工单号，不是活卡号。

授权提交仍须先 scoped status：出现白名单外改动则只提交范围内文件，或停下由用户处理。禁止 `--force`。已提交的撤销由用户做反向合并；Agent 默认不 `svn merge`。

# 4. 创建、删除与工具登记

**trunk C#**

- 新建：只放 `Unity/Assets/Scripts/{Model,Hotfix,ModelView,HotfixView}/...`；禁止在 `DotNet/Model` 或 `DotNet/Hotfix` 新建 `.cs`。
- 禁止手改 `Model/Generate/`。
- 删除、移动、跨模块改名：须写进契约；未写则不做。默认仍在当前 `source_root` 执行，不自动切第二副本。
- 新建后由授权提交的 `commit-units.py` 对本笔未入库路径 `svn add`。

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

- 1.12.0（2026-10-13）：提交工单号改取目标上的 `hook_tasks`。
- 1.11.0（2026-10-13）：写权限与 svn 基准改链到 `AGENTS.md`，开工步骤改链到 `/implement`。
- 1.10.0（2026-10-13）：源码树写入须通过 `etctl guard`。
- 1.9.0（2026-10-13）：Scripts 改动对照提交计划，漏的补进或标注。
- 1.8.0（2026-10-13）：授权提交时，该笔未入库路径先 `svn add` 再提交。
