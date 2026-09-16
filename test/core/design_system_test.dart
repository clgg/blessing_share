import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/core/widgets/primary_action_button.dart';
import 'package:blessing_share/features/catalog/domain/blessing_category.dart';
import 'package:blessing_share/features/catalog/presentation/widgets/blessing_category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('主按钮高度为 56dp 且文字为 20sp', (tester) async {
    await tester.pumpWidget(
      _testHost(
        PrimaryActionButton(label: '一键分享', onPressed: () {}),
      ),
    );

    expect(tester.getSize(find.byType(PrimaryActionButton)).height, 56);
    final text = tester.widget<Text>(find.text('一键分享'));
    expect(text.style?.fontSize, 20);
  });

  testWidgets('分类卡固定 132dp 且点击区可用', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _testHost(
        BlessingCategoryCard(
          category: category,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(tester.getSize(find.byType(BlessingCategoryCard)).height, 132);
    await tester.tap(find.text('日常问候'));
    expect(tapped, isTrue);
  });

  testWidgets('新 Toast 替换旧 Toast 并提供语义消息', (tester) async {
    await tester.pumpWidget(_testHost(const _ToastHarness()));

    await tester.tap(find.text('显示成功'));
    await tester.pump();
    expect(find.text('保存成功'), findsOneWidget);

    await tester.tap(find.text('显示错误'));
    await tester.pump();
    expect(find.text('保存成功'), findsNothing);
    expect(find.bySemanticsLabel('错误：保存失败'), findsOneWidget);
    AppToast.dismiss();
  });

  testWidgets('1.3 倍字体时主按钮与分类卡不溢出', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: _testHost(
          Column(
            children: [
              BlessingCategoryCard(category: category, onTap: () {}),
              PrimaryActionButton(label: '发给微信好友', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Widget _testHost(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 358, child: child),
      ),
    ),
  );
}

class _ToastHarness extends StatelessWidget {
  const _ToastHarness();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => AppToast.show(
            context,
            type: AppToastType.success,
            message: '保存成功',
          ),
          child: const Text('显示成功'),
        ),
        TextButton(
          onPressed: () => AppToast.show(
            context,
            type: AppToastType.error,
            message: '保存失败',
          ),
          child: const Text('显示错误'),
        ),
      ],
    );
  }
}

const category = BlessingCategory(
  id: 'daily',
  name: '日常问候',
  subtitle: '早安 午安 晚安',
  coverAsset: 'assets/images/daily.jpg',
  sortOrder: 1,
);
