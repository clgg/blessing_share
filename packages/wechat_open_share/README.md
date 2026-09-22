# wechat_open_share

自建 Flutter Plugin：通过 **MethodChannel** 桥接微信官方 OpenSDK，**不依赖** fluwx 等第三方微信插件。

## Dart API

```dart
final wx = WechatOpenShare();

await wx.register(
  appId: 'wx........',
  universalLink: 'https://your.domain/app/', // iOS 必填
);

final installed = await wx.isWeChatInstalled();

await wx.shareImage(
  imagePath: '/path/to/image.jpg',
  scene: WechatShareScene.session, // or timeline
);

await wx.shareText(text: '你好', scene: WechatShareScene.session);

await wx.shareWebpage(
  url: 'https://example.com',
  title: '标题',
  description: '描述',
  scene: WechatShareScene.timeline,
);

wx.responses.listen((r) {
  // r.errCode: 0 成功, -2 取消, -1 失败
});
```

## Channel

| Channel | 用途 |
|---------|------|
| `com.clg.wechat_open_share/methods` | register / isWeChatInstalled / share* |
| `com.clg.wechat_open_share/events` | 微信回调 `WechatShareResponse` |

## Android

- 依赖：`com.tencent.mm.opensdk:wechat-sdk-android`
- 宿主必须提供：`{applicationId}.wxapi.WXEntryActivity`，并调用：

```kotlin
WechatOpenSharePlugin.handleIntent(this, intent)
```

- Plugin 内置 FileProvider：`${applicationId}.wechat_open_share.fileprovider`

## iOS

- Pod：`WechatOpenSDK-XCFramework`
- 宿主配置 Universal Link、`CFBundleURLTypes`、`LSApplicationQueriesSchemes`
- 注册时传入 `universalLink`

## 宿主 App（blessing_share）

```bash
flutter run --dart-define=WECHAT_REAL=true --dart-define=WECHAT_APP_ID=wx6f0df91ed313cf6c
```

默认 `WECHAT_REAL=false`，仍走 `DemoWechatGateway`。
