import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:flutter/material.dart';

class BlessingCategoryCard extends StatelessWidget {
  const BlessingCategoryCard({
    required this.category,
    required this.onTap,
    super.key,
  });

  final BlessingCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${category.name}，${category.subtitle}',
      excludeSemantics: true,
      child: SizedBox(
        height: 132,
        child: Material(
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                SizedBox(
                  width: 168,
                  height: double.infinity,
                  child: Image.asset(
                    category.coverAsset,
                    fit: BoxFit.cover,
                    semanticLabel: category.name,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 52,
                  height: 52,
                  child:
                      Icon(Icons.chevron_right_rounded, color: AppColors.title),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
