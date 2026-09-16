import 'dart:convert';

import 'package:blessing_share/core/network/app_exception.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:flutter/services.dart';

class LocalBlessingRepository implements BlessingRepository {
  LocalBlessingRepository({
    AssetBundle? bundle,
    this.assetPath = 'assets/data/blessings.json',
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String assetPath;
  _CatalogData? _cachedData;

  @override
  Future<List<BlessingCategory>> getCategories() async {
    final categories = List<BlessingCategory>.of((await _load()).categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(categories);
  }

  @override
  Future<List<BlessingItem>> getFeatured() async {
    return List.unmodifiable(
        (await _load()).items.where((item) => item.featured));
  }

  @override
  Future<List<BlessingItem>> getByCategory(String categoryId) async {
    return List.unmodifiable(
      (await _load()).items.where((item) => item.categoryId == categoryId),
    );
  }

  @override
  Future<BlessingItem> getById(String id) async {
    for (final item in (await _load()).items) {
      if (item.id == id) return item;
    }
    throw NotFoundException('未找到素材：$id');
  }

  @override
  Future<List<GridTheme>> getGridThemes() async {
    return List.unmodifiable((await _load()).gridThemes);
  }

  Future<_CatalogData> _load() async {
    if (_cachedData case final data?) return data;
    try {
      final source = await _bundle.loadString(assetPath);
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('根节点必须是 JSON 对象');
      }
      final data = _CatalogData.fromJson(decoded);
      _cachedData = data;
      return data;
    } on AppException {
      rethrow;
    } catch (error) {
      throw DataFormatException('演示素材读取失败，请重新加载', cause: error);
    }
  }
}

class _CatalogData {
  const _CatalogData({
    required this.categories,
    required this.items,
    required this.gridThemes,
  });

  factory _CatalogData.fromJson(Map<String, Object?> json) {
    return _CatalogData(
      categories: _mapList(json, 'categories', BlessingCategory.fromJson),
      items: _mapList(json, 'items', BlessingItem.fromJson),
      gridThemes: _mapList(json, 'gridThemes', GridTheme.fromJson),
    );
  }

  final List<BlessingCategory> categories;
  final List<BlessingItem> items;
  final List<GridTheme> gridThemes;
}

List<T> _mapList<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?>) fromJson,
) {
  final values = json[key];
  if (values is! List) throw FormatException('$key 必须是列表');
  return List.unmodifiable(
    values.map((value) => fromJson((value as Map).cast<String, Object?>())),
  );
}
