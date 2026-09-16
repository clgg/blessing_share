import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  testWidgets('首页展示四个分类九宫格和今日推荐', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));

    expect(find.text('日常问候'), findsOneWidget);
    expect(find.text('生日祝福'), findsOneWidget);
    expect(find.text('节日祝福'), findsOneWidget);
    expect(find.text('节气问候'), findsOneWidget);
    expect(find.text('朋友圈九宫格'), findsOneWidget);
    expect(find.text('今日推荐'), findsOneWidget);
  });

  testWidgets('点击分类和推荐素材可进入详情', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));

    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());
    expect(find.text('早安暖心'), findsWidgets);

    await tester.tap(find.text('早安暖心').hitTestable());
    await _pumpUntilFound(tester, find.text('发给微信好友'));
    expect(find.text('发给微信好友'), findsOneWidget);
    expect(find.text('保存到相册'), findsOneWidget);
  });

  for (final size in [const Size(360, 800), const Size(390, 844)]) {
    testWidgets('${size.width.toInt()}dp 首页不溢出', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(BlessingApp(repository: repository));
      await _pumpUntilFound(tester, find.text('今日推荐'));
      expect(find.text('今日推荐'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
