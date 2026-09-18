import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_image_card.dart';
import 'package:flutter/material.dart';

/// Two-column waterfall list driven by each item's [BlessingItem.aspectRatio].
class BlessingMasonryGrid extends StatefulWidget {
  const BlessingMasonryGrid({
    required this.items,
    required this.onItemTap,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 32),
    this.crossAxisSpacing = 14,
    this.mainAxisSpacing = 14,
    this.isFavorite,
    this.onFavorite,
    this.onRefresh,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.loadMoreExtent = 160,
    super.key,
  });

  final List<BlessingItem> items;
  final ValueChanged<BlessingItem> onItemTap;
  final EdgeInsetsGeometry padding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final bool Function(BlessingItem item)? isFavorite;
  final ValueChanged<BlessingItem>? onFavorite;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final double loadMoreExtent;

  /// Greedy balance: place each next card into the shorter column.
  @visibleForTesting
  static List<List<BlessingItem>> splitIntoColumns(
    List<BlessingItem> items,
    double columnWidth,
  ) {
    const titleBlockHeight = 41.25;
    final columns = <List<BlessingItem>>[[], []];
    final heights = <double>[0, 0];

    for (final item in items) {
      final target = heights[0] <= heights[1] ? 0 : 1;
      columns[target].add(item);
      heights[target] +=
          columnWidth / item.aspectRatio + titleBlockHeight + 14;
    }
    return columns;
  }

  @override
  State<BlessingMasonryGrid> createState() => _BlessingMasonryGridState();
}

class _BlessingMasonryGridState extends State<BlessingMasonryGrid> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() => _requestMoreIfNeeded();

  void _requestMoreIfNeeded({bool fromOverscroll = false}) {
    if (widget.onLoadMore == null ||
        !widget.hasMore ||
        widget.isLoadingMore) {
      return;
    }
    if (!_controller.hasClients) return;
    final position = _controller.position;
    if (!position.hasContentDimensions) return;

    // Content fits the viewport: only load when the user pulls past the bottom.
    if (position.maxScrollExtent <= 0) {
      if (fromOverscroll) widget.onLoadMore!();
      return;
    }

    if (fromOverscroll) {
      widget.onLoadMore!();
      return;
    }

    final nearBottom =
        position.pixels >= position.maxScrollExtent - widget.loadMoreExtent;
    if (!nearBottom) return;
    widget.onLoadMore!();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    // Short lists / rubber-band: user pulls up past the bottom edge.
    if (notification is OverscrollNotification) {
      final pullingUpAtBottom =
          notification.metrics.extentAfter <= 0 && notification.overscroll > 0;
      if (pullingUpAtBottom) {
        _requestMoreIfNeeded(fromOverscroll: true);
      }
      return false;
    }

    if (notification is ScrollEndNotification) {
      _requestMoreIfNeeded();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding = widget.padding.resolve(TextDirection.ltr);
        final columnWidth =
            (constraints.maxWidth -
                resolvedPadding.left -
                resolvedPadding.right -
                widget.crossAxisSpacing) /
            2;
        final columns = BlessingMasonryGrid.splitIntoColumns(
          widget.items,
          columnWidth,
        );
        final showFooter =
            widget.items.isNotEmpty && widget.onLoadMore != null;

        Widget list = NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: SingleChildScrollView(
            key: const Key('blessing-masonry-scroll'),
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: resolvedPadding,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var columnIndex = 0;
                        columnIndex < columns.length;
                        columnIndex++) ...[
                      if (columnIndex > 0)
                        SizedBox(width: widget.crossAxisSpacing),
                      Expanded(
                        child: Column(
                          children: [
                            for (var itemIndex = 0;
                                itemIndex < columns[columnIndex].length;
                                itemIndex++) ...[
                              if (itemIndex > 0)
                                SizedBox(height: widget.mainAxisSpacing),
                              BlessingImageCard(
                                item: columns[columnIndex][itemIndex],
                                favorite: widget.isFavorite?.call(
                                      columns[columnIndex][itemIndex],
                                    ) ??
                                    false,
                                onFavorite: widget.onFavorite == null
                                    ? null
                                    : () => widget.onFavorite!(
                                          columns[columnIndex][itemIndex],
                                        ),
                                onTap: () => widget.onItemTap(
                                  columns[columnIndex][itemIndex],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (showFooter) ...[
                  const SizedBox(height: 8),
                  _LoadMoreFooter(
                    hasMore: widget.hasMore,
                    isLoadingMore: widget.isLoadingMore,
                    onRequestMore: widget.hasMore && !widget.isLoadingMore
                        ? widget.onLoadMore
                        : null,
                  ),
                ],
              ],
            ),
          ),
        );

        if (widget.onRefresh != null) {
          list = RefreshIndicator(
            onRefresh: widget.onRefresh!,
            child: list,
          );
        }

        return list;
      },
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.hasMore,
    required this.isLoadingMore,
    this.onRequestMore,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onRequestMore;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: context.blessingColors.textSecondary,
        );
    if (isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text('正在加载更多', style: style),
          ],
        ),
      );
    }
    final label = hasMore ? '上拉加载更多' : '没有更多了';
    final child = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Center(
        child: Text(
          label,
          key: const Key('load-more-footer'),
          style: style,
        ),
      ),
    );
    if (onRequestMore == null) return child;
    return InkWell(
      onTap: onRequestMore,
      child: child,
    );
  }
}
