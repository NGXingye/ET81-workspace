> 最新修改时间：2026-10-15 10:40 UTC+8
> 版本号：1.1.0
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
- 任务栏：只刷预制体里 Panel_Task01/02/03（怪物/机关/BOSS），total≤0 整行隐藏，可见行 Unfinished 与 Finished 两套字都写。
- 三闸 AND（0 跳过）：PreFloorID、PreStoryRaidID（MaxStoryRaidId ≥ 值）、PreQuestID（任务完成）；客户端 `TowerFloorQuestUnlockHelper` 与服务端 `TowerFloorQuestUnlockServerHelper` 同一套。
- 关键入口：`YIUISystem/ClimbingTower/TowerViewComponentSystem.cs`、`Item_Stage1ComponentSystem.cs`、`TowerWinViewComponentSystem.cs`、`YIUISystem/Main/MainPanelComponentSystem.cs`、`HotfixView/Client/Module/GM/GM_Command_ClimbingTower.cs`。

# 2. 坑和不变量

- 不手改 `*Gen`、不手填 TMP、不运行时建文本节点：UIDataBind 会覆盖。缺字先查反向绑定，不查 FinishState。代码不能替未绑的键自动挂绑定。
- 不在代码里改预制体已调好的 Rect / 对齐（LayoutGroup 会覆盖）；不在组件表里的节点（如 Text_Time）按层级名找，不用 FindComponent。
- 列表自由滑，两端（第 1 层页与末页）卡死，不做松手吸附；楼梯只克隆前景 Image_Bg 跟滑，后景 ImageBg02 静止不克隆。
- 不再 Instantiate ClimbingTowerTaskTracingCell；机关没有配置总数，不新做击杀系统。
- 离开钮是 `Comm_Btn02`（不是 `(1)`）；倒计时 10 秒用 WaitAsync + EntityRef，不跨 await 持有 TimerComponent；YIUIOpen 时重置状态；Hotfix 禁可变 static。
- 奖励 tip 用 Comm_Tip_BaseItem，不改 Common 预制体；CreateTipsWithHandle 会铺全屏 PassThroughMask 吃点击，创建后收根尺寸、关模糊射线、禁用遮罩。
- PlayerData 不是 IHLSData，NotifySyncData 帧末会丢；进度写入走 Pack + M2C_SyncData 直推并 DBSave。新号进主线图会把 MaxStoryRaidId 写成当前 raidId（常为 1）。（GM 进度与三闸未验证）
- GM 页签 `EGMType.ClimbingTower=13`（12 已被机械臂占用）；ServerGM 目录只加爬塔命令。GM 第二次打开同一胜利界面时点道具高亮不稳定（已知未收口）。

# 3. 怎么验证

第一页 1–5、第二页 6–10 有字；翻到第三组只有 Image_Bg 克隆；进关显示 0/b，杀一只 +1，total=0 的行不显示；倒计时归零离开；锁提示分「前置关卡 / 主线推图 / 前置任务」。
