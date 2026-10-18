> 最新修改时间：2026-10-18 13:20 UTC+8
> 版本号：1.5.1
> 文档状态：生效
> 读取等级：L1（关键词命中 SkillSync / 转化 / 提交原料或配置时读取）

# 0. 速览

> 速览：把 SkillEditor 里做好的技能（timeline、collider、弹道）经 BridgeEditor 的转化引擎变成 Spell/Buff/SpellShape/SpellUnit 配置，落到本机 trunk 并按序提交 SVN。只服务本机。
> 最大风险：SVN 范围和顺序——整树 update、整份覆盖 globalconfig、先交配置后交原料、ConfigET 与 trunk 同批提交。
> 做对的标准：trunk `Config/Spell/{id}-名/` 下生成对应配置；原料与配置两笔都被 pre-commit hook 放行；ConfigET 对齐无 diff。
>
> 门禁：`profiles/skill_sync.md`

# 1. 怎么运转

SkillEditor 管线输出格 → 预检叠入（提交原料：timeline + collider，弹道类再加 globalconfig 索引那一行和对应轨迹）→ 转化到本地 → 白名单 `File.Copy` 进 trunk Config → 提交配置 → 自动对齐 ConfigET。转技能树不调用 `SpellConversionEngine.Convert`，只在本地写行为树并填 ID。转包围盒仍调用共享的 SpellShape / SpellUnit 写法。共享窗口 `TimelineToSpellConverterV2` 仍走完整 Convert。

- 调度：有开着窗口的 Bridge 就写 `job.json`，由 Headless Tick 自动 `RunJob` 并回写 `result.json`；没有才用 `-batchmode -executeMethod SkillSyncHeadless.RunJob`（只剩过期 UnityLockfile 视为没开）。「取消等待」杀该进程。
- 关键入口：`SkillSync/`（Paths、Orchestrator、TimelineWrite）、`SkillPipelineWindow.cs`（只画输出行）、Bridge `SkillSyncHeadless.cs`、`SpellConversion/SpellConversionEngine*.cs`。
- 输出按钮：构建 Timeline｜调整 Timeline；预检叠入｜转化到本地｜只转轨迹（只写 BallisticCopy）｜取消等待｜更新转化工具（默认不勾）；提交配置。
- trunk 落盘：Buff 与 Spell 同在 `Config/Spell/{id}-名/`（没有 `Config/Buff`）；SpellShape 由 Buff YAML 的 `spellShapesId` 反查；只有 Directional 才有 `Spell/Ballistics/BallisticCopy{id}.asset`；弹体碰撞落 `SpellUnit/{id}_{prefab}.asset`。Damage 的盒子是 SpellShape，位移在 buff 的 LaunchPointConfig。本地 Damage 动画 buff：客户端根上先播放动画，服务端先异步等待再 `BTCastShape`。
- Damage 形状名：技能编辑器读本机 `Assets/Resources/timeline/skills` 里的 effectPrefab，经 job 的 `damageShapeNames` 交给 Bridge。有名写成该预制体名；没有发射特效写成 `skill_{id}_damage` 并继续。Bridge 不靠本地有没有这份预制体来取名。转包围盒不改技能树。

# 2. 坑和不变量

- SVN 只取单个技能前缀：EditorAssetsComm `res/timeline/skills`、Bridge `Assets/collider`、该技能实际用到的 ballistic 文件。不 update 整棵 Bridge Resources，不整份覆盖或 `File.Copy` globalconfig，转化不 `SaveAssets` 它。冲突就停，不回退。
- 改或建弹道 Key 前先 `svn update` SkillEditor 的 globalconfig.asset，只改索引那一行，由预检同笔提交；转行为树前在 EditorAssetsComm 拉同一份。近战和召唤不提交轨迹和 globalconfig。（未验证）
- 顺序固定：原料 → 转化 → 配置 → 对齐 ConfigET。转化必须在预检成功之后；原料仍有 diff 时配置钮禁用；ConfigET 只在配置提交成功后对齐，不与 trunk 同批提交。
- 预检会对磁盘已删的旧变体做 `svn delete`；Headless 只按精确后缀导入 `skill_{id}` 与 `skill_{id}_N`，避免长 ID 前缀误伤。
- 本地专用以 svn 忽略为准：本机 global-ignores（`%APPDATA%\Subversion\config` 的 `[miscellany]`）加 SkillEditor `EditorTools/` 目录的 svn:ignore（SkillPipeline、SkillSync）。新加本地工具文件同单补进本机 global-ignores；`svn status --no-ignore` 显示 `I` 才算生效，`commit-units.py` 遇 `I` 拒绝 add。
- 转化不切到 Bridge 点确定，不开 SkillSyncJobWindow；引擎不能拷进 SkillEditor（SkillEditor 没有 SpellConfig）。
- Unity 对象取名先用 `!= null` 判空，不用 `?.name`（见 `_index.md` 跨模块的坑）；角色受击槽挂地面特效是合法数据，不能让转化中断；两条发射物按 effectPrefab 名分开。
- 共享窗口：`vfxmodel_c_projectile_{N}` 的 SpellUnit Id N 被别的 Prefab 占用时 `PrepareSpellUnitConfig` 抛错，整次 Convert 取消、不覆盖。本地转技能树不写 SpellUnit，不受影响。本地转包围盒以这个名字为权威：只移开这一份旧资产再写，写完放回，控制台提示手删，不因此失败。移开时不要 `AssetDatabase.Refresh()` 整库，否则 Bridge 卡死、`result.json` 写不出。
- Directional 的 SpellUnit 碰撞体外层是 `PhysicsDecoratedShape`、内部是 `PhysicsBoxShape`。共享写法在位移和旋转都是单帧 0 时只写裸 `PhysicsBoxShape`，本地转包围盒在写完后包一层。
- 给 Bridge 的 playable 路径是 `Assets/Resources/res/timeline/skills`，技能编辑器加载不到。收集特效名必须用本机 `Assets/Resources/timeline/skills`，否则名字是空的，包围盒写不出文件。
- 没有发射特效的 Damage 是合法数据，形状名用 `skill_{id}_damage`，不要因空名字停转换。片段上有 effectPrefab 名就用该名，不要再落这个兜底名。
- 资源对照只列 trunk Buff 已引用的 `spellShapesId`。转包围盒新开的形状号不会出现；被引用的旧号在 trunk 没有文件就显示「缺失」。新号要等转技能树按特效名回填后才进对照。
- Damage 片段和多份 collider 按挂点字符串配对尚未被运行验证通过，不要当成已成立。
- 写不写形状看发射页 HasBox，不看挂点名。未勾的是表现发射物：不导出碰撞、不写形状、服务端不加 BTCastShape，客户端仍播。多个逻辑发射物挂点不同则分 buff，相同共用；包围盒不同则形状号不同。转包围盒后把形状挂点 Root 写成 None，才能对上 BindPoint.None。（未验证）
- 本地写出的命中动作触发层级遮罩必须是全部层级。Bridge 旧类型没有该字段时存盘缺项，trunk 加载会跳过字段初始化，值变成 0，任何层都不触发，盒子碰上角色也不加受击 Buff。伤害的目标过滤写敌对（0 则谁都不打），伤害标识写普通。没有地面特效时不要把角色受击 Buff 填进地面槽。遮罩从 0 改成全部层级后受击特效会出现；转化器自己写出 All 这一步（未验证）。
- 共享形状写法不设置 FPS，缺省 60。近战碰撞按 30fps 烘焙，不把形状 FPS 改成 30 时，同一批关键帧会比烘焙时长短一倍播完。
- 挂点：Buff 的 LaunchPointConfig 从 `skill_{id}_colliderdata` 的 Launch Points Dict 按动画名和变体原样抄，不按 Timeline 重采样，不回写 collider；机甲臂技能（skillId 在 1000000–2000000）不抄。不能拿 `{prefab}_colliderdata` 当技能挂点。SpellShape 偏移关键帧来自碰撞盒 `pos`，近战可以全帧相同；`BTCastShape` 的位移读 buff 的 LaunchPointConfig。没抄上时碰撞停在脚底，形状里仍能看到关键帧。
- SkillEditor `Assets/Resources/textures` 与 `meshs` 若只是本地 `svn add`（服务器没有该路径），update 不会刷新特效。版本库里的特效在 EditorAssetsComm `Resources/res/textures` 与 `meshs`。
- 本地转技能树的根运动不读 `PlayAnimationBehaviour.applyRootMotion`，读动画面当前行的开关。勾上后，播动画的 buff 服务端第一个子节点是 BTSetRootMotion，主技能写 IsRootMotion 和同一 MotionType。Damage 已对过；Directional 同一条（未验证）。
- 本地主 Buff（技能号×100）的 Duration 是默认 Attack 姿态时长。按当前这份 Timeline 上动作片段的采样帧换算，不取 Timeline 最晚结束，不写死 1000。导弹把 Timeline 撑长不算姿态。已有主 Buff 每次转都改时长和描述，保留添加 01 的节点。没有动作采样帧就停下。（未验证）
- 角色受击 buff 只保留客户端播特效。空的服务端 Buff 添加仍会建一个没有子节点的 BuffVM，本地转技能树不写；已有的空节点再转时删掉。有子节点的服务端根保留。（未验证）
- 已知局限（不改代码，转完人工处理）：等待层 Buff Duration 写的是 Timeline 最晚 clip.end，应改为 `1000 × 挂点总帧 / 采样帧率`；需要贴枪口的 Copy 要把 `animDistance` 置 0。见 `ballistic.md`。
- Timeline 目录是 svn external（EditorAssetsComm 的 timeline 映到 SkillEditor `Assets/Resources/timeline`），改 playable 要在该层提交；根目录提交默认不带它。

# 3. 怎么验证

- 提交日志带前缀：原料 `task:15 特效相关，{怪物ID}，技能{技能ID}，Timeline和碰撞体提交`；配置 `task:32 特效相关，{怪物ID}，技能{技能ID}，配置提交`。缺前缀 pre-commit 报 E165001。
- 资源对照格：技能树和 AI 始终显示（AI 只列 trunk `Config/AI` 里文件名含技能号的已有行为树）；近战加 SpellShape；Directional 加轨迹与 SpellUnit；召唤不加轨迹和包围盒。源资源可热更，转化产物只在预检或转化完成时刷新，不在 OnGUI 扫 YAML。「缺失」只表示该 `spellShapesId` 在 trunk 没有文件。
- timeline 提交「没有改动」时，先在 external 层 `svn status` 对比 BASE，无 M 就是已经入库。
