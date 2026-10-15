> 最新修改时间：2026-10-15 10:40 UTC+8
> 版本号：1.1.0
> 文档状态：草案
> 读取等级：L2（脚本读取门禁；人和模型读 standards/skill_pipeline.md）

# 0. 职责定位

本文件只保存模块 `skill_pipeline` 的机器门禁（`allowed_write` 等键），由 `runtime/guard.ps1`、`begin-implement` 读取。怎么运转、坑和验证见 [`standards/skill_pipeline.md`](../standards/skill_pipeline.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`skill_pipeline`
- `module_name`：技能编辑器本地管线
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/EditorTools/SkillPipeline/; Assets/Scripts/App/Comm/EditorTools/BallisticPathBake.cs; Assets/Scripts/App/Comm/EditorTools/BallisticPathEditorWindow.cs; Assets/Scripts/App/Comm/EditorTools/SkillSync/; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SkillSyncHeadless.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SpellConversion/`
- `allowed_read`：`Assets/Scripts/App/Comm/EditorTools/BallisticPathEditorWindow.cs; Assets/Editor/SkillEditor/; Assets/Editor/SkillEditor/csvdemo/; Assets/Resources/timeline/skills; Assets/Resources/config/globalconfig/; Assets/collider/`
- `extra_forbidden`：`svn add SkillPipeline; svn add SkillSync; svn commit; Assets/Editor/SkillEditor/SkillEditor2.cs; Assets/Editor/SkillEditor/csvdemo/; Assets/Editor/SkillEditor/ControlColliderCS.cs`

# 2. 版本历史

- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/skill_pipeline.md；本文件只留门禁键。
- 1.0.3（2026-09-29）：t027 中途 harvest：构建可替换 playable；写 SkillSync/Headless/SpellConversion；禁改 ControlColliderCS 源码（只反射导出）；禁 {prefab}_colliderdata 当技能挂点。
- 1.0.2（2026-09-29）：t027 中途 harvest：轨迹页/Bake/新建 playable 进白名单；禁覆盖已有 Timeline。
- 1.0.1（2026-09-21）：补 extra_risk（ignore 未合并 / 改弹道窗）。
- 1.0.0（2026-09-21）：t015 L0+L1 只读面板门禁；弹道窗口只读纳入。
