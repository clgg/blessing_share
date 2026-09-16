import 'package:blessing_share/features/catalog/domain/blessing_item.dart';

enum WechatStatus { success, demo, unavailable, cancelled, failed }

class WechatResult {
  const WechatResult({required this.status, required this.message});

  final WechatStatus status;
  final String message;
}

abstract interface class WechatGateway {
  Future<WechatResult> shareToFriend(BlessingItem item);

  Future<WechatResult> shareToTimeline(BlessingItem item);
}
