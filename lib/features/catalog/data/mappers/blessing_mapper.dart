import 'package:blessing_network/blessing_network.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/category_filter.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';

/// Maps network DTOs to catalog domain entities.
class BlessingMapper {
  const BlessingMapper();

  BlessingCategory toCategory(BlessingCategoryDto dto) {
    return BlessingCategory(
      id: dto.id,
      name: dto.name,
      subtitle: dto.subtitle,
      coverAsset: dto.coverAsset,
      sortOrder: dto.sortOrder,
      allFilterLabel: dto.allFilterLabel,
      filters: List.unmodifiable(dto.filters.map(toFilter)),
    );
  }

  CategoryFilter toFilter(CategoryFilterDto dto) {
    return CategoryFilter(id: dto.id, label: dto.label);
  }

  BlessingItem toItem(BlessingItemDto dto) {
    return BlessingItem(
      id: dto.id,
      title: dto.title,
      caption: dto.caption,
      categoryId: dto.categoryId,
      thumbnailAsset: dto.thumbnailAsset,
      imageAsset: dto.imageAsset,
      thumbnailUrl: dto.thumbnailUrl,
      imageUrl: dto.imageUrl,
      tags: List.unmodifiable(dto.tags),
      featured: dto.featured,
      aspectRatio: dto.aspectRatio,
    );
  }

  GridTheme toGridTheme(GridThemeDto dto) {
    return GridTheme(
      id: dto.id,
      name: dto.name,
      previewAssets: List.unmodifiable(dto.previewAssets),
      centerPlaceholderAsset: dto.centerPlaceholderAsset,
    );
  }
}
