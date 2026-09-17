import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/update/app_update_info.dart';
import 'package:blessing_share/features/update/demo_app_update_gateway.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getCategories();
  });

  testWidgets('进入我的后展示有新版本红点，检测升级可下载并取消', (tester) async {
    final gateway = DemoAppUpdateGateway(
      checkDelay: Duration.zero,
      downloadStepDelay: const Duration(milliseconds: 40),
      downloadSteps: 30,
    );
    await tester.pumpWidget(
      BlessingApp(repository: repository, appUpdateGateway: gateway),
    );

    await tester.tap(find.text('我的'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('有新版本'), findsOneWidget);
    expect(find.byKey(const Key('profile-about-update-badge')), findsOneWidget);

    await tester.ensureVisible(find.text('关于我们'));
    await tester.tap(find.text('关于我们'));
    await tester.pumpAndSettle();

    expect(find.text('检测升级'), findsOneWidget);
    await tester.tap(find.byKey(const Key('about-check-update')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-update-dialog')), findsOneWidget);
    expect(find.textContaining('发现新版本'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-update-start')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byKey(const Key('app-update-progress')), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-update-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-update-dialog')), findsNothing);
  });

  test('演示网关在取消后停止下载', () async {
    final gateway = DemoAppUpdateGateway(
      checkDelay: Duration.zero,
      downloadStepDelay: const Duration(milliseconds: 30),
      downloadSteps: 40,
    );
    final info = await gateway.checkForUpdate(
      currentVersionName: AppVersion.name,
      currentVersionCode: AppVersion.code,
    );
    expect(info, isNotNull);

    final token = CancelToken();
    final future = gateway.downloadApk(
      info!,
      cancelToken: token,
      onProgress: (_) {},
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    token.cancel('stop');
    await expectLater(future, throwsA(isA<DioException>()));
  });
}
