> 最新修改时间：2026-10-13 15:20 UTC+8
> 版本号：1.16.0
> 文档状态：生效
> 读取等级：L2（仅用户了解流程；Agent 禁止为开工或收口打开）

# 0. 职责定位

本文件给用户看流程，不重复硬约束。不变量在 [`AGENTS.md`](./AGENTS.md)。口令在 `.cursor/commands/`。冷启动读序在 `.cursor/rules/et81-cold-start.mdc`。Agent 不为开工或收口打开本文。

# 1. 流程

```text
你提需求 / 问题
        │
        ▼
   discovery     必须写出分析包（含 plan）
        │
        ├─ 模型标 route=fast，你同意 ──► 改 write_paths（不必 /implement）
        │                                      │
        │                                      ▼
        │                                   你验证 ──► /harvest 不停卡
        │                                              /harvests ──► idle
        │
        ├─ 需要你看范围 ──► awaiting_scope
        │                      ├─ /implement ──► implement ──► 你验证
        │                      │                      ├─ 通过 ──► /harvest 不停卡；/harvests ──► idle
        │                      │                      └─ 失败 ──► 仍 implement
        │                      ├─ 你改配置/表 ──► 验证后 /harvests
        │                      └─ 目标变了 ──► 你明确说才退回 discovery
        └─ 继续提问 ──► 留在 discovery
```

- [`implement.md`](./.cursor/commands/implement.md)
- [`harvest.md`](./.cursor/commands/harvest.md)
- [`harvests.md`](./.cursor/commands/harvests.md)
- [`interrupt.md`](./.cursor/commands/interrupt.md)

# 2. 版本历史

- 1.16.0（2026-10-13）：步骤改为链接，不再抄口令与硬约束。
- 1.15.0（2026-10-13）：提交窗口从根目录 `commit.cmd` 打开。
- 1.14.0（2026-10-13）：`/harvests` 写提交计划；一次提交一笔。
- 1.13.0（2026-10-12）：svn update 后以拉下的提交为基准，本地未提交改动往上靠。
- 1.12.0（2026-10-09）：`/harvest` 中途不停卡；`/harvests` 全量 idle。
