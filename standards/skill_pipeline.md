> 最新修改时间：2026-11-11 16:22 UTC+8
> 版本号：1.21.0
> 文档状态：生效
> 读取等级：L1（关键词命中技能管线 / 轨迹页 / 构建 Timeline / 碰撞导出时读取）

# 0. 速览

> 速览：SkillEditor 里的本机提效窗口，一页从「输入→技能→动画→发射→碰撞体→输出」做出一条技能：写 playable、技能碰撞资产和弹道，输出交给 `skill_sync.md`。
> 最大风险：发射点与烘焙原点算错（出生点、根位移、缺曲线时乱补），以及构建时破坏已打开的 Timeline 或共用资源。
> 做对的标准：`skill_{id}[_N].playable` 与一份 `skill_{id}_colliderdata` 按规则生成，导出断言 Dict 与轨迹采样同帧一致，预览从红点出生、落点贴地。
>
> 门禁：`profiles/skill_pipeline.md`、`profiles/skill_collider.md`

# 1. 怎么运转

- 独立 OdinEditorWindow，顶栏两页：技能构建管线｜发射（当前技能名）。没选技能或没有名字时页签只写「发射」。Window 只编排；Table 解析 csvdemo；动作组下是动画：单段只露出一行，随机和分段可以加动画。分段行有顺序号，不改 Timeline 片段先后。随机行在状态后有 0~1 概率，缺省或全 0 时均分。发射页在随机和分段下都有动画序号，切换后时间轴和发射点跟着该段。根运动仍在行上。按钮是加动画。单段不删缓存里的其它行，Build 仍按行各写一份 playable。主页发射面统计表现槽、单位槽、形状槽、阶段槽、事件槽，每行是各点出手时刻。轨迹页钉发射；形状打黄帧；单位打白点、生成曲线、烘焙。
- 输入可切怪物 / 召唤物（召唤物只读 `MonsterPetConfig.bytes`，技能用 SelfSkillId，0 表示无技能）。技能组第一行是技能和模式。第二行只读 `MonsterSkillConfig` 的冷却、attackType、attack_distance、elementtype。后两项只显示。attackType 交给转技能树，不在这一页改时长。
- 构建 Timeline：一次写出所有已填动画行（30fps，先删后建）；构建前把管线动画写进该怪 Override 的 `placeholder_{状态}`。构建源数据不写 `skill_{id}_colliderdata`。发射页分开写同一份资产：导出发射表只重写是逻辑、是阶段的 Launch Points Dict；导出碰撞按挂点更新命中行，不删这次没列到的旧行，不调用会删掉整份资产的怪物导出。
- **发射点三类互斥（是逻辑 / 是阶段 / 是事件）**：同一发射点只选一类。**是逻辑**=形状或单位走施法者挂点；形状时 Buff 加在施法者身上（逻辑形状，见 `skill_tree`）。**是阶段**=映射分阶段Buff单位 Stages（见 `spell_unit_bt_phase`）。**是逻辑的单位**转 `BTCreateBuffUnit`，不要再写成阶段节点。**是事件**=Buff 加在发射物身上，停在当时世界坐标（事件形状）；用 `EventRefKey` 让别人引用，不占触碰角色/环境 hit-fx 号。判断可以写在 00，不因此改类。有「接入碰撞」才显示/编辑碰撞分区；未勾则转盒阶段 Unit 不带 Trigger/Box（见 `skill_sync`）。
- 关键入口：`SkillPipeline/SkillPipelineWindow.cs`、`SkillPipelineTrajectoryPage.cs`（时间轴和发射点列表）、`SkillPipelineFireSections.cs`（选中点分区，partial）、`SkillPipelinePhaseSections.cs`（阶段行）、`SkillPipelineFxView.cs`（主页发射统计）、`SkillPipelineTrajectoryPreview.cs`（角色、残留发射物、采样入口）、`SkillPipelineTrajectoryPreview.Scrub.cs`（时间轴）、`SkillPipelineTrajectoryPreview.Shell.cs`（发射物皮、阶段动画和特效）、`SkillPipelineTrajectoryPreview.Gizmos.cs`（场景轨迹线和碰撞盒）、`EditorTools/BallisticPathBake.cs`、`Assets/Editor/SkillEditor/ControlColliderCS.cs`（只反射调用）。
- 文件：`SkillPipelineCollisionWindow.cs` 管形状的黄帧、按钮和烘焙起止，轨迹页只调用。预览按窗口决定画不画场景盒子；形状在时间条画黄块，单位画白点。行为树不在这里。

# 2. 坑和不变量

- 命名：playable 一条动画时是 `skill_{id}.playable`，两条及以上 attack=`skill_{id}`、attack1=`skill_{id}_2`…，变体号跟着状态名，不按当前行数从 1 重排。构建结束删掉本次没写出的变体。碰撞一份技能只留 `skill_{id}_colliderdata`：发射采样都在 Launch Points Dict，不同碰撞各占 collisionData 一行，用挂点名区分。导出时每个挂点单独 ColliderIndex，避免共享导出把它们合成一行。重写挂点成功后，把 `_2` 到 `_8` 里主文件还没有的碰撞行折进来，再删掉这些文件。不要 `_hang_{名}`。（未验证）
- 只转轨迹只认当前技能的母体 Key。同怪另一条技能把这把 Key 全标成复用时停下，提示切回带母体的技能，不扫全怪去写那份共用 Copy。
- 主页下拉文案是模式，选项只有未设置、发射物、召唤。已有弹道的技能内部仍是 Directional，下拉仍显示发射物。转技能树不看这个下拉，按作者文件里每个发射点的载体。新建发射物存 Damage，不因此创建弹道 Key。构建外壳仍看 `Table.LaunchType`，不看发射槽 Key（Key>0 不代表整技能是弹道）。弹道片段只从单位点写 ballisticId（未验证）。无发射物只留 SkillData+PlayAnimation，不建空 PlayEffect Main 轨。
- 替换已有 playable 前先让 Timeline 窗口 ClearTimeline 并取消选中，再删文件重建；窗口握着轨道时 DeleteTrack / DestroyImmediate 会把文件清空。调整 Timeline 用 `AssetDatabase.OpenAsset`。
- 发射点只来自片段里该挂点自己的曲线：关 Animator → SampleAnimation → 减去根位移，从第 0 帧写到末帧。没这条曲线就不写 Dict 并提示「动画没有{挂点}」，绝不拿预制体当前姿态直接写入 Dict。挂点行在是逻辑或是阶段、且片段没有该曲线时，可以补写动画曲线：只写预制体上该挂点的局部位置和旋转，第 0 帧和末帧相同。路径必须跟片段里已有骨骼同一根，不要带上预制体根外面多出来的那层。模型内的片段不写，重新导入会丢掉。写完再导出发射表。采样片段在 SkillEditor `Assets/Resources/animations`，不是 trunk 的 Res。
- 烘焙起点是减过根位移的逻辑出手点；场景红点是钉发射那一帧含根位移的位置，只给预览出发；蓝点（第 0 帧）不参与反解。曲线第 0 帧偏移为 0，X/Y 米、Z = 多出的前向米 / D。运行时不要把 Z 当成米。
- 是阶段且接入轨迹已打帧时，场景轨迹、落点和飞行中的发射物从该时刻的挂点世界位置出发，不从红帧的挂点原点出发。没打接入轨迹帧时仍从红帧画。
- 烘焙水平前进是角色 Root 在取样时刻的水平朝向：是阶段取接入轨迹时刻，其它发射点取红帧。预览把第 0 帧 Root 旋归成世界正前，动画没转身时这根轴就是世界正前。发射方向圆盘只转窗口里的轨迹和关键点，不转这根轴；再烘焙才改侧向和前后偏移。不手摆参考点。（未验证）
- 显示轨迹曲线手柄只拖曲线鼓包。显示轨迹关键点手柄打开后每个白点可单独拖，只改该点位置，不改发射方向、距离和左右角。点中的白点是当前白点，删除当前白点删它，不要求时间尺正压在这个点上。两个开关可以同时开。关闭、预览、复用或借入曲线时不拖白点。
- 弹道 Key 在单位发射点上选择或新建，不在主页。打开时，没有磁盘资产、也没有资产 GUID 的缓存 Key 清成 0，不再弹「缓存 Key 在磁盘上没有」。下拉列出该怪物磁盘上的 `ballistics_m{怪物Id}_{Key}`、公共 Key（怪物 `ballistics_mCom_{Key}`、召唤物 `ballistics_pCom_{Key}`），以及「随机弹道」。选「新建弹道」或「随机弹道」后，确定设置才生效。随机弹道不改当前曲线：预览和飞行距离仍用这一发的 Key，每次施法从这只怪物磁盘上已有的 Key 里定选一把；改回具体 Key 再确定设置就关闭。表现和形状不绑弹道。一把 Key = 一条空间路径（D、左右、上下、曲线），飞行时间不在 Key 上；路径不同不能共用公共 Key。同一专用 Key 只有一个发射点是「编辑」，其余「复用」只读。落点矩形也只属于这个母体：侧向 L、前进 R 和开关跟着它，要另一块矩形就换 Key。母体可以在同怪另一条技能；打开复用技能或转化它时读那条技能的非复用母体，不拿本技能留下的旧矩形。复用槽的水平距离、左右、上下同样显示母体当前值。换到另一段动画后，本怪磁盘上的 `ballistics_m{怪}_{Key}` 也可以选复用；`ballistic_m{怪}_01` 这种旧文件名会把末尾读成 Key 1，不要收进列表。复用点预览借用母点曲线，平移并转到自己的出手位置和朝向。不是阶段的单位点，时间轴绿段和拖右端都改飞行时间。是阶段时绿段是武装持续时间，飞行时间从接入轨迹时刻起用蓝色盖住。
- Override 是怪物共用的：只有动画行「刷新」、构建、导出碰撞时才写 `{prefab}.overrideController` 对应槽。碰撞导出按 Timeline 状态名找 `placeholder_{状态}`，不用管线选中的 clip。
- 近战（LaunchType.Damage）：可不选发射物，但必须钉出手点，否则不写近战片段；碰撞只烘盒子的偏移和缩放（按 30fps 写入已有碰撞资产，没有要先导出）。重载时多帧不一致或首帧 pos 非零要保留烘焙，只有全帧相同且首帧在原点才落成默认盒。烘焙只覆盖最早黄帧到最晚黄帧，第 0 帧是最早黄帧，不把首帧铺回红钉。Life=0 表示不销毁，playable 至少 1/30 秒。
- 带逻辑（字段仍是 HasBox）按发射点，不按主页发射类型。没勾是表现：跟骨，不画轨迹，不写服务器碰撞。勾上后载体二选一：形状才打黄帧并烘焙碰撞；单位不打碰撞关键帧，轨迹点是白点。黄帧可打在红钉前的蓝条上（相对钉为负，绝对时间不早于 0），时间条用黄块标出。最早到最晚是服务器碰撞；只有一帧按 1/30 秒。没打帧不拿持续时间或动画长度顶替。形状的场景盒子只在黄帧窗口内画。单位点在飞行时间内才画发射物坐标和碰撞盒，表现点不画。恢复默认盒只把场景当前看到的盒子设回 0.25、偏移 0，不改已打的黄帧。相同预制体的单位点，列表编号最早的一发编辑碰撞盒，后面的只显示框，烘焙按各挂点抄母点的大小。相同预制体的形状点同样以列表最早的一发为碰撞编辑源，后面整行按钮锁定，只显示线框，黄帧可以只记在这一发。同一点可加只跟骨骼的表现发射物，时长和挂点跟这一发，转树时各加一个客户端特效，不另建发射点。
- 同时刻两条随机一条只挂在单位槽。构建时只对同一时刻的单位点做两条里随机一条；表现和形状同一时刻都保留。（未验证）
- 碰撞断言在发射页底部：上面是挂点行，下面是导出发射表和导出碰撞。主页输出行没有导出碰撞体。不显示 `skill_{id}_colliderdata` 文件名。一行四段：挂点、大小、偏移、断言。同一挂点、同一帧的逻辑行只显示一条。是逻辑的 SpellUnit 和要碰撞的阶段单位，大小和偏移留在发射槽。导出碰撞不写这些单位行。转包围盒再按槽上的盒子写 SpellUnit。
- 强脱离和弱脱离是作者字段，表现和逻辑形状都有，两个互斥，和持续时间同一排。都不改宿主 Buff 时长。不勾时预览挂在挂点骨骼下，挂点是 None 就挂角色 Root。勾上任一个都停在红帧出手的世界坐标，挂在常驻的 SkillPipelineTrajectoryBullet 下；按当前姿态取样会跟着骨头走。这个空壳不随开关删掉重建。发射物为空时不放默认球，也不再提供大小。跟骨的形状，场景绿盒和红点用同一套当前挂点位置和朝向；跟骨时只把皮挂上骨头，空壳仍停在旧出手点，不能拿空壳当盒子位置。事件停在世界原点，单位仍跟轨迹。
- 形状的静态是发射槽开关，旧缓存缺这个字段时是动态。打开后黄帧只留时间尺最早和最晚两帧，两端都是当前盒子；中间再打不加第三帧，改盒子覆盖这两帧。缩短一端要先删那一帧再打。关掉后一打一帧，各帧保留自己的大小和偏移。静态或动态的文案看这个开关，不按黄帧是否相同来猜。开关不写入形状资产。
- 形状的载体、静态、X/Y/Z 在同一排。三轴各是 -180 到 180。预览在挂点朝向上再转这三个角度。拖动时用新旧旋转的差改写偏移，盒子中心留在原地。烘焙把每一帧旋转写成这三个角度的相反数；共享写法会再取反，存盘后仍是滑条角度。轨道缓存按 Pitch、Yaw、Roll 存，旧缓存只有单轴时落在 Y。不改 trunk 叠乘。
- 触碰角色和触碰环境各有持续时间，画在表现和逻辑中间。角色缺省 1 秒，环境缺省 2 秒。
- 逻辑形状的包围盒文件名是 `{编号}_vfxmodel_c_melee_{编号}`。发射物名正好四段 `vfxmodel_c_melee_正整数` 时编号取末段，形状号不参与；为空或不是这四段时编号取形状号，未填则提示先填。单位行不改名。发射物为空仍不写客户端创建特效；名字不是这四段时客户端特效用真实预制体名。
- 预览：MotionClip 只给弹道根位移和时长；发射物动画（PreviewClip）是默认皮。阶段「接入动画」另选一段片段，打帧之后从该时刻起才改播这段；状态空着时转出用这段动画的名字。发射物根放在路径上再把蒙皮底面中心拉到该点，不改动画 RootT。
- `DamageParameters.radius`（运行时球形触发器）与绿色盒子（`skill_{id}_colliderdata`）是两套，互不读取。
- 碰撞导出读 `csvdemo/*.bytes`：骨架 = MonsterSkillConfig.MonsterId → MonsterScalingLevelConfig.PrefabName；csvdemo 过期会「无法生成角色模型」。变体 N≥2 没配 launchPoint 时回退变体1形状、按当前 Timeline 烘发射点并弹提示。
- 编辑器里不用 `GlobalConfig.instance`（会碰 GameManager 单例），只 `AssetDatabase` 读 globalconfig.asset；App.Comm 不能引用 Editor 程序集（如 SkillTimelineVariantUtil、MonsterPetConfigCsvReader）；`SkillPipelineActorKind` 必须 public。
- 动画面每行的根运动开关写入该行缓存。转技能树用当前行，不看 Timeline 片段上的 applyRootMotion。勾上时场景蓝点改画空路径 RootT 相对第 0 帧的轨迹，当前时间的点更大，旁边标这段位移；烘焙用的第 0 帧蓝点仍不参与反解。只认 RootT / RootQ，不认骨骼 A_Root01。第一次没读到曲线就下一帧再读，不把片段判成没有根曲线。没勾时蓝点仍是逻辑出手坐标。不改动画曲线，不改 trunk 积分。
- 单文件拆分 / 合并按 `code_structure.md`。
- 旧弹道窗 `BallisticPathEditorWindow` 保持 IMGUI，不整窗 Odin 化；csvdemo `.bytes` 只读不写回；管线任务对 `ControlColliderCS` 只反射调用，不改 `SkillEditor2.cs`。
- 是逻辑/是阶段/是事件三类互斥；事件不进 Stages。事件形状的父节点是发射物，不是世界原点；`EventRefKey` 只负责引用。事件不占 hit-fx 号段。
- 待整理：`SkillPipelineTrajectoryPage` 仍超过 1200 行，弹道下拉和随机弹道还在这一份。预览已拆到 Scrub / Shell / Gizmos。
- 碰撞 UI/导出只跟「有接入碰撞」：未勾不要填碰撞关键帧/盒子，转出也不应残留 Trigger/Box。
- 事件碰撞默认挂 Root，不要求骨架上有名为 None 的骨头。阶段只有接入碰撞开着才写碰撞行；没开只进发射表。盒子优先用阶段自己的，没有就用它引用的事件。探针只采到一个静止坐标、碰撞表里该挂点已有逐帧位移时，保留碰撞表。
- 转技能树和转包围盒时，转化产物、SpellShape、SpellUnit 的 svn update 失败、冲突或工作副本未完成（E155037）按本地继续，不回退。提交原料、提交配置、改索引前的冲突和锁仍停下。（未验证）
- 接入骨骼挂点与不变区挂点分开。接入特效和转树都按挂点名字对 BindPoint，忽略大小写。SkillEditor 的 HangPoint 比 Bridge 多 vfxpoint=23、vfxpoint3=24、impactpoint4=25。转树先把这三个数写成名字再对 BindPoint，不能把数字交进去（23 会变成 Bone_R_Forearm）。对不上时提示挂点名字，并要求先导出发射表。

# 3. 怎么验证

- 表现发射点只查预制体骨骼，不读动画曲线；逻辑和阶段仍要片段里有该挂点曲线。列表在片段曲线变化时重读，不必点导出发射表。烘焙发射表仍只认动画曲线。（未验证）
- 导出发射表后跑断言：Dict 与轨迹采样按 `Round(出手秒 × 采样帧率)` 比同一帧，缺曲线的行报「动画没有该挂点」，不拿空 launchPoints 判失败。导出碰撞不改发射表。
- 预览：红点出生、末点 Y 相对红点（贴地时约为负的出手高度），地面爆炸能播。形状盒子只在最早黄帧到最晚黄帧之间出现；跟骨时绿盒跟着当前挂点。单位盒子跟着飞行时间。客户端片段仍从红钉起，时长是持续时间或飞行时间。勾了根运动时，蓝点沿根位移走，当前点旁是相对第 0 帧的数。
- 磁盘：`Assets/Resources/timeline/skills/skill_{id}[_N].playable` 仍可有多份。碰撞只留 `Assets/collider/skill_{id}_colliderdata`，Dict 里有各挂点，collisionData 按挂点分行，没有 `_2` colliderdata。（未验证）
