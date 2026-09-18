import 'package:json_annotation/json_annotation.dart';

part 'blessing_item_dto.g.dart';

@JsonSerializable()
class BlessingItemDto {
  const BlessingItemDto({
    required this.id,
    required this.title,
    required this.caption,
    required this.categoryId,
    this.thumbnailAsset,
    this.imageAsset,
    this.thumbnailUrl,
    this.imageUrl,
    required this.tags,
    required this.featured,
    this.aspectRatio = 1,
  });

  factory BlessingItemDto.fromJson(Map<String, dynamic> json) =>
      _$BlessingItemDtoFromJson(json);

  final String id;
  final String title;
  final String caption;
  final String categoryId;
  final String? thumbnailAsset;
  final String? imageAsset;
  final String? thumbnailUrl;
  final String? imageUrl;
  final List<String> tags;
  @JsonKey(defaultValue: false)
  final bool featured;
  @JsonKey(defaultValue: 1)
  final double aspectRatio;

  Map<String, dynamic> toJson() => _$BlessingItemDtoToJson(this);
}
