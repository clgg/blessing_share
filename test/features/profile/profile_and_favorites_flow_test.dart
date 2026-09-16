import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/favorites/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  testWidgets('收藏页按分类筛选并支持取消与撤销', (tester) async {
    final storage = MemoryAppStorage({
      'favorites.v1': {
        'version': 1,
        'ids': <Object?>['daily_1', 'festival_1'],
      },
    });
    await tester.pumpWidget(
      BlessingApp(repository: repository, storage: storage),
    );
    await tester.tap(find.text('收藏'));
    final favoritesPage = find.byType(FavoritesPage);
    Finder favoriteText(String text) =>
        find.descendant(of: favoritesPage, matching: find.text(text));
    await _pumpUntilFound(tester, favoriteText('春节纳福'));

    await tester.tap(find.widgetWithText(ChoiceChip, '日常问候'));
    await _pumpUntilFound(tester, favoriteText('早安暖心'));
    expect(favoriteText('早安暖心'), findsOneWidget);
    expect(favoriteText('春节纳福'), findsNothing);

    await tester.tap(
      find.descendant(
        of: favoritesPage,
        matching: find.byTooltip('取消收藏'),
      ),
    );
    await tester.pump();
    expect(find.text('撤销'), findsOneWidget);
    await tester.tap(find.text('撤销'));
    await _pumpUntilFound(tester, favoriteText('早安暖心'));
    expect(favoriteText('早安暖心'), findsOneWidget);
  });

  testWidgets('我的展示全部主要功能入口', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await tester.tap(find.text('我的'));
    await tester.pump();

    for (final label in [
      '分享历史',
      '保存记录',
      '我的九宫格',
      '使用帮助',
      '意见反馈',
      '隐私与权限',
      '关于我们',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  for (final label in [
    '分享历史',
    '保存记录',
    '我的九宫格',
    '使用帮助',
    '意见反馈',
    '隐私与权限',
    '关于我们',
  ]) {
    testWidgets('“$label”可进入承接页面', (tester) async {
      await tester.pumpWidget(BlessingApp(repository: repository));
      await tester.tap(find.text('我的'));
      await tester.pump();

      final entry = find.text(label);
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(label)),
        findsOneWidget,
      );
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
