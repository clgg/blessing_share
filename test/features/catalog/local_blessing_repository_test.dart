import 'dart:convert';
import 'dart:typed_data';

import 'package:blessing_share/core/network/app_exception.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalBlessingRepository', () {
    test('读取四个分类并按 sortOrder 排序', () async {
      final repository = LocalBlessingRepository(
        bundle: _StringAssetBundle(_validFixture),
      );

      final categories = await repository.getCategories();

      expect(categories.map((category) => category.id), [
        'daily',
        'birthday',
        'festival',
        'solar_term',
      ]);
    });

    test('按分类返回素材且推荐列表只包含 featured 素材', () async {
      final repository = LocalBlessingRepository(
        bundle: _StringAssetBundle(_validFixture),
      );

      expect((await repository.getByCategory('daily')).length, 2);
      expect(
        (await repository.getFeatured()).map((item) => item.id),
        ['daily_1', 'festival_1'],
      );
    });

    test('按 ID 返回详情且未知 ID 抛出未找到异常', () async {
      final repository = LocalBlessingRepository(
        bundle: _StringAssetBundle(_validFixture),
      );

      expect((await repository.getById('daily_1')).title, '早安暖心');
      expect(
        repository.getById('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('损坏 JSON 抛出可识别的数据异常', () async {
      final repository = LocalBlessingRepository(
        bundle: _StringAssetBundle('{broken'),
      );

      expect(
        repository.getCategories(),
        throwsA(isA<DataFormatException>()),
      );
    });

    test('九宫格主题必须映射八张外围图片', () async {
      final repository = LocalBlessingRepository(
        bundle: _StringAssetBundle(_validFixture),
      );

      final themes = await repository.getGridThemes();

      expect(themes, hasLength(1));
      expect(themes.single.previewAssets, hasLength(8));
    });
  });
}

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.source);

  final String source;

  @override
  Future<ByteData> load(String key) {
    final bytes = utf8.encode(source);
    return Future.value(
      ByteData.sublistView(Uint8List.fromList(bytes)),
    );
  }
}

const _validFixture = '''
{
  "categories": [
    {"id":"festival","name":"节日祝福","subtitle":"春节 中秋 端午","coverAsset":"assets/images/festival.jpg","sortOrder":3},
    {"id":"daily","name":"日常问候","subtitle":"早安 午安 晚安","coverAsset":"assets/images/daily.jpg","sortOrder":1},
    {"id":"solar_term","name":"节气问候","subtitle":"二十四节气","coverAsset":"assets/images/solar_term.jpg","sortOrder":4},
    {"id":"birthday","name":"生日祝福","subtitle":"家人 朋友 长辈","coverAsset":"assets/images/birthday.jpg","sortOrder":2}
  ],
  "items": [
    {"id":"daily_1","title":"早安暖心","caption":"新的一天，平安顺遂","categoryId":"daily","thumbnailAsset":"assets/images/daily.jpg","imageAsset":"assets/images/daily.jpg","tags":["早安"],"featured":true},
    {"id":"daily_2","title":"日日安康","caption":"愿健康常伴左右","categoryId":"daily","thumbnailAsset":"assets/images/daily.jpg","imageAsset":"assets/images/daily.jpg","tags":["健康"],"featured":false},
    {"id":"festival_1","title":"春节纳福","caption":"愿新岁吉祥如意","categoryId":"festival","thumbnailAsset":"assets/images/festival.jpg","imageAsset":"assets/images/festival.jpg","tags":["春节"],"featured":true}
  ],
  "gridThemes": [
    {"id":"warm_reunion","name":"温暖团圆","previewAssets":["assets/images/grid.jpg","assets/images/festival.jpg","assets/images/daily.jpg","assets/images/solar_term.jpg","assets/images/birthday.jpg","assets/images/grid.jpg","assets/images/festival.jpg","assets/images/daily.jpg"],"centerPlaceholderAsset":"assets/images/placeholder_person.jpg"}
  ]
}
''';
