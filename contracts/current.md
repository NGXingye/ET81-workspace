> 最新修改时间：2026-11-09 12:15 UTC+8
> 版本号：1.0.103
> 文档状态：生效
> 读取等级：L0（当游标 contract_ref 指向本文件时读取）
# 0. 职责定位

本文件是唯一活开卡契约：阶段、路径、验证写在 `current_scope.json`。不写长文在本文件；不写版本历史；进度不写在本文件。活卡可追写 `acceptance`（分号非空）；每一条指向 `validation`；证据记录在 `current_scope.json` 的 `evidence`。取值变化更新版本号。
# 1. 契约字段

- `task_id`：`t060`
- `contract_status`：`active`
- `goal`：`接入特效只在客户端按阶段节点挂预制体。服务器不写、不同步 BoneVfxPrefab 与 BoneVfxPoint。先合入最新 SVN，再改本地逻辑。`
- `profile_ref`：`profiles/spell_unit_phase.md`
- `source_root_mode`：`normal`
- `acceptance`：`服务器不再因为接入特效写 BoneVfxPrefab、BoneVfxPoint，也不为此 NotifySyncData。; 客户端按阶段节点的预制体名、挂点和 AtMs 挂到 present 或本单位活骨。视图晚到补挂一次，已挂过的同名预制体不重复挂。; DotNet.Model 不再编译带 UnityEngine.GameObject 的监视组件。`
