import 'dart:async';
import 'dart:io';

import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:blessing_share/features/wechat/wechat_share_image_resolver.dart';
import 'package:wechat_open_share/wechat_open_share.dart';

/// [WechatGateway] backed by [WechatOpenShare] (official OpenSDK via MethodChannel).
class OpenShareWechatGateway implements WechatGateway {
  OpenShareWechatGateway({
    WechatOpenShare? client,
    WechatShareImageResolver? imageResolver,
  })  : _client = client ?? WechatOpenShare(),
        _images = imageResolver ?? const WechatShareImageResolver();

  final WechatOpenShare _client;
  final WechatShareImageResolver _images;

  Future<void> ensureRegistered({
    required String appId,
    String? universalLink,
  }) {
    return _client.register(appId: appId, universalLink: universalLink);
  }

  @override
  Future<WechatResult> shareToFriend(BlessingItem item) {
    return _share(item, WechatShareScene.session);
  }

  @override
  Future<WechatResult> shareToTimeline(BlessingItem item) {
    return _share(item, WechatShareScene.timeline);
  }

  Future<WechatResult> _share(BlessingItem item, WechatShareScene scene) async {
    final installed = await _client.isWeChatInstalled();
    if (!installed) {
      return const WechatResult(
        status: WechatStatus.unavailable,
        message: '未安装微信，请先安装微信后再分享',
      );
    }

    final path = await _images.resolveLocalPath(item);
    if (path == null || !File(path).existsSync()) {
      return const WechatResult(
        status: WechatStatus.failed,
        message: '分享图片准备失败，请稍后重试',
      );
    }

    final pending = _waitForShareResponse();
    final accepted = await _client.shareImage(
      imagePath: path,
      scene: scene,
      title: item.title,
      description: item.caption,
    );
    if (!accepted) {
      return const WechatResult(
        status: WechatStatus.failed,
        message: '无法打开微信分享，请检查 AppId / 包名签名是否匹配',
      );
    }

    final response = await pending.timeout(
      const Duration(minutes: 2),
      onTimeout: () => null,
    );
    if (response == null) {
      return WechatResult(
        status: WechatStatus.success,
        message: scene == WechatShareScene.session
            ? '已打开微信，请完成好友分享'
            : '已打开微信，请完成朋友圈分享',
      );
    }
    if (response.isSuccess) {
      return WechatResult(
        status: WechatStatus.success,
        message: scene == WechatShareScene.session
            ? '已分享到微信好友'
            : '已分享到朋友圈',
      );
    }
    if (response.isCancelled) {
      return const WechatResult(
        status: WechatStatus.cancelled,
        message: '已取消分享',
      );
    }
    return WechatResult(
      status: WechatStatus.failed,
      message: response.errStr?.trim().isNotEmpty == true
          ? response.errStr!
          : '分享失败（errCode=${response.errCode}）',
    );
  }

  Future<WechatShareResponse?> _waitForShareResponse() {
    final completer = Completer<WechatShareResponse?>();
    late final StreamSubscription<WechatShareResponse> sub;
    sub = _client.responses.listen((event) {
      if (event.type != 'share') return;
      if (!completer.isCompleted) completer.complete(event);
      unawaited(sub.cancel());
    });
    return completer.future.whenComplete(() => sub.cancel());
  }
}
