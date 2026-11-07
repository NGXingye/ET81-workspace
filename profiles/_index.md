> 最新修改时间：2026-10-27 22:55 UTC+8
> 版本号：1.12.0
> 文档状态：生效
> 读取等级：L1（查找模块配置时读取）

# 0. 职责定位

本文件是 `profiles/` 的目录索引。每个配置只有 4 个键。`allowed_write` 是目录前缀菜单（相对目标 `workspace_path`，跨工程写绝对路径）：discovery 从中挑 `write_paths`，越出时 `begin-implement` 与机检警告（`runtime/boundary.ps1` 一处开关可改成拒绝）；值为 `workspace_only` 时 guard 拒绝源码写入。实际可写以活卡 `write_paths` 为准。禁区与本地专用在 `targets/<id>.json`，禁改的具体文件写在对应卡片。行为、风险与验证在 [`../standards/_index.md`](../standards/_index.md)，不要写进配置正文。活动配置由 `project_cursor.md` 的 `active_profile` 引用。implement 不打开本目录。

# 1. 文件索引

- [`_template.md`](./_template.md)  
  职责：模块配置模板（只有 4 个键）。  
  读取时机：新建 `profiles/<module_id>.md` 前。
- [`control.md`](./control.md)  
  职责：控制面自身任务；`allowed_write` 为 `workspace_only`。  
  读取时机：`active_profile` 为 `control` 时。
- [`climbing_tower.md`](./climbing_tower.md)  
  职责：爬塔面板/关卡列表；写 ClimbingTower 四件套及 Main、GM、服务端 Tower 相关目录。  
  读取时机：`active_profile` 为 `climbing_tower` 时。
- [`playeffect.md`](./playeffect.md)  
  职责：SkillEditor PlayEffect / Directional 弹道与轨迹预览。  
  读取时机：`active_profile` 为 `playeffect` 时。
- [`skill_collider.md`](./skill_collider.md)  
  职责：SkillEditor 碰撞体导出与变体路由。  
  读取时机：`active_profile` 为 `skill_collider` 时。
- [`skill_pipeline.md`](./skill_pipeline.md)  
  职责：SkillEditor 本地管线；写 EditorTools/ 与 Bridge `Assets/Scripts/Editor/` 两个前缀。  
  读取时机：`active_profile` 为 `skill_pipeline` 时。
- [`skill_sync.md`](./skill_sync.md)  
  职责：本机输出同步；写 EditorTools/、PlayAnimation/ 与 Bridge `Assets/Scripts/Editor/` 三个前缀。  
  读取时机：`active_profile` 为 `skill_sync` 时。
- [`yiui_joystick.md`](./yiui_joystick.md)  
  职责：YIUI 左摇杆；写 Main 与 GM 目录（摇杆手写系统与红区命中）。  
  读取时机：`active_profile` 为 `yiui_joystick` 时。
- [`spell_unit_phase.md`](./spell_unit_phase.md)  
  职责：弹体二阶段；写轨迹摘下与客端寿命特效，Trunk 与 Bridge ScriptsET 成对改。  
  读取时机：`active_profile` 为 `spell_unit_phase` 时。
- [`pet_locomotion.md`](./pet_locomotion.md)  
  职责：宠物跟随的客户端起步动画；写 Unit 运动表现目录。  
  读取时机：`active_profile` 为 `pet_locomotion` 时。

# 2. 版本历史

- 1.12.0（2026-10-27）：登记 `pet_locomotion`（t049）。
- 1.11.0（2026-10-18）：`allowed_write` 改为目录前缀菜单，配置只留 4 个键；行描述去掉已移走的禁区。
- 1.10.0（2026-10-18）：更正脚本实际读取的键；本地专用改以 svn 忽略为准。
- 1.9.0（2026-10-14）：本目录降为脚本门禁；行为与风险移入 `cards/`。
- 1.8.4（2026-10-09）：登记 `spell_unit_phase`（t032）。
