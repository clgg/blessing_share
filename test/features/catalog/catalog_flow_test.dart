import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/widgets/wechat_share_icons.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/category_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_category_card.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
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

  testWidgets('首页分类卡按左右镜像交错', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));

    final cards = find.byType(BlessingCategoryCard);
    final covers = find.byKey(const Key('category-cover'));
    expect(cards, findsNWidgets(4));
    expect(covers, findsNWidgets(4));

    for (var index = 0; index < 4; index++) {
      final imageIsOnRight = index.isOdd;
      final cardCenter = tester.getCenter(cards.at(index));
      final coverCenter = tester.getCenter(covers.at(index));
      expect(coverCenter.dx > cardCenter.dx, imageIsOnRight);
      expect(
        find.descendant(
          of: cards.at(index),
          matching: find.byIcon(
            imageIsOnRight
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
          ),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('点击分类进入瀑布流列表并可打开详情', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));

    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());
    expect(find.text('早安暖心'), findsWidgets);
    expect(find.text('午安小憩'), findsOneWidget);
    expect(find.text('时时顺心'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(CategoryPage),
        matching: find.byType(RefreshIndicator),
      ),
      findsOneWidget,
    );

    final squareCard = find.ancestor(
      of: find.text('早安暖心').hitTestable(),
      matching: find.byType(BlessingImageCard),
    );
    final portraitCard = find.ancestor(
      of: find.text('日日安康'),
      matching: find.byType(BlessingImageCard),
    );
    expect(
      tester.getSize(squareCard).height,
      lessThan(tester.getSize(portraitCard).height),
    );

    await tester.tap(find.text('早安暖心').hitTestable());
    await _pumpUntilFound(tester, find.text('发给微信好友'));
    expect(find.text('发给微信好友'), findsOneWidget);
    expect(find.text('保存到相册'), findsOneWidget);
    expect(find.byTooltip('点赞'), findsOneWidget);
    expect(find.byTooltip('收藏'), findsOneWidget);
    expect(find.byType(WechatFriendIcon), findsOneWidget);
    expect(find.byType(MomentsIcon), findsOneWidget);

    final likeCenter = tester.getCenter(find.byTooltip('点赞'));
    final favoriteCenter = tester.getCenter(find.byTooltip('收藏'));
    expect(likeCenter.dx, lessThan(favoriteCenter.dx));
  });

  testWidgets('分类列表支持下拉刷新与分页加载更多', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));
    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());

    final categoryPage = find.byType(CategoryPage);
    expect(find.text('时时顺心'), findsNothing);
    expect(
      find.descendant(
        of: categoryPage,
        matching: find.byType(RefreshIndicator),
      ),
      findsOneWidget,
    );

    await tester.drag(
      find.descendant(
        of: categoryPage,
        matching: find.byType(RefreshIndicator),
      ),
      const Offset(0, 300),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());
    expect(find.text('时时顺心'), findsNothing);

    expect(find.text('上拉加载更多'), findsOneWidget);
    await tester.tap(find.byKey(const Key('load-more-footer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await _pumpUntilFound(tester, find.text('时时顺心'));
    expect(find.text('时时顺心'), findsOneWidget);
    expect(find.text('上拉加载更多'), findsOneWidget);
  });

  testWidgets('分类列表上拉手势会加载更多', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));
    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());

    expect(find.text('时时顺心'), findsNothing);
    expect(find.text('上拉加载更多'), findsOneWidget);

    final scrollable = find.byKey(const Key('blessing-masonry-scroll'));
    await tester.fling(scrollable, const Offset(0, -1200), 3000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();
    expect(find.text('时时顺心'), findsOneWidget);
  });

  testWidgets('分类列表展示标签筛选并默认选中全部', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));
    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());

    final categoryPage = find.byType(CategoryPage);
    Finder chip(String label) => find.descendant(
          of: categoryPage,
          matching: find.widgetWithText(ChoiceChip, label),
        );

    expect(chip('全部问候'), findsOneWidget);
    expect(chip('早安问候'), findsOneWidget);
    expect(chip('午间问候'), findsOneWidget);
    expect(chip('晚间问候'), findsOneWidget);
    expect(chip('早安'), findsNothing);

    final allChip = tester.widget<ChoiceChip>(chip('全部问候'));
    expect(allChip.selected, isTrue);

    expect(find.text('早安暖心'), findsWidgets);
    expect(find.text('午安小憩'), findsOneWidget);
  });

  testWidgets('分类标签筛选会过滤列表并重置分页', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('日常问候'));
    await tester.tap(find.text('日常问候'));
    await _pumpUntilFound(tester, find.text('早安暖心').hitTestable());

    final categoryPage = find.byType(CategoryPage);
    Finder chip(String label) => find.descendant(
          of: categoryPage,
          matching: find.widgetWithText(ChoiceChip, label),
        );
    Finder itemText(String text) => find.descendant(
          of: categoryPage,
          matching: find.text(text),
        );

    expect(find.text('上拉加载更多'), findsOneWidget);
    await tester.tap(find.byKey(const Key('load-more-footer')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await _pumpUntilFound(tester, itemText('时时顺心'));
    expect(itemText('时时顺心'), findsOneWidget);

    await tester.tap(chip('早安问候'));
    await tester.pumpAndSettle();

    final morningChip = tester.widget<ChoiceChip>(chip('早安问候'));
    expect(morningChip.selected, isTrue);
    expect(itemText('早安暖心'), findsOneWidget);
    expect(itemText('午安小憩'), findsNothing);
    expect(itemText('时时顺心'), findsNothing);
    expect(find.text('上拉加载更多'), findsNothing);

    await tester.tap(chip('全部问候'));
    await tester.pumpAndSettle();
    expect(itemText('早安暖心'), findsWidgets);
    expect(itemText('午安小憩'), findsOneWidget);
    expect(itemText('时时顺心'), findsNothing);
    expect(find.text('上拉加载更多'), findsOneWidget);
  });

  testWidgets('不同分类使用对应的全部标签文案', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('生日祝福'));
    await tester.ensureVisible(find.text('生日祝福'));
    await tester.tap(find.text('生日祝福'));
    await _pumpUntilFound(tester, find.widgetWithText(ChoiceChip, '全部生日'));

    final categoryPage = find.byType(CategoryPage);
    Finder chip(String label) => find.descendant(
          of: categoryPage,
          matching: find.widgetWithText(ChoiceChip, label),
        );

    expect(chip('全部生日'), findsOneWidget);
    expect(chip('家人'), findsOneWidget);
    expect(chip('朋友'), findsOneWidget);
    expect(chip('长辈'), findsOneWidget);
    expect(chip('群聊、社群成员'), findsOneWidget);
    expect(chip('生日'), findsNothing);

    final chips = tester.widgetList<ChoiceChip>(
      find.descendant(
        of: categoryPage,
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(chips, hasLength(13)); // 全部生日 + 12 关系
  });

  testWidgets('节日祝福使用固定节日筛选列表', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('节日祝福'));
    await tester.ensureVisible(find.text('节日祝福'));
    await tester.tap(find.text('节日祝福'));
    await _pumpUntilFound(tester, find.widgetWithText(ChoiceChip, '全部节日'));

    final categoryPage = find.byType(CategoryPage);
    Finder chip(String label) => find.descendant(
          of: categoryPage,
          matching: find.widgetWithText(ChoiceChip, label),
        );

    expect(chip('全部节日'), findsOneWidget);
    expect(chip('春节'), findsOneWidget);
    expect(chip('端午节'), findsOneWidget);
    expect(chip('国庆节'), findsOneWidget);
    expect(chip('圣诞节'), findsOneWidget);
    expect(chip('团圆'), findsNothing);
    expect(chip('喜庆'), findsNothing);

    final chips = tester.widgetList<ChoiceChip>(
      find.descendant(
        of: categoryPage,
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(chips, hasLength(31)); // 全部节日 + 30 节日

    await tester.ensureVisible(chip('中秋节'));
    await tester.pumpAndSettle();
    await tester.tap(chip('中秋节'));
    await tester.pumpAndSettle();
    expect(find.text('中秋月圆'), findsOneWidget);
    expect(find.text('花好月圆'), findsOneWidget);
    expect(find.text('春节纳福'), findsNothing);
  });

  testWidgets('节气问候使用全部加二十四节气筛选', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.text('节气问候'));
    await tester.ensureVisible(find.text('节气问候'));
    await tester.tap(find.text('节气问候'));
    await _pumpUntilFound(tester, find.widgetWithText(ChoiceChip, '全部'));

    final categoryPage = find.byType(CategoryPage);
    Finder chip(String label) => find.descendant(
          of: categoryPage,
          matching: find.widgetWithText(ChoiceChip, label),
        );

    expect(chip('全部'), findsOneWidget);
    expect(chip('立春'), findsOneWidget);
    expect(chip('秋分'), findsOneWidget);
    expect(chip('大寒'), findsOneWidget);
    expect(chip('夏日'), findsNothing);
    expect(chip('春天'), findsNothing);

    final chips = tester.widgetList<ChoiceChip>(
      find.descendant(
        of: categoryPage,
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(chips, hasLength(25)); // 全部 + 24 节气

    await tester.ensureVisible(chip('秋分'));
    await tester.pumpAndSettle();
    await tester.tap(chip('秋分'));
    await tester.pumpAndSettle();
    expect(find.text('秋分安康'), findsOneWidget);
    expect(find.text('立春安康'), findsNothing);
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
