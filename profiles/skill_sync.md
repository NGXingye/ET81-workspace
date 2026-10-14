> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.1.0
> 文档状态：草案
> 读取等级：L2（脚本读取门禁；人和模型读 cards/skill_sync.md）

# 0. 职责定位

本文件只保存模块 `skill_sync` 的机器门禁（`allowed_write` 等键），由 `runtime/guard.ps1`、`begin-implement` 读取。怎么运转、坑和验证见 [`cards/skill_sync.md`](../cards/skill_sync.md)。不在这里写行为事实。

# 1. 模块字段

- `module_id`：`skill_sync`
- `module_name`：技能输出同步
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/EditorTools/SkillSync/; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineWindow.cs; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineTableView.cs; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineBallisticAssets.cs; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineBallisticKeys.cs; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineTrajectoryPage.cs; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineLaunchPose.cs; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineTrajectoryPreview.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SkillSyncHeadless.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SkillPipelineBridge.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SkillPipelineShapeSign.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SpellConversion/; Assets/Scripts/App/Comm/Battle/Scripts/TimelineTracks/Battle/PlayAnimation/PlayAnimationBehaviour.cs`
- `allowed_read`：`Assets/Scripts/App/Comm/EditorTools/SkillPipeline/; Assets/Resources/timeline/skills; Assets/collider/`
- `extra_forbidden`：`svn add SkillSync; svn add SkillSyncHeadless; svn add SkillPipelineBridge; svn add SkillPipelineShapeSign; Assets/Scripts/App/Comm/EditorTools/BallisticPathEditorWindow.cs; Assets/Editor/SkillEditor/SkillEditor2.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/TimelineToSpellConverterV2.cs`

# 2. 版本历史

- 1.1.0（2026-10-14）：行为事实与风险提示移入 cards/skill_sync.md；本文件只留门禁键。
- 1.0.8（2026-10-14）：改 Key 列入可写。
- 1.0.7（2026-10-14）：发射页采样与预览列入可写。
- 1.0.6（2026-10-13）：发射页公共弹道初始化列入可写。
- 1.0.5（2026-10-13）：本地管线中转层 SkillPipelineBridge 列入可写，并禁止 svn add。
