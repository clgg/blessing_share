import 'package:blessing_network/src/dto/category_filter_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'blessing_category_dto.g.dart';

@JsonSerializable(createFactory: false)
class BlessingCategoryDto {
  const BlessingCategoryDto({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.coverAsset,
    required this.sortOrder,
    this.allFilterLabel = '全部',
    this.filters = const [],
  });

  /// Supports filters as string list or `{id,label}` objects.
  factory BlessingCategoryDto.fromJson(Map<String, dynamic> json) {
    final rawFilters = json['filters'];
    final filters = <CategoryFilterDto>[];
    if (rawFilters is List) {
      for (final entry in rawFilters) {
        filters.add(CategoryFilterDto.fromDynamic(entry));
      }
    } else if (rawFilters != null) {
      throw const FormatException('filters 必须是列表');
    }

    return BlessingCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String,
      coverAsset: json['coverAsset'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      allFilterLabel: (json['allFilterLabel'] as String?) ?? '全部',
      filters: List.unmodifiable(filters),
    );
  }

  final String id;
  final String name;
  final String subtitle;
  final String coverAsset;
  final int sortOrder;
  final String allFilterLabel;
  final List<CategoryFilterDto> filters;

  Map<String, dynamic> toJson() => _$BlessingCategoryDtoToJson(this);
}
