import 'package:flutter/material.dart';

/// Asset paths for WeChat share actions (friend / Moments).
abstract final class WechatShareAssets {
  static const friend = 'assets/images/ic_wechat_share.webp';
  static const moments = 'assets/images/ic_wechat_moments.webp';
}

/// Circular WeChat friend-share mark.
class WechatFriendIcon extends StatelessWidget {
  const WechatFriendIcon({this.size = 24, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _ShareAssetIcon(
      asset: WechatShareAssets.friend,
      size: size,
      semanticLabel: '微信',
    );
  }
}

/// WeChat Moments (朋友圈) camera-aperture mark.
class MomentsIcon extends StatelessWidget {
  const MomentsIcon({this.size = 24, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _ShareAssetIcon(
      asset: WechatShareAssets.moments,
      size: size,
      semanticLabel: '朋友圈',
    );
  }
}

class _ShareAssetIcon extends StatelessWidget {
  const _ShareAssetIcon({
    required this.asset,
    required this.size,
    required this.semanticLabel,
  });

  final String asset;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
    );
  }
}
