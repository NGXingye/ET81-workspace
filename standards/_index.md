> 最新修改时间：2026-11-12 14:25 UTC+8
> 版本号：5.42.0
> 文档状态：生效
> 读取等级：L1（每轮 /implement 开头、报错或新需求出现时按关键词路由）

# 0. 职责定位

`standards/` 存模块知识卡（一模块一个 `<模块>.md`）、收口账与审计。用法：拿需求或报错里的词对下面「关键词」，命中 1–2 张卡读它的「坑和不变量」；再扫本文末「跨模块的坑」。写入门禁不在这里，在 `profiles/<id>.md`（卡的速览里写了对应门禁）。

卡片格式：四行版头 + 四节——`# 0. 速览`（三行：做什么 / 最大风险 / 做对的标准，再加一行「门禁：…」）、`# 1. 怎么运转`（数据流 + ≤5 个入口）、`# 2. 坑和不变量`（改代码前逐条过）、`# 3. 怎么验证`。每卡约 80 行以内，不设版本历史，任务号只在有用处括号内注明。

# 1. 卡片索引

- [`framework.md`](./framework.md) — trunk ET8.1 框架与四个编辑器工程。关键词：框架、Core、Loader、Fiber、程序集、asmdef、放置、Generate、YIUI 落点、编译、验证、Combat、Numeric、背包、Quest、HLS、回滚快照、同步上下文。
- [`skill_sync.md`](./skill_sync.md) — SkillEditor → Bridge 转化 → trunk Config 的本机同步与 SVN 提交。关键词：SkillSync、资源同步、转化到本地、转包围盒、SpellShape、HasBox、触发层级遮罩、BTCastShape、预检叠入、提交原料、提交配置、ConfigET、资源对照、只转轨迹、Headless、job.json、task:15、task:32、E165001、timeline svn、playable 提交、external、齐射、单次子弹发射、形状描述、JsonIgnore、全量转技能树、占位目录。
- [`skill_pipeline.md`](./skill_pipeline.md) — SkillEditor 本地技能管线（一页管线、轨迹页、构建 Timeline、近战、碰撞导出）。关键词：技能管线、技能构建管线、SkillPipeline、弹道轨迹页、发射页、HasBox、钉发射、构建 Timeline、调整 Timeline、召唤物、近战、Life、显示碰撞体、公共弹道、初始化为公共ID、弹道 Key、导出碰撞体、colliderdata、Launch Points Dict、launchPointsDict、csvdemo、变体、placeholder、Override、静态开关、碰撞盒旋转、根位移曲线、强脱离、弱脱离、攻击类型、attackType、落点矩形、补写动画曲线、随机概率、复用弹道、母体技能。
- [`ballistic.md`](./ballistic.md) — 弹道全链：SkillEditor 弹道作者面、Copy 转换、trunk 飞行、弹体二阶段。关键词：弹道、BallisticConfig、BallisticCopy、OffsetPositions、Directional、D、攻击时长、animDistance、useAnimDistance、视觉贴附、拉扯、枪口表、LaunchPoint、诡弹、红点、出生点、定点延迟、轨迹进度、二阶段、寿命结束、BTDelaySpellUnitAtPos、2000175、2000010、海豹头球、转向速度、命中容器。
- [`skill_spec.md`](./skill_spec.md) — 技能流水线方向卡（目标、不变原则、覆盖范围、补丁清单）。关键词：技能规格、规格、补丁清单、转化器、零手改、回归样本、手改出口。
- [`code_structure.md`](./code_structure.md) — 本地工具代码（SkillPipeline、SkillSync、Bridge 本地编辑器工具）的结构：拆 / 合 / 不动信号、先挪后改、注释、文件职责表。关键词：拆文件、合文件、巨石、大文件、partial、先挪后改、头注释、文件职责表、本地工具代码、行数。
- [`monster_ai.md`](./monster_ai.md) — 怪物 AI、BuffVM 技能图、召唤/孵化/被动死亡、受击 Buff 四槽。关键词：怪物、AI、current 为空、CharacterType、DetectionRange、ChaseRange、attack_range、min_attack_range、DistanceTrigger、MonsterSkillConfig、BuffVM、BTRepeat、OnExit、AlreadyRate、攻击圈、召唤、孵化、出生施法、70006_ai_pet、脱离母体、被动死亡、BindPoint、受击特效、SpellHitActionAddBuff、BuffId_2、2000182、100282、2000178、槽登记、Current、姿态锁、时长钉住。
- [`root_motion.md`](./root_motion.md) — 技能根运动门控与烘焙查找键、出手姿态维持。关键词：根运动、RootMotion、BTSetRootMotion、IsRootMotion、技能没有位移、attack_forma、烘焙 Id、MotionType、AttackPoseFollowsBuff、姿态维持、转身、重复刷新、发射起点。
- [`climbing_tower.md`](./climbing_tower.md) — 爬塔 UI、任务栏、胜利界面、三闸解锁、爬塔 GM。关键词：爬塔、ClimbingTower、TowerView、Item_Stage1、分页、楼梯背景、任务栏、已击杀、TowerWinView、离开倒计时、奖励 tip、PreQuestID、PreStoryRaidID、MaxStoryRaidId、三闸、爬塔GM、CDE、UIDataBind、GuaranteedDrop、towerProgressFloorId、RewardKind、首通奖励、childCde。
- [`world_map.md`](./world_map.md) — 世界地图传送。关键词：世界地图、WorldMap、传送、指路石、出生地、Born_MapSlot、Comm_Btn03、canTransfer、u_DataCanTransfer。
- [`yiui_joystick.md`](./yiui_joystick.md) — 左右摇杆扇形响应区。关键词：摇杆、左摇杆、右摇杆、扇形、IsDraging、LeftJoystickHitArea、Panel_LeftJoy、Gizmos、瞄准抖动。
- [`control.md`](./control.md) — 控制面自身（本工作区规范与 runtime）。关键词：控制面、口令、钩子、guard、etctl、卡片、harvest、模板、schema。
- [`hand_animator.md`](./hand_animator.md) — 左右手攻击武器的四套主状态机。关键词：状态机、武器切换、OverrideController、overridecontroller、空手、泵枪、混乱抛射、MainSlot6、MainSlot7、手部攻击。

# 2. 账与审计

- [`records/task_outcomes.jsonl`](./records/task_outcomes.jsonl) — 收口账（占用 + interrupt 父足迹）：一个 `task_id` 一行，只由 `/harvests` 写；字段仅 `task_id` / `changed_targets` / `changed_paths` / `recorded_at`。`changed_paths` 只留源码/配置路径，不含控制面。
- [`audit/source_import_record.md`](./audit/source_import_record.md) — trunk Markdown 授权审计；discovery 用到 `editor_md_paths` 后登记。

# 3. 跨模块的坑

只收在两个以上模块都踩过的；模块专属的写在各卡。

- **跨 await 持有实体（ET0035）**：实体、EntityRef、TimerComponent 不跨 await；await 后从 EntityRef 重取（爬塔倒计时 t020、怪物 AI t034）。
- **客户端与服务端各跑一份**：先确认逻辑在哪端执行；加 Buff、拆单位、记账、解锁判定只在服务端，客户端只认下发结果；不同步字段在客户端是默认值。改分界时先问这个字段是权威结果，还是客户端节点上已经有的表现配置；表现配置不要再抄到服务器组件上同步（t022、t029、t034、t060）。
- **时长 / 相位用数据自己的时钟**：按进度查表时除数用被查数据自身的时长，不拿 Timeline 或别的 Buff 时长代替，也不垫数据迁就（t006、t029）。
- **同动作重设才换发射起点**：设置根运动返回成功，才把本 Buff 的发射起点改成这一刻。同动作还在播时默认直接返回，后面的枪口仍用上一次起点，相位会顶到末帧。片段结束前要再开同一段，勾节点「是否能重复刷新」，默认关（t064，用户核对）。
- **原点与单位两端一致**：写数据前对齐出生原点、单位（米还是归一化）、谁再乘一次；在转换处对齐，不改运行时公式（t004、t031）。
- **缺数据就报缺**：曲线、资产、配置缺失时不拿相近数据静默顶替；只有用户认可的回退才允许（t012、t031）。
- **生成或绑定的数据会覆盖手改**：Gen、导表代码、序列化 YAML、数据绑定字段都从源头改（t009、t034）。
- **共用资源不为一个需求改全局**：被多处共用的配置、Override、AI 超时、globalconfig，优先加只影响本例的开关；整份覆盖先问（t030、t032、t035）。
- **先排除放大器再找根因**：一次关掉一个可疑因素看症状是否消失；下游症状（碰撞放大、数量差）不当根因（t003、t004、t011）。
- **分析前先 scoped update**：只更新了调用方、它引用的定义还停在旧修订时，会缺方法或字段。先把要读的文件和直接依赖一起 update，再下结论。
- **回滚快照的工作线程没有同步上下文**：并行恢复快照时，调用线程装上的同步上下文不会跟到工作线程。不在纤维线程上、且同步 Id 变了或缺失时，SetSyncId 对当前上下文投递；上下文为空就空引用，客户端停止预测。每个并行任务开始时挂上回滚那份上下文，改 Id 仍由并行结束后的排空在主线程登记。客户端预测里拆掉再挂上同步组件，快照 Id 就会和现场不一致（t063，用户核对）。

# 4. 版本历史

- 5.42.0（2026-11-12）：空手一侧空槽会拼出双井号，加载为空就不换控制器。装配文件按骨架、大件、小件、护甲召唤、特效拆开。
- 5.41.0（2026-11-12）：登记手部攻击状态机。一个角色四套控制器，只有攻击武器参与切换。
- 5.40.0（2026-11-11）：同动作还在播时，设置根运动默认不重开，发射起点也不换。无限循环把根 Buff 时长钉成负数。全量转技能树先清空当前技能目录，占位目录不能盖过正式名。
- 5.39.0（2026-11-11）：空预制体不再写成 skill_技能号_damage。逻辑 SpellUnit 的碰撞盒按编辑器大小和偏移写。形状描述只留在资源里，打类别 bytes 会跳过。
- 5.38.0（2026-11-11）：回滚快照在工作线程写同步 Id 时要自带同步上下文。Buff 发射的弹体摘下后要把转向速度写成一圈每秒才会朝向目标。