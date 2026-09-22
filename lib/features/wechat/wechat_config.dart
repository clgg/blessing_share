/// WeChat Open Platform credentials (switch via `--dart-define` per build).
abstract final class WechatConfig {
  /// Temporary: kkhc mobile app id for dev until blessing's own app is approved.
  /// Replace default or pass `--dart-define=WECHAT_APP_ID=wx...`
  static const appId = String.fromEnvironment(
    'WECHAT_APP_ID',
    defaultValue: 'wx6f0df91ed313cf6c',
  );

  /// Required on iOS when calling [registerApi]. Empty until iOS Universal Link is ready.
  static const universalLink = String.fromEnvironment(
    'WECHAT_UNIVERSAL_LINK',
    defaultValue: '',
  );

  /// Set `false` to keep [DemoWechatGateway] without calling OpenSDK.
  static const useRealSdk = bool.fromEnvironment(
    'WECHAT_REAL',
    defaultValue: false,
  );
}
