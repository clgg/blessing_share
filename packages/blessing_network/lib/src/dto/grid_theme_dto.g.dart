// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_theme_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GridThemeDto _$GridThemeDtoFromJson(Map<String, dynamic> json) => GridThemeDto(
      id: json['id'] as String,
      name: json['name'] as String,
      previewAssets: (json['previewAssets'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      centerPlaceholderAsset: json['centerPlaceholderAsset'] as String,
    );

Map<String, dynamic> _$GridThemeDtoToJson(GridThemeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'previewAssets': instance.previewAssets,
      'centerPlaceholderAsset': instance.centerPlaceholderAsset,
    };
