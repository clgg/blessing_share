import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/speakable.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:flutter/material.dart';

class BlessingCategoryCard extends StatelessWidget {
  const BlessingCategoryCard({
    required this.category,
    required this.onTap,
    this.imageOnRight = false,
    super.key,
  });

  final BlessingCategory category;
  final VoidCallback onTap;
  final bool imageOnRight;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final speakText = '${category.name}，${category.subtitle}';
    return Semantics(
      button: true,
      label: speakText,
      hint: '长按朗读',
      excludeSemantics: true,
      child: SizedBox(
        height: AppDimens.categoryCardHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final coverWidth =
                (constraints.maxWidth * 0.4).clamp(124.0, 144.0).toDouble();
            final cover = SizedBox(
              key: const Key('category-cover'),
              width: coverWidth,
              height: double.infinity,
              child: AppAssetImage(
                category.coverAsset,
                fit: BoxFit.cover,
                semanticLabel: category.name,
              ),
            );
            final arrow = SizedBox(
              width: 44,
              height: 52,
              child: Icon(
                imageOnRight
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: AppDimens.iconMd,
                color: colors.title,
              ),
            );
            final copy = Expanded(
              child: Padding(
                padding: imageOnRight
                    ? const EdgeInsets.fromLTRB(0, 12, 14, 12)
                    : const EdgeInsets.fromLTRB(14, 12, 0, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: imageOnRight
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign:
                            imageOnRight ? TextAlign.right : TextAlign.left,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colors.title,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppDimens.spaceXs + 2),
                    Flexible(
                      child: Text(
                        category.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign:
                            imageOnRight ? TextAlign.right : TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return Material(
              color: colors.card,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colors.border),
                borderRadius: AppDimens.radiusLgAll,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                onLongPress: () => speakForAccessibility(context, speakText),
                child: Row(
                  children: imageOnRight
                      ? [arrow, copy, cover]
                      : [cover, copy, arrow],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
