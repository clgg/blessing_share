import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const greetingCategories = <String>{
    '上午问候',
    '午间问候',
    '下午问候',
    '晚间问候',
  };

  test('四个日常问候分类各映射 10 张可读取的本地图片', () async {
    final items = await LocalBlessingRepository().getByCategory('daily');

    expect(items, hasLength(40));
    expect(items.map((item) => item.id).toSet(), hasLength(40));

    for (final category in greetingCategories) {
      expect(
        items.where((item) => item.tags.contains(category)),
        hasLength(10),
        reason: '$category 应恰好映射 10 张图片',
      );
    }

    for (final item in items) {
      expect(item.tags, hasLength(1));
      expect(greetingCategories, contains(item.tags.single));
      expect(item.thumbnailAsset, startsWith('assets/images/daily/'));
      expect(item.imageAsset, startsWith('assets/images/daily/'));
      expect(
        (await rootBundle.load(item.thumbnailAsset!)).lengthInBytes,
        greaterThan(0),
      );
      expect(
        (await rootBundle.load(item.imageAsset!)).lengthInBytes,
        greaterThan(0),
      );
    }
  });
}
