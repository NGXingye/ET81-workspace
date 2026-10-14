> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（关键词命中怪物 / AI / BuffVM / 召唤 / 受击时读取）

# 0. 职责定位

> 速览：怪物 AI 在服务端跑行为树选技能（距离带 + DistanceTrigger）；技能本身是 BuffVM 技能图，服务端与客户端按同一进度各跑一份；召唤、孵化、被动死亡、受击 Buff 都挂在这套图上。
> 最大风险：客户端那份 VM 做了只该服务端做的事（加 Buff、读本端目标、拆单位），以及配置距离带互不相交导致「不放技能」。
> 做对的标准：怪物按配置距离放出预期技能；客户端表现只跟服务端 M2C_BuffAdd 走，无闪动、无叠射。

# 1. 怎么运转

- 身份：MonsterScalingLevelConfig.CharacterType=3 → `Unit.IsMonster` → 数值、敌我、AI、动画分支才生效。CharacterType=0 时 AI current 为空、不攻击。
- 距离：DetectionRange 相对自身看见；ChaseRange 相对出生点软拴绳；`[min_attack_range, attack_range]` 是追击停步出手带（不选技能）；DistanceTrigger 用表 `attack_distance` 选技能（Inspector Distance 条件已注释）。有效距离 = max(表距离, 自身半径) + 目标半径。
- 技能图：重复走 BuffVMRepeatHandler，圈内 true、圈外 false → 执行 OnExit；子 Buff 继承父 AlreadyRate。
- 受击 AddBuff 四槽：1 命中持续（目标）、2 不命中=地面持续（加在施法者）、3 命中一次性、4 地面一次性。
- 关键入口：`Hotfix/Server/Demo/Map/Spell/BT/AI/AI_Monster*Handler.cs`、`Hotfix/Server/Demo/Map/Spell/BuffVM/`、`PetComponentSystem.cs`、`SpellHitActionAddBuffHelper.cs`、`Config/Json/cs/MonsterSkillConfig.txt`。

# 2. 坑和不变量

- 距离设计顺序：先定技能 attack_distance，再定 min_attack_range（近战 0~1）、attack_range、DetectionRange、ChaseRange，满足 `0 ≤ min < 技能有效距离 ≤ attack_range ≤ Detection ≤ Chase`。表距离改 0 仍是贴身，不能用来禁用近战。
- 怪物 AI 只在服务端施放；客户端 VM 里的 BTAddBuff 对怪物直接成功不创建，表现只认 M2C_BuffAdd（玩家/宠物的 HLSPredict 预测保留）。出圈判断只读 Buff 上同步的 SpellTarget，不读本端 TargetComponent。
- 不同步字段在客户端是默认值：`PetComponent.DisposeWhenOnwerDispose` 不同步，HLSUpdate 只能在服务端执行，否则母体一移除客户端就拆蛋。
- 循环攻击：间隔不能只看动画结束缓存或游标剩余时间（会叠射或越来越密）；离圈动作挂 OnExit，不挂条件 Out；BTBreak 没有 BuffVM 处理器。
- 客户端表现等待（BTTimeWaitViewAsync）不写 AlreadyRate、不改服务端时钟，从服务端开火等待原样抄。
- 阶段类 env 用 long 写入、TryToLosslessInt 读；`AddStruct/GetStruct<int>` 存不回去。
- 被动死亡是服务端节点，挂在特效 Buff 图的异步等待后面，等上层回空再播 Base 层死亡；不要为露出死亡去清 UState.Attack，也不挂客户端图。
- 节点保持通用：等待、延迟挂 AI、等 Buff 结束再移除各用自己的开关，不做只服务一只怪的复合节点；母体身份在召唤时从施法怪抄（宠物表没有母体 id）。
- BindPoint 是主骨架上的同名挂点；新增挂点加在枚举末尾并写 BindPointDic，不改旧序号。
- 受击：无地面落点树时 BuffId_2/4 必须为 0，否则扫地第一帧在施法者身上加角色受击；转换器会把 2/4 填回 1/3，只改 trunk 再转会被覆盖。前摇 Delay 内盒子跟随但不结算。
- 不手改 Buff 资源的 Odin YAML 塞节点：反序列化失败会把 Effects 清空并覆盖文件。

# 3. 边界

- 门禁：暂无专用 profile；按任务新建。弹体相关改动走 `ballistic.md` 的 spell_unit_phase 门禁。
- 禁碰：共用 AI 资源（如 `50_ai.asset`）的全局参数；`Model/Generate/`。

# 4. 怎么验证

- 怪物：xlsx CharacterType=3 后出现 LightShield / BoneAnimView，靠近能攻击；临时只留一个技能能稳定放出。
- 技能图：圈内 05→01→07 循环，离圈一次 06，无 attack2 闪动；勾脱离母体后母体死蛋还在，玩家死亡仍清召唤物。

# 5. 证据

t003、t006、t013、t017、t028、t029、t034（示例：100004/2000010、100280/2000178、2000182、100282 正步炸弹鸟）。

# 6. 版本历史

- 1.0.0（2026-10-14）：由 monster_ai.json 与 spell_hit_vfx.json 合并提炼。