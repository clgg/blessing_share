import 'dart:convert';
import 'dart:typed_data';

import 'package:blessing_network/blessing_network.dart';
import 'package:blessing_share/core/error/app_exception.dart';
import 'package:blessing_share/features/catalog/data/remote_blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:blessing_share/features/wechat/demo_wechat_gateway.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NetworkClient 配置固定超时和 JSON 请求头', () {
    final dio = NetworkClient.create('https://example.test');
    expect(dio.options.connectTimeout, NetworkClient.defaultConnectTimeout);
    expect(dio.options.receiveTimeout, NetworkClient.defaultReceiveTimeout);
    expect(dio.options.headers['Accept'], 'application/json');
  });

  test('远程 Repository 将分类响应映射为领域模型', () async {
    final repository = _remoteWithFixture(categoriesResponse);

    final categories = await repository.getCategories();

    expect(categories.first.id, 'daily');
    expect(categories.first.name, '日常问候');
  });

  test('远程 Repository 接受仅包含服务端图片 URL 的素材', () async {
    final repository = _remoteWithFixture({
      'data': [
        {
          'id': 'festival_remote_1',
          'title': '春节快乐',
          'caption': '新春纳福，万事如意',
          'categoryId': 'festival',
          'thumbnailUrl': 'https://cdn.example.test/thumb.webp',
          'imageUrl': 'https://cdn.example.test/full.webp',
          'aspectRatio': 0.5625,
          'tags': ['春节'],
          'featured': true,
        },
      ],
    });

    final items = await repository.getByCategory('festival');
    final item = items.single;

    expect(item.thumbnailAsset, isNull);
    expect(item.imageAsset, isNull);
    expect(item.thumbnailUrl, 'https://cdn.example.test/thumb.webp');
    expect(item.imageUrl, 'https://cdn.example.test/full.webp');
  });

  test('远程 Repository 区分超时与损坏 JSON', () async {
    final timeoutDio = NetworkClient.create('https://example.test')
      ..httpClientAdapter = _TimeoutAdapter();
    expect(
      RemoteBlessingRepository(api: BlessingApi(timeoutDio)).getCategories(),
      throwsA(
        isA<AppException>()
            .having((error) => error.message, 'message', contains('超时')),
      ),
    );

    final malformed = _remoteWithFixture({'data': 'bad'});
    expect(
      malformed.getCategories(),
      throwsA(isA<DataFormatException>()),
    );
  });

  test('演示微信网关明确返回 demo 状态', () async {
    final result = await const DemoWechatGateway().shareToFriend(dailyItem);
    expect(result.status, WechatStatus.demo);
    expect(result.message, contains('演示'));
  });
}

RemoteBlessingRepository _remoteWithFixture(Object data) {
  final dio = NetworkClient.create('https://example.test')
    ..httpClientAdapter = _FixtureAdapter(data);
  return RemoteBlessingRepository(api: BlessingApi(dio));
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
  aspectRatio: 1,
);
