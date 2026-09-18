import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/tts/recording_tts_gateway.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  testWidgets('长按标题会朗读对应文字', (tester) async {
    final tts = RecordingTtsGateway();
    await tester.pumpWidget(
      BlessingApp(repository: repository, ttsGateway: tts),
    );
    await _pumpUntilFound(tester, find.text('平安喜乐'));

    await tester.longPress(find.text('平安喜乐'));
    await tester.pump();
    expect(tts.spoken, ['平安喜乐']);
  });

  testWidgets('长按分类卡朗读名称与副标题', (tester) async {
    final tts = RecordingTtsGateway();
    await tester.pumpWidget(
      BlessingApp(repository: repository, ttsGateway: tts),
    );
    await _pumpUntilFound(tester, find.text('日常问候'));

    await tester.longPress(find.text('日常问候'));
    await tester.pump();
    expect(tts.spoken.single, contains('日常问候'));
    expect(tts.spoken.single, contains('上午'));
  });

  testWidgets('长按图片卡片朗读标题与说明', (tester) async {
    final tts = RecordingTtsGateway();
    await tester.pumpWidget(
      BlessingApp(repository: repository, ttsGateway: tts),
    );
    await _pumpUntilFound(tester, find.text('日常问候'));
    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());

    await tester.longPress(find.text('早安暖心').hitTestable());
    await tester.pump();
    expect(tts.spoken.single, contains('早安暖心'));
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
