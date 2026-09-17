import 'package:blessing_share/features/catalog/domain/category_filter.dart';

class BlessingCategory {
  const BlessingCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.coverAsset,
    required this.sortOrder,
    this.allFilterLabel = '全部',
    this.filters = const [],
  });

  factory BlessingCategory.fromJson(Map<String, Object?> json) {
    return BlessingCategory(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      subtitle: _requiredString(json, 'subtitle'),
      coverAsset: _requiredString(json, 'coverAsset'),
      sortOrder: json['sortOrder'] as int,
      allFilterLabel: _optionalString(json, 'allFilterLabel') ?? '全部',
      filters: _parseFilters(json['filters']),
    );
  }

  final String id;
  final String name;
  final String subtitle;
  final String coverAsset;
  final int sortOrder;

  /// Chip label for “show all”, e.g. 全部问候 / 全部节日.
  final String allFilterLabel;

  /// Server- or asset-driven filter chips for this category.
  final List<CategoryFilter> filters;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value.trim();
}

List<CategoryFilter> _parseFilters(Object? raw) {
  if (raw == null) return const [];
  if (raw is! List) throw const FormatException('filters 必须是列表');
  return List.unmodifiable(
    raw.map((value) {
      if (value is String) {
        final text = value.trim();
        if (text.isEmpty) {
          throw const FormatException('filters 条目不能为空字符串');
        }
        return CategoryFilter(id: text, label: text);
      }
      if (value is Map) {
        return CategoryFilter.fromJson(value.cast<String, Object?>());
      }
      throw const FormatException('filters 条目必须是对象或字符串');
    }),
  );
}
