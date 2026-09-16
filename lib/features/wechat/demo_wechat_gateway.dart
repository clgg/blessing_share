import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';

class DemoWechatGateway implements WechatGateway {
  const DemoWechatGateway();

  @override
  Future<WechatResult> shareToFriend(BlessingItem item) async {
    return WechatResult(
      status: WechatStatus.demo,
      message: '已为“${item.title}”生成微信好友分享演示记录',
    );
  }

  @override
  Future<WechatResult> shareToTimeline(BlessingItem item) async {
    return WechatResult(
      status: WechatStatus.demo,
      message: '已为“${item.title}”生成朋友圈分享演示记录',
    );
  }
}
