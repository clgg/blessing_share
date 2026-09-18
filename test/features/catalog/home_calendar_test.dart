import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/core/tts/recording_tts_gateway.dart';
import 'package:blessing_share/core/tts/tts_gateway.dart';
import 'package:blessing_share/features/catalog/data/calendar_occasion_catalog.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/occasion_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/home_calendar_card.dart';
import 'package:blessing_share/features/profile/accessibility_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  test('两周日历从周一起算共 14 天', () {
    final days = CalendarOccasionCatalog.twoWeekDays(
      now: DateTime(2026, 9, 17), // Thursday
    );
    expect(days, hasLength(14));
    expect(days.first.date, DateTime(2026, 9, 14)); // Monday
    expect(days.last.date, DateTime(2026, 9, 27));
  });

  test('中秋与秋分标注正确', () {
    final midAutumn =
        CalendarOccasionCatalog.occasionsOn(DateTime(2026, 9, 25));
    expect(midAutumn.single.label, '中秋');
    expect(midAutumn.single.categoryId, 'festival');
    expect(midAutumn.single.filterTag, '中秋节');

    final autumnEquinox =
        CalendarOccasionCatalog.occasionsOn(DateTime(2026, 9, 23));
    expect(autumnEquinox.single.label, '秋分');
    expect(autumnEquinox.single.categoryId, 'solar_term');
    expect(autumnEquinox.single.filterTag, '秋分');
  });

  test('二十四节气列表完整', () {
    expect(CalendarOccasionCatalog.solarTerms, hasLength(24));
    expect(CalendarOccasionCatalog.solarTerms.first, '立春');
    expect(CalendarOccasionCatalog.solarTerms.last, '大寒');
  });

  test('分类筛选配置由数据源下发', () async {
    final categories = await repository.getCategories();
    final byId = {for (final c in categories) c.id: c};

    expect(byId['daily']!.allFilterLabel, '全部问候');
    expect(
      byId['daily']!.filters.map((f) => f.id).toList(),
      ['上午问候', '午间问候', '下午问候', '晚间问候'],
    );

    expect(byId['birthday']!.allFilterLabel, '全部生日');
    expect(byId['birthday']!.filters, hasLength(12));
    expect(byId['birthday']!.filters.first.id, '家人');
    expect(byId['birthday']!.filters.last.id, '群聊、社群成员');

    expect(byId['festival']!.allFilterLabel, '全部节日');
    expect(byId['festival']!.filters, hasLength(30));
    expect(byId['festival']!.filters.first.id, '春节');
    expect(byId['festival']!.filters.last.id, '圣诞节');
    expect(
      byId['festival']!.filters.map((f) => f.id),
      containsAll(['中秋节', '国庆节']),
    );

    expect(byId['solar_term']!.allFilterLabel, '全部');
    expect(byId['solar_term']!.filters, hasLength(24));
    expect(byId['solar_term']!.filters.first.id, '立春');
    expect(byId['solar_term']!.filters.last.id, '大寒');
  });

  testWidgets('首页包含节日节气日历卡', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _pumpUntilFound(tester, find.byType(HomeCalendarCard));
    final now = DateTime.now();
    expect(find.text('${now.year}年${now.month}月'), findsOneWidget);
  });

  testWidgets('日历标注日进入独立节庆页并筛选素材', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final storage = MemoryAppStorage();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TtsGateway>(create: (_) => RecordingTtsGateway()),
          ChangeNotifierProvider(
            create: (_) => CatalogProvider(repository: repository),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                AccessibilitySettingsProvider(storage: storage)..load(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.of(AppThemeId.festiveRed),
          home: Scaffold(
            body: HomeCalendarCard(
              now: DateTime(2026, 9, 21),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('中秋'), findsOneWidget);
    await tester.tap(find.text('中秋'));
    await tester.pumpAndSettle();

    expect(find.byType(OccasionPage), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('中秋节日'),
      ),
      findsOneWidget,
    );
    expect(find.text('2026年9月25日'), findsOneWidget);
    expect(find.textContaining('已为您筛选'), findsNothing);
    expect(find.textContaining('节日祝福'), findsNothing);
    await _pumpUntilFound(tester, find.text('中秋月圆'));
    expect(find.text('中秋月圆'), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
