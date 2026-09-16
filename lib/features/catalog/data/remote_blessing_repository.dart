import 'package:blessing_share/core/network/api_client.dart';
import 'package:blessing_share/core/network/app_exception.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:dio/dio.dart';

class RemoteBlessingRepository implements BlessingRepository {
  RemoteBlessingRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<List<BlessingCategory>> getCategories() {
    return _getList('/categories', BlessingCategory.fromJson);
  }

  @override
  Future<List<BlessingItem>> getFeatured() {
    return _getList('/featured', BlessingItem.fromJson);
  }

  @override
  Future<List<BlessingItem>> getByCategory(String categoryId) {
    return _getList(
      '/categories/${Uri.encodeComponent(categoryId)}/items',
      BlessingItem.fromJson,
    );
  }

  @override
  Future<BlessingItem> getById(String id) async {
    final data = await _getData('/items/${Uri.encodeComponent(id)}');
    try {
      return BlessingItem.fromJson(_asMap(data));
    } catch (error) {
      throw DataFormatException('素材详情数据格式不正确', cause: error);
    }
  }

  @override
  Future<List<GridTheme>> getGridThemes() {
    return _getList('/grid-themes', GridTheme.fromJson);
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, Object?> json) fromJson,
  ) async {
    final data = await _getData(path);
    try {
      if (data is! List) throw const FormatException('data 必须是列表');
      return List.unmodifiable(data.map((item) => fromJson(_asMap(item))));
    } catch (error) {
      if (error is DataFormatException) rethrow;
      throw DataFormatException('服务器数据格式不正确', cause: error);
    }
  }

  Future<Object?> _getData(String path) async {
    try {
      final response = await _dio.get<Object?>(path);
      final body = response.data;
      if (body is Map && body.containsKey('data')) return body['data'];
      return body;
    } on DioException catch (error) {
      throw ApiClient.mapDioException(error);
    }
  }
}

Map<String, Object?> _asMap(Object? value) {
  if (value is! Map) throw const FormatException('条目必须是对象');
  return value.cast<String, Object?>();
}
