> 最新修改时间：2026-09-21 18:45 UTC+8
> 版本号：1.6.0
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
  职责：SkillEditor 本地管线；只写 SkillPipeline/，禁 SVN 与弹道窗口。  
  读取时机：`active_profile` 为 `skill_pipeline` 时。

# 2. 版本历史

- 1.6.0（2026-09-21）：登记 `skill_pipeline`（t015）。
- 1.5.0（2026-09-21）：登记 `skill_collider`（t012）。
- 1.4.0（2026-09-17）：登记 `playeffect`（t002）。
- 1.3.0（2026-09-16）：标明门禁目录；事实在 `standards/`。
- 1.2.0（2026-09-15）：登记 `climbing_tower`（t007）。
