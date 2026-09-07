> 最新修改时间：2026-09-07 14:55 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（框架知识或代码路由变更前读取）

# 0. 职责定位

本文件是 `standards/` 的目录索引，登记 ET81-workspace 内长期稳定的框架与路由标准。

本目录不保存任务状态；状态见 `project_cursor.md`。

# 1. 文件索引

- [`framework_baseline.md`](./framework_baseline.md)  
  职责：核验后的 Unity/ET 版本、程序集分层、代码放置与验证边界。  
  读取时机：新模块配置、跨层改动或验证方式选择前。
- [`source_code_map.md`](./source_code_map.md)  
  职责：需求关键词 → 相对 `source_root` 的源码路径路由。  
  读取时机：定位允许打开的源码文件前；Agent 只读「优先打开」列。
- [`source_import_record.md`](./source_import_record.md)  
  职责：一次性 trunk 文档初始化审计、冲突记录与 `frozen` 门禁状态。  
  读取时机：申请临时访问 trunk Markdown 前；登记授权后。

# 2. 版本历史

- 1.0.0（2026-09-07）：建立 standards 目录索引首版。
