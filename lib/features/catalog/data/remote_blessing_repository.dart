import 'package:blessing_network/blessing_network.dart';
import 'package:blessing_share/core/error/app_exception.dart';
import 'package:blessing_share/features/catalog/data/mappers/blessing_mapper.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';

class RemoteBlessingRepository implements BlessingRepository {
  RemoteBlessingRepository({
    required BlessingApi api,
    BlessingMapper mapper = const BlessingMapper(),
  })  : _api = api,
        _mapper = mapper;

  /// Convenience: Dio from [NetworkClient.create] + [BlessingApi].
  factory RemoteBlessingRepository.fromBaseUrl(
    String baseUrl, {
    bool enableLogging = false,
  }) {
    final dio = NetworkClient.create(baseUrl, enableLogging: enableLogging);
    return RemoteBlessingRepository(api: BlessingApi(dio));
  }

  final BlessingApi _api;
  final BlessingMapper _mapper;

  @override
  Future<List<BlessingCategory>> getCategories() {
    return _mapList(
      () => _api.getCategories(),
      _mapper.toCategory,
      errorMessage: '服务器数据格式不正确',
    );
  }

  @override
  Future<List<BlessingItem>> getFeatured() {
    return _mapList(
      () => _api.getFeatured(),
      _mapper.toItem,
      errorMessage: '服务器数据格式不正确',
    );
  }

  @override
  Future<List<BlessingItem>> getByCategory(String categoryId) {
    return _mapList(
      () => _api.getByCategory(categoryId),
      _mapper.toItem,
      errorMessage: '服务器数据格式不正确',
    );
  }

  @override
  Future<BlessingItem> getById(String id) async {
    try {
      final dto = await _api.getById(id);
      return _mapper.toItem(dto);
    } on DioException catch (error) {
      throw _mapNetwork(error, formatMessage: '素材详情数据格式不正确');
    } catch (error) {
      if (error is AppException) rethrow;
      throw DataFormatException('素材详情数据格式不正确', cause: error);
    }
  }

  @override
  Future<List<GridTheme>> getGridThemes() {
    return _mapList(
      () => _api.getGridThemes(),
      _mapper.toGridTheme,
      errorMessage: '服务器数据格式不正确',
    );
  }

  Future<List<T>> _mapList<D, T>(
    Future<List<D>> Function() call,
    T Function(D dto) map, {
    required String errorMessage,
  }) async {
    try {
      final dtos = await call();
      return List.unmodifiable(dtos.map(map));
    } on DioException catch (error) {
      throw _mapNetwork(error, formatMessage: errorMessage);
    } catch (error) {
      if (error is AppException) rethrow;
      throw DataFormatException(errorMessage, cause: error);
    }
  }

  AppException _mapNetwork(
    DioException error, {
    String formatMessage = '服务器数据格式不正确',
  }) {
    if (_isFormatFailure(error)) {
      return DataFormatException(formatMessage, cause: error);
    }
    final failure = NetworkFailureMapper.fromDio(error);
    return switch (failure) {
      NetworkTimeoutFailure() =>
        AppTimeoutException(failure.message, cause: failure.cause),
      NetworkCancelledFailure() =>
        RequestCancelledException(failure.message, cause: failure.cause),
      NetworkHttpFailure() || NetworkConnectionFailure() =>
        NetworkException(failure.message, cause: failure.cause),
      _ => NetworkException(failure.message, cause: failure.cause),
    };
  }

  bool _isFormatFailure(DioException error) {
    final cause = error.error;
    return cause is FormatException ||
        cause is TypeError ||
        (error.type == DioExceptionType.unknown &&
            error.response?.statusCode == 200);
  }
}
