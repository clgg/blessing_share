class BlessingCategory {
  const BlessingCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.coverAsset,
    required this.sortOrder,
  });

  factory BlessingCategory.fromJson(Map<String, Object?> json) {
    return BlessingCategory(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      subtitle: _requiredString(json, 'subtitle'),
      coverAsset: _requiredString(json, 'coverAsset'),
      sortOrder: json['sortOrder'] as int,
    );
  }

  final String id;
  final String name;
  final String subtitle;
  final String coverAsset;
  final int sortOrder;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}
