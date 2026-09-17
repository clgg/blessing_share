import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_masonry_grid.dart';
import 'package:blessing_share/features/likes/like_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  final Map<String, BlessingItem> _itemCache = {};
  List<BlessingItem> _items = const [];
  String _loadedIds = '';
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final likes = context.watch<LikeProvider>();
    final ids = likes.likedIds.join(',');
    if (ids != _loadedIds && !_loading) {
      _loadedIds = ids;
      _loadItems(likes.likedIds);
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
    setState(() {
      _items = [
        for (final id in ids)
          if (_itemCache[id] case final item?) item,
      ];
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    final likes = context.read<LikeProvider>();
    await likes.load();
    if (!mounted) return;
    _itemCache.clear();
    await _loadItems(likes.likedIds);
  }

  @override
  Widget build(BuildContext context) {
    final likes = context.watch<LikeProvider>();
    final visibleItems =
        _items.where((item) => likes.contains(item.id)).toList();

    return AppScaffold(
      title: '我的点赞',
      body: _loading && visibleItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : visibleItems.isEmpty
              ? const AppEmptyState(
                  icon: Icons.thumb_up_outlined,
                  title: '还没有点赞素材',
                  message: '在祝福详情点一下赞，喜欢的图片会出现在这里。',
                )
              : BlessingMasonryGrid(
                  items: visibleItems,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  onRefresh: _refresh,
                  onItemTap: (item) => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetailPage(itemId: item.id),
                    ),
                  ),
                ),
    );
  }
}
