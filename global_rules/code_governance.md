> 最新修改时间：2026-09-07 17:35 UTC+8
> 版本号：1.0.1
> 文档状态：生效
> 读取等级：L1（改 workspace 工具或 trunk C# 前必读）

# 0. 职责定位

本文件是代码读写的**全局门禁**。约束控制面工具与 trunk C# 的读、写、SVN 更新/提交边界。

不写 C# 命名、重构手法、业务文件行数；那些等第一个真实模块对着白名单源码再补。放置与验证见 [`../standards/framework_baseline.md`](../standards/framework_baseline.md)，路径见 [`../standards/source_code_map.md`](../standards/source_code_map.md)。

# 1. 两棵树与工作副本

| 树 | 根 | 允许的代码 | 版本 |
|---|---|---|---|
| 控制面工具 | `ET81-workspace/tools/` | 已登记的 `.ps1`/`.py` | Git |
| 游戏源码 | `project_cursor.md` 的 `source_root` | 契约白名单内的 C# 等 | SVN |

禁止混用：workspace 不复制 C#；trunk 不堆治理脚本；未登记脚本禁止存在。

**默认** `source_root` 为 `C:\myProject\trunk`，`source_root_mode` 为 `normal`，直接改这一份。  
**第二工作副本**（另检出的目录）仅当用户**明确要求**时启用：写入 `isolated_source_root`，并把 `source_root` 指过去，`source_root_mode` 为 `isolated`。用户未点名则不得自行 checkout 或切换。

# 2. 读写真序

无 `contracts/current.md` 开工形态时：禁止改任何代码，禁止新增工具文件。

写之前：

1. 读本文件与当前契约、模块配置（若有）。
2. trunk C#：只打开代码地图「优先打开」列或配置白名单。禁止对 `source_root` 全树 Glob/Grep。
3. 工具：只打开 `tools/_index.md` 已登记文件。
4. 按 §3 做**白名单路径** `svn update`；失败则停止。
5. 再改文件。
6. `powershell -File tools/check-workspace.ps1`。
7. 同步地图或 `tools/_index.md`（若路径/工具集合变了）。
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

**workspace 工具**

- 只允许 `tools/` 下、且已写入 [`../tools/_index.md`](../tools/_index.md) 的文件。
- **未登记 = 禁止存在**（含根目录、`local/`、一次性 `fix.py`）。
- 先改索引再加文件。写法见 [`tools_code.md`](./tools_code.md)。默认不得改 trunk C#、不得读 trunk Markdown、不得 `revert`/`commit`/`cleanup`。
- C# 命名/重构/行数门禁：推迟，不在本文件展开。

# 5. 违规处置

| 违规 | 只允许 |
|---|---|
| 全树扫描 / 白名单外修改 | 停下；不 revert 他人改动；报告路径等用户 |
| `svn update` 失败 | `blocked`；不继续写；不自行解冲突 |
| 未授权提交 | 不 commit；把说明草稿交给用户 |
| 未登记工具 | 删除或移出仓库；先补索引再实现 |
| 想用第二副本 | 用户未明确要求则继续改 trunk |
| 需要 C# 细规 | 标 `unverified` 或问用户；不编造命名法 |

机检：`tools/check-workspace.ps1`。工具集合与索引不一致则失败。

# 6. 版本历史

- 1.0.1（2026-09-07）：工具写法指向 `tools_code.md`。
- 1.0.0（2026-09-07）：门禁 + 工具登记；默认 trunk；第二副本仅用户点名；SVN 白名单更新与授权提交。
