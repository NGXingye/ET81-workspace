> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（关键词命中弹道 / Copy / 枪口 / 定点延迟 / 二阶段时读取）

# 0. 职责定位

> 速览：弹道从 SkillEditor 的 BallisticConfig（作者面）经 Bridge 转成 trunk 的 BallisticCopy，再由 SpellUnit 的 TrackMove 在两端按进度飞；弹体还可在中途「摘下」转成 AI 移动（二阶段）。
> 最大风险：三处单位与原点不一致——Z 的单位（米 vs 米/D）、飞行时钟（Buff 时长 vs Copy.Time）、出生点（红点 vs 第 0 帧）。
> 做对的标准：游戏里弹道与编辑器预览一致、不拉扯，落点贴地能触发地面爆炸，二阶段在指定进度接续同一发。

# 1. 怎么运转

- 作者面：SkillEditor `BallisticConfig` 是唯一权威（目录 `globalconfig/ballistic`，无 s；资产 `ballistics_m{怪}_{Key}`）。D = 以发射点为圆心的水平半径，终点必在圆上；正算统一走 `DirectionalPathEval`：`fire + dir×D×p + right×X + up×Y + dir×Z`。
- 转换：Bridge `SampleBallisticCurves` 写 Copy：X/Y 仍是米，Z_copy = Z米 / D，并把 D 写进 `Copy.animDistance`。
- 运行：`pos = 挂点 + rate×L×fwd + right×X + up×Y + L×Z×fwd`。怪物 L = 节点 speed × 子弹 Buff 秒，不读 Copy.Time/Distance（两者都为 0 才用 Copy）。采样点数 = OffsetPositions.Count，相邻点直线插值。
- 二阶段：`BTDelaySpellUnitAtPos` 挂在 OnEachLaunchChildren，当帧只盖章；进度到了摘掉 TrackMove、换 AI 移动，寿命/速度/命中/行为写在同一发上，原地不吸附。
- 关键入口：`SpellUnitHelper.cs`、`SpellUnitTrackMoveComponentSystem.cs`、`BuffVMCreateBuffUnitHandler.cs`、`SpellUnitVisualAttach*`、Bridge `SpellConversionEngine.ConfigWriter.cs`。

# 2. 坑和不变量

- 不要把 TrackMove 改成 Z 当米：会毁掉 `useAnimDistance=true` 的动画烘焙弹道（如 1202/1203），这类 Copy 也不要再 ÷D。已 ÷D 的资产不要重复转。
- 曲线 0～1 是这一发从出生到结束的进度，没有全局播放头；源曲线末时间对齐子弹 Buff 飞行秒，不是技能总长。
- Directional（animDistance>0 且 useAnimDistance=false）：TrackMove 把 forward 压到 XZ，客户端不挂视觉贴附；贴附只给 useAnimDistance 的枪口叙事用。空中「拉扯」先查贴附，不是采样或碰撞。
- 需要贴枪口的 Copy 目前转完人工把 animDistance 置 0；不要为关开关去上游清 Z 曲线。
- 出生点是挂点表在发射相位那一帧（帧号 = 出手秒 × 采样帧率），曲线第 0 帧必须 (0,0,0)；末点 Y 相对出生点，贴地 ≈ 负的出手高度，否则碰不到地不爆炸。
- 枪口表按开火 Buff 的 AlreadyRate 采样（子 Buff 继承父的 AlreadyRate）；开火层 Duration 必须 = `1000 × 挂点总帧 / 采样帧率`，不要把表垫到 Timeline 帧数。排队用的等待若推进相位，后续开火会从动画中段取枪口。
- 骨架挂点轨道按 `RootMotionComponent.motionType` 现取，动作切换后还在飞的子弹会跟新轨道。
- 二阶段：轨迹未 Awake / startTimeStamp=0 / totalTime 无效时进度「不可读」，只盖章，不能当成 1。进度 1 与 Buff 到期同帧，必须在结束分支 DelayDispose 之前处理；找到节点后再置 fired；盖章时按剩余飞行 + LifeTimeMs 延长创建 Buff 与根 Buff。
- 二阶段不新建技能体（重开动画会停顿一帧）；前面不要挂「等待轨迹结束」。客端寿命结束特效靠同步字段在移除/预测超时时补放，同配置同节点约 0.5 米 500ms 内只放一次；不改共用的 `50_ai` 超时。
- 二阶段动画沿用出生时的 Animator：拆轨迹动画组件再挂、交叉淡化一次；不走 AnimatorParamHelper，不调 `Animator.Update(0)`。
- 怪物不走 ClampThrowPosAboveGround；SpellUnit 盒子有半高，Y 终点不扣会提前 OnHitGround。

# 3. 边界

- 门禁：作者面任务 `profiles/playeffect.md`；二阶段 `profiles/spell_unit_phase.md`（Trunk 与 BridgeEditor `ScriptsET` 成对改）。
- 禁碰：`Config/AI/50_ai.asset`、`Model/Generate/`、整份覆盖 `200017501` / `200017504`；不把 Play 选 Clip / Binder 当作者入口，不把曲线图当编辑器（UseVelocityCurve 保持关）。

# 4. 怎么验证

- 中段 Z ÷ animDistance 后与预览一致；关贴附后不再拉扯；四发水平方向跟客户端枪口。
- 二阶段：进度 0.9 先飞再摘；进度 1 飞完进入追击、不在终点销毁；提前命中不炸寿命特效。

# 5. 证据

t003、t004、t006、t011、t029、t031、t032（示例配置：2000010 四发 1202/1203、海豹 50005、2000182/50030、2000175/50027）。

# 6. 版本历史

- 1.0.0（2026-10-14）：由 ballistic.json、playeffect.json、spell_unit_phase.json 与对应 profile 合并提炼。