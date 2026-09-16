import 'package:blessing_share/app/blessing_app.dart';
import 'package:blessing_share/app/app_shell.dart';
import 'package:blessing_share/features/catalog/data/local_blessing_repository.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final repository = LocalBlessingRepository();

  setUpAll(() async {
    await repository.getGridThemes();
  });

  testWidgets('预览固定九格且第 5 格为演示照片', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _openGridPreview(tester);

    expect(find.byKey(const Key('grid-cell-5-user-photo')), findsOneWidget);
    for (var index = 1; index <= 9; index++) {
      expect(find.text('$index'), findsOneWidget);
    }
  });

  testWidgets('保存后记录九宫格并进入大字引导', (tester) async {
    await tester.pumpWidget(BlessingApp(repository: repository));
    final activity = Provider.of<ActivityProvider>(
      tester.element(find.byType(AppShell)),
      listen: false,
    );
    await _openGridPreview(tester);

    final save = find.text('保存九宫格');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('打开微信朋友圈'), findsOneWidget);
    expect(activity.records.single.type, ActivityType.grid);
  });

  testWidgets('360dp 九宫格流程无布局溢出', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(BlessingApp(repository: repository));
    await _openGridPreview(tester);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openGridPreview(WidgetTester tester) async {
  await _pumpUntilFound(tester, find.text('朋友圈九宫格'));
  final entry = find.text('朋友圈九宫格');
  await tester.ensureVisible(entry);
  await tester.tap(entry);
  await _pumpUntilFound(tester, find.text('温暖团圆').hitTestable());
  await tester.tap(find.text('温暖团圆').hitTestable());
  await _pumpUntilFound(tester, find.text('保存九宫格'));
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('等待界面内容超时：$finder');
}
