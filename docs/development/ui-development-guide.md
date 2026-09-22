# UI 开发规范

面向「祝福分享」App（50 岁以上用户）的界面开发约定。后续页面与组件改动均按本文执行；实现以代码为准，冲突时以 `packages/ui_common` 与 `lib/app/app_theme.dart` 为准并回写本文。

---

## 1. 目标与原则

- **易读易点**：字号偏大、行高充足、主按钮高度 ≥ 56，重要操作有明确文案。
- **风格统一**：颜色、间距、圆角、按钮、Chip、列表行优先走主题与 `AppDimens`，禁止页面内私自发明一套尺寸。
- **防溢出**：窄屏（≥ 360dp）与放大字体（≥ 1.3x）下不出现 `RenderFlex overflow`；长文案必须可截断。
- **少造轮子**：能用共享组件就用共享组件；新增视觉样式先扩主题，再扩页面。

---

## 2. 源码索引（唯一真相）

公用 UI 在 Flutter 包 **`packages/ui_common`**（`import 'package:ui_common/ui_common.dart'`）。

| 职责 | 路径 |
|------|------|
| 间距 / 圆角 / 控件高度 | `packages/ui_common/.../app_dimens.dart` |
| 语义色 `BlessingPalette` / `AppThemeId` | `packages/ui_common/.../blessing_palette.dart` |
| ThemeData 装配（字体等） | [`lib/app/app_theme.dart`](../../lib/app/app_theme.dart) |
| 页面骨架 | `ui_common` → `AppScaffold` |
| 主按钮 | `ui_common` → `PrimaryActionButton` |
| 空态 | `ui_common` → `AppEmptyState` |
| Toast | `ui_common` → `AppToast` |
| 图片 / 缩放查看 | `ui_common` → `BlessingMediaImage` / `ZoomableImagePage` |
| 底栏（业务 Tab） | [`lib/core/widgets/app_bottom_navigation.dart`](../../lib/core/widgets/app_bottom_navigation.dart) |
| 长按朗读 | [`lib/core/widgets/speakable.dart`](../../lib/core/widgets/speakable.dart) |
| 瀑布流 + 加载更多 | [`lib/features/catalog/presentation/widgets/blessing_masonry_grid.dart`](../../lib/features/catalog/presentation/widgets/blessing_masonry_grid.dart) |

颜色取值：`context.blessingColors`（`BlessingPalette`），不要硬编码业务色。

业务专用组件（TTS / 微信图标 / 底栏文案）**不要**放进 `ui_common`。

---

## 3. 尺寸规范（AppDimens）

### 3.1 间距

| Token | 值 | 用途 |
|-------|----|------|
| `spaceXs` | 4 | 标题与副标题极小间隙 |
| `spaceSm` | 8 | Chip 间距、图标与文字 |
| `spaceMd` | 12 | 区块内常见竖向间隔 |
| `spaceLg` | 16 | **页面左右边距** |
| `spaceXl` | 20 | 卡片内边距、区块间隔 |
| `spacePageBottom` | 32 | 列表 / 滚动页底部留白 |

预置边距：

- 推入页 / 普通列表：`AppDimens.pagePadding` → `16, 12, 16, 32`
- Tab 根页（首页 / 收藏 / 我的）：`AppDimens.pagePaddingTab` → `16, 22, 16, 32`

### 3.2 圆角

| Token | 值 | 用途 |
|-------|----|------|
| `radiusSm` | 12 | 缩略图、小块 |
| `radiusMd` | 16 | 图片卡片、Toast |
| `radiusLg` | 20 | **默认卡片**（分类卡、日历卡、我的入口卡） |

容器优先：`AppDimens.radiusLgAll` / `radiusMdAll`。

### 3.3 控件高度

| Token | 值 | 说明 |
|-------|----|------|
| `buttonHeight` | 56 | 主 / 次按钮统一高度 |
| `listTileMinHeight` | 68 | 设置、关于、个人中心列表行 |
| `categoryCardHeight` | 132 | 首页分类卡固定高 |
| `gridEntryHeight` | 148 | 九宫格入口卡固定高 |
| `bottomNavHeight` | 76 | 底部导航 |

### 3.4 图标

| Token | 值 | 用途 |
|-------|----|------|
| `iconSm` | 20 | 辅助小图标 |
| `iconMd` | 28 | 默认操作 / 箭头 |
| `iconLg` | 30 | 强调箭头、入口图标 |

禁止再使用 32 / 34 等随意尺寸，除非写进 `AppDimens` 并更新本文。

---

## 4. 字体与文案层级

默认字体：`NotoSansSC`；大标题衬线：`NotoSerifSC`。

| 样式 | 字号 | 场景 |
|------|------|------|
| `displaySmall` | 32 | Tab 页大标题（平安喜乐 / 收藏 / 我的） |
| `headlineSmall` | 24 | 详情主标题、九宫格入口标题 |
| `titleLarge` | 22 | 分类卡名称、卡片主信息 |
| AppBar `titleTextStyle` | 20 | 推入页导航标题 |
| `bodyLarge` | 17 | 正文、副标题 |
| `bodyMedium` | 16 | 次要说明、加载更多文案 |
| ListTile title | 18 | 设置类列表标题 |
| Chip label | 15 | 筛选 Chip |

规则：

1. 优先 `Theme.of(context).textTheme.xxx`，不要在页面写大量 `fontSize: …`。
2. 需要强调色时用 `copyWith(color: colors.title / primary / …)`。
3. **凡有 `maxLines` 必须同时设 `overflow: TextOverflow.ellipsis`。**

---

## 5. 颜色

通过 `context.blessingColors` 使用语义色，支持主题切换（喜庆红 / 清新绿 / 高贵金）：

| 字段 | 用途 |
|------|------|
| `background` | 页面底 |
| `card` | 卡片底 |
| `primary` / `onPrimary` | 主色按钮 |
| `title` | 标题强调色 |
| `textPrimary` / `textSecondary` | 正文 / 次文 |
| `border` | 描边 |
| `success` / `info` / `danger` / `warning` (+ Container) | Toast / 状态 |

禁止在业务页写死 `#C9252E` 等色值。

---

## 6. 共享组件用法

### 6.1 页面骨架

```dart
return AppScaffold(
  title: '页面标题', // 自动单行省略
  body: ...,
);
```

- Tab 根页可不用 AppBar，用 `displaySmall` 做页内大标题。
- 推入页统一 `AppScaffold`，不要各自拼 `Scaffold` + 透明 AppBar（全屏看图等特例除外）。

### 6.2 按钮

- **主操作**：`PrimaryActionButton`（高度 56、全宽、字号 20）。
- **次操作**：`OutlinedButton` / `OutlinedButton.icon`，走主题（高度 56、胶囊形）；需要全宽时外包：

```dart
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(...),
);
```

- 不要为次按钮再写一套 `minimumSize: Size.fromHeight(56)`（主题已覆盖）。

### 6.3 空态 / Toast / 底栏

- 列表无数据、加载失败：`AppEmptyState`（自带可滚动，防小屏溢出）。
- 反馈：`AppToast.show`；带撤销时操作文案要短。
- 底栏：只用 `AppBottomNavigation`，高度与图标勿改。

### 6.4 筛选 Chip

- 使用 `ChoiceChip`，样式吃 `chipTheme`。
- 横向过多时：`SingleChildScrollView(scrollDirection: Axis.horizontal)`，不要挤进会溢出的 `Row`。
- 「全部」文案与筛选项来自 `BlessingCategory.allFilterLabel` / `filters`，页面不要硬编码分类标签列表。

### 6.5 瀑布流

- 统一 `BlessingMasonryGrid`。
- 「加载更多」挂在**列表内容末尾**，禁止再钉在屏幕底部。
- 触底自动加载 + 文案「上拉加载更多」/「没有更多了」/「正在加载更多」。

### 6.6 无障碍朗读

- 重要标题、卡片说明包一层 `Speakable(text: …, child: …)`。
- 圆角卡片长按涟漪需传 `borderRadius`，与卡片圆角一致。

---

## 7. 布局与防溢出清单

做页面时逐项自检：

1. **固定高度卡片**（分类卡 132、九宫格入口 148）内文字必须 `Flexible` + `ellipsis`，禁止裸 `Column` 堆大字号。
2. **`Row` 内长文本**必须 `Expanded` / `Flexible`，右侧按钮/图标给固定宽度。
3. **AppBar / 详情标题**长文案单行或双行 + `ellipsis`。
4. **空态 / 表单**在矮屏 + 大字号下可滚动（`SingleChildScrollView` 或 `AppEmptyState`）。
5. **窄屏**：至少验证 360dp、390dp；首页已有对应测试可参照。
6. **大字号**：至少验证 `TextScaler.linear(1.3)` 下主按钮与分类卡不溢出（见 `test/core/design_system_test.dart`）。
7. 正交滚动（Chip 横滑 + 列表竖滑）允许；同轴嵌套滚动慎用，`GridView` 嵌在外层滚动时设 `NeverScrollableScrollPhysics` + `shrinkWrap`。

---

## 8. 页面结构约定

| 类型 | 结构 |
|------|------|
| Tab 根页 | `SafeArea` + `pagePaddingTab` + `displaySmall` 标题 + 内容 |
| 推入列表页 | `AppScaffold` + 可选横向 Chip + `BlessingMasonryGrid` / 列表 |
| 详情页 | `AppScaffold` + 大图 + 标题操作行 + 主按钮 + 次按钮 |
| 设置 / 关于 | `AppScaffold` + 圆角卡片包 `ListTile`（`minTileHeight: 68`） |
| 空态页 | `AppEmptyState` 居中，失败带「再试一次」 |

---

## 9. 禁止事项

- 在业务页硬编码主题色、随意 `fontSize` / `BorderRadius.circular(18)` 等游离值。
- 主按钮高度 &lt; 56，或可点区域过小（建议触控边长 ≥ 44）。
- `maxLines` 不配 `overflow`。
- 把「加载更多」做成吸底固定栏。
- 为单个页面复制一套 Chip / ListTile / 按钮样式而不走主题。
- 忽略 50+ 可读性（过小字、过浅对比、过密信息）。

---

## 10. 新增 UI 的流程

1. 能复用现有组件 → 直接复用。  
2. 需要新尺寸 → 先加 `AppDimens`，再引用，并更新本文表格。  
3. 需要新语义色 → 先加 `BlessingPalette` 字段，三套主题一起补齐。  
4. 需要新控件样式 → 优先改 `AppTheme.fromPalette`（`chipTheme` / `outlinedButtonTheme` / `listTileTheme` 等）。  
5. 提交前跑：  
   - `flutter test test/core/design_system_test.dart`  
   - 相关流程测试（如 `catalog_flow_test`、窄屏不溢出用例）  
6. 自测：360dp 宽度 + 系统字体放大一档，扫一眼目标页。

---

## 11. 快速对照（当前约定一览）

```
页边距：     左右 16，底 32；Tab 顶 22，普通顶 12
卡片圆角：   默认 20；媒体卡 / Toast 16
主按钮：     高 56，字 20 加粗，全宽胶囊
次按钮：     高 56，主题 Outlined，需全宽外包 SizedBox
列表行：     最小高 68，标题 18 加粗
筛选 Chip：  字 15，圆角 20，横滑不挤压
加载更多：   列表内容末尾，非吸底
颜色：       只用 context.blessingColors
```

---

## 12. 修订记录

| 日期 | 说明 |
|------|------|
| 2026-09-18 | 初版：对齐 `AppDimens`、主题与共享组件，明确防溢出与开发流程 |
