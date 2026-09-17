import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required AppStorage storage}) : _storage = storage;

  static const _storageKey = 'theme.v1';
  final AppStorage _storage;
  AppThemeId _themeId = AppThemeId.festiveRed;
  Future<void>? _loadOperation;

  AppThemeId get themeId => _themeId;
  BlessingPalette get palette => BlessingPalette.of(_themeId);
  ThemeData get themeData => AppTheme.of(_themeId);

  Future<void> load() => _loadOperation ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final value = await _storage.readJson(_storageKey);
    final raw = value['themeId'] as String?;
    if (raw != null) {
      for (final id in AppThemeId.values) {
        if (id.name == raw) {
          _themeId = id;
          break;
        }
      }
    }
    notifyListeners();
  }

  Future<void> setTheme(AppThemeId id) async {
    await load();
    if (_themeId == id) return;
    _themeId = id;
    await _storage.writeJson(_storageKey, {
      'version': 1,
      'themeId': id.name,
    });
    notifyListeners();
  }
}
