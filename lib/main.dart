import 'dart:async';

import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/storage/shared_preferences_app_storage.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/wechat/open_share_wechat_gateway.dart';
import 'package:blessing_share/features/wechat/wechat_config.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_common/ui_common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ImageMemoryPolicy.apply();

  // Non-blocking: do not delay the first Flutter frame on chrome mode.
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  SystemChrome.setSystemUIOverlayStyle(AppSystemUi.overlayStyle);

  final repository = LocalBlessingRepository();
  // Prefs + catalog parse in parallel under the native splash.
  final storageFuture = SharedPreferencesAppStorage.create();
  final preloadFuture = repository.preload();
  final storage = await storageFuture;
  await preloadFuture;

  final wechatGateway = await _createWechatGateway();

  runApp(
    BlessingApp(
      storage: storage,
      repository: repository,
      wechatGateway: wechatGateway,
    ),
  );
}

Future<WechatGateway?> _createWechatGateway() async {
  if (!WechatConfig.useRealSdk) return null; // BlessingApp falls back to Demo.
  if (kIsWeb) return null;
  final gateway = OpenShareWechatGateway();
  try {
    await gateway.ensureRegistered(
      appId: WechatConfig.appId,
      universalLink: WechatConfig.universalLink.isEmpty
          ? null
          : WechatConfig.universalLink,
    );
  } catch (error, stack) {
    debugPrint('微信 OpenSDK 注册失败: $error\n$stack');
  }
  return gateway;
}
