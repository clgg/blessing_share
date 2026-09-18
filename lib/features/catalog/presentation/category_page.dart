import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/category_filter.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_masonry_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    required this.category,
    super.key,
  });

  final BlessingCategory category;

  @visibleForTesting
  static const pageSize = 4;

  /// Unique tags in first-seen order across [items] (fallback when filters empty).
  @visibleForTesting
  static List<String> tagsForItems(Iterable<BlessingItem> items) {
    final seen = <String>{};
    final tags = <String>[];
    for (final item in items) {
      for (final tag in item.tags) {
        if (seen.add(tag)) tags.add(tag);
      }
    }
    return tags;
  }

  /// Filter chips for a category — prefers server/asset [BlessingCategory.filters].
  @visibleForTesting
  static List<CategoryFilter> filtersFor(
    BlessingCategory category,
    Iterable<BlessingItem> items,
  ) {
    if (category.filters.isNotEmpty) return category.filters;
    return [
      for (final tag in tagsForItems(items))
        CategoryFilter(id: tag, label: tag),
    ];
  }

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool _loadingMore = false;
  int _visibleCount = CategoryPage.pageSize;
  String? _selectedFilterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategory(widget.category.id);
    });
  }

  void _selectFilter(String? filterId) {
    if (_selectedFilterId == filterId) return;
    setState(() {
      _selectedFilterId = filterId;
      _visibleCount = CategoryPage.pageSize;
      _loadingMore = false;
    });
  }

  Future<void> _refresh() async {
    await context.read<CatalogProvider>().loadCategory(
          widget.category.id,
          keepExistingItems: true,
        );
    if (!mounted) return;
    setState(() {
      _visibleCount = CategoryPage.pageSize;
      _loadingMore = false;
    });
  }

  Future<void> _loadMore(int totalCount) async {
    if (_loadingMore || _visibleCount >= totalCount) return;
    setState(() => _loadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _visibleCount = (_visibleCount + CategoryPage.pageSize) > totalCount
          ? totalCount
          : _visibleCount + CategoryPage.pageSize;
      _loadingMore = false;
    });
  }

  List<BlessingItem> _filteredItems(List<BlessingItem> allItems) {
    final filterId = _selectedFilterId;
    if (filterId == null) return allItems;
    return allItems.where((item) => item.tags.contains(filterId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final allItems = catalog.categoryItems;
    final filters = CategoryPage.filtersFor(widget.category, allItems);
    final filteredItems = _filteredItems(allItems);
    final pageItems = filteredItems.take(_visibleCount).toList();
    final hasMore = pageItems.length < filteredItems.length;
    final allLabel = widget.category.allFilterLabel;

    return AppScaffold(
      title: widget.category.name,
      body: Builder(
        builder: (context) {
          if (catalog.isLoading && allItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (catalog.error case final error?) {
            return AppEmptyState(
              icon: Icons.image_not_supported_outlined,
              title: '这一组素材没有加载出来',
              message: error.message,
              actionLabel: '再试一次',
              onAction: () => catalog.loadCategory(widget.category.id),
            );
          }
          if (allItems.isEmpty) {
            return const AppEmptyState(
              icon: Icons.image_outlined,
              title: '这一类暂时没有素材',
              message: '稍后再来看看，或者先浏览其他祝福分类。',
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(allLabel),
                        selected: _selectedFilterId == null,
                        onSelected: (_) => _selectFilter(null),
                      ),
                      for (final filter in filters) ...[
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(filter.label),
                          selected: _selectedFilterId == filter.id,
                          onSelected: (_) => _selectFilter(filter.id),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: filteredItems.isEmpty
                    ? AppEmptyState(
                        icon: Icons.filter_alt_outlined,
                        title: '这个标签暂时没有素材',
                        message: '换一个标签试试，或者回到「$allLabel」看看全部内容。',
                      )
                    : BlessingMasonryGrid(
                        items: pageItems,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        onRefresh: _refresh,
                        hasMore: hasMore,
                        isLoadingMore: _loadingMore,
                        onLoadMore: () => _loadMore(filteredItems.length),
                        onItemTap: (item) => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetailPage(itemId: item.id),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
