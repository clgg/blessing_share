import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/core/storage/shared_preferences_app_storage.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await SharedPreferencesAppStorage.create();
  runApp(BlessingApp(storage: storage));
}
