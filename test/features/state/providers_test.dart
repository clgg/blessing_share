import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
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
