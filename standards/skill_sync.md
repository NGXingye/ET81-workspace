> 最新修改时间：2026-11-11 23:00 UTC+8
> 版本号：1.24.0
> 文档状态：生效
> 读取等级：L1（关键词命中 SkillSync / 转化 / 提交原料或配置时读取）

# 0. 速览

> 速览：把 SkillEditor 里做好的技能（timeline、collider、弹道）经 BridgeEditor 的转化引擎变成 Spell/Buff/SpellShape/SpellUnit 配置，落到本机 trunk 并按序提交 SVN。只服务本机。
> 最大风险：SVN 范围和顺序——整树 update、整份覆盖 globalconfig、先交配置后交原料、ConfigET 与 trunk 同批提交。
> 做对的标准：trunk `Config/Spell/{id}-名/` 下生成对应配置；原料与配置两笔都被 pre-commit hook 放行；ConfigET 对齐无 diff。
>
> 门禁：`profiles/skill_sync.md`

# 1. 怎么运转

SkillEditor 管线输出格 → 预检叠入（提交原料：timeline + collider；发射点上有弹道 Key 时再加 globalconfig 索引那一行和对应轨迹）→ 转化到本地 → 白名单 `File.Copy` 进 trunk Config → 提交配置 → 自动对齐 ConfigET。转技能树不调用 `SpellConversionEngine.Convert`，只在本地写行为树并填 ID。转包围盒仍调用共享的 SpellShape / SpellUnit 写法。共享窗口 `TimelineToSpellConverterV2` 仍走完整 Convert。

- 调度：有开着窗口的 Bridge 就写 `job.json`，由 Headless Tick 自动 `RunJob` 并回写 `result.json`；没有才用 `-batchmode -executeMethod SkillSyncHeadless.RunJob`（只剩过期 UnityLockfile 视为没开）。「取消等待」杀该进程。
- 关键入口：`SkillSync/`（Paths、Orchestrator、TimelineWrite）、`SkillPipelineWindow.cs`（只画输出行）、Bridge `SkillSyncHeadless.cs`、`SpellConversion/SpellConversionEngine*.cs`。
- Bridge 本地转化巨石已拆 partial（均在 `targets/BridgeEditor.json` `local_only`，须 `etctl sync-ignores`）：
  | 文件 | 职责 |
  |---|---|
  | `SkillPipelineBridge.cs` | 编排入口、共享状态、菜单 |
  | `SkillPipelineBridgeAuthor.cs` | 作者文件/发射点读入 |
  | `SkillPipelineBridgeShots.cs` | 出手/MissingShot 与树片段 |
  | `SkillPipelineBridgePhase.cs` | 是阶段 → Stages 写出 |
  | `SkillPipelineBridgeBoxes.cs` | 转包围盒 Shape+Unit 双写、无碰撞清 Trigger/Box；空小件槽写成 None；动态形状按黄帧窗口对齐条数，关键帧保持挂点局部偏移；全帧相同或已是一帧则时长 1、帧率 30 |
  | `SkillPipelineBridgeLaunch.cs` | 发射/轨迹相关写出；只转轨迹在共享重采样之后写攻击时长和水平距离 |
  | `SkillPipelineCollisionBuff.cs` | 碰撞 Buff 命中汇总；伤害 Buff 的挂点只留黄帧窗口，时长是这段帧数/30 秒；`AppendHits`/`Success` 看 `HasHardError`，`Errors` 里「提示：」不算硬失败 |
  | `SkillPipelineShapeSign.cs` | 把形状位置 Y 乘回正，再调用 Boxes 的挂点局部烘焙 |

- 输出按钮：导出碰撞体、构建源数据、预检叠入在同一行（导出在最左，未验证）。下面是转包围盒、转技能树、转轨迹、取消等待、全量转技能树。主页没有调整 Timeline。提交配置仍在预检之后。只转轨迹先由共享引擎重采样并落盘 BallisticCopy；飞行时间写入 `Copy.Time`、水平距离写入 `Copy.Distance` 由 `SkillPipelineBridgeLaunch` 在其后完成。`animDistance` 已删除，采样不再写它，也不再按它跳过。共享引擎整次转化仍用 Time×速度写 Distance，只转轨迹再覆盖这两项。
- trunk 落盘：Buff 与 Spell 同在 `Config/Spell/{id}-名/`（没有 `Config/Buff`）；SpellShape 由 Buff YAML 的 `spellShapesId` 反查；只有 Directional 才有 `Spell/Ballistics/BallisticCopy{id}.asset`；弹体碰撞落 `SpellUnit/{id}_{prefab}.asset`。Damage 的盒子是 SpellShape，位移在 buff 的 LaunchPointConfig。
- 本地转出 Buff **描述语义**跟结构走（勿写「本地技能树 / 客户端表象 / 服务器逻辑」）：`技能主树`；挂点伤害（逻辑形状，Buff 加在施法者身上）；阶段单位；事件形状（Buff 加在发射物身上，停在当时坐标）。边界见 `skill_tree`。多段时主树写成 `技能主树 · 第N段 · {动画 common}`（转化器尚未按段拆多份主 Buff 时只标到第 1 段；日后 01/02/03 同格式套第 n 段）。`BTTimeWaitViewAsync` 的 **NodeTitle 保持「表现异步等待」**，不要改成「视图异步等待」。
- 本地写出树的**首个**表现异步等待勾上 `AlignToLogicStart=true`；仍非整树权威时间轴，重转覆盖。见 `skill_spec` 补丁行。
- 本地转技能树：00 是姿态锁。01 客户端树是播放、根运动、等到出手时刻，然后直接写表现点的 BTCreateBuffEffect，不另开「客户端表现」Buff，也不写 LaunchPointConfig。01 的 Duration 只等于这段动作，不跟特效出手、寿命或黄帧窗口。跟骨和弱脱离登记在这个 Buff 上，Buff 结束就收；强脱离不登记，按节点 Duration 自己消失。节点上的 Duration 仍是这一发从播出起算的寿命。单位写「服务器逻辑」里的 BTCreateBuffUnit，不另写同一预制体的客户端特效；同一出手的额外表现跟这一发写在 01 上，各一个 BTCreateBuffEffect。形状按挂点各写一个 Buff：有发射物时客户端播它，发射物为空时不写客户端创建特效；服务器都用 BTCastShape，01 只添加这一次。形状采样是黄帧最早到最晚，特效时长用这一发的持续时间。碰撞盒寿命写在 BTCastShape：持续时长是黄帧毫秒，间隔是 100。job 里的 attackType 为 2 或 4 时，触发次数上限是这段毫秒除以 100 再加 1，其余为 1。攻击距离和元素不参与。同名形状共用一个形状号和一套盒子；黄帧可以只记在列表最早的一发，转树时其余挂点借用。逻辑形状的包围盒是 `{编号}_vfxmodel_c_melee_{编号}`。发射物名正好四段 `vfxmodel_c_melee_正整数` 时编号取末段，形状号不参与；为空或不是这四段时用作者形状号，未填才警告并跳过。编号来自形状号且被占用时，勾了覆盖旧号才替换，否则不写文件，行为树沿用已有号。编号来自发射物末段时不看覆盖旧号。单位行不改名。名字不是这四段时，客户端特效用真实预制体名。表现和逻辑形状的强脱离写入该点客户端 BTCreateBuffEffect.isWorldPositionStays，弱脱离写入 DetachBone，两个互斥，都不改宿主 Buff 时长。受击角色只写客户端特效并绑 HitPoint，时长缺省 1 秒；受击环境只写位置创建特效，时长缺省 2 秒。两个时长都写入受击 Buff 和客户端特效。随机弹道仍把这只怪物磁盘上的 Key 写入 `ballisticIdList`。


> 多段顺序动画（A→B→C）的 Buff 号分配：原则见 `skill_tree.md`（一动画一 Buff、00 编排）；具体连续号 vs 可覆盖号规则 **待与本卡对齐**，转化器尚未实现顺序多段。
- Buff 号从 `技能号×100+2` 起复用。可覆盖的是客户端表现、服务器逻辑、`hit fx on `、说明以「单次子弹发射」结尾的发射 Buff，和空壳；别的说明视为手改，跳过那个号。同一段里稍后相同的齐射复用已建号，每个等待只添加一次，不按发数重复加。本轮没再写出的可覆盖号在 Bridge 删掉，拷到主干后再删主干里 Bridge 已没有的同号文件。不要用目录最大号 +1：受击 Buff 一旦落到末尾，下一轮会从它后面接着编，中间旧号也删不掉。
- Damage 形状名：技能编辑器读本机 `Assets/Resources/timeline/skills` 里的 effectPrefab，经 job 的 `damageShapeNames` 交给 Bridge。有名把预制体名交给 Bridge。逻辑形状的资产名不跟空名兜底，按 `vfxmodel_c_melee` 编号写出。Bridge 不靠本地有没有这份预制体来取名。转包围盒不改技能树。

# 2. 坑和不变量

- SVN 只取单个技能前缀：EditorAssetsComm `res/timeline/skills`、Bridge `Assets/collider`、该技能实际用到的 ballistic 文件。不 update 整棵 Bridge Resources，不整份覆盖或 `File.Copy` globalconfig，转化不 `SaveAssets` 它。冲突就停，不回退。
- 同号已有目录时，正式名优先。名字是 skill_{id}、skill、new 或纯数字的占位目录不能当正式目录。枚举的第一个常是占位目录，再转会写进去，已入库的正式目录不动（2000182，用户核对）。
- 「全量转技能树」不再拉取共享 SpellConversion。勾选后只处理当前技能号：已入库目录先 svn revert -R，再删其中文件，目录留下；未入库目录直接删，然后转。转化前不提交。未勾选不回退、不清空。转包围盒不因勾选清空目录（用户核对）。
- 改或建弹道 Key 前先 `svn update` SkillEditor 的 globalconfig.asset，只改索引那一行，由预检同笔提交；转行为树前在 EditorAssetsComm 拉同一份。预检看发射点上有没有弹道 Key，不看主页是不是弹道类型。有 Key 就提交对应轨迹和索引并拉到中转；启用随机弹道时，这只怪物磁盘上的 Key 一并提交。没有 Key 不提交这两处。
- 顺序固定：原料 → 转化 → 配置 → 对齐 ConfigET。转化必须在预检成功之后；原料仍有 diff 时配置钮禁用；ConfigET 只在配置提交成功后对齐，不与 trunk 同批提交。
- 预检会对磁盘已删的旧变体做 `svn delete`；Headless 只按精确后缀导入 `skill_{id}` 与 `skill_{id}_N`，避免长 ID 前缀误伤。
- 本地专用以 `targets/SkillEditor.json`、`targets/BridgeEditor.json` 的 `local_only` 为准；`etctl sync-ignores` 把名字同步进本机 svn global-ignores（TortoiseSVN 同读），机检对不上会警告。新加本地工具文件：同单补进对应 `local_only`，再跑 `etctl sync-ignores`；`svn status --no-ignore` 显示 `I` 才算生效。`commit-units.py` 命中 `local_only` 或遇 `I` 都拒绝。
- 同步任务不改共享窗口 `TimelineToSpellConverterV2.cs`（Bridge）、`SkillEditor2.cs` 与旧弹道窗 `BallisticPathEditorWindow.cs`。
- 转化不切到 Bridge 点确定，不开 SkillSyncJobWindow；引擎不能拷进 SkillEditor（SkillEditor 没有 SpellConfig）。
- Unity 对象取名先用 `!= null` 判空，不用 `?.name`（见 `_index.md` 跨模块的坑）；角色受击槽挂地面特效是合法数据，不能让转化中断；两条发射物按 effectPrefab 名分开。
- 共享窗口：`vfxmodel_c_projectile_{N}` 的 SpellUnit Id N 被别的 Prefab 占用时 `PrepareSpellUnitConfig` 抛错，整次 Convert 取消、不覆盖。本地转技能树不写 SpellUnit，不受影响。本地转包围盒以这个名字为权威：只移开这一份旧资产再写，写完放回，控制台提示手删，不因此失败。移开时不要 `AssetDatabase.Refresh()` 整库，否则 Bridge 卡死、`result.json` 写不出。
- Directional 的 SpellUnit 碰撞体外层是 `PhysicsDecoratedShape`、内部是 `PhysicsBoxShape`。共享写法在位移和旋转都是单帧 0 时只写裸 `PhysicsBoxShape`，本地转包围盒在写完后包一层。是逻辑的 SpellUnit、以及要碰撞的阶段单位，半尺寸和偏移以编辑器发射槽为准：半尺寸是大小的一半，偏移写在外层位置，不再留预制体网格盒（t063，用户核对）。
- 给 Bridge 的 playable 路径是 `Assets/Resources/res/timeline/skills`，技能编辑器加载不到。收集特效名必须用本机 `Assets/Resources/timeline/skills`，否则名字是空的，包围盒写不出文件。
- 没有发射特效的逻辑形状是合法数据，不要因空名字停转换。包围盒用作者形状号写成 `{编号}_vfxmodel_c_melee_{编号}`；未填形状号才跳过。空名不再写成 `skill_{技能号}_damage`。是事件且载体是形状、要碰撞的阶段，同样按形状号写。盘上已有的 skill_damage 文件先留着。空发射物的形状 Buff 不写客户端 BTCreateBuffEffect，服务器碰撞保留。名字不是四段 `vfxmodel_c_melee_正整数` 时，客户端特效用真实预制体名。另加的表现发射物仍写客户端。单位行不改名。
- 资源对照只列 trunk Buff 已引用的 `spellShapesId`。转包围盒新开的形状号不会出现；被引用的旧号在 trunk 没有文件就显示「缺失」。新号要等转技能树按特效名回填后才进对照。
- 转技能树按挂点名对发射采样。SkillEditor 多出的 23、24、25 先写成 vfxpoint、vfxpoint3、impactpoint4。对不上时提示这个名字，并要求先导出发射表，不报枚举数字。
- Damage 与碰撞按挂点名配对：本地转包围盒从一份 `skill_{id}_colliderdata` 取出该挂点的 collisionData 行，再交给共享形状写法。共享写法会把传入资产的每一行写进同一个形状，不能把整份多挂点资产直接交进去。共享 SpellConversion 不改。是逻辑的单位和要碰撞的阶段单位不走这份挂点行，按发射槽上的盒子写 SpellUnit。
- 写不写服务器碰撞看带逻辑的形状有没有黄帧。复用点自己没记黄帧时，借用同名最早一发；完全没打帧不写服务器碰撞。挂点不同各写一个 Buff，同名共用形状号，不按盒子再拆号。（未验证）
- SpellShape 的 prefab 名称是特效名。转包围盒靠它找回已有形状，特效名映射也读它。不要改成技能名。描述是另一个字段，只在资源里辨认技能，标 `JsonIgnore`，打 `SpellShapesConfigCategory.bytes` 不写。本地转包围盒把本轮 SpellUnit 和 SpellShape 的描述写成技能号加作者 `SkillName`（t063，用户核对）。
- 逻辑形状和事件形状不要写成同一个标题。逻辑形状的描述是挂点伤害，Buff 加在该段施法者时间轴上，位移抄这一段的挂点。事件形状的描述才是「事件形状」，Buff 加在发射物上，停在当时坐标，不抄施法者挂点曲线。转技能树不写 SpellShape 文件；盒子要等转包围盒按挂点对上碰撞行。逻辑形状的形状号按四段 `vfxmodel_c_melee` 名或作者形状号填。2000207 第 3 段勾了是逻辑，转出的 Buff 标题仍是事件形状，对照格里 SpellShape 为空（用户所见；按新边界改写尚未验证）。
- 逻辑形状的 Buff 时长和 BTCastShape 持续都写成黄帧窗口帧数 / 30 的毫秒。窗口帧数是首尾按 30 帧率盖住的帧数，首尾都算。父 Buff 里的等待不推进这个传感器，时钟从创建形状起算。没重转的旧节点仍可能只剩几十毫秒，盒子一闪就没（t043，用户核对）。转树把间隔写成 100。attackType 为 2（持续喷射）或 4（近战持续攻击）时，触发次数上限是这段毫秒除以 100 再加 1；其余类型为 1。攻击距离和元素只在技能面显示。
- attackType 为 2 时，运行时仍用技能表的攻击时长和攻击频率盖掉节点上的持续时长、间隔和次数上限。类型 4 读节点上的次数。节点上的数不是类型 2 进游戏后的结算值（未验证）。
- 本地写出的命中动作触发层级遮罩必须是全部层级。Bridge 旧类型没有该字段时存盘缺项，trunk 加载会跳过字段初始化，值变成 0，任何层都不触发，盒子碰上角色也不加受击 Buff。伤害的目标过滤写敌对（0 则谁都不打），伤害标识写普通。没有地面特效时不要把角色受击 Buff 填进地面槽。遮罩从 0 改成全部层级后受击特效会出现；转化器自己写出 All 这一步（未验证）。
- 形状小件槽必须是字符串 None，空字符串对不上怪物发射表：三个匹配分支都进不去，Positions 留空，传感器不结算。GM 调试画的是形状关键帧，不走这套匹配，所以盒子在动、碰上没伤害。要写在交给共享形状写法之前的碰撞行上；写完再改已加载的资产，保存的仍是改之前那份。挂点名 Root 仍写成 None。
- 共享形状写法不设置 FPS，缺省 60。动态形状的动画帧率固定 30，动画时长帧数等于黄帧窗口的采样条数，不改成采样数 / 检测秒数。检测时长用同一条数 / 30 秒，形状帧号和发射下标才是同一拍。把帧率抬到数百会把整段挂点挤进一次检测。漏写 30 时，同一批关键帧会比烘焙时长短一倍播完。
- 转包围盒前更新 SpellShape 会同时拉 Bridge `Assets/ConfigET/SpellShape` 和主干 `Unity/Assets/Config/SpellShape`。报「冲突」时主干可以是干净的。树冲突常在 Bridge 那份：本地未纳入版本的形状文件挡住对面的新增。`svn revert` 这些冲突文件后再 update。只看主干会误以为没有冲突。
- 挂点：Buff 的 LaunchPointConfig 从 `skill_{id}_colliderdata` 的 Launch Points Dict 按动画名和变体原样抄，不按 Timeline 重采样，不回写 collider。多挂点的采样都在这一份 Dict 里，不另读 `skill_{id}_2_colliderdata`。（未验证）机甲臂技能（skillId 在 1000000–2000000）不抄。不能拿 `{prefab}_colliderdata` 当技能挂点。`BTCastShape` 的位移读这份 LaunchPointConfig。没抄上时碰撞停在脚底。
- 碰撞盒 `pos` 已是挂点局部偏移，不是模型根上的盒子中心。trunk 按单位 × 挂点姿态 × 关键帧叠乘，不改这个公式。发射表负责手掌，形状关键帧保持这份偏移和自身旋转，再减一次发射点会把盒子送回模型根附近，碰撞特效也不在手上。动态形状只把条数对齐到黄帧窗口的 30 帧率采样，不把整段挂点曲线写进形状。播放器用帧号当下标，不按时间插值。全帧姿态相同，或资源里已经只有一帧，时长帧数保持 1、帧率 30，发射表仍只留窗口；发射槽上的静态开关不写入形状（这一档转出结果未验证）。
- SkillEditor `Assets/Resources/textures` 与 `meshs` 若只是本地 `svn add`（服务器没有该路径），update 不会刷新特效。版本库里的特效在 EditorAssetsComm `Resources/res/textures` 与 `meshs`。
- 本地转技能树的根运动不读 `PlayAnimationBehaviour.applyRootMotion`，读动画面当前行的开关。勾上后，播动画的 buff 服务端第一个子节点是 BTSetRootMotion，主技能写 IsRootMotion 和同一 MotionType。Damage 已对过；Directional 同一条（未验证）。
- 本地主 Buff（技能号×100）的 Duration 是默认 Attack 姿态时长。按当前这份 Timeline 上动作片段的采样帧换算，不取 Timeline 最晚结束，不写死 1000。导弹把 Timeline 撑长不算姿态。已有主 Buff 每次转都改时长和描述，保留添加 01 的节点。没有动作采样帧就停下。（未验证）
- 角色受击 buff 只保留客户端播特效。空的服务端 Buff 添加仍会建一个没有子节点的 BuffVM，本地转技能树不写；已有的空节点再转时删掉。有子节点的服务端根保留。（未验证）
- 客户端表现必须写在服务器会下发的 Buff（01）的客户端树上。只在客户端用 BTAddBuff 拉起的子 Buff 服务器不下发，那支树不会跑，表现不出现，也没有加载报错。和怪物 Root 同级的弹体是服务器轨迹，位置是对的。
- BTCreateBuffEffect 按特效名加载预制体。名字必须是资源预制体名，转树时写入，打开节点不改这个字符串。SpellUnit 配置名是 `{编号}_{预制体}`，里面含着预制体名。检查器若按名字片段取第一份资源，会先绑到这份配置或同名材质，点选后把配置名存回去。`OdinUnityObject` 只接受名字完全相同的预制体做预览；点到配置或材质不改 Name，点到预制体才写入预制体名。这是 trunk 已纳入版本的共享脚本，提交，不进 `local_only`。
- 已知局限（不改代码，转完人工处理）：等待层 Buff Duration 写的是 Timeline 最晚 clip.end，应改为 `1000 × 挂点总帧 / 采样帧率`。贴枪口不再靠把 `animDistance` 置 0，该字段已删。见 `ballistic.md`。
- Bridge `Assets/Plugins` 的 `Share.SourceGenerator.dll`、`Share.Analyzer.dll`、`Jolt.SourceGenerator.dll` 是 Bridge 仓库自己的副本，不是 trunk 外链。trunk 换过这三份后，对 Bridge 做 `svn update` 不会带上。生成器 CS8790 或生成代码找不到类型时，对一下两边文件大小和 Last Changed Rev。脚本外链已经新、插件 DLL 仍旧，会和已删除的字段对不上。
- Timeline 目录是 svn external（EditorAssetsComm 的 timeline 映到 SkillEditor `Assets/Resources/timeline`），改 playable 要在该层提交；根目录提交默认不带它。

# 3. 怎么验证

- 提交日志带前缀：原料 `task:15 特效相关，{怪物ID}，技能{技能ID}，Timeline和碰撞体提交`；配置 `task:32 特效相关，{怪物ID}，技能{技能ID}，配置提交`。缺前缀 pre-commit 报 E165001。
- 资源对照格：技能树和 AI 始终显示（AI 只列 trunk `Config/AI` 里文件名含技能号的已有行为树）；近战加 SpellShape；Directional 加轨迹与 SpellUnit；召唤不加轨迹和包围盒。源资源可热更，转化产物只在预检或转化完成时刷新，不在 OnGUI 扫 YAML。「缺失」只表示该 `spellShapesId` 在 trunk 没有文件。
- timeline 提交「没有改动」时，先在 external 层 `svn status` 对比 BASE，无 M 就是已经入库。
- 转包围盒后：逻辑形状文件名是 `{编号}_vfxmodel_c_melee_{编号}`；有挂点的形状小件槽是 None。姿态有变化时变换关键帧条数等于挂点采样数；全帧姿态相同则只留 1 帧（未验证）。Play 里角色转向时，盒子仍落在编辑器那只根坐标盒子上，碰上角色能结算。
