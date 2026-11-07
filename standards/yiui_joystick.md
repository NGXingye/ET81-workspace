> 最新修改时间：2026-10-18 17:52 UTC+8
> 版本号：1.2.0
> 文档状态：生效
> 读取等级：L1（关键词命中摇杆 / 扇形 / IsDraging 时读取）

# 0. 速览

> 速览：主界面左右摇杆固定不跟手，响应区是画布左右下角两个 90° 扇形；扇形把按下/抬起转发给 zFrame 摇杆本体。
> 最大风险：只转发事件不设 fingerId，`IsDraging` 为假，主界面会清 Aiming，瞄准开关抖动。
> 做对的标准：在扇形内按下拖动，移动/瞄准连续稳定；GM 打开后能看到两个绿色扇形。
>
> 门禁：`profiles/yiui_joystick.md`

# 1. 怎么运转

扇形命中组件 `LeftJoystickHitArea`（ModelView）→ `ExecuteEvents.pointerDown/Up` 到 Joystick → `IsDraging = fingerId != MinValue` → `Panel_JoystickComponentSystem` 读摇杆。半径 = 画布高度 × RadiusOverHeight（默认 0.7）；尖角钉在 (-1200,-539) 与 (1202,-542)；约 140 像素拉满 maxRadius。

# 2. 坑和不变量

- 左右摇杆 `IsDynamic=false`；旧的 Panel_Range 绿区与铺满的红区方案已废。
- 不改 zFrame 摇杆本体 `Unity/Assets/3party/Comm/Joystick/`，扇形只转发事件。
- 尖角不要用 `parent.rect` 推窗口角。
- 不改 MainPanel、WASD 和左右监听：左/WASD 管移动，右管 SetTurnDirection + Aiming；只有左时朝向跟移动。
- 命中组件放 ModelView：Hotfix 不能声明实例字段，静态字段要 `[StaticField]`。
- GM「摇杆扇形范围」只涂色、不改响应，不画 Scene Gizmos。
- 游戏窗口线条用 `UnlitWireframeLines` 的线段网格，`Graphics.DrawMesh` 到 Game 的 Base 相机。`OnRenderObject` 的 GL 在 URP 的 Game 窗口不显示；不要因为相机有 `targetTexture` 就跳过。
- 选单位用 `GameObjectComponent.Id`，不用 `InstanceId`。颜色和粗细在未播放时由编辑器 GM 写入；单位 Id 和显示开关在运行时 GM，要点执行才生效。
- 身体胶囊读 `PhysicsCharacterComponent` 的当前形状。整体胶囊开关尚未在运行中确认。（未验证）

# 3. 怎么验证

右摇杆扇形内离开本体拖动时瞄准不闪断；左右同时操作各司其职。
