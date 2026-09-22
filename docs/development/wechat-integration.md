# 微信分享接入方案

面向 **Flutter 双端（Android + iOS）**，使用自建插件 [`packages/wechat_open_share`](../../packages/wechat_open_share) 桥接**微信官方 OpenSDK**（不用 fluwx）。

---

## 1. 方案

```
DetailPage → WechatGateway
               ├─ DemoWechatGateway          (默认 / 测试)
               └─ OpenShareWechatGateway     (WECHAT_REAL=true)
                        ↓
                 WechatOpenShare (Dart)
                        ↓ MethodChannel
         Android OpenSDK          iOS OpenSDK
```

插件提供：

- `register(appId, universalLink?)`
- `isWeChatInstalled()`
- `shareImage` / `shareText` / `shareWebpage`
- `responses` 流（分享结果 errCode）

---

## 2. 启用真分享

```bash
flutter run \
  --dart-define=WECHAT_REAL=true \
  --dart-define=WECHAT_APP_ID=wx6f0df91ed313cf6c
```

自有 AppId 通过后：

```bash
flutter run \
  --dart-define=WECHAT_REAL=true \
  --dart-define=WECHAT_APP_ID=wx你的AppId \
  --dart-define=WECHAT_UNIVERSAL_LINK=https://你的域名/...
```

配置见 `lib/features/wechat/wechat_config.dart`。

### 开放平台注意

临时使用 kkhc 的 `wx6f0df91ed313cf6c` 时，开放平台绑定的包名/签名必须是当前工程的 `com.clg.blessing_share` + 对应签名，否则 `sendReq` 会失败。

---

## 3. Android 宿主已配置

- `WXEntryActivity` → `WechatOpenSharePlugin.handleIntent`
- Manifest `queries` 含 `com.tencent.mm`
- Plugin 内 FileProvider（大图路径分享）

---

## 4. iOS（工程就绪后）

1. `pod install`（插件依赖 `WechatOpenSDK-XCFramework`）
2. Universal Link + Associated Domains
3. `Info.plist`：URL Scheme = AppId；`LSApplicationQueriesSchemes` 含 weixin/wechat
4. `register` 传入同一 Universal Link

---

## 5. 与 kkhc 的关系

分享实现参考 kkhc `WxShareUtil`（路径 + FileProvider + 缩略图 32KB），但不依赖 kkhc-android 壳；独立插件可复用到其他 Flutter 工程。
