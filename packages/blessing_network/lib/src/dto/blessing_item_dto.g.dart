// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blessing_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlessingItemDto _$BlessingItemDtoFromJson(Map<String, dynamic> json) =>
    BlessingItemDto(
      id: json['id'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String,
      categoryId: json['categoryId'] as String,
      thumbnailAsset: json['thumbnailAsset'] as String?,
      imageAsset: json['imageAsset'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      featured: json['featured'] as bool? ?? false,
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$BlessingItemDtoToJson(BlessingItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'caption': instance.caption,
      'categoryId': instance.categoryId,
      'thumbnailAsset': instance.thumbnailAsset,
      'imageAsset': instance.imageAsset,
      'thumbnailUrl': instance.thumbnailUrl,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
      'featured': instance.featured,
      'aspectRatio': instance.aspectRatio,
    };
