import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({required this.onGoHome, super.key});

  final VoidCallback onGoHome;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<BlessingItem> _items = const [];
  String _loadedIds = '';
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ids = context.watch<FavoritesProvider>().visibleIds.join(',');
    if (ids != _loadedIds && !_loading) {
      _loadedIds = ids;
      _loadItems(context.read<FavoritesProvider>().visibleIds);
    }
  }

  Future<void> _loadItems(List<String> ids) async {
    _loading = true;
    final repository = context.read<BlessingRepository>();
    final items = <BlessingItem>[];
    for (final id in ids) {
      try {
        items.add(await repository.getById(id));
      } catch (_) {
        // A removed local demo item should not block the rest of the collection.
      }
    }
    if (!mounted) return;
    context.read<FavoritesProvider>().registerItems(items);
    setState(() {
      _items = items;
      _loading = false;
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('我的收藏', style: Theme.of(context).textTheme.displaySmall),
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
              child: _loading
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
                      : GridView.builder(
                          padding: const EdgeInsets.only(bottom: 28),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: .78,
                          ),
                          itemCount: visibleItems.length,
                          itemBuilder: (context, index) {
                            final item = visibleItems[index];
                            return BlessingImageCard(
                              item: item,
                              favorite: true,
                              onFavorite: () => _remove(context, item),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DetailPage(itemId: item.id),
                                ),
                              ),
                            );
                          },
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
