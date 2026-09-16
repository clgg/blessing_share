import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/category_page.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_category_card.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
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
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('祝福首页', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                '把温暖的问候，送给牵挂的人',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
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
                for (final category in catalog.categories) ...[
                  BlessingCategoryCard(
                    category: category,
                    onTap: () => _openCategory(context, category),
                  ),
                  const SizedBox(height: 14),
                ],
                _GridEntry(onTap: onOpenGrid ?? () {}),
                const SizedBox(height: 28),
                Text('今日推荐', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 14),
                _FeaturedRow(items: catalog.featured),
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
    return SizedBox(
      height: 148,
      child: Material(
        color: AppColors.title,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/grid.jpg', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xCC5B1010), Color(0x335B1010)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '朋友圈九宫格',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '选主题 · 放照片 · 看预览',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 34),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
