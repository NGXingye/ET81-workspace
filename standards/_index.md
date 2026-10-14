> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：4.0.0
> 文档状态：生效
> 读取等级：L1（/harvests 记收口账或登记 trunk 文档授权时读取）

# 0. 职责定位

`standards/` 不再存放模块知识。模块知识与通用坑在 [`../cards/_index.md`](../cards/_index.md)。本目录只留两样：收口账与 trunk 文档授权审计。旧的按编辑器分区 JSON、`catalog.json`、框架基线已归档到 [`../archive/_index.md`](../archive/_index.md)。

# 1. 文件索引

- [`records/task_outcomes.jsonl`](./records/task_outcomes.jsonl)  
  职责：收口账。一个 `task_id` 一行，只由 `/harvests` 写。旧行里的 `promoted` 路径指向已归档文件，保持原样。  
  读取时机：`/interrupt` 校验 parent 写集；非冷启动默认。
- [`audit/source_import_record.md`](./audit/source_import_record.md)  
  职责：trunk Markdown 授权审计。  
  读取时机：discovery 用到 `editor_md_paths` 后登记。

# 2. 版本历史

- 4.0.0（2026-10-14）：模块知识全量提炼进 `cards/`；catalog、编辑器分区 JSON、基线与遗留路由归档。
- 3.34.0（2026-10-13）：收口账改为一个任务号一行。
- 3.33.0（2026-10-09）：t032 harvest：定点延迟按进度摘下同一发；进度 1 在终点前进二阶段。活卡 idle。
- 3.32.0（2026-10-02）：t029 harvest：退出尾段含 OnExit 等待；BuffVM 等待认动画结束；枪口轨道跟当前根运动。活卡 idle。
- 3.31.0（2026-10-02）：t029 中途 harvest：重复 OnExit、怪物客户端不加子 Buff、枪口表跟开火相位、姿态维持到主 Buff。活卡不 idle。