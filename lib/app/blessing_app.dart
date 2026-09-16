import 'package:blessing_share/app/app_shell.dart';
import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/session_provider.dart';
import 'package:blessing_share/features/wechat/demo_wechat_gateway.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BlessingApp extends StatelessWidget {
  const BlessingApp({
    this.repository,
    this.storage,
    this.wechatGateway,
    super.key,
  });

  final BlessingRepository? repository;
  final AppStorage? storage;
  final WechatGateway? wechatGateway;

  @override
  Widget build(BuildContext context) {
    final appStorage = storage ?? MemoryAppStorage();
    return MultiProvider(
      providers: [
        Provider<BlessingRepository>(
          create: (_) => repository ?? LocalBlessingRepository(),
        ),
        Provider<WechatGateway>(
          create: (_) => wechatGateway ?? const DemoWechatGateway(),
        ),
        ChangeNotifierProvider(
          create: (context) => CatalogProvider(
            repository: context.read<BlessingRepository>(),
          )..loadHome(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(storage: appStorage)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(storage: appStorage)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(storage: appStorage)..load(),
        ),
        ChangeNotifierProvider(create: (_) => GridProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '祝福素材分享',
        theme: AppTheme.light(),
        home: const AppShell(),
      ),
    );
  }
}
