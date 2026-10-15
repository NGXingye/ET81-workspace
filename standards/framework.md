> 最新修改时间：2026-10-15 10:40 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L1（需要框架、程序集、放置或验证事实时读取）

# 0. 速览

> 速览：trunk 是 ET8.1 双端共源的 Unity 工程；旁边有 SkillEditor（技能作者面）、BridgeEditor（转化引擎）、ActionEditor 三个 Unity 编辑器工程，全部用 SVN。
> 最大风险：代码放错程序集、手改生成代码、对目标工程全树搜索。
> 做对的标准：Share/Server 改动 dotnet 构建与 ET 分析器通过；View 改动在 Unity 编辑器内编译通过。
>
> 门禁：无（全局约束）

# 1. 怎么运转

- trunk `C:\myProject\trunk`：ET8.1，Unity 2022.3.62f3（以 `ProjectVersion.txt` 为准），客户端 .NET Framework 4.7.1 / C# 9，服务端 .NET 8，`ET.sln`。源码都在 `Unity/Assets/Scripts/`，服务端 csproj 链接同一套源码；配置在 `Unity/Assets/Config/`。
| 项 | 值 |
|---|---|
| Unity 编辑器 | `2022.3.62f3` |

- 程序集：Core、Loader、Model、Hotfix 服务端也编；ModelView、HotfixView 只在客户端。
- 放置：数据进 Model，逻辑进 Hotfix；按执行端分 Client / Server / Share。表现数据进 ModelView，表现逻辑、YIUI、GameObject 操作进 HotfixView。
- YIUI：插件在 `Plugins/YIUIFramework/`；业务四件套 = `HotfixView/Client/YIUISystem/<模块>/` + `ModelView/Client/YIUIComponent/<模块>/` + 两处 `YIUIGen/`；通用 UI Helper 在 `HotfixView/Client/Module/UI/`。
- 编辑器工程：SkillEditor `C:\myProject\SkillEditor`；BridgeEditor `C:\myProject\BridgeEditor`（`ConfigET`、`ScriptsET` 是 trunk 的外链工作副本）；ActionEditor `C:\myProject\ActionEditor`（只核验过目录存在，尚无模块知识）。
- 遗留入口（未验证）：Spell `Hotfix/Client/Module/Spell`；HLS 移动 `Hotfix/Share/Demo/HybridLS/`；Combat `Hotfix/Server/Module/Combat`；Numeric `Hotfix/{Server,Client}/Module/Numeric`；背包 `Hotfix/Server/Demo/Bag`（`YIUISystem/Bag_New/` 是旧版）；Quest `Hotfix/Server/Quest`。

# 2. 坑和不变量

- 不手改 `Model/Generate/` 与任何 `*Gen`；字段来自导表，YIUI Gen 只许用户在编辑器点「生成」。
- 不在 `DotNet/Model`、`DotNet/Hotfix` 下新增 `.cs`。
- Hotfix 程序集不能声明实例字段，也不要可变 static；必须的静态字段加 `[StaticField]`，实例数据放 Model / ModelView 组件。
- 编进程序集不等于运行时会执行：判断执行端看启动链路和实际调用（见 `_index.md` 跨模块的坑）。
- 实体、`EntityRef`、`TimerComponent` 不跨 `await` 持有（ET0035），见 `_index.md` 跨模块的坑。
- 风格：Tab 宽 4、禁 `var`、大括号必写、块作用域命名空间、用项目 `Log` 不用 `Console`；改已有文件保留原行尾。
- trunk 内 `Documents/ET框架/Unity工程架构.md` 写的 Unity/C# 版本已过时，不采用。
- 全局禁碰：`**/Generate/`、`Unity/Library/`、`Unity/Assets/Res/`、`Unity/Bundles/`、`Bin/`、`obj/`、`Share/Share.SourceGenerator/`、`Share/joltc/`。
- Core / Loader / 协议生成 / 跨模块批量改动属高风险，先标 `blocked` 再与用户商量。

# 3. 怎么验证

- Model/Hotfix 的 Share、Server：dotnet 构建 + ET 分析器，服务端警告即错误。
- ModelView、HotfixView、YIUI：Unity 编辑器内编译；命令行编不全客户端。批处理入口 `Unity/scripts/unity.ps1`。
