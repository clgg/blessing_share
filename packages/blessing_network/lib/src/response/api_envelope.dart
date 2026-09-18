import 'package:dio/dio.dart';

/// Unwraps `{ "data": ... }` envelopes so Retrofit sees the inner payload.
///
/// Bare JSON bodies are left unchanged (compatible with both server styles).
final class ApiEnvelopeInterceptor extends Interceptor {
  const ApiEnvelopeInterceptor();

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map && body.containsKey('data') && body.length == 1) {
      response.data = body['data'];
    } else if (body is Map && body.containsKey('data')) {
      // Common API shape: { code, message, data } — prefer data when present.
      final data = body['data'];
      if (data != null) {
        response.data = data;
      }
    }
    handler.next(response);
  }
}
