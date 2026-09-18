import 'package:blessing_network/src/response/api_envelope.dart';
import 'package:dio/dio.dart';

/// Creates a configured [Dio] for REST calls.
abstract final class NetworkClient {
  static const defaultConnectTimeout = Duration(seconds: 8);
  static const defaultReceiveTimeout = Duration(seconds: 12);
  static const defaultSendTimeout = Duration(seconds: 12);

  /// Builds Dio with JSON headers, timeouts, optional logging, and envelope unwrap.
  static Dio create(
    String baseUrl, {
    bool enableLogging = false,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    List<Interceptor> extraInterceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout ?? defaultConnectTimeout,
        receiveTimeout: receiveTimeout ?? defaultReceiveTimeout,
        sendTimeout: sendTimeout ?? defaultSendTimeout,
        responseType: ResponseType.json,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(const ApiEnvelopeInterceptor());
    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: false,
          responseBody: false,
        ),
      );
    }
    dio.interceptors.addAll(extraInterceptors);
    return dio;
  }
}
