class BlessingItem {
  const BlessingItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.categoryId,
    required this.thumbnailAsset,
    required this.imageAsset,
    required this.tags,
    required this.featured,
  });

  factory BlessingItem.fromJson(Map<String, Object?> json) {
    final tags = json['tags'];
    if (tags is! List) {
      throw const FormatException('tags 必须是列表');
    }
    return BlessingItem(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      caption: _requiredString(json, 'caption'),
      categoryId: _requiredString(json, 'categoryId'),
      thumbnailAsset: _requiredString(json, 'thumbnailAsset'),
      imageAsset: _requiredString(json, 'imageAsset'),
      tags: List.unmodifiable(tags.map((tag) => tag as String)),
      featured: json['featured'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String caption;
  final String categoryId;
  final String thumbnailAsset;
  final String imageAsset;
  final List<String> tags;
  final bool featured;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}
