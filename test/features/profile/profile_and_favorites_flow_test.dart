import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/core/tts/recording_tts_gateway.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/favorites/favorites_page.dart';
import 'package:blessing_share/features/likes/likes_page.dart';
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

  testWidgets('收藏页瀑布流支持下拉刷新与分页加载更多', (tester) async {
    final storage = MemoryAppStorage({
      'favorites.v1': {
        'version': 1,
        'ids': <Object?>[
          'daily_1',
          'daily_2',
          'daily_3',
          'daily_4',
          'daily_5',
          'daily_6',
        ],
      },
    });
    await tester.pumpWidget(
      BlessingApp(repository: repository, storage: storage),
    );
    await tester.tap(find.text('收藏'));
    final favoritesPage = find.byType(FavoritesPage);
    Finder favoriteText(String text) =>
        find.descendant(of: favoritesPage, matching: find.text(text));

    await _pumpUntilFound(tester, favoriteText('早安暖心'));
    expect(favoriteText('早安暖心'), findsOneWidget);
    expect(favoriteText('时时顺心'), findsNothing);
    expect(
      find.descendant(
        of: favoritesPage,
        matching: find.byType(RefreshIndicator),
      ),
      findsOneWidget,
    );

    await tester.drag(
      find.descendant(
        of: favoritesPage,
        matching: find.byType(RefreshIndicator),
      ),
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _pumpUntilFound(tester, favoriteText('早安暖心'));

    expect(
      find.descendant(
        of: favoritesPage,
        matching: find.text('上拉加载更多'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('load-more-footer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await _pumpUntilFound(tester, favoriteText('时时顺心'));
    expect(favoriteText('时时顺心'), findsOneWidget);
  });

  testWidgets('我的展示全部主要功能入口', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await tester.tap(find.text('我的'));
    await tester.pump();

    expect(find.byKey(const Key('profile-settings-button')), findsOneWidget);
    for (final label in [
      '我的点赞',
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

  testWidgets('设置页可开关长按朗读', (tester) async {
    final tts = RecordingTtsGateway();
    final storage = MemoryAppStorage();
    await tester.pumpWidget(
      BlessingApp(
        repository: repository,
        storage: storage,
        ttsGateway: tts,
      ),
    );
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile-settings-button')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('设置')),
      findsOneWidget,
    );
    expect(find.text('语音开关控制'), findsOneWidget);

    final toggle = find.byKey(const Key('settings-long-press-speak'));
    final switchTile = tester.widget<SwitchListTile>(toggle);
    expect(switchTile.value, isTrue);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('首页'));
    await _pumpUntilFound(tester, find.text('平安喜乐'));
    await tester.longPress(find.text('平安喜乐'));
    await tester.pump();
    expect(tts.spoken, isEmpty);
  });

  for (final label in [
    '我的点赞',
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

  testWidgets('我的点赞空态可用', (tester) async {
    await tester.pumpWidget(
      BlessingApp(repository: repository, storage: MemoryAppStorage()),
    );
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.tap(find.text('我的点赞'));
    await tester.pumpAndSettle();
    expect(find.byType(LikesPage), findsOneWidget);
    expect(find.text('还没有点赞素材'), findsOneWidget);
  });

  testWidgets('我的点赞展示已赞图片并支持打开详情', (tester) async {
    final storage = MemoryAppStorage({
      'likes.v1': {
        'version': 1,
        'ids': <Object?>['daily_1', 'festival_1'],
      },
    });
    await tester.pumpWidget(
      BlessingApp(repository: repository, storage: storage),
    );
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.tap(find.text('我的点赞'));
    await _pumpUntilFound(
      tester,
      find.descendant(of: find.byType(LikesPage), matching: find.text('早安暖心')),
    );
    expect(
      find.descendant(of: find.byType(LikesPage), matching: find.text('春节纳福')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: find.byType(LikesPage), matching: find.text('早安暖心')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('祝福详情')),
      findsOneWidget,
    );
    expect(find.byTooltip('点赞'), findsNothing);
    expect(find.byTooltip('取消点赞'), findsOneWidget);
  });

  testWidgets('分享历史展示图片标题时间并支持勾选删除', (tester) async {
    final storage = MemoryAppStorage({
      'activity.v1': {
        'version': 1,
        'records': <Object?>[
          {
            'id': 'share-1',
            'itemId': 'daily_1',
            'type': 'share',
            'target': 'friend',
            'createdAt': '2026-09-16T10:00:00.000',
          },
          {
            'id': 'share-2',
            'itemId': 'festival_1',
            'type': 'share',
            'target': 'timeline',
            'createdAt': '2026-09-16T11:00:00.000',
          },
        ],
      },
    });
    await tester.pumpWidget(
      BlessingApp(repository: repository, storage: storage),
    );
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.tap(find.text('分享历史'));
    await tester.pumpAndSettle();

    expect(find.text('早安暖心'), findsOneWidget);
    expect(find.text('春节纳福'), findsOneWidget);
    expect(find.byKey(const ValueKey('share-target-friend')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('share-target-timeline')),
      findsOneWidget,
    );
    // Target is icon-only; keep subtitle to time so delete-mode does not reflow.
    expect(find.text('微信好友'), findsNothing);
    expect(find.text('朋友圈'), findsNothing);
    expect(find.textContaining('2026-09-16'), findsWidgets);
    expect(find.byType(Checkbox), findsNothing);

    await tester.tap(find.text('早安暖心'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('祝福详情')),
      findsOneWidget,
    );
    expect(find.text('发给微信好友'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('删除'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(2));
    expect(find.byTooltip('取消'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('确定删除'), findsOneWidget);

    await tester.tap(find.byTooltip('确定删除'));
    await tester.pumpAndSettle();
    expect(find.text('春节纳福'), findsNothing);
    expect(find.text('早安暖心'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('我的九宫格记录可再次打开预览并修改分享', (tester) async {
    final storage = MemoryAppStorage({
      'activity.v1': {
        'version': 1,
        'records': <Object?>[
          {
            'id': 'grid-1',
            'itemId': 'warm_reunion',
            'type': 'grid',
            'createdAt': '2026-09-16T12:00:00.000',
          },
        ],
      },
    });
    await tester.pumpWidget(
      BlessingApp(repository: repository, storage: storage),
    );
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.tap(find.text('我的九宫格'));
    await tester.pumpAndSettle();

    expect(find.text('温暖团圆'), findsOneWidget);
    await tester.tap(find.text('温暖团圆'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('九宫格预览')),
      findsOneWidget,
    );
    expect(find.text('已选择演示照片'), findsOneWidget);
    expect(find.text('保存九宫格'), findsOneWidget);
  });

  testWidgets('主题风格页可切换到清新绿并立即生效', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('profile-settings-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('主题风格'));
    await tester.pumpAndSettle();

    expect(find.text('喜庆红'), findsOneWidget);
    expect(find.text('清新绿'), findsOneWidget);
    expect(find.text('高贵金'), findsOneWidget);

    await tester.tap(find.text('清新绿'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme!
          .extension<BlessingPalette>()!
          .primary,
      BlessingPalette.freshGreen.primary,
    );
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
