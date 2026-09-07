> 最新修改时间：2026-09-07 14:20 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L2（申请 trunk Markdown 临时授权时读取）

# 0. 职责定位

本文件记录 ET81-workspace **一次性初始化**时参考过的 trunk 资料、核验结论、冲突与门禁冻结状态。

它是来源审计记录，**不是**日常知识源；冻结后不得因「查原文」而回读下列 trunk 文件。

# 1. 门禁状态

- `trunk_markdown_access`：`frozen`（自 2026-09-07 起）
- `init_completed`：`true`
- `init_method`：规划阶段 selective read + `ProjectVersion.txt` 工程核验

# 2. 初始化读取清单（已冻结，勿再读）

| trunk 路径 | 用途 | 抽取去向 |
|---|---|---|
| `AGENTS.md` | 语言约定、目录布局、Skill 体系、代码放置 | `framework_baseline.md` §2–§5；硬约束写入 workspace `AGENTS.md` |
| `Unity/AGENTS.md` | Unity 客户端 C# 9、目录、协作规则 | `framework_baseline.md` §1 |
| `Documents/项目目录结构说明.md` | 顶层目录职责 | `framework_baseline.md` §2 |
| `Documents/项目代码结构说明.md` | 程序集、放置、验证 | `framework_baseline.md` §3–§6 |
| `Documents/ET框架/Unity工程架构.md` | Unity 架构 | **部分弃用**，见 §3 冲突 |
| `Documents/业务模块/README.md` | 模块→源码索引 | `framework_baseline.md` §7、`source_code_map.md` |
| `Documents/ET框架/YIUI/README.md` | YIUI 落点 | `framework_baseline.md` §4 |
| `Documents/AI协作/知识沉淀约定.md` | 团队沉淀分流 | workspace 不自动回写 trunk；仅知悉团队规范存在 |

未读取：trunk 内其余 `Documents/**`、业务模块正文、需求 spec/plan、Book/、Store/ 说明。

# 3. 核验冲突记录

| 主题 | trunk 文档说法 | 采用结论 | 证据 |
|---|---|---|---|
| Unity 版本 | `Unity工程架构.md`：2022.3.17f1c1 | **2022.3.62f3c1** | `Unity/ProjectSettings/ProjectVersion.txt` |
| C# 语言版本 | `Unity工程架构.md`：C# 11 | **C# 9** | trunk `Unity/AGENTS.md`（初始化读取） |
| 服务端 Client 源码 | 文档描述超集编译 | 采用文档描述，以 `.csproj` 为准维护 | `DotNet.Model.csproj` / `DotNet.Hotfix.csproj` |

# 4. 临时授权登记（空）

| 日期 | 授权文件 | 目的 | 是否吸收进 workspace | 恢复 frozen |
|---|---|---|---|---|
| （无） | — | — | — | — |

# 5. 版本历史

- 1.0.0（2026-09-07）：完成初始化审计；trunk Markdown 门禁冻结。
