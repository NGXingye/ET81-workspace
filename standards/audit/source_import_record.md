> 最新修改时间：2026-09-16 16:10 UTC+8
> 版本号：1.1.0
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
| `AGENTS.md` | 语言约定、目录布局、Skill 体系、代码放置 | `standards/trunk/target.json`、`framework_baseline.md`；硬约束写入 workspace `AGENTS.md` |
| `Unity/AGENTS.md` | Unity 客户端 C# 9、目录、协作规则 | `standards/trunk/target.json` csharp |
| `Documents/项目目录结构说明.md` | 顶层目录职责 | `framework_baseline.md` §2 |
| `Documents/项目代码结构说明.md` | 程序集、放置、验证 | `framework_baseline.md` §2–§5 |
| `Documents/ET框架/Unity工程架构.md` | Unity 架构 | **部分弃用**，见 §3 冲突 |
| `Documents/业务模块/README.md` | 模块→源码索引 | `catalog.json` / `standards/trunk/modules/*.json`（逐步替代 `source_code_map.md`） |
| `Documents/ET框架/YIUI/README.md` | YIUI 落点 | `framework_baseline.md` §4 |
| `Documents/AI协作/知识沉淀约定.md` | 团队沉淀分流 | workspace 不自动回写 trunk；仅知悉团队规范存在 |

未读取：trunk 内其余 `Documents/**`、业务模块正文、需求 spec/plan、Book/、Store/ 说明。

# 3. 核验冲突记录

| 主题 | trunk 文档说法 | 采用结论 | 证据 |
|---|---|---|---|
| Unity 版本 | `Unity工程架构.md`：2022.3.17f1c1 | **2022.3.62f3** | `Unity/ProjectSettings/ProjectVersion.txt` |
| C# 语言版本 | `Unity工程架构.md`：C# 11 | **C# 9** | trunk `Unity/AGENTS.md`（初始化读取） |
| 服务端 Client 源码 | 文档描述超集编译 | 采用文档描述，以 `.csproj` 为准维护 | `DotNet.Model.csproj` / `DotNet.Hotfix.csproj` |

# 4. 临时授权登记

| 日期 | 授权文件 | 目的 | 是否吸收进 workspace | 恢复 frozen |
|---|---|---|---|---|
| 2026-09-14 | `Documents/业务模块/AI/AI框架机制.md`；`Documents/业务模块/AI/怪物与玩家AI.md`；`Documents/ET框架/AI框架.md` | t003 分析怪物 AI current 为空 | 沉淀 `standards/trunk/modules/monster_ai.json`；配置事实为 `Unity/Assets/Config/Excel/MonsterScalingLevelConfig.xlsx` | 是 |
| 2026-09-15 | `Documents/ET框架/YIUI/README.md`；`Documents/ET框架/YIUI/1-架构与核心概念.md`；`Documents/ET框架/YIUI/6-通用item容器YIUIItemContainer.md`；`Documents/ET框架/YIUI/7-OSA流式网格YIUIOSAFlowGrid.md` | t007 分析爬塔关卡离散分页 | 未吸收；运行事实以 ClimbingTower 源码为准 | 是 |
| 2026-09-15 | `Documents/ET框架/YIUI/4-开发工作流.md`；`Documents/ET框架/YIUI/3-CDE绑定系统.md` | t007 写出 Item_Stage 收成单关的手改步骤 | 未吸收 | 是 |
| 2026-09-16 | `Documents/ET框架/YIUI/3-CDE绑定系统.md`；`Documents/ET框架/YIUI/4-开发工作流.md` | t009 Item_Stage1 五关 CDE 配法 | 分析结论写入 current_scope；不改 Res | 是 |

# 5. 版本历史

- 1.1.0（2026-09-14）：迁入 `standards/audit/`；t003 知识 harvest。
- 1.0.0（2026-09-07）：完成初始化审计；trunk Markdown 门禁冻结。
