> 最新修改时间：2026-11-12 14:25 UTC+8
> 版本号：1.1.0
> 文档状态：生效
> 读取等级：L1（关键词命中手部状态机、武器切换、OverrideController 时读取）

# 0. 速览

> 速览：角色主 Animator 只在左右手有没有攻击武器之间切换，一共四套 OverrideController。
> 最大风险：按零件真名各加载一套，或把防御件、别的种族手臂当成攻击武器。
> 做对的标准：泵枪、混乱抛射这类攻击武器落到对应的一套；初始手臂和防御件不单独换套；加载地址保留 `_overridecontroller`。
>
> 门禁：[`profiles/hand_animator.md`](../profiles/hand_animator.md)

# 1. 怎么运转

- 槽：`MainSlot6` 是左手臂，`MainSlot7` 是右手臂。
- 攻击武器：`MainItemTypeHelper.IsAttackWeapon`，类型 0 到 5（线性、喷射、召唤、木桩、近战、抛射）。泵枪是喷射，混乱抛射是抛射。
- 四套地址，后缀都是 `_overridecontroller`：空手只有骨架名；只左手是 `main5_0007` 加 `main6_角色编号`；只右手是 `main5_角色编号` 加 `main6_0007`；双手两侧都是 `0007`。
- 非攻击侧（空槽、本角色手臂、别的种族手臂、防御件）固定写成 `equip_c_main5_` 或 `equip_c_main6_` 加角色编号，不从槽位物体名现拼。
- 加载键是收集登记的定位地址，文件名再加 `_overridecontroller`。加载回来后，控制器自己的名字是不带这段的文件名。
- 入口：`AnimatorCombineComponentSystem.SwitchAnimatorController`。`EquipmentCombineComponentSystem.Main.cs` 的 `AttachEquipment` 在 6/7 槽进字典后等待这次切换。
- 文件：`AnimatorCombineComponentSystem.cs` 管四套地址和写入。`EquipmentCombineComponentSystem.cs` 管主骨架、骨骼缓存、槽位是否可拼。`Main.cs` 管大件装拆和碰撞。`Sub.cs` 管小件。`SummonArmor.cs` 管护甲、召唤器和按类型分发。`Vfx.cs` 管装备特效和元素特效。

# 2. 坑和不变量

- 不恢复按左右手零件真名拼的 `prefix` 加载。那会为每件武器要一个控制器。
- `_overridecontroller` 是收集后的定位地址，加载键保留。资源窗口里的显示名可以不带这段。
- 加载结果为空不算一次完成的切换，不能把已经配对的那次作废。骨架名为空或组件已失效的调用不占新版本。
- 名字校验接受骨架本名、本名后接 `#`、以及 `_overridecontroller`。
- 非攻击侧从槽位物体名拼时，空槽会出双井号。那个地址加载为空，代码不赋值，预制体上的默认控制器就留下。
- 攻击武器判定留在 `AnimatorCombineComponentSystem`。装配文件只负责在 6/7 槽等待切换。

# 3. 怎么验证

- 右手装上泵枪或混乱抛射后，主控制器是带 `equip_c_main6_0007_overridecontroller` 的那套，离开预制体自带的空手控制器。
- 换上别的种族手臂或防御件时，仍只按手上有没有攻击武器在四套里选。
- 卸掉攻击武器后回到骨架名加 `_overridecontroller`。连续换装，结果不随先后颠倒。
