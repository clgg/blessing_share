class GridTheme {
  const GridTheme({
    required this.id,
    required this.name,
    required this.previewAssets,
    required this.centerPlaceholderAsset,
  });

  factory GridTheme.fromJson(Map<String, Object?> json) {
    final assets = json['previewAssets'];
    if (assets is! List || assets.length != 8) {
      throw const FormatException('九宫格主题必须包含八张外围图片');
    }
    return GridTheme(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      previewAssets: List.unmodifiable(assets.map((asset) => asset as String)),
      centerPlaceholderAsset: _requiredString(json, 'centerPlaceholderAsset'),
    );
  }

  final String id;
  final String name;
  final List<String> previewAssets;
  final String centerPlaceholderAsset;
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value;
}
