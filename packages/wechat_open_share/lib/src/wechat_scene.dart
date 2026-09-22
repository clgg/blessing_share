/// Share destination in WeChat.
enum WechatShareScene {
  /// 微信好友会话
  session,

  /// 朋友圈
  timeline,
}

extension WechatShareSceneX on WechatShareScene {
  String get wireName => switch (this) {
        WechatShareScene.session => 'session',
        WechatShareScene.timeline => 'timeline',
      };
}
