> 最新修改时间：2026-09-21 18:45 UTC+8
> 版本号：3.11.0
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
  职责：爬塔 Item_Stage1 五槽页、任务栏已击杀/总数、TowerWinView 离开倒计时与 GM 预览。  
  读取时机：catalog 命中爬塔/TowerView/任务栏/TowerWinView。
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
  职责：SkillEditor 本地管线 L0/L1、SVN 隔离与文件预算。  
  读取时机：catalog 命中技能管线 / 怪物页。
- [`BridgeEditor/target.json`](./BridgeEditor/target.json)  
  职责：`C:\myProject\BridgeEditor` 存在事实。尚无模块。
- [`ActionEditor/target.json`](./ActionEditor/target.json)  
  职责：`C:\myProject\ActionEditor` 存在事实。尚无模块。
- [`integrations/_index.md`](./integrations/_index.md)  
  职责：跨编辑器数据流（当前空）。  
  读取时机：出现已验证跨编辑器传递时。
- [`records/task_outcomes.jsonl`](./records/task_outcomes.jsonl)  
  职责：已结束任务指针。非冷启动默认。
- [`framework_baseline.md`](./framework_baseline.md)  
  职责：trunk 框架 L2 备份；Agent 优先 `trunk/target.json`。
- [`source_code_map.md`](./source_code_map.md)  
  职责：未迁入 `trunk/modules` 的遗留路由。
- [`audit/source_import_record.md`](./audit/source_import_record.md)  
  职责：trunk Markdown 授权审计。

# 2. 版本历史

- 3.11.0（2026-09-21）：t015：SkillEditor 本地管线 L0+L1 设计（未改源码）。
- 3.10.0（2026-09-21）：t014 harvest：SkillEditor timeline 为 svn external。
- 3.9.0（2026-09-21）：t013 harvest：攻击圈不相交与 Spell 启用根运动 GUI。
- 3.8.0（2026-09-21）：t012 harvest：SkillEditor `skill_collider.json`（碰撞导出与 csvdemo 主表）。
- 3.7.0（2026-09-20）：t003 harvest：SkillEditor `playeffect.json`（弹道轨迹编辑器）。
