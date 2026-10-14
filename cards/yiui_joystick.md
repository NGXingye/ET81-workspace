> 最新修改时间：2026-10-14 23:40 UTC+8
> 版本号：1.0.0
> 文档状态：生效
> 读取等级：L1（关键词命中摇杆 / 扇形 / IsDraging 时读取）

# 0. 职责定位

> 速览：主界面左右摇杆固定不跟手，响应区是画布左右下角两个 90° 扇形；扇形把按下/抬起转发给 zFrame 摇杆本体。
> 最大风险：只转发事件不设 fingerId，`IsDraging` 为假，主界面会清 Aiming，瞄准开关抖动。
> 做对的标准：在扇形内按下拖动，移动/瞄准连续稳定；GM 打开后能看到两个绿色扇形。

# 1. 怎么运转

扇形命中组件 `LeftJoystickHitArea`（ModelView）→ `ExecuteEvents.pointerDown/Up` 到 Joystick → `IsDraging = fingerId != MinValue` → `Panel_JoystickComponentSystem` 读摇杆。半径 = 画布高度 × RadiusOverHeight（默认 0.7）；尖角钉在 (-1200,-539) 与 (1202,-542)；约 140 像素拉满 maxRadius。

# 2. 坑和不变量

- 左右摇杆 `IsDynamic=false`；旧的 Panel_Range 绿区与铺满的红区方案已废。
- 尖角不要用 `parent.rect` 推窗口角。
- 不改 MainPanel、WASD 和左右监听：左/WASD 管移动，右管 SetTurnDirection + Aiming；只有左时朝向跟移动。
- 命中组件放 ModelView：Hotfix 不能声明实例字段，静态字段要 `[StaticField]`。
- GM「摇杆扇形范围」只涂色、不改响应，不画 Scene Gizmos。

# 3. 边界

- 门禁：`profiles/yiui_joystick.md`。
- 禁碰：`3party/Comm/Joystick/`（zFrame 本体）、YIUI 插件、`Res/`。

# 4. 怎么验证

右摇杆扇形内离开本体拖动时瞄准不闪断；左右同时操作各司其职。

# 5. 证据

t025、t026。

# 6. 版本历史

- 1.0.0（2026-10-14）：由 profile yiui_joystick 与 yiui_joystick.json 合并提炼。