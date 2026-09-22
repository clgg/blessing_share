import 'package:flutter_test/flutter_test.dart';
import 'package:wechat_open_share/wechat_open_share.dart';

void main() {
  test('WechatShareResponse parses native map', () {
    final r = WechatShareResponse.fromMap({
      'type': 'share',
      'errCode': 0,
      'errStr': null,
    });
    expect(r.isSuccess, isTrue);
    expect(r.type, 'share');
  });

  test('WechatShareScene wire names', () {
    expect(WechatShareScene.session.wireName, 'session');
    expect(WechatShareScene.timeline.wireName, 'timeline');
  });
}
