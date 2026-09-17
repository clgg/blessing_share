import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/storage/shared_preferences_app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppSystemUi.overlayStyle);
  final storage = await SharedPreferencesAppStorage.create();
  runApp(BlessingApp(storage: storage));
}
