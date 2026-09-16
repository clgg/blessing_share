import 'dart:convert';
import 'dart:typed_data';

import 'package:blessing_share/core/network/api_client.dart';
import 'package:blessing_share/core/network/app_exception.dart';
import 'package:blessing_share/features/catalog/data/remote_blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/wechat/demo_wechat_gateway.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiClient 配置固定超时和 JSON 请求头', () {
    final dio = ApiClient.create('https://example.test');
    expect(dio.options.connectTimeout, const Duration(seconds: 8));
    expect(dio.options.receiveTimeout, const Duration(seconds: 12));
    expect(dio.options.headers['Accept'], 'application/json');
  });

  test('远程 Repository 将分类响应映射为领域模型', () async {
    final dio = Dio()..httpClientAdapter = _FixtureAdapter(categoriesResponse);
    final repository = RemoteBlessingRepository(dio: dio);

    final categories = await repository.getCategories();

    expect(categories.first.id, 'daily');
    expect(categories.first.name, '日常问候');
  });

  test('远程 Repository 区分超时与损坏 JSON', () async {
    final timeoutDio = Dio()..httpClientAdapter = _TimeoutAdapter();
    expect(
      RemoteBlessingRepository(dio: timeoutDio).getCategories(),
      throwsA(
        isA<AppException>()
            .having((error) => error.message, 'message', contains('超时')),
      ),
    );

    final malformedDio = Dio()
      ..httpClientAdapter = _FixtureAdapter({'data': 'bad'});
    expect(
      RemoteBlessingRepository(dio: malformedDio).getCategories(),
      throwsA(isA<DataFormatException>()),
    );
  });

  test('演示微信网关明确返回 demo 状态', () async {
    final result = await const DemoWechatGateway().shareToFriend(dailyItem);
    expect(result.status, WechatStatus.demo);
    expect(result.message, contains('演示'));
  });
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.data);

  final Object data;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _TimeoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionTimeout,
    );
  }

  @override
  void close({bool force = false}) {}
}

const categoriesResponse = {
  'data': [
    {
      'id': 'daily',
      'name': '日常问候',
      'subtitle': '早安 午安 晚安',
      'coverAsset': 'assets/images/daily.jpg',
      'sortOrder': 1,
    },
  ],
};

const dailyItem = BlessingItem(
  id: 'daily_1',
  title: '早安暖心',
  caption: '新的一天，愿平安顺遂',
  categoryId: 'daily',
  thumbnailAsset: 'assets/images/daily.jpg',
  imageAsset: 'assets/images/daily.jpg',
  tags: ['早安'],
  featured: true,
);
