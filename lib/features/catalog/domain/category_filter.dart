/// A filter chip option under a [BlessingCategory].
///
/// [id] is matched against [BlessingItem.tags]. [label] is shown on the chip.
/// Local demo uses the same Chinese string for both; a future server can ship
/// stable English ids while keeping localized labels.
class CategoryFilter {
  const CategoryFilter({
    required this.id,
    required this.label,
  });

  factory CategoryFilter.fromJson(Map<String, Object?> json) {
    final id = _requiredString(json, 'id');
    final labelValue = json['label'];
    final label = labelValue is String && labelValue.trim().isNotEmpty
        ? labelValue.trim()
        : id;
    return CategoryFilter(id: id, label: label);
  }

  final String id;
  final String label;

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
      };
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key 必须是非空字符串');
  }
  return value.trim();
}
