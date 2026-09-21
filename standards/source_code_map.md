> 最新修改时间：2026-09-14 22:39 UTC+8
> 版本号：1.3.0
> 文档状态：生效
> 读取等级：L1（遗留路由；优先 catalog）

# 0. 职责定位

**优先** [`catalog.json`](./catalog.json) 与 [`trunk/modules/*.json`](./trunk/modules/)。本文件只保留尚未迁入模块 JSON 的关键词路由。

路径均**相对** `source_root`。行结构见 `runtime/schema/map_entry.schema.json`。Agent 只读「优先打开」列。

# 1. 框架与公共

| 需求关键词 | 优先打开 | 通常不要动 | 可信 |
|---|---|---|---|
| 框架 Core / Fiber / ETTask | `Unity/Assets/Scripts/Core/` | `Share/Share.SourceGenerator/` | candidate |
| 启动 / Loader | `Unity/Assets/Scripts/Loader/` | `DotNet/App/Program.cs`（服务端入口，非 Unity 任务勿改） | candidate |
| 分析器规则 | `Share/Analyzer/` | `Share/AnalyzerTest/`（改规则时再开） | candidate |
| CodeMode 客户端/服务端切换 | `Unity/Assets/Scripts/Loader/MonoBehaviour/GlobalConfig.cs` | — | candidate |

# 2. 业务模块（摘要）

| 需求关键词 | 优先打开 | 通常不要动 | 可信 |
|---|---|---|---|
| UI / YIUI / 面板 | `Unity/Assets/Scripts/HotfixView/Client/YIUISystem/`、`ModelView/Client/`、`Unity/Assets/Scripts/Core/YIUI/` | `Unity/Assets/Plugins/YIUIFramework/`（框架本体） | candidate |
| 技能 Spell | `Unity/Assets/Scripts/Hotfix/Client/Module/Spell` | `Hotfix/Server/Module/Spell`（跨端任务再开） | candidate |
| 动作 / 移动 MoveSystem / HLS | `Unity/Assets/Scripts/Hotfix/Share/Demo/HybridLS/`、`Hotfix/Share/Module/Unit/` | `Hotfix/Server/Demo/Map/Move/` | candidate |
| 根运动 RootMotion（遗留） | 见 `trunk/modules/root_motion.json` | — | stale |
| 战斗 Combat | `Unity/Assets/Scripts/Hotfix/Server/Module/Combat` | — | candidate |
| 战斗效果 CombatEffect | `Unity/Assets/Scripts/Hotfix/Share/Module/CombatEffect/` | — | candidate |
| 数值 Numeric | `Hotfix/Server/Module/Numeric`、`Hotfix/Client/Module/Numeric` | — | candidate |
| 背包 Bag | `Hotfix/Server/Demo/Bag`、`HotfixView/Client/YIUISystem/Bag/` | `YIUISystem/Bag_New/`（旧版） | candidate |
| AI / 宠物（遗留） | `Hotfix/Share/Module/AI/` | 怪物 AI 见 `trunk/modules/monster_ai.json` | stale |
| 账号 Account | `Hotfix/Server/Demo/Account` | — | candidate |
| 任务 Quest | `Hotfix/Server/Quest` | — | candidate |

# 3. 明确禁止的改动面（全局）

- `Unity/Assets/Scripts/**/Generate/` — 生成代码
- `Unity/Library/`、`Unity/Assets/Res/**`（除非模块配置显式授权资源路径）
- `Share/Share.SourceGenerator/`、`Share/joltc/` — 除非框架级任务且高风险副本

# 4. 扩展规则

- 新增模块：harvest 时优先写 `standards/<editor>/modules/<id>.json` 并在 `catalog.json` 登记；无模块 JSON 时再按 `map_entry.schema.json` 在本表加一行。
- `trust`：`candidate` / `observed` / `verified` / `stale`。初始化抽取为 candidate；本单打开过为 observed；用户验证后为 verified。
- 禁止预建空知识库目录。重复诊断模式出现两次以上再考虑独立标准。
- 路径使用正斜杠；相对 `source_root`。

# 5. 版本历史

- 1.3.0（2026-09-14）：根运动迁 `trunk/modules/root_motion.json`。
- 1.2.0（2026-09-14）：怪物 AI 迁 `trunk/modules/monster_ai.json`；本表降为遗留。
- 1.1.0（2026-09-12）：增加可信列与 map_entry 模板；现有行标为 candidate。
- 1.0.0（2026-09-07）：首版摘要路由；细节随模块配置扩展。
