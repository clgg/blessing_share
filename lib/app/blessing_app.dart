import 'package:blessing_share/app/app_shell.dart';
import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/theme_provider.dart';
import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:blessing_share/core/tts/flutter_tts_gateway.dart';
import 'package:blessing_share/core/tts/tts_gateway.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/presentation/catalog_provider.dart';
import 'package:blessing_share/features/favorites/favorites_provider.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
import 'package:blessing_share/features/likes/like_provider.dart';
import 'package:blessing_share/features/profile/accessibility_settings_provider.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/session_provider.dart';
import 'package:blessing_share/features/update/app_update_gateway.dart';
import 'package:blessing_share/features/update/app_update_provider.dart';
import 'package:blessing_share/features/update/demo_app_update_gateway.dart';
import 'package:blessing_share/features/wechat/demo_wechat_gateway.dart';
import 'package:blessing_share/features/wechat/wechat_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BlessingApp extends StatelessWidget {
  const BlessingApp({
    this.repository,
    this.storage,
    this.wechatGateway,
    this.ttsGateway,
    this.appUpdateGateway,
    super.key,
  });

  final BlessingRepository? repository;
  final AppStorage? storage;
  final WechatGateway? wechatGateway;
  final TtsGateway? ttsGateway;
  final AppUpdateGateway? appUpdateGateway;

  @override
  Widget build(BuildContext context) {
    final appStorage = storage ?? MemoryAppStorage();
    return MultiProvider(
      providers: [
        Provider<BlessingRepository>(
          // Default: local JSON assets. For remote:
          // RemoteBlessingRepository.fromBaseUrl('https://api.example.com')
          create: (_) => repository ?? LocalBlessingRepository(),
        ),
        Provider<WechatGateway>(
          lazy: true,
          create: (_) => wechatGateway ?? const DemoWechatGateway(),
        ),
        Provider<TtsGateway>(
          // FlutterTts binds a platform channel — only create on first speak.
          lazy: true,
          create: (_) => ttsGateway ?? FlutterTtsGateway(),
        ),
        Provider<AppUpdateGateway>(
          lazy: true,
          create: (_) => appUpdateGateway ?? const DemoAppUpdateGateway(),
        ),
        ChangeNotifierProvider(
          create: (context) => CatalogProvider(
            repository: context.read<BlessingRepository>(),
          )..loadHome(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage: appStorage)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = FavoritesProvider(storage: appStorage);
            _defer(provider.load);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = LikeProvider(storage: appStorage);
            _defer(provider.load);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = ActivityProvider(storage: appStorage);
            _defer(provider.load);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = SessionProvider(storage: appStorage);
            _defer(provider.load);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = AccessibilitySettingsProvider(storage: appStorage);
            _defer(provider.load);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          lazy: true,
          create: (context) => AppUpdateProvider(
            gateway: context.read<AppUpdateGateway>(),
          ),
        ),
        ChangeNotifierProvider(
          lazy: true,
          create: (_) => GridProvider(),
        ),
      ],
      child: const _BlessingAppView(),
    );
  }
}

void _defer(Future<void> Function() task) {
  // After the first frame so home paint is not competing with prefs reads.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    task();
  });
}

class _BlessingAppView extends StatelessWidget {
  const _BlessingAppView();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      key: const Key('app-system-ui-style'),
      value: AppSystemUi.overlayStyleFor(themeProvider.palette),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '祝福素材分享',
        theme: themeProvider.themeData,
        home: const AppShell(),
      ),
    );
  }
}
