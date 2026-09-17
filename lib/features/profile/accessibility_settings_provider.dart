import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:flutter/material.dart';

/// Persists accessibility preferences such as long-press TTS.
class AccessibilitySettingsProvider extends ChangeNotifier {
  AccessibilitySettingsProvider({required AppStorage storage})
      : _storage = storage;

  static const _storageKey = 'accessibility.v1';
  final AppStorage _storage;
  bool _longPressSpeakEnabled = true;
  Future<void>? _loadOperation;

  bool get longPressSpeakEnabled => _longPressSpeakEnabled;

  Future<void> load() => _loadOperation ??= _loadFromStorage();

  Future<void> _loadFromStorage() async {
    final value = await _storage.readJson(_storageKey);
    final raw = value['longPressSpeakEnabled'];
    if (raw is bool) {
      _longPressSpeakEnabled = raw;
    }
    notifyListeners();
  }

  Future<void> setLongPressSpeakEnabled(bool enabled) async {
    await load();
    if (_longPressSpeakEnabled == enabled) return;
    _longPressSpeakEnabled = enabled;
    await _storage.writeJson(_storageKey, {
      'version': 1,
      'longPressSpeakEnabled': enabled,
    });
    notifyListeners();
  }
}
