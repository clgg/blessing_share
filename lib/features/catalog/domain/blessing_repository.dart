import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';

abstract interface class BlessingRepository {
  Future<List<BlessingCategory>> getCategories();

  Future<List<BlessingItem>> getFeatured();

  Future<List<BlessingItem>> getByCategory(String categoryId);

  Future<BlessingItem> getById(String id);

  Future<List<GridTheme>> getGridThemes();
}
