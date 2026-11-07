> 最新修改时间：2026-11-05 18:20 UTC+8
> 版本号：1.8.0
> 文档状态：生效
> 读取等级：L1（关键词命中怪物 / AI / BuffVM / 召唤 / 受击时读取）

# 0. 速览

> 速览：怪物 AI 在服务端跑行为树选技能（距离带 + DistanceTrigger）；技能本身是 BuffVM 技能图，服务端与客户端按同一进度各跑一份；召唤、孵化、被动死亡、受击 Buff 都挂在这套图上。
> 最大风险：客户端那份 VM 做了只该服务端做的事（加 Buff、读本端目标、拆单位），以及配置距离带互不相交导致「不放技能」。
> 做对的标准：怪物按配置距离放出预期技能；客户端表现只跟服务端 M2C_BuffAdd 走，无闪动、无叠射。
>
> 门禁：[`profiles/pet_locomotion.md`](../profiles/pet_locomotion.md)（宠物客户端起步）；怪物其余任务开工时仍可另建或借用。

# 1. 怎么运转

- 身份：MonsterScalingLevelConfig.CharacterType=3 → `Unit.IsMonster` → 数值、敌我、AI、动画分支才生效。CharacterType=0 时 AI current 为空、不攻击。
- 距离：DetectionRange 相对自身看见；ChaseRange 相对出生点软拴绳；`[min_attack_range, attack_range]` 是追击停步出手带（不选技能）；DistanceTrigger 用表 `attack_distance` 选技能（Inspector Distance 条件已注释）。有效距离 = max(表距离, 自身半径) + 目标半径。
- 技能图：重复走 BuffVMRepeatHandler，圈内 true、圈外 false → 执行 OnExit；子 Buff 继承父 AlreadyRate。
- 受击 AddBuff 四槽：1 命中持续（目标）、2 不命中=地面持续（加在施法者）、3 命中一次性、4 地面一次性。
- 关键入口：`Hotfix/Server/Demo/Map/Spell/BT/AI/AI_Monster*Handler.cs`、`Hotfix/Server/Demo/Map/Spell/BuffVM/`、`PetComponentSystem.cs`、`SpellHitActionAddBuffHelper.cs`、`Config/Json/cs/MonsterSkillConfig.txt`。
- 宠物跟随：`AI_PetFollow` 每帧 `NearMove`，力度按离槽距离衰减，不置 `UState.AIPetFollow`。游走才是稳定 `WalkSpeed` 寻路。客户端步态只在判成 Run 时写 `priorState=1` 且 `moveSpeed` 过起步门槛。

# 2. 坑和不变量

- 距离设计顺序：先定技能 attack_distance，再定 min_attack_range（近战 0~1）、attack_range、DetectionRange、ChaseRange，满足 `0 ≤ min < 技能有效距离 ≤ attack_range ≤ Detection ≤ Chase`。表距离改 0 仍是贴身，不能用来禁用近战。
- 怪物 AI 只在服务端施放。客户端 VM 里的 BTAddBuff 对怪物直接成功不创建，表现只认 M2C_BuffAdd（玩家/宠物的 HLSPredict 预测保留）。不加「怪物客户端预测」或「客户端提前播表现」：那是旧加 Buff 节点上的补丁，没有时间轴权威，已撤（t043）。另做一颗表现球去跟预测弹，预测弹没提前出来时表现球停在脱手点，不用来补空档（t043）。出圈判断只读 Buff 上同步的 SpellTarget，不读本端 TargetComponent。
- 不同步字段在客户端是默认值：`PetComponent.DisposeWhenOnwerDispose` 不同步，HLSUpdate 只能在服务端执行，否则母体一移除客户端就拆蛋。
- 循环攻击：间隔不能只看动画结束缓存或游标剩余时间（会叠射或越来越密）；离圈动作挂 OnExit，不挂条件 Out；BTBreak 没有 BuffVM 处理器。
- 填怪物技能冷却时，`MonsterSkillConfig.cooldown` 从出手起算，秒数已经包含技能有效时间，不吃攻速。动作结束后的空等 = 表秒数 − 有效时间。有效时间 3 秒还要再空等 3 秒就填 6；填成和有效时间一样，动作一结束就会再放。
- 客户端表现等待（BTTimeWaitViewAsync）默认不写 AlreadyRate、不改服务端时钟，从节点执行起用墙钟等。「对齐逻辑启动」仍是旧节点上的补丁，不是时间轴权威。服务器异步等待没有「对齐施法起点」，从节点执行起等（t043）。
- 阶段类 env 用 long 写入、TryToLosslessInt 读；`AddStruct/GetStruct<int>` 存不回去。
- 被动死亡是服务端节点，挂在特效 Buff 图的异步等待后面，等上层回空再播 Base 层死亡；不要为露出死亡去清 UState.Attack，也不挂客户端图。
- 节点保持通用：等待、延迟挂 AI、等 Buff 结束再移除各用自己的开关，不做只服务一只怪的复合节点；母体身份在召唤时从施法怪抄（宠物表没有母体 id）。
- BindPoint 是主骨架上的同名挂点；新增挂点加在枚举末尾并写 BindPointDic，不改旧序号。
- 一份施法形状上的多个挂点名会各出一个碰撞盒，多挂点已经实现。看不见时先看 BTCastShape 碰撞信息里的持续时长：30 毫秒会马上结束，改成 900 毫秒就能看见各挂点的盒子。550005 的额外挂点因此被误判成没实现（t043，用户核对）。盒子寿命是这个节点的持续时长，不是所属 buff 的持续时间。
- 受击：无地面落点时 BuffId_2/4 必须为 0，否则扫地第一帧在施法者身上加角色受击。本地转化不再把空的地面槽填成角色槽（未验证）。前摇 Delay 内盒子跟随但不结算。挂点 Positions 为空时保持不结算。
- 不手改 Buff 资源的 Odin YAML 塞节点：反序列化失败会把 Effects 清空并覆盖文件。
- 宠物贴槽跟着走时，衰减后的力度常常过不了起步门槛，位置在动，动画停在 idle。逻辑在移动且未明确停止时，攻击门还在也要把速度抬过门槛；普通宠物同时把 `isAiming` 写成 false，`idle_attack` 才能进 `move_attack`。站桩出手不抬。不加大 `NearMove` 力度，否则高速会冲过槽位；也不要 `Animator.Play` 硬切（t049）。
- 宠物回人：攻击优先于跟随。离主人超过 `max_owner_distance` 后闩住回人，回到编队位置附近才允许再打。当前目标还活着且在攻击距离内时不改选，否则在回人临界上会对着身边的怪来回转（t049）。
- 怪物槽（不是机械臂 MainSlot11/12）上任意一颗普通 Buff 被移除时，`BuffHelper.RemoveBuff` 会清掉整个 `SpellComponent.Current`。姿态锁是没有父 Buff、配置号等于技能 `BuffId` 的那颗根 Buff，它还在走。用槽登记看计时会提前变成没在施法，动作和后续子 Buff 仍继续。显示和「是否还在施法」要认这颗根 Buff。不要为了计时去改这次清槽：`SpellHelper.Stop`、攻击节点 `IsCastingSpell`、词条动作覆盖都读这个登记（t056）。
- 攻击姿态不锁平移，位移锁只有冲锋和跳跃。攻击中的追击每帧停下，除非施法者身上的追击租约还在，或 `is_tracking`。循环段要走：租约挂在施法者上，本段 Buff 在时刷新，消失后再留两帧，交接不断步。速度系数按跑速乘，战斗态的走路速度不参与；1 是跑速。不要开 `is_tracking`（会走过前摇和带根运动的后摇），不要用冲锋。循环期间怪物能走已由用户确认。
- 播放动画的过渡时长默认 0，是硬切。服务器等待按逻辑帧量化，循环段会提前打断片段。过渡填在开始下一段的播放节点上，从当前姿势融到新动作开头，不补完被掐掉的尾巴。只改层权重的路径不播放、也不过渡。循环段过渡已由用户确认。
- 后摇播了不等于爆炸已加在发射物上。取施法者技能体按配置号写单位和 Pos；客户端怪物找不到时仍 Success 并写 0，后面的添加会继续。爆炸加在这颗技能体上。本轮退出循环有后摇，没有爆炸形状和触发特效；持握未测，根因未闭环。

# 3. 怎么验证

- 怪物：xlsx CharacterType=3 后出现 LightShield / BoneAnimView，靠近能攻击；临时只留一个技能能稳定放出。
- 技能图：圈内 05→01→07 循环，离圈一次 06，无 attack2 闪动；勾脱离母体后母体死蛋还在，玩家死亡仍清召唤物。
- 宠物：非战斗贴槽跟着走时离开 idle；战斗中跟着走时 `idle_attack` 进 `move_attack`；主人超出回人距离后，回到身边前不再开打、不原地转。
- 循环段挂施法者追击：攻击姿态里朝威胁目标走，交接不断步；播放节点过渡时长大于 0 时，片段被提前打断仍能融过去。
