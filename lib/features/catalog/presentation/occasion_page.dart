import 'package:blessing_share/app/app_theme.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/calendar_occasion.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_masonry_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Dedicated page for a calendar festival / solar-term pick.
/// Not shared with the category browsing page.
class OccasionPage extends StatefulWidget {
  const OccasionPage({
    required this.occasion,
    required this.date,
    super.key,
  });

  final CalendarOccasion occasion;
  final DateTime date;

  @override
  State<OccasionPage> createState() => _OccasionPageState();
}

class _OccasionPageState extends State<OccasionPage> {
  static const _pageSize = 6;
  bool _loadingMore = false;
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadCategory(widget.occasion.categoryId);
    });
  }

  String get _title {
    final kind = widget.occasion.kind == CalendarOccasionKind.festival
        ? '节日'
        : '节气';
    return '${widget.occasion.label}$kind';
  }

  String get _dateLabel {
    final d = widget.date;
    return '${d.year}年${d.month}月${d.day}日';
  }

  List<BlessingItem> _matchedItems(List<BlessingItem> all) {
    final tag = widget.occasion.filterTag;
    final label = widget.occasion.label;
    return all.where((item) {
      if (tag != null && item.tags.contains(tag)) return true;
      if (item.tags.contains(label)) return true;
      if (item.title.contains(label)) return true;
      return false;
    }).toList();
  }

  Future<void> _refresh() async {
    await context.read<CatalogProvider>().loadCategory(
          widget.occasion.categoryId,
          keepExistingItems: true,
        );
    if (!mounted) return;
    setState(() {
      _visibleCount = _pageSize;
      _loadingMore = false;
    });
  }

  Future<void> _loadMore(int total) async {
    if (_loadingMore || _visibleCount >= total) return;
    setState(() => _loadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() {
      _visibleCount =
          (_visibleCount + _pageSize) > total ? total : _visibleCount + _pageSize;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final colors = context.blessingColors;
    final matched = _matchedItems(catalog.categoryItems);
    final pageItems = matched.take(_visibleCount).toList();
    final hasMore = pageItems.length < matched.length;

    return AppScaffold(
      title: _title,
      body: Builder(
        builder: (context) {
          if (catalog.isLoading && catalog.categoryItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (catalog.error case final error?) {
            return AppEmptyState(
              icon: Icons.cloud_off_outlined,
              title: '素材暂时没有加载出来',
              message: error.message,
              actionLabel: '再试一次',
              onAction: () => catalog.loadCategory(widget.occasion.categoryId),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Speakable(
                  text: '${widget.occasion.label}，$_dateLabel',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.occasion.label,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _dateLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: matched.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.image_outlined,
                        title: '这一天暂无对应素材',
                        message: '可以先浏览其他节日或节气，稍后再回来看看。',
                      )
                    : BlessingMasonryGrid(
                        items: pageItems,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        onRefresh: _refresh,
                        hasMore: hasMore,
                        isLoadingMore: _loadingMore,
                        onLoadMore: () => _loadMore(matched.length),
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
