import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wechat_open_share/src/wechat_scene.dart';
import 'package:wechat_open_share/src/wechat_share_response.dart';

/// Dart façade over MethodChannel → native WeChat OpenSDK.
class WechatOpenShare {
  WechatOpenShare({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _method = methodChannel ??
            const MethodChannel('com.clg.wechat_open_share/methods'),
        _events = eventChannel ??
            const EventChannel('com.clg.wechat_open_share/events');

  final MethodChannel _method;
  final EventChannel _events;
  Stream<WechatShareResponse>? _responses;

  /// Register with WeChat Open Platform.
  ///
  /// [universalLink] is required on iOS; ignored on Android.
  Future<bool> register({
    required String appId,
    String? universalLink,
  }) async {
    final ok = await _method.invokeMethod<bool>('register', {
      'appId': appId,
      if (universalLink != null && universalLink.isNotEmpty)
        'universalLink': universalLink,
    });
    return ok ?? false;
  }

  Future<bool> isWeChatInstalled() async {
    final ok = await _method.invokeMethod<bool>('isWeChatInstalled');
    return ok ?? false;
  }

  /// Share a local image file (absolute path) to WeChat.
  ///
  /// Returns whether `sendReq` was accepted by the SDK (not the final user result).
  /// Listen to [responses] for the real outcome after returning from WeChat.
  Future<bool> shareImage({
    required String imagePath,
    WechatShareScene scene = WechatShareScene.session,
    String? title,
    String? description,
  }) async {
    final ok = await _method.invokeMethod<bool>('shareImage', {
      'imagePath': imagePath,
      'scene': scene.wireName,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    });
    return ok ?? false;
  }

  Future<bool> shareText({
    required String text,
    WechatShareScene scene = WechatShareScene.session,
  }) async {
    final ok = await _method.invokeMethod<bool>('shareText', {
      'text': text,
      'scene': scene.wireName,
    });
    return ok ?? false;
  }

  Future<bool> shareWebpage({
    required String url,
    WechatShareScene scene = WechatShareScene.session,
    String? title,
    String? description,
    String? thumbPath,
  }) async {
    final ok = await _method.invokeMethod<bool>('shareWebpage', {
      'url': url,
      'scene': scene.wireName,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (thumbPath != null) 'thumbPath': thumbPath,
    });
    return ok ?? false;
  }

  /// Native → Dart share / auth responses (errCode from WeChat).
  Stream<WechatShareResponse> get responses {
    return _responses ??= _events
        .receiveBroadcastStream()
        .map((event) => WechatShareResponse.fromMap(
              Map<Object?, Object?>.from(event as Map),
            ));
  }
}
