import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('素材卡优先使用服务端缩略图 URL', (tester) async {
    const item = BlessingItem(
      id: 'remote_1',
      title: '远程节日素材',
      caption: '祝福语',
      categoryId: 'festival',
      thumbnailUrl: 'https://cdn.example.test/thumb.webp',
      imageUrl: 'https://cdn.example.test/full.webp',
      tags: ['春节'],
      featured: false,
      aspectRatio: 0.5625,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 360,
            child: BlessingImageCard(item: item, onTap: () {}),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('blessing-media-image')),
    );
    expect(image.image, isA<NetworkImage>());
  });

  testWidgets('本地素材卡继续使用 AssetImage', (tester) async {
    const item = BlessingItem(
      id: 'local_1',
      title: '本地节日素材',
      caption: '祝福语',
      categoryId: 'festival',
      thumbnailAsset: 'assets/images/festival.jpg',
      imageAsset: 'assets/images/festival.jpg',
      tags: ['春节'],
      featured: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 360,
            child: BlessingImageCard(item: item, onTap: () {}),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(
      find.byKey(const Key('blessing-media-image')),
    );
    expect(image.image, isA<AssetImage>());
  });
}
