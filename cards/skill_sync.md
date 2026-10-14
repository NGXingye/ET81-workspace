> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（关键词命中 SkillSync / 转化 / 提交原料或配置时读取）

# 0. 职责定位

> 速览：把 SkillEditor 里做好的技能（timeline、collider、弹道）经 BridgeEditor 的转化引擎变成 Spell/Buff/SpellShape/SpellUnit 配置，落到本机 trunk 并按序提交 SVN。只服务本机。
> 最大风险：SVN 范围和顺序——整树 update、整份覆盖 globalconfig、先交配置后交原料、ConfigET 与 trunk 同批提交。
> 做对的标准：trunk `Config/Spell/{id}-名/` 下生成对应配置；原料与配置两笔都被 pre-commit hook 放行；ConfigET 对齐无 diff。

# 1. 怎么运转

SkillEditor 管线输出格 → 预检叠入（提交原料：timeline + collider，弹道类再加 globalconfig 索引那一行和对应轨迹）→ 转化到本地（Bridge 进程内跑 `SpellConversionEngine`）→ 白名单 `File.Copy` 进 trunk Config → 提交配置 → 自动对齐 ConfigET。

- 调度：有开着窗口的 Bridge 就写 `job.json`，由 Headless Tick 自动 `RunJob` 并回写 `result.json`；没有才用 `-batchmode -executeMethod SkillSyncHeadless.RunJob`（只剩过期 UnityLockfile 视为没开）。「取消等待」杀该进程。
- 关键入口：`SkillSync/`（Paths、Orchestrator、TimelineWrite）、`SkillPipelineWindow.cs`（只画输出行）、Bridge `SkillSyncHeadless.cs`、`SpellConversion/SpellConversionEngine*.cs`。
- 输出按钮：构建 Timeline｜调整 Timeline；预检叠入｜转化到本地｜只转轨迹（只写 BallisticCopy）｜取消等待｜更新转化工具（默认不勾）；提交配置。
- trunk 落盘：Buff 与 Spell 同在 `Config/Spell/{id}-名/`（没有 `Config/Buff`）；SpellShape 由 Buff YAML 的 `spellShapesId` 反查；只有 Directional 才有 `Spell/Ballistics/BallisticCopy{id}.asset`；弹体碰撞落 `SpellUnit/{id}_{prefab}.asset`；近战 Damage 的碰撞就是 SpellShape。

# 2. 坑和不变量

- SVN 只取单个技能前缀：EditorAssetsComm `res/timeline/skills`、Bridge `Assets/collider`、该技能实际用到的 ballistic 文件。不 update 整棵 Bridge Resources，不整份覆盖或 `File.Copy` globalconfig，转化不 `SaveAssets` 它。冲突就停，不回退。
- 改或建弹道 Key 前先 `svn update` SkillEditor 的 globalconfig.asset，只改索引那一行，由预检同笔提交；转行为树前在 EditorAssetsComm 拉同一份。近战和召唤不提交轨迹和 globalconfig。（未验证）
- 顺序固定：原料 → 转化 → 配置 → 对齐 ConfigET。转化必须在预检成功之后；原料仍有 diff 时配置钮禁用；ConfigET 只在配置提交成功后对齐，不与 trunk 同批提交。
- 预检会对磁盘已删的旧变体做 `svn delete`；Headless 只按精确后缀导入 `skill_{id}` 与 `skill_{id}_N`，避免长 ID 前缀误伤。
- 本地专用文件永不 `svn add`：`SkillSync/`、`SkillPipeline/`（父目录 svn:ignore 两者都要有）、`SkillSyncHeadless`、`SkillPipelineBridge`、`SkillPipelineShapeSign`。
- 转化不切到 Bridge 点确定，不开 SkillSyncJobWindow；引擎不能拷进 SkillEditor（SkillEditor 没有 SpellConfig）。
- Unity 对象取名先用 `!= null` 判空，不用 `?.name`（见 `pitfalls.md`）；角色受击槽挂地面特效是合法数据，不能让转化中断；两条发射物按 effectPrefab 名分开。
- `vfxmodel_c_projectile_{N}` 占用 SpellUnit Id N；该 Id 已被别的 Prefab 占用时整次转化取消、不覆盖。换未占用的 N 或先清旧配置。（未验证）
- 挂点：Buff 的 LaunchPointConfig 从 `skill_{id}_colliderdata` 的 Launch Points Dict 按动画名和变体原样抄，不按 Timeline 重采样，不回写 collider；机甲臂技能（skillId 在 1000000–2000000）不抄。不能拿 `{prefab}_colliderdata` 当技能挂点。
- 转化读 `PlayAnimationBehaviour.applyRootMotion`（默认 false），勾上才挂 BTSetRootMotion；该字段缺失 Bridge 会 CS1061。
- 已知局限（不改代码，转完人工处理）：等待层 Buff Duration 写的是 Timeline 最晚 clip.end，应改为 `1000 × 挂点总帧 / 采样帧率`；需要贴枪口的 Copy 要把 `animDistance` 置 0。见 `ballistic.md`。
- Timeline 目录是 svn external（EditorAssetsComm 的 timeline 映到 SkillEditor `Assets/Resources/timeline`），改 playable 要在该层提交；根目录提交默认不带它。

# 3. 边界

- 门禁：`profiles/skill_sync.md`。
- 可改：SkillSync/、管线窗口与发射页几个文件、Bridge 的 Headless / PipelineBridge / ShapeSign / SpellConversion、`PlayAnimationBehaviour.cs`。
- 禁碰：`TimelineToSpellConverterV2.cs`、`SkillEditor2.cs`、`BallisticPathEditorWindow.cs`。

# 4. 怎么验证

- 提交日志带前缀：原料 `task:15 特效相关，{怪物ID}，技能{技能ID}，Timeline和碰撞体提交`；配置 `task:32 特效相关，{怪物ID}，技能{技能ID}，配置提交`。缺前缀 pre-commit 报 E165001。
- 资源对照格：技能树和 AI 始终显示（AI 只列 trunk `Config/AI` 里文件名含技能号的已有行为树）；近战加 SpellShape；Directional 加轨迹与 SpellUnit；召唤不加轨迹和包围盒。源资源可热更，转化产物只在预检或转化完成时刷新，不在 OnGUI 扫 YAML。
- timeline 提交「没有改动」时，先在 external 层 `svn status` 对比 BASE，无 M 就是已经入库。

# 5. 证据

t014、t016、t019、t027、t029、t035（另有两条无任务号的用户确认：受击槽转化、SpellUnit 占号）。

# 6. 版本历史

- 1.0.0（2026-10-14）：由 profile skill_sync、integrations/skill_sync.json、SkillEditor/skill_sync.json、timeline_wc.json 合并提炼。