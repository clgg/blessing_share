import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/tts/recording_tts_gateway.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  testWidgets('查看器支持 InteractiveViewer 并可经 AppBar 返回关闭', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => ZoomableImagePage.open(
                context,
                imageAsset: 'assets/images/daily.jpg',
                title: '早安暖心',
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('zoomable-image-page')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.bySemanticsLabel('早安暖心'), findsWidgets);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('zoomable-image-page')), findsNothing);
  });

  testWidgets('详情页点击图片打开查看器，长按仍可朗读', (tester) async {
    final tts = RecordingTtsGateway();
    await tester.pumpWidget(
      BlessingApp(repository: repository, ttsGateway: tts),
    );
    await _pumpUntilFound(tester, find.text('日常问候'));
    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());
    await tester.tap(find.text('早安暖心').hitTestable());
    await _pumpUntilFound(tester, find.byKey(const Key('detail-hero-image')));

    await tester.longPress(find.byKey(const Key('detail-hero-image')));
    await tester.pump();
    expect(tts.spoken, ['早安暖心']);

    await tester.tap(find.byKey(const Key('detail-hero-image')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('zoomable-image-page')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
