class BlessingItem {
  const BlessingItem({
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
  })  : assert(thumbnailAsset != null || thumbnailUrl != null),
        assert(imageAsset != null || imageUrl != null);

  factory BlessingItem.fromJson(Map<String, Object?> json) {
    final tags = json['tags'];
    if (tags is! List) {
      throw const FormatException('tags 必须是列表');
    }
    final thumbnailAsset = _optionalString(json, 'thumbnailAsset');
    final imageAsset = _optionalString(json, 'imageAsset');
    final thumbnailUrl = _optionalString(json, 'thumbnailUrl');
    final imageUrl = _optionalString(json, 'imageUrl');
    if (thumbnailAsset == null && thumbnailUrl == null) {
      throw const FormatException('thumbnailAsset 或 thumbnailUrl 必须提供一个');
    }
    if (imageAsset == null && imageUrl == null) {
      throw const FormatException('imageAsset 或 imageUrl 必须提供一个');
    }

    return BlessingItem(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      caption: _requiredString(json, 'caption'),
      categoryId: _requiredString(json, 'categoryId'),
      thumbnailAsset: thumbnailAsset,
      imageAsset: imageAsset,
      thumbnailUrl: thumbnailUrl,
      imageUrl: imageUrl,
      tags: List.unmodifiable(tags.map((tag) => tag as String)),
      featured: json['featured'] as bool? ?? false,
      aspectRatio: _aspectRatio(json['aspectRatio']),
    );
  }

  final String id;
  final String title;
  final String caption;
  final String categoryId;

  /// Bundled fallback used by the offline catalog.
  final String? thumbnailAsset;
  final String? imageAsset;

  /// Optional CDN sources. When present, presentation widgets prefer these
  /// and fall back to the bundled assets if loading fails.
  final String? thumbnailUrl;
  final String? imageUrl;
  final List<String> tags;
  final bool featured;

  /// Image width / height. Demo values: `1`, `9/16`, `16/9`.
  final double aspectRatio;
}

String? _optionalString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}

double _aspectRatio(Object? value) {
  if (value == null) return 1;
  if (value is num && value > 0) return value.toDouble();
  throw const FormatException('aspectRatio 必须是正数');
}
