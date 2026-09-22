# 祝福素材分享 — 开发文档

面向工程师的项目总览：产品功能、技术栈、工程结构与扩展方式。UI 细则见同目录 [ui-development-guide.md](./ui-development-guide.md)；网络包见 [network-package.md](./network-package.md)。

---

## 1. 产品定位

- **名称**：祝福素材分享  
- **包名**：`com.clg.blessing_share`  
- **受众**：50 岁以上用户（大字号、易点、长按朗读、少层级）  
- **形态**：Flutter Android 高保真演示；默认**离线**，本地 JSON + 资源图，可完整走通主流程  
- **演示边界**：不真实唤起微信、不写相册、不裁剪合成；相关操作以「演示记录」提示

---

## 2. 功能清单

### 2.1 底部三栏

| Tab | 能力 |
|-----|------|
| 首页 | 分类入口、节日/节气日历、今日推荐、九宫格入口 |
| 收藏 | 已收藏素材列表、分类筛选、分页加载、取消收藏与短时撤销 |
| 我的 | 演示登录、主题、设置、历史记录、帮助/反馈/隐私/关于、检查更新入口 |

冷启动仅构建首页 Tab（`LazyIndexedStack`），收藏 / 我的首次进入再构建。

### 2.2 素材目录（Catalog）

- **四类祝福**：日常问候、生日祝福、节日祝福、节气问候  
- **分类筛选**：服务端/资产下发的 `CategoryFilter`（含「全部 xxx」文案）  
- **分类列表**：瀑布流 + 下拉刷新 + 加载更多（页脚在滚动内容内）  
- **详情**：大图、收藏/点赞、微信好友/朋友圈演示分享、保存演示、点击进缩放查看  
- **日历 Occasion**：两周条 + 节日/节气跳转 Occasion 页，按标签筛素材  
- **今日推荐**：featured 素材（演示数据限制数量）

### 2.3 收藏 / 点赞

- 收藏、点赞状态本地持久化（SharedPreferences）  
- 收藏页筛选、撤销 Toast  
- 「我的点赞」列表与详情跳转

### 2.4 个人中心与活动

- 游客 / 演示登录切换  
- 分享历史、保存记录、九宫格记录（演示），支持勾选删除  
- 主题风格：喜庆红 / 清新绿 / 高贵金  
- 设置：长按朗读开关等无障碍项  
- 使用帮助、意见反馈、隐私与权限、关于我们  
- 应用内更新检查（演示 Gateway）

### 2.5 朋友圈九宫格

- 选主题 → 九格预览（第 5 格为演示中心照片）→ 大字发布引导  
- 固定预览顺序；不写真实相册

### 2.6 无障碍与体验

- 长按朗读（TTS，可开关）  
- 语义标签、大触控区、Toast / 空态统一组件  
- 窄屏（360/390dp）与放大字体布局约束（见 UI 文档与自动化测试）

---

## 3. 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | Flutter（SDK ≥3.4，工程验证常用 3.22.x） |
| 语言 | Dart 3 |
| 状态管理 | Provider（`ChangeNotifier` + 构造注入，无 get_it） |
| 本地存储 | SharedPreferences（`AppStorage` 抽象） |
| 网络（可选） | Dio + Retrofit + json_serializable（`packages/blessing_network`） |
| TTS | flutter_tts（`TtsGateway` 抽象，演示可注入 Recording 实现） |
| UI 设计系统 | `packages/ui_common`（Dimens / Palette / 通用组件） |
| 测试 | flutter_test（流程、布局、边界、Provider） |
| Android | minSdk 23；debug 仅打包 `arm64-v8a` 以减小安装体积 |

---

## 4. 工程结构

```
blessing_share/
├── lib/
│   ├── main.dart                 # 启动：图片缓存策略、Prefs∥目录预热
│   ├── app/                      # Shell、ThemeData 装配、ThemeProvider
│   ├── core/                     # 存储、TTS、异常、业务向 Widget（底栏/朗读/微信图标）
│   └── features/
│       ├── catalog/              # 目录：domain / data / presentation
│       ├── favorites/ likes/ grid/ profile/ update/ wechat/
├── packages/
│   ├── blessing_network/         # 纯 Dart 网络基础设施（DDD）
│   └── ui_common/                # 公用 UI Token + 组件
├── assets/data/blessings.json    # 演示目录数据
├── assets/images/                # 演示图片
├── test/                         # 自动化测试
└── docs/development/             # 本目录：开发与 UI 文档
```

### 4.1 分层约定（Catalog）

```
Presentation (Pages / Providers)
        ↓
Domain (BlessingRepository 接口、实体)
        ↓
Data (LocalBlessingRepository | RemoteBlessingRepository + Mapper)
        ↓
blessing_network（仅 Remote）
```

- 领域实体留在 App，不进入 network 包  
- 默认注入 `LocalBlessingRepository`；远程见 [network-package.md](./network-package.md)

### 4.2 关键 Provider（启动时）

| Provider | 说明 |
|----------|------|
| `CatalogProvider` | 首页分类 + 推荐 |
| `ThemeProvider` | 主题 |
| `FavoritesProvider` / `LikeProvider` / `ActivityProvider` / `SessionProvider` / `AccessibilitySettingsProvider` | 首帧后延后 load |
| `AppUpdateProvider` / `GridProvider` / TTS / Wechat | lazy，按需创建 |

---

## 5. 数据与资源

- **目录数据**：`assets/data/blessings.json`（分类、filters、items、gridThemes）  
- **加载**：本地仓储 isolate 解析 + 内存缓存；启动时 `preload()` 与 Prefs 并行  
- **图片内存**：按布局 × DPR 解码（`BlessingMediaImage` / `AppAssetImage`）；全局缓存约 80 张 / 64MB；缩放页按最大倍率解码保清晰度  

---

## 6. 扩展接入点

| 目标 | 做法 |
|------|------|
| 真实 API | 注入 `RemoteBlessingRepository.fromBaseUrl(...)` |
| 微信 OpenSDK | 实现 `WechatGateway`，替换 `DemoWechatGateway` |
| 应用更新 | 实现 `AppUpdateGateway`，替换 Demo |
| TTS | 实现 / 替换 `TtsGateway` |
| 新主题色 | 扩 `BlessingPalette` 预设 + `AppThemeId`，ThemeData 仍由 App 装配 |

业务页面不直接依赖平台通道或第三方 SDK。

---

## 7. 运行与验证

```bash
flutter pub get
flutter test
flutter run                 # debug，仅 arm64
flutter build apk --debug
```

- 自动化：`test/`  
- 人工：`docs/testing/manual-checklist.md`  
- UI 约定：`docs/development/ui-development-guide.md`

网络包 codegen：

```bash
cd packages/blessing_network
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. 文档索引

| 文档 | 内容 |
|------|------|
| [development-guide.md](./development-guide.md) | 本文：功能 + 技术 |
| [ui-development-guide.md](./ui-development-guide.md) | UI 规范（尺寸、组件、防溢出） |
| [network-package.md](./network-package.md) | 网络 Package / DDD / 切 Remote |
| [../testing/manual-checklist.md](../testing/manual-checklist.md) | 人工验收 |
| [../product/激励视频计划.md](../product/激励视频计划.md) | 产品侧计划（若有） |
