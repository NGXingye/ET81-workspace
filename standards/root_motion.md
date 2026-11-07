> 最新修改时间：2026-11-06 14:18 UTC+8
> 版本号：1.3.0
> 文档状态：生效
> 读取等级：L1（关键词命中根运动 / 技能无位移 / 姿态维持时读取）

# 0. 速览

> 速览：技能的逻辑位移只来自烘焙的 RootMotionConfig 积分（Animator.applyRootMotion 关闭，动画只播骨骼）；由 SpellConfig 开关和 BT 节点共同决定是否积分。
> 最大风险：开关没开或查找键不对，导致「动画在动、单位不动」。
> 做对的标准：放技能时逻辑坐标随烘焙 TotalPosition 移动，不再报「没有找到根运动配置」。
>
> 门禁：无（开工时按任务新建或借用相近 profile）

# 1. 怎么运转

`SpellConfig.IsRootMotion`（积分门控）→ 动画 Buff 上的 `BTSetRootMotion`（Motion Type）→ `RootMotionConfig.Get(hash(bakerId + "_" + GetRootMotionName(MotionType)))` → 积分位移。

- bakerId = PrefabName 最后一个 `_` 后的数字；名字字典命中用字典值，否则枚举名小写（Attack → `attack`）。配置按 Id 字段索引，不按文件名。
- 关键入口：`BTSetRootMotionHandler.cs`、`BuffVMSetRootMotionHandler.cs`、`SpellConfig.cs`、`RootMotionConfig.cs`、`RootMotionGenerator.cs`。

# 2. 坑和不变量

- `IsRootMotion=false` 时两个 Handler 直接 Succeed，不积分；AI 转身（`AILocomotionHelper`）直接 SetRootMotion，不读这个开关，所以「转身正常」不代表开关已开。
- 查找键用 `attack`，不是 clip 名 `attack_forma`；烘焙器不手动指定 Attack 会写出 `{id}_attack_forma`，运行时不会读。两份可并存，只认 Id 对上的那份。
- BTSetRootMotion 加在随机选出的动画 Buff（01/03/05）上，排在 BTCastShape 前，不加在 master 00。
- `SpellConfig.MotionType` 给 AI 施法前探障碍和位移长度用，必须与节点类型一致，不能删。
- Inspector「启用根运动」要独立勾选；bool 与 `ShowIf` 放同一 BoxGroup 会被 Odin 整组藏掉。
- 烘焙器对纯位移攻击报 yaw≈0 红字是误报；总位移为 0 的攻击片段（转圈只在骨骼）SetRootMotion 也不会转单位。
- 出手姿态维持到主 Buff 结束：`SpellConfig.AttackPoseFollowsBuff`（不在 BuffConfig），施法成功后等主 Buff 的 EntityRef 失效再清 UState.Attack；尾段短于后摇时姿态会先掉。
- 未勾该开关时，UState.Attack 按主 Buff 的 Duration 落下，不跟 01/02 的寿命。00 到期不连带清 01/02（没有 ParentRemoveRemove）。Attack 不锁平移，位移锁只有冲锋和跳跃。循环段要走，不能靠姿态锁放行。短 00 会提前卸攻击层；卸层后的滑步尚未再验证。循环中能移动已由用户确认。
- 不改 Animator.applyRootMotion=false 的全局约定。双手撑地、根在脚底的原地转体，片段 RootT 仍可能晃；勾了根运动后积分的是这份烘焙位移，整只单位跟着飘。噪声在曲线里。技能管线预览用蓝点标出相对第 0 帧的位移，用来在转化前看见这段，不在管线里把曲线清零。
- 动画窗口里的 Root T / Root Q 是空路径曲线。A_Root01 的位移和旋转是另一根骨骼，对不上 RootT。第一次取样时曲线可能还没就绪，空结果不能当成片段没有根曲线，下一帧再读。

# 3. 怎么验证

`Config/RootMotion/{bakerId}_attack.asset` 存在且 Id = hash("{bakerId}_attack")；勾开关后放技能单位有位移。
