import 'package:json_annotation/json_annotation.dart';

part 'category_filter_dto.g.dart';

@JsonSerializable(createFactory: false)
class CategoryFilterDto {
  const CategoryFilterDto({
    required this.id,
    required this.label,
  });

  factory CategoryFilterDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final labelValue = json['label'];
    final label = labelValue is String && labelValue.trim().isNotEmpty
        ? labelValue.trim()
        : id;
    return CategoryFilterDto(id: id, label: label);
  }

  /// Shorthand: a bare string becomes id == label.
  factory CategoryFilterDto.fromDynamic(Object? value) {
    if (value is String) {
      final text = value.trim();
      if (text.isEmpty) {
        throw const FormatException('filters 条目不能为空字符串');
      }
      return CategoryFilterDto(id: text, label: text);
    }
    if (value is Map) {
      return CategoryFilterDto.fromJson(Map<String, dynamic>.from(value));
    }
    throw const FormatException('filters 条目必须是对象或字符串');
  }

  final String id;
  final String label;

  Map<String, dynamic> toJson() => _$CategoryFilterDtoToJson(this);
}
