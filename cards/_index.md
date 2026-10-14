> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（每轮 /implement 开头、报错或新需求出现时按关键词路由）

# 0. 职责定位

`cards/` 是模型与用户共读的知识层，取代原 `standards/catalog.json` 路由与 `standards/**/*.json` 事实库。用法：拿需求或报错里的词对下表「关键词」，命中 1–2 张卡就读它的 `# 0` 与 `# 2`；再扫 [`pitfalls.md`](./pitfalls.md) 的「场景触发」。都没命中就记为「未知领域」（写入 scope 的 `knowledge_gap`）。

写入门禁不在这里，在 `profiles/<id>.md`（`active_profile` 指向）。

# 1. 文件索引

- [`_template.md`](./_template.md) — 新建卡模板。
- [`pitfalls.md`](./pitfalls.md) — 跨模块通用坑。关键词：报错、空引用、await、ET0035、同步、客户端、服务端、时长、相位、原点、坐标、单位、覆盖、生成、svn、冲突、外链。
- [`framework.md`](./framework.md) — trunk ET8.1 框架与四个编辑器工程。门禁：无。关键词：框架、Core、Loader、Fiber、程序集、asmdef、放置、Generate、YIUI 落点、编译、验证、Combat、Numeric、背包、Quest、HLS。
- [`skill_sync.md`](./skill_sync.md) — SkillEditor → Bridge 转化 → trunk Config 的本机同步与 SVN 提交。门禁：`skill_sync`。关键词：SkillSync、资源同步、转化到本地、预检叠入、提交原料、提交配置、ConfigET、资源对照、只转轨迹、Headless、job.json、task:15、task:32、E165001、timeline svn、playable 提交、external。
- [`skill_pipeline.md`](./skill_pipeline.md) — SkillEditor 本地技能管线（一页管线、轨迹页、构建 Timeline、近战、碰撞导出）。门禁：`skill_pipeline`、`skill_collider`。关键词：技能管线、技能构建管线、SkillPipeline、弹道轨迹页、发射页、钉发射、构建 Timeline、调整 Timeline、召唤物、近战、Life、显示碰撞体、公共弹道、初始化为公共ID、弹道 Key、导出碰撞体、colliderdata、Launch Points Dict、launchPointsDict、csvdemo、变体、placeholder、Override。
- [`ballistic.md`](./ballistic.md) — 弹道全链：SkillEditor 弹道作者面、Copy 转换、trunk 飞行、弹体二阶段。门禁：`playeffect`、`spell_unit_phase`。关键词：弹道、BallisticConfig、BallisticCopy、OffsetPositions、Directional、D、animDistance、useAnimDistance、视觉贴附、拉扯、枪口表、LaunchPoint、诡弹、红点、出生点、定点延迟、轨迹进度、二阶段、寿命结束、BTDelaySpellUnitAtPos、2000175、2000010、海豹头球。
- [`monster_ai.md`](./monster_ai.md) — 怪物 AI、BuffVM 技能图、召唤/孵化/被动死亡、受击 Buff 四槽。门禁：无专用（按任务另建）。关键词：怪物、AI、current 为空、CharacterType、DetectionRange、ChaseRange、attack_range、min_attack_range、DistanceTrigger、MonsterSkillConfig、BuffVM、BTRepeat、OnExit、AlreadyRate、攻击圈、召唤、孵化、脱离母体、被动死亡、BindPoint、受击特效、SpellHitActionAddBuff、BuffId_2、2000182、100282、2000178。
- [`root_motion.md`](./root_motion.md) — 技能根运动门控与烘焙查找键、出手姿态维持。门禁：无。关键词：根运动、RootMotion、BTSetRootMotion、IsRootMotion、技能没有位移、attack_forma、烘焙 Id、MotionType、AttackPoseFollowsBuff、姿态维持、转身。
- [`climbing_tower.md`](./climbing_tower.md) — 爬塔 UI、任务栏、胜利界面、三闸解锁、爬塔 GM。门禁：`climbing_tower`。关键词：爬塔、ClimbingTower、TowerView、Item_Stage1、分页、楼梯背景、任务栏、已击杀、TowerWinView、离开倒计时、奖励 tip、PreQuestID、PreStoryRaidID、MaxStoryRaidId、三闸、爬塔GM、CDE、UIDataBind。
- [`yiui_joystick.md`](./yiui_joystick.md) — 左右摇杆扇形响应区。门禁：`yiui_joystick`。关键词：摇杆、左摇杆、右摇杆、扇形、IsDraging、LeftJoystickHitArea、Panel_LeftJoy、Gizmos、瞄准抖动。
- [`control.md`](./control.md) — 控制面自身（本工作区规范与 runtime）。门禁：`control`。关键词：控制面、口令、钩子、guard、etctl、卡片、harvest、模板、schema。

# 2. 版本历史

- 1.0.0（2026-10-14）：首版；由 profiles 与 standards 全量提炼，取代 catalog 路由。