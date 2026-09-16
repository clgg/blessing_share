enum ActivityType { save, share, grid }

enum ShareTarget { friend, timeline }

class ActivityRecord {
  const ActivityRecord({
    required this.id,
    required this.itemId,
    required this.type,
    required this.createdAt,
    this.target,
  });

  factory ActivityRecord.fromJson(Map<String, Object?> json) {
    return ActivityRecord(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      type: ActivityType.values.byName(json['type'] as String),
      target: json['target'] == null
          ? null
          : ShareTarget.values.byName(json['target'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String itemId;
  final ActivityType type;
  final ShareTarget? target;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'itemId': itemId,
        'type': type.name,
        'target': target?.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
