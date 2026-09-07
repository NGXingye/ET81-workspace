> 最新修改时间：2026-09-07 17:35 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L1（新增或修改 tools 下脚本前必读）

# 0. 职责定位

本文件登记 `tools/` 内允许存在的辅助脚本。未出现在本表中的 `.ps1` / `.py` **禁止存在**。

写法见 [`../global_rules/tools_code.md`](../global_rules/tools_code.md)。不得替代 [`../global_rules/code_governance.md`](../global_rules/code_governance.md) 的 SVN 授权规则。

# 1. 文件索引

- [`check-workspace.ps1`](./check-workspace.ps1)  
  职责：机检入口（编排文档、游标、契约、工具登记与体积）。  
  副作用：无写入、无 SVN 变更。  
  入口：`powershell -File tools/check-workspace.ps1`
- [`check-helpers.ps1`](./check-helpers.ps1)  
  职责：机检函数库（版头、键值、行数、基线 Unity 版本）。  
  副作用：无。非独立入口，由 `check-workspace.ps1` dot-source。

# 2. 版本历史

- 1.1.0（2026-09-07）：登记 `check-helpers.ps1`；入口与函数库拆分。
- 1.0.0（2026-09-07）：登记唯一工具 `check-workspace.ps1`。
