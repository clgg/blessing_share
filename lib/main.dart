import 'dart:async';

import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/storage/shared_preferences_app_storage.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
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

  runApp(
    BlessingApp(
      storage: storage,
      repository: repository,
    ),
  );
}
