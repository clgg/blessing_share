import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/core/widgets/blessing_media_image.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/detail_page.dart';
import 'package:blessing_share/features/grid/grid_preview_page.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage(
      {required this.title, required this.type, super.key});

  final String title;
  final ActivityType type;

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final Map<String, _ActivityDisplay> _displayByItemId = {};
  final Set<String> _selectedIds = {};
  bool _selecting = false;
  bool _loadingDisplay = false;
  String _loadedSignature = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final records = context
        .watch<ActivityProvider>()
        .records
        .where((record) => record.type == widget.type)
        .toList();
    final signature = records.map((record) => record.itemId).join(',');
    if (signature != _loadedSignature && !_loadingDisplay) {
      _loadedSignature = signature;
      _loadDisplay(records);
    }
  }

  Future<void> _loadDisplay(List<ActivityRecord> records) async {
    _loadingDisplay = true;
    final repository = context.read<BlessingRepository>();
    final neededIds = records.map((record) => record.itemId).toSet();
    for (final itemId in neededIds) {
      if (_displayByItemId.containsKey(itemId)) continue;
      try {
        if (widget.type == ActivityType.grid) {
          final themes = await repository.getGridThemes();
          for (final theme in themes) {
            _displayByItemId.putIfAbsent(
              theme.id,
              () => _ActivityDisplay(
                title: theme.name,
                imageAsset: theme.previewAssets.isNotEmpty
                    ? theme.previewAssets.first
                    : theme.centerPlaceholderAsset,
                imageUrl: null,
              ),
            );
          }
        } else {
          final item = await repository.getById(itemId);
          _displayByItemId[itemId] = _ActivityDisplay(
            title: item.title,
            imageAsset: item.thumbnailAsset,
            imageUrl: item.thumbnailUrl,
          );
        }
      } catch (_) {
        _displayByItemId.putIfAbsent(
          itemId,
          () => const _ActivityDisplay(
            title: '记录已失效',
            imageAsset: null,
            imageUrl: null,
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() => _loadingDisplay = false);
  }

  void _toggleSelecting() {
    setState(() {
      _selecting = !_selecting;
      _selectedIds.clear();
    });
  }

  Future<void> _confirmDelete() async {
    if (_selectedIds.isEmpty) return;
    final ids = Set<String>.of(_selectedIds);
    await context.read<ActivityProvider>().deleteByIds(ids);
    if (!mounted) return;
    setState(() {
      _selecting = false;
      _selectedIds.clear();
    });
  }

  void _onActionPressed() {
    if (!_selecting) {
      _toggleSelecting();
      return;
    }
    if (_selectedIds.isNotEmpty) {
      _confirmDelete();
      return;
    }
    _toggleSelecting();
  }

  void _onRecordTap(ActivityRecord record, {required bool selected}) {
    if (_selecting) {
      setState(() {
        if (selected) {
          _selectedIds.remove(record.id);
        } else {
          _selectedIds.add(record.id);
        }
      });
      return;
    }
    _openRecord(record);
  }

  Future<void> _openRecord(ActivityRecord record) async {
    if (record.type == ActivityType.grid) {
      await _openGridPreview(record.itemId);
      return;
    }

    try {
      await context.read<BlessingRepository>().getById(record.itemId);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        context,
        type: AppToastType.error,
        message: '这条记录对应的素材已经失效',
      );
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailPage(itemId: record.itemId),
      ),
    );
  }

  Future<void> _openGridPreview(String themeId) async {
    try {
      final themes = await context.read<BlessingRepository>().getGridThemes();
      final matched = themes.where((item) => item.id == themeId);
      if (matched.isEmpty) {
        throw StateError('theme missing');
      }
      final theme = matched.first;
      if (!mounted) return;
      final grid = context.read<GridProvider>();
      grid.selectTheme(theme);
      // Restore demo photo so users can tweak and share again immediately.
      grid.selectDemoPhoto();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GridPreviewPage()),
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        context,
        type: AppToastType.error,
        message: '这条九宫格记录暂时无法打开',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = context
        .watch<ActivityProvider>()
        .records
        .where((record) => record.type == widget.type)
        .toList();
    final hasSelection = _selectedIds.isNotEmpty;

    return AppScaffold(
      title: widget.title,
      actions: records.isEmpty
          ? null
          : [
              _HistoryActionButton(
                selecting: _selecting,
                hasSelection: hasSelection,
                onPressed: _onActionPressed,
              ),
            ],
      body: records.isEmpty
          ? AppEmptyState(
              icon: widget.type == ActivityType.grid
                  ? Icons.grid_view_rounded
                  : Icons.history_rounded,
              title: '暂无${widget.title}',
              message: '完成一次对应的演示操作后，记录会显示在这里。',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                final display = _displayByItemId[record.itemId];
                final selected = _selectedIds.contains(record.id);
                return _ActivityHistoryTile(
                  title: display?.title ?? '加载中…',
                  subtitle: _formatTime(record.createdAt),
                  shareTarget:
                      record.type == ActivityType.share ? record.target : null,
                  showShareTarget: record.type == ActivityType.share,
                  imageAsset: display?.imageAsset ?? '',
                  imageUrl: display?.imageUrl,
                  selecting: _selecting,
                  selected: selected,
                  onTap: () => _onRecordTap(record, selected: selected),
                  onLongPress: _selecting
                      ? null
                      : () => speakForAccessibility(
                            context,
                            '${display?.title ?? '记录'}，'
                            '${_speakTargetLabel(record)}'
                            '${_formatTime(record.createdAt)}',
                          ),
                );
              },
            ),
    );
  }

  String _speakTargetLabel(ActivityRecord record) {
    if (record.type != ActivityType.share) return '';
    final label = switch (record.target) {
      ShareTarget.friend => '微信好友',
      ShareTarget.timeline => '朋友圈',
      null => '分享',
    };
    return '$label，';
  }

  String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}

class _HistoryActionButton extends StatelessWidget {
  const _HistoryActionButton({
    required this.selecting,
    required this.hasSelection,
    required this.onPressed,
  });

  final bool selecting;
  final bool hasSelection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final tooltip = !selecting
        ? '删除'
        : hasSelection
            ? '确定删除'
            : '取消';

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.72, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: selecting
            ? TweenAnimationBuilder<Color?>(
                key: ValueKey<String>(
                  hasSelection ? 'check-ready' : 'check-idle',
                ),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                tween: ColorTween(
                  begin: colors.confirmIdle,
                  end: hasSelection ? colors.confirmReady : colors.confirmIdle,
                ),
                builder: (context, animatedColor, _) {
                  return Icon(
                    Icons.check_rounded,
                    size: 28,
                    color: animatedColor,
                  );
                },
              )
            : Icon(
                Icons.delete_outline_rounded,
                key: const ValueKey<String>('delete'),
                size: 28,
                color: colors.textPrimary,
              ),
      ),
    );
  }
}

class _ActivityDisplay {
  const _ActivityDisplay({
    required this.title,
    required this.imageAsset,
    required this.imageUrl,
  });

  final String title;
  final String? imageAsset;
  final String? imageUrl;
}

class _ActivityHistoryTile extends StatelessWidget {
  const _ActivityHistoryTile({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.imageUrl,
    required this.selecting,
    required this.selected,
    required this.onTap,
    required this.showShareTarget,
    this.shareTarget,
    this.onLongPress,
  });

  final String title;
  final String subtitle;
  final bool showShareTarget;
  final ShareTarget? shareTarget;
  final String? imageAsset;
  final String? imageUrl;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumbnail(
                imageAsset: imageAsset,
                imageUrl: imageUrl,
                title: title,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (showShareTarget) ...[
                          const SizedBox(width: 6),
                          _ShareTargetIcon(target: shareTarget),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Fixed trailing slot so checkbox/chevron swap does not reflow text.
              SizedBox(
                width: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: selecting
                      ? Checkbox(
                          key: const ValueKey('checkbox'),
                          value: selected,
                          onChanged: (_) => onTap(),
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          key: const ValueKey('chevron'),
                          size: 28,
                          color: colors.textSecondary,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareTargetIcon extends StatelessWidget {
  const _ShareTargetIcon({this.target});

  final ShareTarget? target;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final (icon, label, key) = switch (target) {
      ShareTarget.friend => (
          Icons.chat_bubble_outline_rounded,
          '微信好友',
          const ValueKey<String>('share-target-friend'),
        ),
      ShareTarget.timeline => (
          Icons.people_outline_rounded,
          '朋友圈',
          const ValueKey<String>('share-target-timeline'),
        ),
      null => (
          Icons.share_outlined,
          '分享',
          const ValueKey<String>('share-target-unknown'),
        ),
    };
    return Tooltip(
      message: label,
      child: Icon(
        icon,
        key: key,
        size: 20,
        color: colors.textSecondary,
        semanticLabel: label,
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.imageAsset,
    required this.imageUrl,
    required this.title,
  });

  final String? imageAsset;
  final String? imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageAsset == null && imageUrl == null
            ? ColoredBox(
                color: colors.border,
                child: const Center(
                    child: Icon(Icons.image_not_supported_outlined)),
              )
            : BlessingMediaImage(
                assetPath: imageAsset,
                networkUrl: imageUrl,
                fit: BoxFit.cover,
                semanticLabel: title,
              ),
      ),
    );
  }
}
