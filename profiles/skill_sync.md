> 最新修改时间：2026-10-08 20:18 UTC+8
> 版本号：1.0.3
> 文档状态：草案
> 读取等级：L2（active_profile 为 skill_sync 时读取）

# 0. 职责定位

本文件是本机技能输出同步门禁。只写 SkillSync、管线输出格、Bridge Headless 与转换引擎空引用防护。不改 TimelineToSpellConverterV2 窗口。

# 1. 模块字段

- `module_id`：`skill_sync`
- `module_name`：技能输出同步
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/EditorTools/SkillSync/; Assets/Scripts/App/Comm/EditorTools/SkillPipeline/SkillPipelineWindow.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SkillSyncHeadless.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/SpellConversion/; Assets/Scripts/App/Comm/Battle/Scripts/TimelineTracks/Battle/PlayAnimation/PlayAnimationBehaviour.cs`
- `allowed_read`：`Assets/Scripts/App/Comm/EditorTools/SkillPipeline/; Assets/Resources/timeline/skills; Assets/collider/`
- `extra_forbidden`：`svn add SkillSync; svn add SkillSyncHeadless; Assets/Scripts/App/Comm/EditorTools/BallisticPathEditorWindow.cs; Assets/Editor/SkillEditor/SkillEditor2.cs; C:/myProject/BridgeEditor/Assets/Scripts/Editor/TimelineToSpellConverterV2.cs`
- `extra_risk`：`未 ignore 就 svn add SkillSync; 转化时 svn update 整树; 先交配置后交原料; commit ConfigET 与 trunk 同一批; 叠入整份 globalconfig.asset`

# 2. 版本历史

- 1.0.3（2026-10-08）：转化读根运动开关，允许改 PlayAnimationBehaviour 这一个文件。
- 1.0.2（2026-09-29）：t027 中途 harvest：允许 SpellConversion 空引用防护；禁 JobWindow；禁整份 globalconfig 叠入。
- 1.0.1（2026-09-22）：t016 harvest：白名单补 Headless；禁 svn add Headless。
- 1.0.0（2026-09-22）：t016 本机同步门禁；提交锁序先原料后配置。
