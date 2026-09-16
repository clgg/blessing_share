import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:flutter/foundation.dart';

class GridProvider extends ChangeNotifier {
  GridTheme? _selectedTheme;
  bool _hasDemoPhoto = false;
  bool _isComplete = false;

  GridTheme? get selectedTheme => _selectedTheme;
  bool get hasDemoPhoto => _hasDemoPhoto;
  bool get isComplete => _isComplete;

  void selectTheme(GridTheme theme) {
    _selectedTheme = theme;
    _hasDemoPhoto = false;
    _isComplete = false;
    notifyListeners();
  }

  void selectDemoPhoto() {
    if (_selectedTheme == null) throw StateError('请先选择九宫格主题');
    _hasDemoPhoto = true;
    notifyListeners();
  }

  void complete() {
    if (_selectedTheme == null) throw StateError('请先选择九宫格主题');
    _isComplete = true;
    notifyListeners();
  }
}
