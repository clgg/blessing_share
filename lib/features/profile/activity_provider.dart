import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:flutter/foundation.dart';

class ActivityProvider extends ChangeNotifier {
  ActivityProvider({
    required AppStorage storage,
    DateTime Function()? clock,
  })  : _storage = storage,
        _clock = clock ?? DateTime.now;

  static const _storageKey = 'activity.v1';
  final AppStorage _storage;
  final DateTime Function() _clock;
  final List<ActivityRecord> _records = [];
  Future<void>? _loadOperation;

  List<ActivityRecord> get records => List.unmodifiable(_records);

  Future<void> load() => _loadOperation ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final value = await _storage.readJson(_storageKey);
    final records = value['records'];
    _records
      ..clear()
      ..addAll(
        records is List
            ? records.whereType<Map>().map(
                (item) => ActivityRecord.fromJson(item.cast<String, Object?>()))
            : const [],
      )
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> recordSave(String itemId) {
    return _record(itemId: itemId, type: ActivityType.save);
  }

  Future<void> recordShare(String itemId, ShareTarget target) {
    return _record(itemId: itemId, type: ActivityType.share, target: target);
  }

  Future<void> recordGrid(String themeId) {
    return _record(itemId: themeId, type: ActivityType.grid);
  }

  Future<void> _record({
    required String itemId,
    required ActivityType type,
    ShareTarget? target,
  }) async {
    await load();
    final createdAt = _clock();
    _records.insert(
      0,
      ActivityRecord(
        id: '${createdAt.microsecondsSinceEpoch}-${type.name}',
        itemId: itemId,
        type: type,
        target: target,
        createdAt: createdAt,
      ),
    );
    if (_records.length > 50) _records.removeRange(50, _records.length);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.writeJson(_storageKey, {
      'version': 1,
      'records': _records.map((record) => record.toJson()).toList(),
    });
  }
}
