import 'package:blessing_share/app/app_theme.dart';
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
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.thumbnailAsset,
                    fit: BoxFit.cover,
                    semanticLabel: item.title,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                      color: AppColors.border,
                      child: Center(
                          child: Icon(Icons.image_not_supported_outlined)),
                    ),
                  ),
                  if (onFavorite != null)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: SizedBox.square(
                        dimension: 52,
                        child: IconButton.filledTonal(
                          onPressed: onFavorite,
                          tooltip: favorite ? '取消收藏' : '收藏',
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
