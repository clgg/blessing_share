import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:flutter/foundation.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({required AppStorage storage}) : _storage = storage;

  static const _storageKey = 'favorites.v1';
  final AppStorage _storage;
  final Set<String> _favoriteIds = {};
  final Map<String, String> _categoryById = {};
  String? _filterCategoryId;
  String? _removedId;

  bool contains(String itemId) => _favoriteIds.contains(itemId);

  String? get filterCategoryId => _filterCategoryId;

  List<String> get visibleIds {
    final ids = _favoriteIds.where((id) {
      return _filterCategoryId == null ||
          _categoryById[id] == _filterCategoryId;
    }).toList();
    return List.unmodifiable(ids);
  }

  Future<void> load() async {
    final value = await _storage.readJson(_storageKey);
    final ids = value['ids'];
    _favoriteIds
      ..clear()
      ..addAll(ids is List ? ids.whereType<String>() : const []);
    notifyListeners();
  }

  void registerItems(Iterable<BlessingItem> items) {
    for (final item in items) {
      _categoryById[item.id] = item.categoryId;
    }
  }

  Future<void> toggle(BlessingItem item) async {
    _categoryById[item.id] = item.categoryId;
    if (_favoriteIds.contains(item.id)) {
      await remove(item.id);
      return;
    }
    _favoriteIds.add(item.id);
    _removedId = null;
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String itemId) async {
    if (!_favoriteIds.remove(itemId)) return;
    _removedId = itemId;
    await _persist();
    notifyListeners();
  }

  Future<void> undoRemove() async {
    final itemId = _removedId;
    if (itemId == null) return;
    _favoriteIds.add(itemId);
    _removedId = null;
    await _persist();
    notifyListeners();
  }

  void setFilter(String? categoryId) {
    if (_filterCategoryId == categoryId) return;
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> _persist() {
    return _storage.writeJson(_storageKey, {
      'version': 1,
      'ids': _favoriteIds.toList(),
    });
  }
}
