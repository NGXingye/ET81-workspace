> 最新修改时间：2026-11-03 20:30 UTC+8
> 版本号：2.3.9
> 文档状态：生效
> 读取等级：L1（改发射物阶段 BT / 分阶段Buff单位 时）

# 0. 速览

是什么：服务器一弹改阶段的 BT 叶子——「分阶段Buff单位」只保留 Input/Output、单位ID、Stages；Stages 是单颗 SpellUnit 的生命周期管线（接入+能力盖章），Children 才挂轨完等事件反应树。  
最大风险：把条件/循环/选目标塞进 Stages；把 HitActions 误拆进 Children；误用已废弃的「接入冲击」；同 SpellUnitId 多子 Buff 抢 present 键；把作者面「是事件」误写成阶段 Stages。  
做对的标准：权威一般在「接入逻辑」才 Create（仅接入骨骼保持客户端 present，不提前 Create；到期靠 CleanupPresentForBuff）；AtMs 是施法时间轴绝对关键帧；Stages=武装/盖章，Children=离散事件后 BT；弹着点爆炸走 WaitTrackComplete→AddBuff（传 HitPosition）；表现皮客户端播，逻辑/轨/碰撞服务端改；无「接入碰撞」阶段则转出的 SpellUnit 不应带着 Trigger/Box。  
门禁：不改 2000193 资产直到用户确认；trunk ↔ Bridge ScriptsET 成对同步；不 SVN 直至确认。

# 1. 怎么运转

- 旧节点 `BTCreateBuffUnit` / **创建Buff单位**：杂志、子母弹、落地动画等完整创建。已无 `HoldOnLaunchPoint`。
- 新节点 `BTCreatePhaseBuffUnit` / **分阶段Buff单位**（`NodeTitle`）：`BTAction`。字段：Caster / Buff → Unit、`SpellUnitId`、`Stages`（SerializeReference）；**Children** 挂事件反应子树。
- 基类 `SpellUnitCreatePhase.AtMs`：**施法时间轴关键帧**（相对根/本 Buff 的 `LaunchStartTimeMs`，吃根 TimeScale）；`<=0` 不额外等。晚创建时已过关键帧 → 剩余 0、立刻执行。API：`GetPhaseAtMs` / `ResolvePhaseWaitRemainMs` / `AwaitPhaseAtMsAsync`。
- **01 外层 `BTTimeWait` 只作创建门闩**，不从各阶段 AtMs 再扣一遍。
- **多段动画（01/02/03）时间轴**：CreatePhase / EnterBone / AttachVfx / PlayAnim 的 AtMs、AwaitPhaseAtMs、ResolvePhaseWaitRemainMs 对齐的是 **施法根 Buff 的 LaunchStartTimeMs 总轴**（本阶段 Buff 若已 CopyLaunchPhaseFrom 则用自身 LaunchStartTimeMs；否则回落根）。**不是** 01/02/03 段本地动画轴，也不是 Buff Duration，更不是 EffectClientBuffAdd 里 BTCreateBuffEffect.Duration。AtMs<=0 立即执行。
- **仅骨 present 表现时序**：EnterBone 异步 Spawn present；AttachVfx/PlayAnim（ClientDrive）若 present 尚未 Register 则 **入队**，Register 后 Flush。仅骨无 Create 时 PlayAnim 落到 present GO Animator。Buff 仍存活则 present 不因 PresentTimeoutMs 被清。
- **LaunchStartTimeMs 起点与拷贝**：施法根 Buff InitializeLaunchPhase 时写入（默认 startTimeMs ?? CreateTime；BTSetRootMotion/BuffVMSetRootMotion 可按新 Motion 重写）。子 Buff 经 CreateChildBuff → CopyLaunchPhaseFrom(parent) **只拷 immediate 父**的 LaunchStartTimeMs/LaunchDurationMs（故 705←702←700 是父链拷贝，不是搜索整树）。ResolvePhaseWaitRemainMs：本 Buff LaunchStartTimeMs>0 用本 Buff，否则用根。
- **AtMs=0 语义**：不等待总轴，**BuffAdd/阶段驱动当帧立即执行**。多段里若 02 开段才 AddBuff(05) 且 AtMs=0，创建 时刻=02 开段，与「对齐 02 段轴还是总轴」无关；循环中丢球应查 present 竞态/Duration 到期/CleanupPresent/挂点切换，而非总轴。
- **若需要「相对本段开段」的 AtMs>0 关键帧**（例如 02 开段后再等 200ms）：现状拷贝后 origin 仍是施法总轴起点，要把 AtMs 配成总轴绝对时刻，或另开 AtMsOrigin=BuffCreate|ParentCreate（未实现，需选型）。循环贴盾保活优先靠 Buff Duration/EnterHold/present 跟骨，不要靠改总轴。
- **拆子 Buff(05) vs CreatePhase 挂在动画 Buff(02)**（设计选型，勿大改运行时）：
  - **路 A（现 702→705）**：00 编排各段动画 Buff → 02 客户端播动画 → 服务器 BTAddBuff/CreateChildBuff(05) → 05 上挂 CreatePhase。CreateChildBuff 会 CopyLaunchPhaseFrom + RegisterChild：父 02 Dispose 默认 ParentRemove 连带 05；但可**单独 Remove 05**（提前炸/清球）而 02 动画继续。present/Create 的 BuffId 领养键是 **05.Id**，与 02 动画树分离。
  - **路 B**：CreatePhase Stages（或同 Buff 的 EffectClientBuffAdd + CreatePhase）直接挂在 02。少一个资产；BuffId=02；球与段动画同生共死；提前结束球需手动 CleanupPresent 或结束整个 02，多段复用时 Stages 易把 02 树撑胖。
  - **AtMs 纠正**：对齐参考**不是** 05.CreateTime，而是拷贝后的 LaunchStartTimeMs（施法总轴）。仅 AtMs<=0 时行为碰巧≈05 创建/BuffAdd 当帧。AtMs>0 仍相对总轴，不是「相对 05 创建再等 N ms」。00 的 Wait 仍决定「何时 Add 05」；不决定 AtMs 原点。
  - **推荐**：贴盾循环炸弹 / 需提前炸或球与动画寿命不同 → **路 A**；单段、球与动画同生共死、配置求简 → 路 B。纯客户端-only 骨皮可挂 02；需同步权威球/碰撞仍走服务器 Add 子 Buff（或 02 上带接入逻辑的 CreatePhase，由服务器驱动）。

- **Stages（本单位生命周期管线；已删 Wait/Birth；勿用 EnterImpact）**：
  - **接入骨骼** `EnterBone`：用 `SpellUnitId` 配皮（不另选预制体），挂施法者 `CasterPoint`。仅客户端 present；**服务端不占 `PresentSpawnKeys`**。仅骨（无接入逻辑/轨迹）不 Create 权威 Unit，避免 PlayAnim/EnsureCreated 过早 Create→TryConsume 摘活骨；Buff 到期由 `CleanupPresentForBuff` / `RemoveSpellUnitsByBuffId` 清 present（及同 buffId Unit）。有接入逻辑后 Create 前须写入 `BuffId`/`BuffUnitId`；`TryConsume` 要求 `buffId!=0` 且严格同 Buff 领养（多子 Buff 同 SpellUnitId 不互抢皮）。
  - **接入特效** `AttachVfx`：特效预制体 + 单位实例 `BindPoint`（父级始终本单位皮，非施法者）；可在接入逻辑前，逻辑前需已有骨皮。
  - **接入逻辑** `EnterLogic`：无参；到此才权威 Create（GO↔Unit）；挂点来自当前 Buff 烘焙表。BT：`RunStagesDeferredAsync`。只创建，不握持。
  - **接入持握** `EnterHold`：挂点 `Point`。同一颗已创建的单位，采样该挂点在本 Buff 烘焙表里的那一行并握上。不要求轨迹。表里没有这一行则握失败，单位留在原地。接入轨迹会松开并飞出。（未验证）
  - **接入轨迹** `EnterTrack`：`ballisticId` / `ballisticIdList`，**`TrackSeekMs`（切入时间毫秒，默认 0=从头）**；不填 Speed；有本阶段时 Create 握持，到此 `Release` 进轨。Seek 只读显式 `TrackSeekMs`，**不因 AtMs/elapsed 自动推相位**。弹道前段平段「多等」属弹道资源；要跳过则填平段时长（如 50054≈1967）。**不等待轨完**；轨完后反应走 Children。
  - **接入动画** `PlayAnim`：`AnimState` 打到单位自己的 Animator；可放在接入轨迹后、更大 AtMs → 飞中切状态（非施法者 MotionType）。
  - **接入碰撞** `EnterCollision`：`CollisionDurationMs`、`HitActions`；开 PhysicsBody 并盖命中配置。HitActions 留在 Stage（与 ballisticId 同层盖章），由物理命中管线执行，**不拆进 Children**。作者面未勾「有接入碰撞」时转化器不应写出本 Stage（见 `skill_sync` / `skill_pipeline`）。
- **Stages vs Children 三层边界**：
  1. Stages = 接入/武装（打开本单位能力）。
  2. Stage 字段 = 能力配置盖章（`ballisticId`、`HitActions`、`CollisionDurationMs`、`AnimState`、挂点/特效名）——不是 Children。
  3. Children = 离散生命周期事件后的反应 BT（如 `等待轨迹走完` → `AddBuff`）。仅当产品要「每次命中再跑整棵 BT」才考虑新「等待命中」节点——现在不做。
- **作者面三类发射语义（交叉引用）**：管线「是逻辑 / 是阶段 / 是事件」互斥；**是阶段**才映射本卡 Stages。**是事件**的 Buff 加在这颗发射物身上，停在当时坐标，用 EventRefKey 引用，不占触碰角色/环境 hit-fx 号。判断可以写在 00，不必写在本节点的 Children。边界在 `skill_tree`，本卡不复制整段转化。
- **Case A 弹着点爆炸（已验证）**：同树 `BTCreatePhaseBuffUnit.Children` → `等待轨迹走完` → `AddBuff(爆炸Buff号)`。AddBuff 把黑板 `Pos`/`HitPositions` 戳进子 Buff `SpellTarget.HitPosition`（`BuffHelper.TryStampChildHitPosition*`）。爆炸 Buff 自带 Duration + 点特效/`CastShape`；创建 Buff 不必覆盖爆炸窗。勿用接入冲击；勿在 EnterTrack 下挂 0–1 进度事件（除非将来要 progress∈(0,1) 且不停轨）。
- **Case B 施法者烘焙挂点爆炸（设计）**：01（或外层动画 Buff）`AddBuff(新号)`，新号自带 LaunchPoint 烘焙 + 独立 Duration；不走弹体 Stages，不用接入冲击。
- 入口：`SpellUnitCreatePhaseHelper`；async BT Handler；BuffVM `BuffVMCreatePhaseBuffUnitHandler`；客户端 `SpellUnitPhasePresentInvokeHandler` / present 组件。
- 甜点顺序：骨 → 特效? → 逻辑 → 持握? → 轨 → 播放动画? → 碰撞?。无表现可略过骨/特效。无接入碰撞则略过碰撞 Stage。要跟骨头走且不飞出，用持握，不要把该挂点烘焙成轨迹。
- 仍可单独挂旧三节点：握持挂点 / 释放进轨 / 命中开关。杂志类继续用旧创建。


- **EnterBone→EnterTrack 同 Unit**：Create 握持→ReleaseToTrack，不新建弹体；present TryConsume 只换皮。握持/Create 采挂点进度优先用烘焙时钟 elapsed/(Positions.Count/SampleFrameRate)（对齐 AtMs），避免 LaunchDurationMs==0 或快照强制 rate=0 采到第 0 帧导致骨皮接不上。**进轨起飞**：`EnterTrack.TrackSeekMs` 显式配置弹道切入点（→ `ResolveTrackSeekRate` → `SeekToRateForHoldRelease`）；默认 0 从头。多等前段平段是弹道资源问题，不是 Stages 又等了一遍 AtMs；要跳过平段请填 `TrackSeekMs`（如 50054 填 1967），勿写死 rate、勿按 AtMs 自动 seek。


# 2. Speed 与时钟

- 阶段节点**不暴露 Speed**；时空归 `BallisticCopy`（`Time`/`Distance`/`animDistance`/`useAnimDistance`）。
- EnterTrack 握持后再挂 TrackMove：须 `useBallisticGeometry=true`（非仅 useAnimDistance），否则 `duration*speed(=0)` 零前进距。
- AtMs 与 01 等待是两层语义：门闩管「何时开始跑 04」；AtMs 管「动画轴上何时进下一生命周期」。
- 接入轨迹本身不阻塞后续阶段；轨完用 `等待轨迹走完`（开火早于 `DelayDispose`）。

# 3. 坑和不变

- 接入轨迹切入段用 `TrackSeekMs` 显式配置；多等前段平段是弹道资源，不是自动 seek 写死 rate。
- 同一颗蒙皮弹出池再上盾：LeanPool 只收回根 TRS，attack3 把朝向写在根 `localRotation`。出池抄回预制体根旋转和缩放（不改根位移）及子节点，然后停掉 Animator。不要 Rebind 后再 Play 当前状态，那会重新进入 attack3。同一发跟骨或飞行中的皮不洗。飞行中若开过 `updateWhenOffscreen` 或 `forceMatrixRecalculationPerRender`，出池必须关掉，否则停掉的 Animator 仍按上一发末帧蒙皮。
- 跟骨皮进轨换父会空一两帧：换父发生在本帧蒙皮更新之后。提前摘骨、补裁剪、渲染时重算矩阵都消不掉，且重算会把上一发末帧留在池里。不要提前 `EnterTrack`，不要改活骨骼或缩放。

- Stages **只描述本单位生命周期次序**；分支/条件/选目标留外层 BT 或 Children 事件树。
- HitActions / ballisticId 是 Stage 盖章，不是 Children；命中走物理管线。
- 「接入冲击」已废弃：弹着点爆炸用 Case A；烘焙挂点用 Case B。
- 挂点跟 **LaunchPoint 烘焙**；EnterBone present 跟施法者活骨是皮，不作权威位姿。
- 一弹同 Id 改阶段，禁止表现球销毁交接第二颗逻辑球。
- 服务端 EnterBone 早退，勿 `PresentSpawnKeys.Add`；Create 前写 BuffId，TryConsume 严格同 Buff。
- 接入特效父级 = 本单位实例骨骼；逻辑前挂特效依赖已接入骨骼。
- Buff 寿命：`EnsureBuffCoversCreatePhaseWaits` 按最大 AtMs 延长；碰撞窗归 `CollisionDurationMs` / 轨迹；爆炸窗归爆炸子 Buff Duration，不拿创建 Buff 硬顶。
- 资产若仍残留旧 Wait/Birth/EnterImpact 行：检视器删除后重存。
- 无「接入碰撞」时转包围盒应对 Stage Unit **清掉 Trigger/Box**（可保留 Move）；勿把空碰撞当成失败。细节见 `skill_sync`。
- 接入逻辑只创建。跟指定挂点走且不飞出，用接入持握，采样该挂点自己的烘焙行；没有这一行则握失败。第二次接入骨骼不改挂点。接入轨迹会松开持握。（未验证）
- 触发器类型为无、碰撞体为空的技能体仍会建物理体，并打开连续碰撞。内半径为 0（空形状、网格、圆角为 0 的盒子）时改用离散，跳过 LinearCast，否则每步断言。只跟轨迹的单位不补实心形状。空形状不再刷错已由用户确认。

# 4. 怎么验证

1. 节点名「分阶段Buff单位」；Stages 可选骨/特效/逻辑/持握/轨/播放动画/碰撞（无 Wait/Birth/接入冲击）；每项有 AtMs。持握不要求轨迹，运行尚未测到。
2. 01 等待后创 04；关键帧与动画轴对齐；晚创已过 AtMs 立即落地。
3. 同 SpellUnitId 两子 Buff：先入轨者不摘后发者骨皮；各 Buff 严格领养自己的 present。
4. `接入轨迹 → 播放动画(更大 AtMs)`：飞中切到指定 AnimState。
5. Case A：Children 挂 `等待轨迹走完`→`AddBuff`；轨完爆炸在弹着点（非施法目标点）；创建 Buff 短命、爆炸 Duration 独立；弹体 DelayDispose 后特效仍播完。
6. 服务端无 present 占键；客户端 AtMs 到可见骨皮；有接入逻辑后才有权威 Unit/碰撞；仅接入骨骼不 Create（present + CleanupPresentForBuff 到期销毁）。
7. 旧「创建Buff单位」行为不变；trunk 与 Bridge ScriptsET 成对。
8. 作者面未勾接入碰撞的阶段：转盒后 SpellUnit 无 Trigger/Box；有勾才有 EnterCollision Stage。
9. 不改 2000193 配表直至确认。

# 5. 定位（拍板用）

- 本节点 = `BTCreateBuffUnit` 的分阶段形态（创建类叶子 + 关键帧管线），**不是**新技能中间件。
- 新需求优先外层/Children 加节点或子树，不把 Stages 撑成通用脚本。
