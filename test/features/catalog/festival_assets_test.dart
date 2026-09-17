import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const traditionalFestivals = <String>{
    '春节',
    '元宵节',
    '龙抬头',
    '上巳节',
    '清明节',
    '端午节',
    '七夕节',
    '中元节',
    '中秋节',
    '重阳节',
    '寒衣节',
    '下元节',
    '腊八节',
    '小年',
    '除夕',
  };

  test('15 个传统节日各映射 5 张可读取的 9:16 本地图片', () async {
    final items = await LocalBlessingRepository().getByCategory('festival');
    final traditionalItems = items
        .where((item) => item.tags.any(traditionalFestivals.contains))
        .toList();

    expect(traditionalItems, hasLength(75));
    for (final festival in traditionalFestivals) {
      expect(
        traditionalItems.where((item) => item.tags.contains(festival)),
        hasLength(5),
        reason: '$festival 应恰好映射 5 张图片',
      );
    }

    for (final item in traditionalItems) {
      expect(item.tags, hasLength(1));
      expect(item.aspectRatio, closeTo(9 / 16, 0.0001));
      expect(item.thumbnailAsset, startsWith('assets/images/festivals/'));
      expect(item.imageAsset, startsWith('assets/images/festivals/'));
      expect((await rootBundle.load(item.thumbnailAsset!)).lengthInBytes,
          greaterThan(0));
      expect((await rootBundle.load(item.imageAsset!)).lengthInBytes,
          greaterThan(0));
    }
  });
}
