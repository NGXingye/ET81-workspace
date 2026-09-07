> 最新修改时间：2026-09-07 15:25 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L1（框架相关开发前读取相关节）

# 0. 职责定位

本文件是 ET81-workspace 内**唯一**的 ET8.1 框架基线知识源，保存经工程配置核验后的版本、分层、放置与验证规则。

它不保存模块业务细节（由模块配置维护）或 trunk 文档原文。

# 1. 工程与版本（已核验）

| 项 | 值 | 证据 |
|---|---|---|
| 框架 | ET8.1 双端共源 | 初始化自 trunk 目录结构 + 工程布局 |
| Unity 编辑器 | 2022.3.62f3c1 | `Unity/ProjectSettings/ProjectVersion.txt` |
| Unity 客户端目标框架 | .NET Framework 4.7.1 | Unity 生成 csproj |
| Unity 客户端 C# | 9 | 初始化自 trunk `Unity/AGENTS.md`（已冻结，不再回读） |
| 服务端 | .NET 8.0 | `DotNet/*.csproj` |
| 主解决方案 | `ET.sln` | trunk 根目录 |
| 版本控制 | SVN | trunk 工作副本 |

**已知 trunk 文档冲突（不采用）**：`Documents/ET框架/Unity工程架构.md` 仍写 Unity 2022.3.17f1c1 与 C# 11；以 `ProjectVersion.txt` 与 `Unity/AGENTS.md` 核验结果为准。

# 2. 源码位置与程序集

所有 C# 源码位于 `Unity/Assets/Scripts/`（相对 `source_root`）。服务端通过 `DotNet/*.csproj` 的 `<Compile Include>` 链接同一套源码。**禁止**直接在 `DotNet/Model` 或 `DotNet/Hotfix` 下新增 `.cs`。

| 程序集 | 职责 | 服务端编译 |
|---|---|---|
| `Core` | Entity/World/Fiber/ETTask、Network、YIUI 核心 | ✅ |
| `Loader` | 入口与 MonoBehaviour 桥接 | ✅ |
| `Model` | 实体/组件数据定义 | ✅ |
| `Hotfix` | 系统/逻辑（可热重载） | ✅ |
| `ModelView` | 客户端表现层数据 | ❌ |
| `HotfixView` | 客户端表现层逻辑 | ❌ |

`Model` / `Hotfix` 下再分 `Client` / `Server` / `Share` / `Generate`。

### 放置口诀

- 纯数据 → `Model`；逻辑/系统 → `Hotfix`；是否跨端 → `Client`/`Server`/`Share`。
- 不依赖 Unity 表现程序集的客户端业务 → `Hotfix/Client`。
- 表现 Entity/Component 数据 → `ModelView`；表现逻辑、YIUI、GameObject 操作 → `HotfixView`。
- `Model/Generate/` 为生成代码，**勿手改**。

### 三层判断

1. **源码职责**：Client / Server / Share 目录与命名空间。
2. **编译参与**：以 `.asmdef` / `.csproj` 为准。
3. **运行执行**：启动链路与实际调用决定是否在服务端执行；编进程序集 ≠ 运行时一定执行。

# 3. 客户端 UI（YIUI）落点

| 落点 | 相对路径 | 职责 |
|---|---|---|
| 插件本体 | `Unity/Assets/Plugins/YIUIFramework/` | YIUI 框架源码 |
| ET 接入 | `Unity/Assets/Scripts/Core/YIUI/`、`HotfixView/Client/Module/YIUI/` | Core 扩展与 Invoke |
| 业务面板 | `ModelView/Client/`、`HotfixView/Client/` 下 YIUIGen/YIUIComponent/YIUISystem | 各 Panel 四件套 |
| UI 资源 | `Unity/Assets/Res/YIUI/` | prefab / 图集（非代码搜索默认范围） |

通用 UI Helper 放 `HotfixView/Client/Module/UI/`；业务 System 放 `HotfixView/Client/YIUISystem/<模块>/`。

# 4. 代码风格（硬约束摘要）

- 制表符（宽 4）、CRLF、**禁用 `var`**、大括号必写、块作用域命名空间。
- 日志用项目 `Log` / `Logger` / `NLogger`；禁用 `Console.WriteLine`。
- 编辑既有文件时**保留原始行尾**（仓库存在 CRLF/LF 混用）。

# 5. 验证边界

| 改动层 | 验证方式 |
|---|---|
| `Model/Share`、`Hotfix/Share`、`Hotfix/Server` 等 | dotnet 构建 + ET 分析器；服务端 `TreatWarningsAsErrors=on` |
| `ModelView`、`HotfixView`、YIUI | **Unity 编辑器内编译**；勿指望命令行编译 Unity 侧全量通过 |
| 跨模块 / Core / Loader / 协议生成 | 高风险：切换第二 SVN 工作副本 |

Unity 批处理入口（如需）：`Unity/scripts/unity.ps1`（相对 `source_root`）。

# 6. 业务模块入口（索引级，细节进模块配置）

| 模块 | 主要源码相对路径 |
|---|---|
| Spell 技能 | `Unity/Assets/Scripts/Hotfix/Client/Module/Spell` |
| UI / YIUI | `Unity/Assets/Scripts/HotfixView/Client/YIUISystem/`、`ModelView/Client/` |
| MoveSystem 动作移动 | `Unity/Assets/Scripts/Hotfix/Share/Demo/HybridLS/`、`Hotfix/Share/Module/Unit/` |
| Combat 战斗 | `Unity/Assets/Scripts/Hotfix/Server/Module/Combat` |
| Numeric 数值 | `Hotfix/Server/Module/Numeric`、`Hotfix/Client/Module/Numeric` |

完整模块列表在初始化时自 trunk 模块索引抽取；新增模块须在 `source_code_map.md` 与模块配置中登记。

# 7. 版本历史

- 1.1.0（2026-09-07）：合并源码位置与程序集为一节，以符合章节上限 8。
- 1.0.0（2026-09-07）：首版框架基线；Unity 2022.3.62f3c1 经 ProjectVersion.txt 核验。
