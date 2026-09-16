# 祝福素材分享 App

基于需求文档和 UI 规范实现的 Flutter Android 高保真框架演示版。应用默认离线运行，使用本地 JSON 与压缩后的演示图片，可完整点击三栏导航、素材浏览、收藏、演示分享/保存历史、个人中心和朋友圈九宫格流程。

## 工程信息

- Android 包名：`com.clg.blessing_share`
- 应用名称：祝福素材分享
- Flutter：3.22.1
- 状态管理：Provider
- 网络预留：Dio
- 本地持久化：SharedPreferences
- 当前验证使用的 Flutter 命令：`/private/tmp/flutter-3.22.1/bin/flutter`

## 运行与构建

```bash
/private/tmp/flutter-3.22.1/bin/flutter pub get
/private/tmp/flutter-3.22.1/bin/flutter test
/private/tmp/flutter-3.22.1/bin/flutter run
/private/tmp/flutter-3.22.1/bin/flutter build apk --debug
```

调试 APK 输出到：

`build/app/outputs/flutter-apk/app-debug.apk`

## 演示范围

- 首页四类祝福素材、今日推荐和九宫格入口
- 分类列表、图片详情、收藏与取消收藏
- 微信好友/朋友圈分享演示记录和保存演示记录
- 收藏筛选与 6 秒撤销
- 游客/演示登录状态、分享历史、保存记录、九宫格记录
- 使用帮助、意见反馈、隐私与权限、关于我们
- 九宫格选主题、中心演示照片、固定顺序预览和大字发布引导
- 360dp / 390dp 布局、1.3 倍字体和关键语义标签自动化检查

当前版本不会真实唤起微信、写入系统相册、裁剪照片或合成九张图片。相关操作会明确显示“演示记录”，避免把框架行为误认为真实外部操作。

## 数据与扩展点

- 本地演示数据：`assets/data/blessings.json`
- 压缩演示图片：`assets/images/`
- 本地 Repository：`lib/features/catalog/data/local_blessing_repository.dart`
- Dio 配置：`lib/core/network/api_client.dart`
- 远程 Repository：`lib/features/catalog/data/remote_blessing_repository.dart`
- 微信接口：`lib/features/wechat/wechat_gateway.dart`
- 当前演示实现：`lib/features/wechat/demo_wechat_gateway.dart`

接入真实服务时，在应用根节点注入 `RemoteBlessingRepository`；接入微信 OpenSDK 时新增实现 `WechatGateway` 的适配器并替换 `DemoWechatGateway`。业务页面无需依赖平台通道或具体 SDK。

## 验收

自动化测试位于 `test/`，人工检查项见 `docs/testing/manual-checklist.md`。
