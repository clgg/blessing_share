import 'package:blessing_network/src/client/network_client.dart';
import 'package:test/test.dart';

void main() {
  test('NetworkClient configures timeouts and JSON headers', () {
    final dio = NetworkClient.create('https://example.test');

    expect(dio.options.baseUrl, 'https://example.test');
    expect(dio.options.connectTimeout, NetworkClient.defaultConnectTimeout);
    expect(dio.options.receiveTimeout, NetworkClient.defaultReceiveTimeout);
    expect(dio.options.sendTimeout, NetworkClient.defaultSendTimeout);
    expect(dio.options.headers['Accept'], 'application/json');
    expect(dio.options.headers['Content-Type'], 'application/json');
    expect(dio.interceptors, isNotEmpty);
  });

  test('NetworkClient enables logging interceptor when requested', () {
    final quiet = NetworkClient.create('https://example.test');
    final verbose = NetworkClient.create(
      'https://example.test',
      enableLogging: true,
    );

    expect(verbose.interceptors.length, greaterThan(quiet.interceptors.length));
  });
}
