> 最新修改时间：2026-09-07 14:20 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（定位源码前读取相关行）

# 0. 职责定位

本文件是需求关键词 → 源码路径的路由表。路径均**相对** `project_cursor.md` 的 `source_root`（默认 `C:\myProject\trunk`）。

Agent **只读「优先打开」列**；「通常不要动」除非模块配置或用户明确要求。

# 1. 框架与公共

| 需求关键词 | 优先打开 | 通常不要动 |
|---|---|---|
| 框架 Core / Fiber / ETTask | `Unity/Assets/Scripts/Core/` | `Share/Share.SourceGenerator/` |
| 启动 / Loader | `Unity/Assets/Scripts/Loader/` | `DotNet/App/Program.cs`（服务端入口，非 Unity 任务勿改） |
| 分析器规则 | `Share/Analyzer/` | `Share/AnalyzerTest/`（改规则时再开） |
| CodeMode 客户端/服务端切换 | `Unity/Assets/Scripts/Loader/MonoBehaviour/GlobalConfig.cs` | — |

# 2. 业务模块（摘要）

| 需求关键词 | 优先打开 | 通常不要动 |
|---|---|---|
| UI / YIUI / 面板 | `Unity/Assets/Scripts/HotfixView/Client/YIUISystem/`、`ModelView/Client/`、`Unity/Assets/Scripts/Core/YIUI/` | `Unity/Assets/Plugins/YIUIFramework/`（框架本体） |
| 技能 Spell | `Unity/Assets/Scripts/Hotfix/Client/Module/Spell` | `Hotfix/Server/Module/Spell`（跨端任务再开） |
| 动作 / 移动 MoveSystem / HLS | `Unity/Assets/Scripts/Hotfix/Share/Demo/HybridLS/`、`Hotfix/Share/Module/Unit/` | `Hotfix/Server/Demo/Map/Move/` |
| 战斗 Combat | `Unity/Assets/Scripts/Hotfix/Server/Module/Combat` | — |
| 战斗效果 CombatEffect | `Unity/Assets/Scripts/Hotfix/Share/Module/CombatEffect/` | — |
| 数值 Numeric | `Hotfix/Server/Module/Numeric`、`Hotfix/Client/Module/Numeric` | — |
| 背包 Bag | `Hotfix/Server/Demo/Bag`、`HotfixView/Client/YIUISystem/Bag/` | `YIUISystem/Bag_New/`（旧版） |
| AI / 宠物 | `Hotfix/Share/Module/AI/`、`Hotfix/Share/Module/Spell/BT/AI/` | — |
| 账号 Account | `Hotfix/Server/Demo/Account` | — |
| 任务 Quest | `Hotfix/Server/Quest` | — |

# 3. 明确禁止的改动面（全局）

- `Unity/Assets/Scripts/**/Generate/` — 生成代码
- `Unity/Library/`、`Unity/Assets/Res/**`（除非模块配置显式授权资源路径）
- `Share/Share.SourceGenerator/`、`Share/joltc/` — 除非框架级任务且高风险副本

# 4. 扩展规则

- 新增模块路由：先更新活动 `profiles/<模块>.md`，再在本表登记一行。
- 路径使用正斜杠；相对 `source_root`。
- 改 ports/协议/公共枚举时同步更新模块配置并评估是否切换 `isolated_source_root`。

# 5. 版本历史

- 1.0.0（2026-09-07）：首版摘要路由；细节随模块配置扩展。
