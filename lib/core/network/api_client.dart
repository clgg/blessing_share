import 'package:blessing_share/core/network/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract final class ApiClient {
  static Dio create(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: false,
          responseBody: false,
        ),
      );
    }
    return dio;
  }

  static AppException mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        AppTimeoutException('网络请求超时，请稍后重试', cause: error),
      DioExceptionType.cancel =>
        RequestCancelledException('请求已取消', cause: error),
      DioExceptionType.badResponse => NetworkException(
          '服务器返回异常（${error.response?.statusCode ?? '未知状态'}）',
          cause: error,
        ),
      DioExceptionType.connectionError =>
        NetworkException('暂时无法连接网络，请检查网络设置', cause: error),
      DioExceptionType.badCertificate =>
        NetworkException('网络证书校验失败', cause: error),
      DioExceptionType.unknown =>
        NetworkException('网络请求失败，请稍后重试', cause: error),
    };
  }
}
