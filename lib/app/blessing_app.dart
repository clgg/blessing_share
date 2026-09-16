import 'package:blessing_share/app/app_shell.dart';
import 'package:blessing_share/app/app_theme.dart';
import 'package:flutter/material.dart';

class BlessingApp extends StatelessWidget {
  const BlessingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '祝福素材分享',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
