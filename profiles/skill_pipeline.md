> 最新修改时间：2026-09-21 18:45 UTC+8
> 版本号：1.0.0
> 文档状态：草案
> 读取等级：L2（active_profile 为 skill_pipeline 时读取）

# 0. 职责定位

本文件是 SkillEditor 本地提效管线门禁。只写本机工具目录，不提交 SVN，不改弹道窗口与源表。

# 1. 模块字段

- `module_id`：`skill_pipeline`
- `module_name`：技能编辑器本地管线
- `profile_status`：`draft`
- `allowed_write`：`Assets/Scripts/App/Comm/EditorTools/SkillPipeline/`
- `allowed_read`：`Assets/Scripts/App/Comm/EditorTools/BallisticPathEditorWindow.cs; Assets/Editor/SkillEditor/; Assets/Editor/SkillEditor/csvdemo/`
- `extra_forbidden`：`svn commit; svn add; Assets/Scripts/App/Comm/EditorTools/BallisticPathEditorWindow.cs; Assets/Editor/SkillEditor/SkillEditor2.cs; Assets/Editor/SkillEditor/csvdemo/; Assets/Resources/timeline/`

# 2. 版本历史

- 1.0.0（2026-09-21）：t015 L0+L1 只读面板门禁；弹道窗口只读纳入。
