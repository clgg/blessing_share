import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/category_page.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_category_card.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/home_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({this.onOpenGrid, super.key});

  final VoidCallback? onOpenGrid;

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: context.read<CatalogProvider>().loadHome,
        child: SingleChildScrollView(
          key: const PageStorageKey('home-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDimens.pagePaddingTab,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Speakable(
                text: '平安喜乐',
                child: Text(
                  '平安喜乐',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 6),
              Speakable(
                text: '把温暖的问候，送给牵挂的人',
                child: Text(
                  '把温暖的问候，送给牵挂的人',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 20),
              if (!catalog.isLoading || catalog.categories.isNotEmpty)
                const HomeCalendarCard(),
              const SizedBox(height: 20),
              if (catalog.isLoading && catalog.categories.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (catalog.error case final error?)
                AppEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: '素材暂时没有加载出来',
                  message: error.message,
                  actionLabel: '重新加载',
                  onAction: catalog.loadHome,
                )
              else ...[
                for (var index = 0;
                    index < catalog.categories.length;
                    index++) ...[
                  BlessingCategoryCard(
                    category: catalog.categories[index],
                    imageOnRight: index.isOdd,
                    onTap: () =>
                        _openCategory(context, catalog.categories[index]),
                  ),
                  const SizedBox(height: 14),
                ],
                _GridEntry(onTap: onOpenGrid ?? () {}),
                const SizedBox(height: 28),
                Speakable(
                  text: '今日推荐',
                  child: Text(
                    '今日推荐',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 14),
                _FeaturedRow(items: catalog.featured.take(2).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, BlessingCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryPage(category: category),
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({required this.items});

  final List<BlessingItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: BlessingImageCard(
              item: items[index],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DetailPage(itemId: items[index].id),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GridEntry extends StatelessWidget {
  const _GridEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    return Speakable(
      text: '朋友圈九宫格，选主题，放照片，看预览',
      child: SizedBox(
        height: AppDimens.gridEntryHeight,
        child: Material(
          color: colors.title,
          borderRadius: AppDimens.radiusLgAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppAssetImage(
                  'assets/images/grid.jpg',
                  fit: BoxFit.cover,
                  semanticLabel: '朋友圈九宫格',
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.overlayStrong, colors.overlaySoft],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimens.spaceXl),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                '朋友圈九宫格',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: colors.onOverlay),
                              ),
                            ),
                            const SizedBox(height: AppDimens.spaceXs + 2),
                            Flexible(
                              child: Text(
                                '选主题 · 放照片 · 看预览',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: colors.onOverlay),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colors.onOverlay,
                        size: AppDimens.iconLg,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
