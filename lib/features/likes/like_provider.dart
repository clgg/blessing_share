import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:flutter/foundation.dart';

class LikeProvider extends ChangeNotifier {
  LikeProvider({required AppStorage storage}) : _storage = storage;

  static const _storageKey = 'likes.v1';
  final AppStorage _storage;
  final Set<String> _likedIds = {};
  Future<void>? _loadOperation;

  bool contains(String itemId) => _likedIds.contains(itemId);

  List<String> get likedIds => List.unmodifiable(_likedIds);

  Future<void> load() => _loadOperation ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final value = await _storage.readJson(_storageKey);
    final ids = value['ids'];
    _likedIds
      ..clear()
      ..addAll(ids is List ? ids.whereType<String>() : const []);
    notifyListeners();
  }

  Future<void> toggle(BlessingItem item) async {
    await load();
    if (_likedIds.contains(item.id)) {
      _likedIds.remove(item.id);
    } else {
      _likedIds.add(item.id);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.writeJson(_storageKey, {
      'version': 1,
      'ids': _likedIds.toList(),
    });
  }
}
