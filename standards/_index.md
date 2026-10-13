> 最新修改时间：2026-10-13 15:46 UTC+8
> 版本号：3.34.0
> 文档状态：生效
> 读取等级：L1（知识 harvest 或路由变更前读取）

# 0. 职责定位

`standards/` 按**已核验编辑器目录**物理分区。模型先读 [`catalog.json`](./catalog.json)，再只加载命中编辑器下的 1–2 个 JSON。禁止登记未核验路径，禁止编造编辑器。

# 1. 文件索引

- [`catalog.json`](./catalog.json)  
  职责：四个编辑器根路径 + 关键词 → 知识文件。  
  读取时机：discovery 或定位模块前。
- [`trunk/target.json`](./trunk/target.json)  
  职责：主 trunk 框架/配置根事实。  
  读取时机：catalog 命中 `trunk` 框架类。
- [`trunk/modules/monster_ai.json`](./trunk/modules/monster_ai.json)  
  职责：怪物 AI、CharacterType、侦测/追击圈与 DistanceTrigger 选技能。  
  读取时机：catalog 命中怪物/AI/距离触发。
- [`trunk/modules/root_motion.json`](./trunk/modules/root_motion.json)  
  职责：技能根运动门控、烘焙 Id、Spell 启用勾选与 Buff 节点。  
  读取时机：catalog 命中根运动/技能无位移。
- [`trunk/modules/ballistic.json`](./trunk/modules/ballistic.json)  
  职责：怪物弹道时钟、Copy 采样、2000010 四发映射。  
  读取时机：catalog 命中弹道/BallisticCopy。
- [`trunk/modules/climbing_tower.json`](./trunk/modules/climbing_tower.json)  
  职责：爬塔 Item_Stage1 五槽页（组距 1080）、自由滑两端卡死、仅 Image_Bg 跟滑、任务栏已击杀/总数、TowerWinView 离开倒计时与奖励 tip、层解锁三闸（层/主线/任务）、爬塔 GM 进度。  
  读取时机：catalog 命中爬塔/TowerView/任务栏/TowerWinView/PreQuestID。
- [`trunk/modules/spell_hit_vfx.json`](./trunk/modules/spell_hit_vfx.json)  
  职责：CastShape 受击加 Buff 四槽、角色 CreateBuffEffect 与地面 OnPos、近战自机环与 launchpoint。  
  读取时机：catalog 命中受击特效 / SpellHitActionAddBuff / 2000178。
- [`trunk/modules/spell_unit_phase.json`](./trunk/modules/spell_unit_phase.json)  
  职责：定点延迟按轨迹进度摘下同一发、进度 1 与 Buff 到期、客端寿命结束特效。  
  读取时机：catalog 命中定点延迟 / 轨迹进度 / 2000175 / 炸弹鸟。
- [`trunk/modules/yiui_joystick.json`](./trunk/modules/yiui_joystick.json)  
  职责：左右摇杆固定不跟手，画布下角扇形响应；扇形按下须让 Joystick.IsDraging 为真；GM Gizmos 涂扇形。  
  读取时机：catalog 命中左摇杆 / 扇形 / IsDraging / LeftJoystickHitArea。
- [`SkillEditor/target.json`](./SkillEditor/target.json)  
  职责：`C:\myProject\SkillEditor` 存在事实。
- [`SkillEditor/modules/playeffect.json`](./SkillEditor/modules/playeffect.json)  
  职责：弹道轨迹编辑器、BallisticConfig 权威、D 为终点圆、绘制/预览分工。  
  读取时机：catalog 命中 SkillEditor 弹道轨迹编辑器 / BallisticConfig。
- [`SkillEditor/modules/skill_collider.json`](./SkillEditor/modules/skill_collider.json)  
  职责：碰撞体导出、csvdemo 主表 Prefab、变体碰撞回退。  
  读取时机：catalog 命中导出碰撞体 / colliderdata / csvdemo。
- [`SkillEditor/modules/timeline_wc.json`](./SkillEditor/modules/timeline_wc.json)  
  职责：Resources/timeline 为 svn external；playable 须在该层提交。  
  读取时机：catalog 命中 timeline svn / playable 提交。
- [`SkillEditor/modules/skill_pipeline.json`](./SkillEditor/modules/skill_pipeline.json)  
  职责：本地管线（输入→技能→动画→特效→碰撞体→输出）、轨迹页、替换 playable、skill_{id}_colliderdata。  
  读取时机：catalog 命中技能管线 / 技能构建管线 / 弹道轨迹页。
- [`SkillEditor/modules/skill_sync.json`](./SkillEditor/modules/skill_sync.json)  
  职责：管线输出三行钮、资源对照格、SkillSync 文件地图与提交日志。  
  读取时机：catalog 命中 SkillSync / 转化到本地 / 预检叠入。
- [`BridgeEditor/target.json`](./BridgeEditor/target.json)  
  职责：`C:\myProject\BridgeEditor` 存在事实。ConfigET 为 trunk Config 外链；同步见 skill_sync。
- [`ActionEditor/target.json`](./ActionEditor/target.json)  
  职责：`C:\myProject\ActionEditor` 存在事实。尚无模块。
- [`integrations/_index.md`](./integrations/_index.md)  
  职责：跨编辑器数据流。  
  读取时机：出现已验证跨编辑器传递时。
- [`integrations/skill_sync.json`](./integrations/skill_sync.json)  
  职责：SkillEditor→Bridge 引擎→本地 trunk；提交先原料后配置；Spell/Buff/SpellShape/SpellUnit 落盘。  
  读取时机：catalog 命中资源同步 / 提交配置。
- [`records/task_outcomes.jsonl`](./records/task_outcomes.jsonl)  
  职责：收口账。一个 `task_id` 一行。非冷启动默认。
- [`framework_baseline.md`](./framework_baseline.md)  
  职责：trunk 框架 L2 备份；Agent 优先 `trunk/target.json`。
- [`source_code_map.md`](./source_code_map.md)  
  职责：未迁入 `trunk/modules` 的遗留路由。
- [`audit/source_import_record.md`](./audit/source_import_record.md)  
  职责：trunk Markdown 授权审计。

# 2. 版本历史

- 3.34.0（2026-10-13）：收口账改为一个任务号一行。
- 3.33.0（2026-10-09）：t032 harvest：定点延迟按进度摘下同一发；进度 1 在终点前进二阶段。活卡 idle。
- 3.32.0（2026-10-02）：t029 harvest：退出尾段含 OnExit 等待；BuffVM 等待认动画结束；枪口轨道跟当前根运动。活卡 idle。
- 3.31.0（2026-10-02）：t029 中途 harvest：重复 OnExit、怪物客户端不加子 Buff、枪口表跟开火相位、姿态维持到主 Buff。活卡不 idle。
- 3.30.0（2026-09-30）：t029 中途 harvest：枪口表帧=映射动画；等待层 Duration 应对齐表时长；animDistance 是定向开关。活卡不 idle。
