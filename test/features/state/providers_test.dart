import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/theme_provider.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
import 'package:blessing_share/features/likes/like_provider.dart';
import 'package:blessing_share/features/profile/accessibility_settings_provider.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:blessing_share/features/profile/session_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('收藏支持添加取消筛选和撤销且每次变更持久化', () async {
    final storage = MemoryAppStorage();
    final provider = FavoritesProvider(storage: storage);
    await provider.load();

    await provider.toggle(dailyItem);
    await provider.toggle(festivalItem);
    expect(provider.contains(dailyItem.id), isTrue);

    provider.setFilter('daily');
    expect(provider.visibleIds, [dailyItem.id]);

    await provider.remove(dailyItem.id);
    expect(provider.contains(dailyItem.id), isFalse);
    await provider.undoRemove();
    expect(provider.visibleIds, [dailyItem.id]);
    expect(storage.writeCount, 4);
  });

  test('点赞支持添加取消并持久化', () async {
    final storage = MemoryAppStorage();
    final provider = LikeProvider(storage: storage);
    await provider.load();

    await provider.toggle(dailyItem);
    expect(provider.contains(dailyItem.id), isTrue);
    expect(provider.likedIds, [dailyItem.id]);
    expect(storage.writeCount, 1);

    await provider.toggle(festivalItem);
    expect(provider.likedIds, containsAll([dailyItem.id, festivalItem.id]));

    await provider.toggle(dailyItem);
    expect(provider.contains(dailyItem.id), isFalse);
    expect(provider.likedIds, [festivalItem.id]);

    final restored = LikeProvider(storage: storage);
    await restored.load();
    expect(restored.contains(festivalItem.id), isTrue);
    expect(restored.contains(dailyItem.id), isFalse);
  });

  test('保存分享与九宫格历史按最新时间在前', () async {
    var now = DateTime(2026, 9, 16, 10);
    final provider = ActivityProvider(
      storage: MemoryAppStorage(),
      clock: () => now,
    );
    await provider.load();

    await provider.recordSave(dailyItem.id);
    now = now.add(const Duration(minutes: 1));
    await provider.recordShare(dailyItem.id, ShareTarget.friend);
    now = now.add(const Duration(minutes: 1));
    await provider.recordGrid('warm_reunion');

    expect(provider.records.map((record) => record.type), [
      ActivityType.grid,
      ActivityType.share,
      ActivityType.save,
    ]);
  });

  test('活动记录支持按 id 批量删除并持久化', () async {
    var now = DateTime(2026, 9, 16, 11);
    final storage = MemoryAppStorage();
    final provider = ActivityProvider(
      storage: storage,
      clock: () => now,
    );
    await provider.load();

    await provider.recordSave(dailyItem.id);
    now = now.add(const Duration(minutes: 1));
    await provider.recordSave(festivalItem.id);
    now = now.add(const Duration(minutes: 1));
    await provider.recordShare(dailyItem.id, ShareTarget.timeline);

    final removable = provider.records
        .where((record) => record.type == ActivityType.save)
        .map((record) => record.id)
        .toList();
    await provider.deleteByIds(removable);

    expect(provider.records, hasLength(1));
    expect(provider.records.single.type, ActivityType.share);

    final restored = ActivityProvider(storage: storage);
    await restored.load();
    expect(restored.records, hasLength(1));
    expect(restored.records.single.type, ActivityType.share);
  });

  test('演示登录可在游客和已登录状态间切换并恢复', () async {
    final storage = MemoryAppStorage();
    final provider = SessionProvider(storage: storage);
    await provider.load();

    await provider.toggleDemoLogin();
    expect(provider.isLoggedIn, isTrue);

    final restored = SessionProvider(storage: storage);
    await restored.load();
    expect(restored.isLoggedIn, isTrue);

    await restored.toggleDemoLogin();
    expect(restored.isLoggedIn, isFalse);
  });

  test('主题切换可持久化并提供三套调色板', () async {
    final storage = MemoryAppStorage();
    final provider = ThemeProvider(storage: storage);
    await provider.load();
    expect(provider.themeId, AppThemeId.festiveRed);
    expect(provider.palette.primary, BlessingPalette.festiveRed.primary);

    await provider.setTheme(AppThemeId.freshGreen);
    expect(provider.themeId, AppThemeId.freshGreen);
    expect(provider.palette.primary, BlessingPalette.freshGreen.primary);

    final restored = ThemeProvider(storage: storage);
    await restored.load();
    expect(restored.themeId, AppThemeId.freshGreen);

    await restored.setTheme(AppThemeId.nobleGold);
    expect(restored.palette.primary, BlessingPalette.nobleGold.primary);
  });

  test('长按朗读开关默认开启且可持久化', () async {
    final storage = MemoryAppStorage();
    final provider = AccessibilitySettingsProvider(storage: storage);
    await provider.load();
    expect(provider.longPressSpeakEnabled, isTrue);

    await provider.setLongPressSpeakEnabled(false);
    expect(provider.longPressSpeakEnabled, isFalse);

    final restored = AccessibilitySettingsProvider(storage: storage);
    await restored.load();
    expect(restored.longPressSpeakEnabled, isFalse);
  });

  test('九宫格必须先选择主题才能完成并记录照片选择', () async {
    final provider = GridProvider();

    expect(() => provider.complete(), throwsStateError);
    provider.selectTheme(gridTheme);
    provider.selectDemoPhoto();
    provider.complete();

    expect(provider.selectedTheme?.id, 'warm_reunion');
    expect(provider.hasDemoPhoto, isTrue);
    expect(provider.isComplete, isTrue);
  });
}

class MemoryAppStorage implements AppStorage {
  final Map<String, Map<String, Object?>> values = {};
  int writeCount = 0;

  @override
  Future<Map<String, Object?>> readJson(String key) async {
    return Map<String, Object?>.from(values[key] ?? {'version': 1});
  }

  @override
  Future<void> writeJson(String key, Map<String, Object?> value) async {
    writeCount++;
    values[key] = Map<String, Object?>.from(value);
  }
}

const dailyItem = BlessingItem(
  id: 'daily_1',
  title: '早安暖心',
  caption: '新的一天，平安顺遂',
  categoryId: 'daily',
  thumbnailAsset: 'assets/images/daily.jpg',
  imageAsset: 'assets/images/daily.jpg',
  tags: ['早安'],
  featured: true,
  aspectRatio: 1,
);

const festivalItem = BlessingItem(
  id: 'festival_1',
  title: '春节纳福',
  caption: '新岁吉祥',
  categoryId: 'festival',
  thumbnailAsset: 'assets/images/festival.jpg',
  imageAsset: 'assets/images/festival.jpg',
  tags: ['春节'],
  featured: true,
  aspectRatio: 1,
);

const gridTheme = GridTheme(
  id: 'warm_reunion',
  name: '温暖团圆',
  previewAssets: [
    '1',
    '2',
    '3',
    '4',
    '6',
    '7',
    '8',
    '9',
  ],
  centerPlaceholderAsset: 'center',
);
