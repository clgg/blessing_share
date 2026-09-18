import 'package:blessing_share/app/app_theme.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:flutter/material.dart';

class BlessingImageCard extends StatelessWidget {
  const BlessingImageCard({
    required this.item,
    required this.onTap,
    this.favorite = false,
    this.onFavorite,
    super.key,
  });

  final BlessingItem item;
  final VoidCallback onTap;
  final bool favorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final speakText = item.caption.trim().isEmpty
        ? item.title
        : '${item.title}，${item.caption}';
    final title = Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 17,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );

    final image = Stack(
      fit: StackFit.expand,
      children: [
        BlessingMediaImage(
          imageKey: const Key('blessing-media-image'),
          assetPath: item.thumbnailAsset,
          networkUrl: item.thumbnailUrl,
          fit: BoxFit.cover,
          semanticLabel: item.title,
        ),
        if (onFavorite != null)
          Positioned(
            right: 4,
            top: 4,
            child: SizedBox.square(
              dimension: 52,
              child: Semantics(
                button: true,
                label: favorite ? '取消收藏' : '收藏',
                excludeSemantics: true,
                child: IconButton.filledTonal(
                  onPressed: onFavorite,
                  tooltip: favorite ? '取消收藏' : '收藏',
                  icon: Icon(
                    favorite ? Icons.favorite : Icons.favorite_border,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Material(
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => speakForAccessibility(context, speakText),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boundedHeight = constraints.maxHeight.isFinite;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: boundedHeight ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (boundedHeight)
                  Expanded(child: image)
                else
                  AspectRatio(aspectRatio: item.aspectRatio, child: image),
                title,
              ],
            );
          },
        ),
      ),
    );
  }
}
