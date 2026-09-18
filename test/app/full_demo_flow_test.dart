import 'package:blessing_share/app/app_shell.dart';
import 'package:blessing_share/app/blessing_app.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/favorites/favorites_page.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  testWidgets('完整演示链路可浏览收藏分享查看历史并完成九宫格', (tester) async {
    addTearDown(AppToast.dismiss);
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));

    await tester.tap(find.text('日常问候').hitTestable());
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());
    await tester.tap(find.text('早安暖心').hitTestable());
    await _pumpUntilFound(tester, find.byTooltip('收藏'));

    await tester.ensureVisible(find.byTooltip('收藏'));
    await tester.tap(find.byTooltip('收藏'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('已收藏到本地'), findsOneWidget);

    final share = find.text('发给微信好友');
    await tester.ensureVisible(share);
    await tester.tap(share);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('微信好友分享演示记录'), findsOneWidget);
    final activity = Provider.of<ActivityProvider>(
      tester.element(find.byType(AppShell, skipOffstage: false)),
      listen: false,
    );
    expect(
      activity.records.map((record) => record.type),
      contains(ActivityType.share),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('收藏').last);
    final favoriteItem = find.descendant(
      of: find.byType(FavoritesPage),
      matching: find.text('早安暖心'),
    );
    await _pumpUntilFound(tester, favoriteItem);
    expect(favoriteItem, findsOneWidget);

    await tester.tap(find.text('我的').last);
    await tester.pump();
    final shareHistory = find.text('分享历史');
    await tester.ensureVisible(shareHistory);
    await tester.tap(shareHistory);
    await tester.pumpAndSettle();
    AppToast.dismiss();
    await tester.pump();
    expect(find.text('早安暖心'), findsWidgets);
    expect(find.byKey(const ValueKey('share-target-friend')), findsOneWidget);
    expect(find.byTooltip('删除'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('首页').last);
    await tester.pump();
    final gridEntry = find.text('朋友圈九宫格');
    await tester.ensureVisible(gridEntry);
    await tester.tap(gridEntry);
    await _pumpUntilFound(tester, find.text('温暖团圆').hitTestable());
    await tester.tap(find.text('温暖团圆').hitTestable());
    await _pumpUntilFound(tester, find.text('保存九宫格'));
    final saveGrid = find.text('保存九宫格');
    await tester.ensureVisible(saveGrid);
    await tester.tap(saveGrid);
    await tester.pumpAndSettle();

    expect(find.text('打开微信朋友圈'), findsOneWidget);
    expect(
      activity.records.map((record) => record.type),
      containsAll([ActivityType.share, ActivityType.grid]),
    );
    AppToast.dismiss();
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
