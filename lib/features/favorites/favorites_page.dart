import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_masonry_grid.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({required this.onGoHome, super.key});

  final VoidCallback onGoHome;

  @visibleForTesting
  static const pageSize = 4;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<String, BlessingItem> _itemCache = {};
  List<BlessingItem> _items = const [];
  String _loadedIds = '';
  String? _loadedFilter;
  bool _loading = false;
  bool _loadingMore = false;
  int _visibleCount = FavoritesPage.pageSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final favorites = context.watch<FavoritesProvider>();
    final ids = favorites.visibleIds.join(',');
    final filter = favorites.filterCategoryId;
    if ((ids != _loadedIds || filter != _loadedFilter) && !_loading) {
      _loadedIds = ids;
      _loadedFilter = filter;
      _visibleCount = FavoritesPage.pageSize;
      _loadItems(favorites.visibleIds);
    }
  }

  Future<void> _loadItems(List<String> ids) async {
    _loading = true;
    final repository = context.read<BlessingRepository>();
    for (final id in ids) {
      if (_itemCache.containsKey(id)) continue;
      try {
        _itemCache[id] = await repository.getById(id);
      } catch (_) {
        // A removed local demo item should not block the rest of the collection.
      }
    }
    if (!mounted) return;
    final items = [
      for (final id in ids)
        if (_itemCache[id] case final item?) item,
    ];
    context.read<FavoritesProvider>().registerItems(items);
    setState(() {
      _items = items;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _refresh() async {
    final favorites = context.read<FavoritesProvider>();
    await favorites.load();
    if (!mounted) return;
    // Drop cache so refresh re-reads local demo payloads.
    _itemCache.clear();
    setState(() {
      _visibleCount = FavoritesPage.pageSize;
      _loadingMore = false;
    });
    await _loadItems(favorites.visibleIds);
  }

  Future<void> _loadMore(int totalCount) async {
    if (_loadingMore || _visibleCount >= totalCount) return;
    _loadingMore = true;
    setState(() {});
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _visibleCount = (_visibleCount + FavoritesPage.pageSize) > totalCount
          ? totalCount
          : _visibleCount + FavoritesPage.pageSize;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final categories = context.watch<CatalogProvider>().categories;
    final visibleItems = _items.where((item) {
      return favorites.contains(item.id) &&
          (favorites.filterCategoryId == null ||
              item.categoryId == favorites.filterCategoryId);
    }).toList();
    final pageItems = visibleItems.take(_visibleCount).toList();
    final hasMore = pageItems.length < visibleItems.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Speakable(
              text: '我的收藏',
              child: Text(
                '我的收藏',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('全部收藏'),
                    selected: favorites.filterCategoryId == null,
                    onSelected: (_) => favorites.setFilter(null),
                  ),
                  for (final category in categories) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(category.name),
                      selected: favorites.filterCategoryId == category.id,
                      onSelected: (_) => favorites.setFilter(category.id),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _loading && visibleItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : visibleItems.isEmpty
                      ? AppEmptyState(
                          icon: Icons.favorite_border_rounded,
                          title: favorites.filterCategoryId == null
                              ? '还没有收藏素材'
                              : '这个分类还没有收藏',
                          message: '遇到喜欢的祝福图片，点一下爱心就会留在这里。',
                          actionLabel: '去首页看看',
                          onAction: widget.onGoHome,
                        )
                      : BlessingMasonryGrid(
                          items: pageItems,
                          padding: const EdgeInsets.only(bottom: 28),
                          isFavorite: (_) => true,
                          onFavorite: (item) => _remove(context, item),
                          onRefresh: _refresh,
                          hasMore: hasMore,
                          isLoadingMore: _loadingMore,
                          onLoadMore: () => _loadMore(visibleItems.length),
                          onItemTap: (item) => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DetailPage(itemId: item.id),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(BuildContext context, BlessingItem item) async {
    final favorites = context.read<FavoritesProvider>();
    await favorites.remove(item.id);
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.undo,
      message: '已取消收藏“${item.title}”',
      actionLabel: '撤销',
      onAction: favorites.undoRemove,
    );
  }
}
