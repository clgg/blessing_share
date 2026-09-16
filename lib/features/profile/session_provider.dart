import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:flutter/foundation.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({required AppStorage storage}) : _storage = storage;

  static const _storageKey = 'session.v1';
  final AppStorage _storage;
  bool _isLoggedIn = false;
  Future<void>? _loadOperation;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> load() => _loadOperation ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final value = await _storage.readJson(_storageKey);
    _isLoggedIn = value['isLoggedIn'] as bool? ?? false;
    notifyListeners();
  }

  Future<void> toggleDemoLogin() async {
    await load();
    _isLoggedIn = !_isLoggedIn;
    await _storage.writeJson(_storageKey, {
      'version': 1,
      'isLoggedIn': _isLoggedIn,
    });
    notifyListeners();
  }
}
