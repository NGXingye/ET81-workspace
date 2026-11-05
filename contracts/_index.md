> 最新修改时间：2026-11-05 10:20 UTC+8
> 版本号：1.17.0
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
- [`_template_interrupt.json`](./_template_interrupt.json)  
  职责：热插队分析包模板（新号 + `parent_task_id` + trivial/fast）。  
  读取时机：活卡占用时写插队候选，再 `etctl interrupt`。
- [`_template_commit_plan.json`](./_template_commit_plan.json)  
  职责：活动/暂留提交计划共用模板。笔数以 10 为参考；一笔最多 8 个 `.cs`。  
  读取时机：`/harvests` 写活动槽 `commit_plan.json` 前。
- [`commit_plan.json`](./commit_plan.json)  
  职责：**活动**提交计划槽。`/harvests` 写入；`commit-units` 默认读此文件；promote 只拦此槽未交笔。`omitted` 只记本槽真排除（不含 held 未交笔、不含 targets `local_only`）。  
  读取时机：收口写计划、授权提交、promote 前。
- [`held_commit_plan.json`](./held_commit_plan.json)  
  职责：**暂留**提交计划槽（同时最多一笔、固定一个 `task_id`）。本地测完再交时用 `etctl hold-plan` 从活动槽挪入；`restore-plan` 挪回；`commit-units --held` 直接交暂留。不拦 promote。活动槽 `--fill`/`--verify` 把其未交笔 paths 视同已覆盖，不在活动 `omitted` 镜像。空骨架：`task_id=none`、`units=[]`。  
  读取时机：需要推迟 SVN 提交且还要开下一任务时。
- [`current.md`](./current.md)  
  职责：唯一活契约（目标、验收、本单 workspace 写集）。空闲时仅 2 个最小字段。  
  读取时机：`project_cursor.md` 的 `contract_ref` 指向本文件时。
- [`current_scope.json`](./current_scope.json)  
  职责：机读范围（phase、路径、证据、`plan`、`editor_md_paths`）。implement 工作令由 `etctl begin-implement` / `packet` 从此导出。  
  读取时机：与 `current.md` 同时；`/implement` 只消费命令 stdout，不要为开工手改本文件；同 target+profile 且用户明确继续本卡时按 `implement.md`「补活卡」追加（goal 可概括改写）。
- [`candidates/_index.md`](./candidates/_index.md)  
  职责：未开工分析包（最多 2）。活卡 idle 后用户点名 `etctl promote <task_id>`。热插队由 `etctl interrupt` 把活卡勾进本目录（可含 implement）。  
  读取时机：活卡占用时新开分析窗口。

# 2. 版本历史

- 1.17.0（2026-11-05）：活动 fill/verify 认 held 覆盖与 local_only；omitted 只留真排除。
- 1.16.0（2026-11-04）：补活卡条件改为同 target+profile 且用户明确继续本卡；goal 可概括改写。
- 1.15.0（2026-10-28）：登记活动槽 `commit_plan.json` 与暂留槽 `held_commit_plan.json`；同时只一笔暂留。
- 1.14.0（2026-10-17）：`current_scope.json` 可按补活卡增量追加。
- 1.13.0（2026-10-15）：撤回 `knowledge_used` / `knowledge_gap`。
- 1.12.0（2026-10-14）：分析包模板加 `knowledge_used` / `knowledge_gap`。

