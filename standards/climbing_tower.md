> 最新修改时间：2026-11-04 12:30 UTC+8
> 版本号：1.7.0
> 文档状态：生效
> 读取等级：L1（关键词命中爬塔 / TowerView / 任务栏 / TowerWinView 时读取）

# 0. 速览

> 速览：爬塔的 YIUI 界面（关卡分页、楼梯背景、主界面任务栏、胜利界面）加上客户端与服务端同一套的层解锁三闸和爬塔 GM。
> 最大风险：手改 Gen / 运行时改预制体布局被 YIUI 数据绑定覆盖，以及只改客户端被服务端记账拒绝。
> 做对的标准：第一页右下为第 1 层、两端滑动卡死；任务栏显示「已击杀/总数」；锁提示与服务端判定一致。
>
> 门禁：`profiles/climbing_tower.md`

# 1. 怎么运转

- 关卡列表：`YIUIItemContainer<Item_Stage1>`，一页一个 clone 五槽（Stage01=页内最小层、右下）。组距固定 1080，页 0 锚点 (-741, 1175)，`itemIndex = pageCount-1-i`；ScrollRect 轴向关，跟手改 FloorList.Y。
- 层号显示只走 CDE：代码 SetValue `u_DataLayerNNum / FinishStateN / IsSelectN`，前提是原件已把每个 Text_Title 反向绑到对应键并点生成。
- 任务栏只走 CDE：Panel_Task01/02/03 的击杀、总数、完成、怪物进度条都 SetValue。total≤0 整行隐藏。机关没有配置总数，行保持隐藏。数字只绑 Panel_Unfinished；Panel_Finished 在预制体里保持不勾选。
- 三闸 AND（0 跳过）：PreFloorID（已通关层达到该号）、PreStoryRaidID（最高可抵达 `MaxStoryRaidId` 必须大于该号；清完推图 N 后进度写成 N+1，所以填 N 要等 N 打满）、PreQuestID（任务完成）。主线比较在客户端 `IsStoryPreMet`、服务端 `IsFloorUnlocked` 与 `TryRecordTowerFloorClear`，三处同一口径。任务闸是 `TowerFloorQuestUnlockHelper` 与 `TowerFloorQuestUnlockServerHelper`。
- 当前层击杀分普通怪、Boss 两份存档（`towerKilledMonsterCount` / `towerKilledBossCount`），另存剩余复活和分组击杀。服务端按整图累加并封顶，Pack 直推。人还在塔里关游戏不改当前层，上线仍续这一层。主动离开把层号抄到 `towerProgressFloorId`，再把 `CurrentTowerFloorId` 写成 0，击杀和复活次数不动；再进同一层时恢复层号后清暂存。`EndTowerChallenge` 把暂存清 0。
- 首通额外 RewardKind=2：`GuaranteedDrop == 1` 的行全部发放且不进权重；其余行仍按 Probability 抽一条，权重全 0 退回第一条。Probability 等于 100 没有特殊含义。Kind 1 仍抽一条，Kind 4 仍按配置全发。
- 关卡奖励预览：`Mode == 2` 且配了扫荡则只显示 Kind 4，否则显示 Kind 1 和 2。同一 ItemId 合成一张，数量相加。图标挂组件表 `u_ComRewardList1`–`5`，该引用必须指到本格的 `Panel_Rewards`。
- 正式胜利从 `YIUIMgrComponent.Inst.Root` 打开 ClimbingTowerPanel 再开 TowerWinView，仍发通关协议。GM 预览才设 GmPreviewOpen。
- 主界面爬塔放 `MainPanelComponentSystem.ClimbingTower.cs`，不要再往 `MainPanelComponentSystem.cs` 里叠。`OnEventOpenClimbingTowerAction` 与 `OnEventOutClimbingTowerAction` 留在大文件：生成器只扫这一份，参数名必须是 `self`。
- 爬塔按钮与背包、强化同一规则：当前追踪任务是 `TaskId.ClimbingTower` 且状态已到 `TaskState.ClimbingTowerUnlocked`，或任务号更大，就 SetValue `u_DataShowClimbingTowerBtn`。服务端 `FunctionOpenComponentSystemServer` 用同一阈值 `TryOpen`。主界面 TimeCache 约 10 秒会销毁，显隐不能只记在面板字段上。解锁飞线播放期间先隐藏。
- 胜利界面 `ClimbingTowerPanel.YIUIOpen` 停用左摇杆并 `NotifyMoveStickReleased`，关闭再启用。主界面隐藏只淡 CanvasGroup，停不住已经按住的移动。
- 进图 `Panel_Toastmap` 留在 `MainPanelComponentSystem.RefreshToastMap`。当前层 `ReviveMode` 为无限复活时整段不打开。有限复活才播：播放期间停掉 `u_DataShowClimbingMark` 的显隐绑定，数字写 `TowerFloorConfig.ReviveCount`，播完再启用绑定并置假。
- 关键入口：`YIUISystem/ClimbingTower/ClimbingTowerPanelComponentSystem.cs`、`TowerViewComponentSystem.cs`、`Item_Stage1ComponentSystem.cs`、`TowerWinViewComponentSystem.cs`、`YIUISystem/Main/MainPanelComponentSystem.ClimbingTower.cs`、`MainPanelComponentSystem.cs`、`HotfixView/Client/Module/GM/GM_Command_ClimbingTower.cs`、`Hotfix/Server/Module/FunctionOpen/FunctionOpenComponentSystemServer.cs`。

# 2. 坑和不变量

- 不手改 `*Gen`、不手填 TMP、不运行时建文本节点：UIDataBind 会覆盖。主界面点生成会把技能槽名字覆盖写进预制体；覆盖丢了就不要按节点名另找，退回 `UIPanel_Skill0`–`6`。缺字先查反向绑定，不查 FinishState。代码不能替未绑的键自动挂绑定。
- 不在代码里改预制体已调好的 Rect / 对齐（LayoutGroup 会覆盖）。显隐、数字、进度优先 CDE SetValue，不 Find / FindChildRecursive。缺绑定先在原件补反向绑定再生成。
- 界面逻辑不写裸任务号和状态号，走 `TaskId` / `TaskState` 助手，和背包、强化一样。不在主界面上另记一份会随面板销毁丢掉的点亮标记。
- 列表自由滑，两端（第 1 层页与末页）卡死，不做松手吸附；楼梯只克隆前景 Image_Bg 跟滑，后景 ImageBg02 静止不克隆。
- 不再 Instantiate ClimbingTowerTaskTracingCell；机关没有配置总数，不新做击杀系统。重进后任务条叠行：追踪条还没激活时，文字首选高度仍是预制高度，提前 Rebuild 会直接返回。等加载结束且量到的高度大于当前高度再写；中途变矮不改位置。
- 胜利界面打开后角色还在走：主界面隐藏只淡 CanvasGroup。打开时停用左摇杆并 NotifyMoveStickReleased，关闭再启用。不改 zFrame Joystick。
- 爬塔进图黑色底展开前闪一下：显隐绑定在 Timeline 展开前 SetActive，节点回到预制尺寸。有限复活播放期间停掉 `u_DataShowClimbingMark` 这条绑定，播完再启用并置假。`ReviveMode` 为无限复活时整段 Panel_Toastmap 不打开。
- 离开钮是 `Comm_Btn02`（不是 `(1)`）；倒计时 10 秒用 WaitAsync + EntityRef，不跨 await 持有 TimerComponent；YIUIOpen 时重置状态；Hotfix 禁可变 static。
- 奖励 tip 用 Comm_Tip_BaseItem，不改 Common 预制体；CreateTipsWithHandle 会铺全屏 PassThroughMask 吃点击，创建后收根尺寸、关模糊射线、禁用遮罩。
- PlayerData 不是 IHLSData，NotifySyncData 帧末会丢；进度写入走 Pack + M2C_SyncData 直推并 DBSave。新号进主线图会把 MaxStoryRaidId 写成当前 raidId（常为 1）。前置推图不要用大于等于：刚进推图 N 的 0% 时进度已经是 N，大于等于会早开一关。（GM 改进度未验证）
- GM 页签 `EGMType.ClimbingTower=13`（12 已被机械臂占用）；ServerGM 目录只加爬塔命令。GM 第二次打开同一胜利界面时点道具高亮不稳定（已知未收口）。
- 整数键的字典用 ArrayOfArrays。Document 配整数键会在离开存档时 SerializeKeyString，无法退出。旧的整图击杀字典只用于把已有进度并进普通怪/Boss，不作为现行计数。
- 主动离开不要调用 `EndTowerChallenge`，它会把击杀清掉。暂存层号不要写进旧的 `towerFloorKillCounts`，那份旧数据在当前层为 0 时会把人送回塔里。
- 奖励父节点绑到 `Panel_Reward` 时，隐藏模板会把 ImageBg 关掉，图标挂成它的兄弟。不要按名字再找 `Panel_Rewards`。
- 表里首通额外的 `GuaranteedDrop` 全是 1 时，该层额外全部掉落，不再多选一。想抽一条要把参与抽取的行改成 0。
- 不按配置顺序或刷怪点列表拆怪。那样会把后加载批次里没打过的怪一起拆掉，差几只卡关。重进怪会再刷，计数接着走。
- 清图任务栏认服务端同步的绝对数。死亡后再 +1 会比存档多 1，未满就打开胜利界面。64 位任务击杀掩码装不下整图。（未验证）
- 当前场景上的 YIUIRoot 不挂 Layer3。正式胜利从 `YIUIMgrComponent.Inst.Root` 打开，不设 GmPreviewOpen。淡出主界面先 DOKill 并 SetTarget。（未验证）

# 3. 怎么验证

第一页 1–5、第二页 6–10 有字；翻到第三组只有 Image_Bg 克隆；进关显示 0/b，杀一只任务栏加 1，total=0 的行不显示；倒计时归零离开；锁提示分「前置关卡 / 主线推图 / 前置任务」。前置推图填 N 时，人停在推图 N 的 0% 该层仍锁，N 打满后主线闸通过。未通关层退出再进，普通怪和 Boss 计数续上，怪会再刷；主动离开后再登录停在进塔前的地图，再进同一层击杀还在。Mode 1 预览是通关加首通，同一物品一张；Mode 2 且有扫荡只显示扫荡。杀满后 Layer3 上 ClimbingTowerPanel 与 MainPanel 同级，并完成服务端结算。
