import 'package:blessing_share/core/error/app_exception.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:flutter/foundation.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({required BlessingRepository repository})
      : _repository = repository;

  final BlessingRepository _repository;
  List<BlessingCategory> _categories = const [];
  List<BlessingItem> _featured = const [];
  List<BlessingItem> _categoryItems = const [];
  bool _isLoading = false;
  AppException? _error;
  String? _requestedCategoryId;

  List<BlessingCategory> get categories => _categories;
  List<BlessingItem> get featured => _featured;
  List<BlessingItem> get categoryItems => _categoryItems;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  Future<void> loadHome() async {
    final showSpinner = _categories.isEmpty && _featured.isEmpty;
    if (showSpinner) {
      _setLoading();
    } else {
      _error = null;
    }
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getFeatured(),
      ]);
      _categories = results[0] as List<BlessingCategory>;
      _featured = results[1] as List<BlessingItem>;
      _error = null;
    } on AppException catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategory(
    String categoryId, {
    bool keepExistingItems = false,
  }) async {
    _requestedCategoryId = categoryId;
    if (keepExistingItems) {
      _error = null;
    } else {
      _categoryItems = const [];
      _setLoading();
    }
    try {
      final items = await _repository.getByCategory(categoryId);
      if (_requestedCategoryId != categoryId) return;
      _categoryItems = items;
      _error = null;
    } on AppException catch (error) {
      if (_requestedCategoryId == categoryId) _error = error;
    } finally {
      if (_requestedCategoryId == categoryId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<BlessingItem> itemById(String id) => _repository.getById(id);

  void _setLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
}
