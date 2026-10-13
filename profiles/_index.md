> 最新修改时间：2026-10-09 21:06 UTC+8
> 版本号：1.8.4
> 文档状态：生效
> 读取等级：L1（查找模块配置时读取）

# 0. 职责定位

本文件是 `profiles/` 的目录索引。本目录只保存模块长期门禁（能碰哪、禁什么）。行为事实在 `standards/`，不要写进配置正文。活动配置由 `project_cursor.md` 的 `active_profile` 引用。

# 1. 文件索引

- [`_template.md`](./_template.md)  
  职责：模块配置模板（最小 4 个键值项，可选最多 6）。  
  读取时机：新建 `profiles/<module_id>.md` 前。
- [`control.md`](./control.md)  
  职责：控制面自身任务；`allowed_write` 为 `workspace_only`。  
  读取时机：`active_profile` 为 `control` 时。
- [`climbing_tower.md`](./climbing_tower.md)  
  职责：爬塔面板/关卡列表；写 ClimbingTower 四件套，禁插件与 Res。  
  读取时机：`active_profile` 为 `climbing_tower` 时。
- [`playeffect.md`](./playeffect.md)  
  职责：SkillEditor PlayEffect / Directional 弹道与轨迹预览。  
  读取时机：`active_profile` 为 `playeffect` 时。
- [`skill_collider.md`](./skill_collider.md)  
  职责：SkillEditor 碰撞体导出与变体路由。  
  读取时机：`active_profile` 为 `skill_collider` 时。
- [`skill_pipeline.md`](./skill_pipeline.md)  
  职责：SkillEditor 本地管线；写 SkillPipeline/、SkillSync/、Bake、Headless、SpellConversion；禁 SkillEditor2 与改 ControlColliderCS。  
  读取时机：`active_profile` 为 `skill_pipeline` 时。
- [`skill_sync.md`](./skill_sync.md)  
  职责：本机输出同步；写 SkillSync、Headless、SpellConversion 防护，以及 PlayAnimationBehaviour 的根运动开关。禁改 V2 窗口。  
  读取时机：`active_profile` 为 `skill_sync` 时。
- [`yiui_joystick.md`](./yiui_joystick.md)  
  职责：YIUI 左摇杆；写 Main 摇杆手写系统与红区命中，禁改 zFrame 摇杆、插件与 Res。  
  读取时机：`active_profile` 为 `yiui_joystick` 时。
- [`spell_unit_phase.md`](./spell_unit_phase.md)  
  职责：弹体二阶段；写轨迹摘下与客端寿命特效，Trunk 与 Bridge ScriptsET 成对改。禁改 50_ai 与 200017501/504。  
  读取时机：`active_profile` 为 `spell_unit_phase` 时。

# 2. 版本历史

- 1.8.4（2026-10-09）：登记 `spell_unit_phase`（t032）。
- 1.8.3（2026-10-08）：skill_sync 白名单加上 PlayAnimationBehaviour，转化要读根运动开关。
- 1.8.2（2026-09-29）：t027 中途 harvest：skill_pipeline/skill_sync 白名单扩 SkillSync 与 SpellConversion。
- 1.8.1（2026-09-29）：t027 中途 harvest：skill_pipeline 白名单扩 Bake/新建 playable。
- 1.8.0（2026-09-24）：登记 `yiui_joystick`（t025）。
