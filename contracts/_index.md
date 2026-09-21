> 最新修改时间：2026-09-17 10:20 UTC+8
> 版本号：1.6.0
> 文档状态：生效
> 读取等级：L1（查找开工契约时读取）

# 0. 职责定位

本文件是 `contracts/` 的目录索引。活卡只有一张（`current.md` + `current_scope.json`）。未开工分析可停在 `candidates/`（最多 2），不是第二张活契约，不能 `/implement`，不能改 trunk。

# 1. 文件索引

- [`_template.md`](./_template.md)  
  职责：空闲/开工字段模板与省略规则。  
  读取时机：复制或重置 `current.md` 前。
- [`_template_scope.json`](./_template_scope.json)  
  职责：分析阶段数据包模板（intent/size/route/路径/证据/`plan`）。  
  读取时机：进入 discovery 或填写 `current_scope.json` 前。
- [`current.md`](./current.md)  
  职责：唯一活契约（目标、验收、本单 workspace 写集）。空闲时仅 2 个最小字段。  
  读取时机：`project_cursor.md` 的 `contract_ref` 指向本文件时。
- [`current_scope.json`](./current_scope.json)  
  职责：机读范围（phase、路径、证据、`plan`、`editor_md_paths`）。implement 工作令由 `etctl begin-implement` / `packet` 从此导出。  
  读取时机：与 `current.md` 同时；`/implement` 只消费命令 stdout，不要为开工手改本文件。
- [`candidates/_index.md`](./candidates/_index.md)  
  职责：未开工分析包（最多 2）。活卡 idle 后用户点名 `etctl promote <task_id>`。  
  读取时机：活卡占用时新开分析窗口。

# 2. 版本历史

- 1.6.0（2026-09-17）：登记 `candidates/`；最多 2 个未开工分析包。
- 1.5.0（2026-09-16）：分析包增加 `plan`。
- 1.4.0（2026-09-16）：implement 开工改走 `etctl begin-implement`。
- 1.3.0（2026-09-14）：`etctl packet` 从 current_scope 导出 implement 工作令。
- 1.2.0（2026-09-12）：登记分析包模板；discovery 可无模块。
