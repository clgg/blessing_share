import 'package:dio/dio.dart';

/// Infrastructure-level network failure (no Flutter / domain dependency).
class NetworkFailure implements Exception {
  const NetworkFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class NetworkTimeoutFailure extends NetworkFailure {
  const NetworkTimeoutFailure(super.message, {super.cause});
}

class NetworkCancelledFailure extends NetworkFailure {
  const NetworkCancelledFailure(super.message, {super.cause});
}

class NetworkConnectionFailure extends NetworkFailure {
  const NetworkConnectionFailure(super.message, {super.cause});
}

class NetworkHttpFailure extends NetworkFailure {
  const NetworkHttpFailure(super.message, {super.cause, this.statusCode});

  final int? statusCode;
}

/// Maps [DioException] into typed [NetworkFailure]s.
abstract final class NetworkFailureMapper {
  static NetworkFailure fromDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        NetworkTimeoutFailure('网络请求超时，请稍后重试', cause: error),
      DioExceptionType.cancel =>
        NetworkCancelledFailure('请求已取消', cause: error),
      DioExceptionType.badResponse => NetworkHttpFailure(
          '服务器返回异常（${error.response?.statusCode ?? '未知状态'}）',
          cause: error,
          statusCode: error.response?.statusCode,
        ),
      DioExceptionType.connectionError =>
        NetworkConnectionFailure('暂时无法连接网络，请检查网络设置', cause: error),
      DioExceptionType.badCertificate =>
        NetworkConnectionFailure('网络证书校验失败', cause: error),
      DioExceptionType.unknown =>
        NetworkFailure('网络请求失败，请稍后重试', cause: error),
    };
  }
}
