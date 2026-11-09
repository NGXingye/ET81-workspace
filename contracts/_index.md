> 最新修改时间：2026-11-09 10:30 UTC+8
> 版本号：1.20.0
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
  职责：活动提交计划模板。笔数以 10 为参考；一笔最多 8 个 `.cs`。  
  读取时机：`/harvests` 写活动槽 `commit_plan.json` 前。
- [`commit_plan.json`](./commit_plan.json)  
  职责：**活动**提交计划槽。`/harvests` 写入；`commit-units` 默认读此文件；promote 只拦此槽未交笔。`omitted` 只记本槽真排除（不含 held 未交笔、不含 targets `local_only`）。  
  读取时机：收口写计划、授权提交、promote 前。
- [`held_commit_plan.json`](./held_commit_plan.json)  
  职责：按模块记的本地未交工作。对话点名留下的一块直接改本文件：同一目标且同一件事更新原模块，换目标或另一件事才新开。每模块有归属目标、路径、意图、阻碍、来源任务号。无总 `task_id`，无提交状态，不能直接提交。`hold-plan` 只在活动槽整单都不交时，按目标合并进同编号模块（路径取并集，保留原阻碍）并清空活动槽。`restore-plan` 不整份还原。不拦 promote。活动槽 `--fill`/`--verify` 按工作区匹配：无符号交集视同已覆盖，有交集只报告不补进。提交成功后才划掉正好对上的文件，目录项不自动拆开。空骨架：`modules=[]`。  
  读取时机：对话里点名留下一块，或下一单要避开这些路径时。
- [`held_commit_plan.t059.json`](./held_commit_plan.t059.json)  
  职责：t059 迁出前的原件，只读。白名单、无逻辑差、备份和控制面路径留在这里，没有收进模块。  
  读取时机：核对这次迁移时。
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

- 1.20.0（2026-11-09）：hold 合并保留阻碍；提交成功后才核销；符号相交只报告。
- 1.19.0（2026-11-07）：对话点名直接改 held 模块；hold-plan 只收整单不交。
- 1.18.0（2026-11-07）：held 改为模块索引；t059 原件留档。
- 1.17.0（2026-11-05）：活动 fill/verify 认 held 覆盖与 local_only；omitted 只留真排除。
- 1.16.0（2026-11-04）：补活卡条件改为同 target+profile 且用户明确继续本卡；goal 可概括改写。

