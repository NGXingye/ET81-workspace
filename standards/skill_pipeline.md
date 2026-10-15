> 最新修改时间：2026-10-15 10:40 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L1（关键词命中技能管线 / 轨迹页 / 构建 Timeline / 碰撞导出时读取）

# 0. 速览

> 速览：SkillEditor 里的本机提效窗口，一页从「输入→技能→动画→特效→碰撞体→输出」做出一条技能：写 playable、技能碰撞资产和弹道，输出交给 `skill_sync.md`。
> 最大风险：发射点与烘焙原点算错（出生点、根位移、缺曲线时乱补），以及构建时破坏已打开的 Timeline 或共用资源。
> 做对的标准：`skill_{id}[_N].playable` 与 `skill_{id}[_N]_colliderdata` 按规则生成，导出断言 Dict 与轨迹采样同帧一致，预览从红点出生、落点贴地。
>
> 门禁：`profiles/skill_pipeline.md`、`profiles/skill_collider.md`

# 1. 怎么运转

- 独立 OdinEditorWindow，顶栏两页：技能构建管线｜弹道轨迹（发射页）。Window 只编排；Table 解析 csvdemo；Motion 管多行动画（状态不可重复）；Fx 一行对一行动画；轨迹页钉发射、打黄点、生成曲线、烘焙。
- 输入可切怪物 / 召唤物（召唤物只读 `MonsterPetConfig.bytes`，技能用 SelfSkillId，0 表示无技能）。
- 构建 Timeline：一次写出所有已填动画行（30fps，先删后建）；构建前把管线动画写进该怪 Override 的 `placeholder_{状态}`，构建后反射 `ExportAllColliderData_Monster` 导出碰撞，文件名跟 Timeline 名。
- 关键入口：`SkillPipeline/SkillPipelineWindow.cs`、`SkillPipelineTrajectoryPage.cs`、`SkillPipelineTrajectoryPreview.cs`、`EditorTools/BallisticPathBake.cs`、`Assets/Editor/SkillEditor/ControlColliderCS.cs`（只反射调用）。

# 2. 坑和不变量

- 命名：只有一条动画时是 `skill_{id}.playable` / `skill_{id}_colliderdata`（文件名小写）；两条及以上 attack=`skill_{id}`、attack1=`skill_{id}_2`…；构建结束删掉本次没写出的变体。同技能多个挂点时第二个写 `skill_{id}_2_colliderdata`（按发射槽里挂点首次出现顺序），不要 `_hang_{名}`。（多挂点未验证）
- 构建类型看 `Table.LaunchType`，不看发射槽 Key（Key>0 不代表弹道）；无发射物只留 SkillData+PlayAnimation，不建空 PlayEffect Main 轨。
- 替换已有 playable 前先让 Timeline 窗口 ClearTimeline 并取消选中，再删文件重建；窗口握着轨道时 DeleteTrack / DestroyImmediate 会把文件清空。调整 Timeline 用 `AssetDatabase.OpenAsset`。
- 发射点只来自片段里该挂点自己的曲线：关 Animator → SampleAnimation → 减去根位移，从第 0 帧写到末帧。没这条曲线就不写 Dict 并提示「动画没有{挂点}」，绝不拿预制体姿态顶替。采样片段在 SkillEditor `Assets/Resources/animations`，不是 trunk 的 Res。
- 烘焙起点是减过根位移的逻辑出手点；场景红点是钉发射那一帧含根位移的位置，只给预览出发；蓝点（第 0 帧）不参与反解。曲线第 0 帧偏移为 0，X/Y 米、Z = 多出的前向米 / D。
- 弹道 Key 只在主页创建；发射页只绑定磁盘已有的专用 Key 或当前类型的公共 Key（怪物 `ballistics_mCom_{Key}`、召唤物 `ballistics_pCom_{Key}`），确定设置不新建资产。一把 Key = 一条空间路径（D、左右、上下、曲线），飞行时间不在 Key 上；路径不同不能共用公共 Key。同一专用 Key 只有一个发射点是「编辑」，其余「复用」只读。
- Override 是怪物共用的：只有动画行「刷新」、构建、导出碰撞时才写 `{prefab}.overrideController` 对应槽。碰撞导出按 Timeline 状态名找 `placeholder_{状态}`，不用管线选中的 clip。
- 近战（LaunchType.Damage）：可不选发射物，但必须钉出手点，否则不写近战片段；碰撞只烘盒子的偏移和缩放（按 30fps 写入已有碰撞资产，没有要先导出）；未烘焙的关键帧重载会丢。Life=0 表示不销毁，playable 至少 1/30 秒。
- 预览：MotionClip 只给弹道根位移和时长；发射物预览动画用 PreviewClip。发射物根放在路径上再把蒙皮底面中心拉到该点，不改动画 RootT。
- `DamageParameters.radius`（运行时球形触发器）与绿色盒子（`skill_{id}_colliderdata`）是两套，互不读取。
- 碰撞导出读 `csvdemo/*.bytes`：骨架 = MonsterSkillConfig.MonsterId → MonsterScalingLevelConfig.PrefabName；csvdemo 过期会「无法生成角色模型」。变体 N≥2 没配 launchPoint 时回退变体1形状、按当前 Timeline 烘发射点并弹提示。
- 编辑器里不用 `GlobalConfig.instance`（会碰 GameManager 单例），只 `AssetDatabase` 读 globalconfig.asset；App.Comm 不能引用 Editor 程序集（如 SkillTimelineVariantUtil、MonsterPetConfigCsvReader）；`SkillPipelineActorKind` 必须 public。
- 单文件软上限 500、硬顶 600 行，超限只拆私有方法。
- 旧弹道窗 `BallisticPathEditorWindow` 保持 IMGUI，不整窗 Odin 化；csvdemo `.bytes` 只读不写回；管线任务对 `ControlColliderCS` 只反射调用。

# 3. 怎么验证

- 构建或再点导出碰撞体时跑断言：Dict 与轨迹采样按 `Round(出手秒 × 采样帧率)` 比同一帧，缺曲线的行报「动画没有该挂点」，不拿空 launchPoints 判失败。
- 预览：红点出生、末点 Y 相对红点（贴地时约为负的出手高度），地面爆炸能播；近战盒子在出手到出手+Life 之间跟随挂点。
- 磁盘：`Assets/Resources/timeline/skills/skill_{id}[_N].playable`、`Assets/collider/skill_{id}[_N]_colliderdata` 存在且含 Launch Points Dict。
