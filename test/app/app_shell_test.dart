import 'package:blessing_share/app/blessing_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('默认选中首页并按首页收藏我的排列三栏', (tester) async {
    await tester.pumpWidget(const BlessingApp());

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.bySemanticsLabel('首页，已选中'), findsOneWidget);
  });

  testWidgets('切换底栏后显示对应页面', (tester) async {
    await tester.pumpWidget(const BlessingApp());

    await tester.tap(find.text('收藏'));
    await tester.pump();
    expect(find.text('我的收藏'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pump();
    expect(find.text('我的'), findsWidgets);
  });

  testWidgets('每个底栏入口的触控高度不小于 52dp', (tester) async {
    await tester.pumpWidget(const BlessingApp());

    for (final key in const [
      Key('bottom-nav-home'),
      Key('bottom-nav-favorites'),
      Key('bottom-nav-profile'),
    ]) {
      expect(tester.getSize(find.byKey(key)).height, greaterThanOrEqualTo(52));
    }
  });
}
