> 最新修改时间：2026-09-12 16:45 UTC+8
> 版本号：1.5.0
> 文档状态：生效
> 读取等级：L1（全局规则变更前读取）

# 0. 职责定位

本文件是 `global_rules/` 的目录索引，登记跨任务、长期稳定的控制面规则。

# 1. 文件索引

- [`md_governance.md`](./md_governance.md)  
  职责：版头、命名、章节/篇幅预算（按读取等级）、违规处置、先读大纲、版本与防爆炸。  
  读取时机：创建或改写受管理 Markdown 或 JSON 数据前。
- [`kv_budget.md`](./kv_budget.md)  
  职责：游标、模块配置、开工契约的键值最小集、上限与违规处置。不是章节标题表。  
  读取时机：改这三种文件的键值项前。
- [`code_governance.md`](./code_governance.md)  
  职责：运行时与 trunk C# 读写门禁、SVN 更新与授权提交。不含 C# 细规。  
  读取时机：改代码或 runtime 前。
- [`runtime_code.md`](./runtime_code.md)  
  职责：`runtime/` 架构、命名、JSON 归属、体积与拆分处置。  
  读取时机：新增或改 runtime 脚本、schema 前。

# 2. 版本历史

- 1.5.0（2026-09-12）：`tools_code.md` 迁为 `runtime_code.md`。
- 1.4.0（2026-09-07）：登记 `tools_code.md`（后迁移）。
- 1.3.0（2026-09-07）：登记 `code_governance.md`。
- 1.2.0（2026-09-07）：登记章节预算（H1 最小 2 / 上限 8）。
- 1.1.0（2026-09-07）：`field_schema.md` 更名为 `kv_budget.md`；索引区分章节与键值。
