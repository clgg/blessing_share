import 'package:json_annotation/json_annotation.dart';

part 'grid_theme_dto.g.dart';

@JsonSerializable()
class GridThemeDto {
  const GridThemeDto({
    required this.id,
    required this.name,
    required this.previewAssets,
    required this.centerPlaceholderAsset,
  });

  factory GridThemeDto.fromJson(Map<String, dynamic> json) =>
      _$GridThemeDtoFromJson(json);

  final String id;
  final String name;
  final List<String> previewAssets;
  final String centerPlaceholderAsset;

  Map<String, dynamic> toJson() => _$GridThemeDtoToJson(this);
}
