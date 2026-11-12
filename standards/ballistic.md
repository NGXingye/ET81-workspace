> 最新修改时间：2026-11-11 23:00 UTC+8
> 版本号：1.8.0
> 文档状态：生效
> 读取等级：L1（关键词命中弹道 / Copy / 枪口 / 定点延迟 / 二阶段时读取）

# 0. 速览

> 速览：弹道从 SkillEditor 的 BallisticConfig（作者面）经 Bridge 转成 trunk 的 BallisticCopy，再由 SpellUnit 的 TrackMove 在两端按进度飞；弹体还可在中途「摘下」转成 AI 移动（二阶段）。
> 最大风险：三处单位与原点不一致——Z 的单位（米 vs 米/D）、飞行时钟（Buff 时长 vs Copy.Time）、出生点（红点 vs 第 0 帧）。
> 做对的标准：游戏里弹道与编辑器预览一致、不拉扯，落点贴地能触发地面爆炸，二阶段在指定进度接续同一发。
>
> 门禁：`profiles/playeffect.md`、`profiles/spell_unit_phase.md`

# 1. 怎么运转

- 作者面：SkillEditor `BallisticConfig` 是唯一权威（目录 `globalconfig/ballistic`，无 s；资产 `ballistics_m{怪}_{Key}`）。D = 以发射点为圆心的水平半径，终点必在圆上；正算统一走 `DirectionalPathEval`：`fire + dir×D×p + right×X + up×Y + dir×Z`。
- 转换：`SampleBallisticCurves` 把曲线求值写入 OffsetPositions，用水平距离 D 决定采样帧数，不再写 `animDistance`（trunk r8924 已删该字段和 `useAnimDistance`）。只转轨迹再由本地 Launch 把飞行秒写入 `Copy.Time`、D 写入 `Copy.Distance`。
- 运行：`pos = 挂点 + rate×L×fwd + right×X + up×Y + L×Z×fwd`。定点几何（`useBallisticGeometry`）的长度是 `Copy.Distance`，时长是 `Copy.Time`（有 overrideSpeed 时用 Distance/speed）。没有这面几何时，怪物 L 仍是节点 speed × 子弹 Buff 秒，Time 与 Distance 都为 0 才用 Copy。采样点数 = OffsetPositions.Count，相邻点直线插值。（几何分支读 Time/Distance 未验证）
- 二阶段：`BTDelaySpellUnitAtPos` 挂在 OnEachLaunchChildren，当帧只盖章；进度到了摘掉 TrackMove、换 AI 移动，寿命/速度/命中/行为写在同一发上，原地不吸附。
- 关键入口：`SpellUnitHelper.cs` 留公共类型和定点创建入口。`SpellUnitHelperDelay.cs` 到进度摘下，下一拍再追击。`SpellUnitHelperLaunch.cs` 算挂点位姿并握住。`SpellUnitHelperCreate.cs` 组装弹体、飞行时长和落地动画。`SpellUnitHelperLife.cs` 轨迹结束和寿命结束。另有 `SpellUnitTrackMoveComponentSystem.cs`、`BuffVMCreateBuffUnitHandler.cs`、`SpellUnitVisualAttach*`、Bridge `SpellConversionEngine.ConfigWriter.cs`。

# 2. 坑和不变量

- 不要把 TrackMove 改成 Z 当米。`animDistance` 与 `useAnimDistance` 已删除，不要再写这两个字段。已 ÷D 的资产不要重复转。
- 曲线 0～1 是这一发从出生到结束的进度，没有全局播放头；源曲线末时间对齐子弹 Buff 飞行秒，不是技能总长。
- 空中「拉扯」先查视觉贴附，不是采样或碰撞。贴附不再由 `useAnimDistance` 开关。不要为关贴附去上游清 Z 曲线。
- 出生点是挂点表在发射相位那一帧（帧号 = 出手秒 × 采样帧率），曲线第 0 帧必须 (0,0,0)；末点 Y 相对出生点，贴地 ≈ 负的出手高度，否则碰不到地不爆炸。
- 枪口表按发射相位采样。子 Buff 复制父的 LaunchStartTimeMs 和 LaunchDurationMs，不复制 AlreadyRate。相位 = (现在 − 起点) / 时长，夹在 0 到 1。时长是这次根运动的 TotalDuration，不是表的帧数，也不是别的 Buff 的 Duration。等待只推迟创建。设置根运动成功才把起点改成这一刻；同动作还在播时默认不改。播放动画不改起点（t064，用户核对）。不要把表垫到 Timeline 帧数。
- 骨架挂点轨道按 `RootMotionComponent.motionType` 现取，动作切换后还在飞的子弹会跟新轨道。
- 二阶段：轨迹未 Awake / startTimeStamp=0 / totalTime 无效时进度「不可读」，只盖章，不能当成 1。进度 1 与 Buff 到期同帧，必须在结束分支 DelayDispose 之前处理；找到节点后再置 fired。节点 LifeTimeMs 不延长创建 Buff 和根技能 Buff，宿主时长仍是到期时钟。摘下只离开轨迹；追击和寿命子节点不放在 TrackMove 的更新栈里（t063，用户核对）。
- Buff 发射的弹体不走定点创建，转向速度是 0。追击会 TurnToUnit，角速度为 0 时不写旋转，弹体保持弹道朝向。摘下时若转向速度约等于 0，把 TurnSpeedBase 写成一圈每秒，与定点创建相同。不改 50_ai，不改 200017501、200017504（2000175，用户核对）。
- 定点节点的 HitActions 不是空的时，摘下拆掉弹体上的 SpellUnitHitActionsComponent，再按该节点的列表新建。飞行命中在 BTCreateBuffUnit，摘下后的命中在 BTDelaySpellUnitAtPos，两份可以不是同一套。客户端预测也会换，新容器的同步 Id 和快照里的不一样（200017504，用户核对）。
- 二阶段不新建技能体（重开动画会停顿一帧）；前面不要挂「等待轨迹结束」。客端寿命结束特效靠同步字段在移除/预测超时时补放，同配置同节点约 0.5 米 500ms 内只放一次；不改共用的 `50_ai` 超时，也不改 `Config/Spell/2000175-正步炸弹鸟-炸弹小鸟/` 的 200017501、200017504 两份行为树。
- 二阶段动画沿用出生时的 Animator：拆轨迹动画组件再挂、交叉淡化一次；不走 AnimatorParamHelper，不调 `Animator.Update(0)`。
- 怪物不走 ClampThrowPosAboveGround；SpellUnit 盒子有半高，Y 终点不扣会提前 OnHitGround。
- 二阶段改动 trunk 与 BridgeEditor `ScriptsET` 成对改。
- 不把 Play 选 Clip / Binder 当弹道作者入口，不把曲线图当编辑器（UseVelocityCurve 保持关）。
- 落点矩形是同一条曲线在名义终点周围另抽一点，不是再做一把 Key，也不写进 BallisticCopy。L 是侧向全长，范围 [-L/2, L/2]；R 是前进全宽，范围 [-R/2, R/2]；高度锁在名义终点。一把 Key 只有母体那一块矩形，复用发和同怪另一条技能都收成这块。同一段动画里，同一时刻、同一预制体、同一挂点、同一把 Key 是一个 Buff：`SpellUnitIdList` 按发数重复同一个 Id，挂点只有一个，`BTSpellUnitLandingRandom` 挂在 `OnEachLaunchChildren`。稍后相同的齐射复用这个 Buff，每个等待只加一次。两段动画即使矩形相同也各一份，因为发射表按动画各烘，曲线不同不能共用。作者仍是一发一条。每一行写入命中角色和命中地面特效名。每一发是单独一枪，节点打在这一枪自己的子弹上。`ballisticIdList` 仍是每次施法定选曲线形状。转出生方向或改 speed 会带动整条弧；节点 speed 仍是这一发当前 Key 的 D 除以飞行时间。客户端同名特效在 0.4 米、0.15 秒内会合并，扎堆落地看起来可能少几发。（游戏内齐射散开与地面特效数量未验证）

# 3. 怎么验证

- 只转轨迹后 Copy.Time 是飞行秒、Copy.Distance 是水平 D；拷贝上不再有 animDistance。关贴附后不再拉扯；四发水平方向跟客户端枪口。（Time/Distance 写入未在游戏内核对）
- 二阶段：进度 0.9 先飞再摘；进度 1 飞完进入追击、不在终点销毁；提前命中不炸寿命特效。定点弹到进度后离开轨迹并追击，机头朝向目标，宿主 Buff 不被节点存活拉长，到期拆掉弹体。客户端已经预测超前时，回滚不再因写同步 Id 空引用而停预测（2000175，用户核对）。
