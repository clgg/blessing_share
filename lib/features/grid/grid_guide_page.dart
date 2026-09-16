import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/core/widgets/primary_action_button.dart';
import 'package:flutter/material.dart';

class GridGuidePage extends StatelessWidget {
  const GridGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '九宫格发布引导',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF2E8B62), size: 72),
            const SizedBox(height: 12),
            Text(
              '九宫格演示已完成',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const _GuideStep(number: '1', text: '打开微信朋友圈'),
            const _GuideStep(number: '2', text: '按 1 到 9 的顺序选择图片'),
            const _GuideStep(number: '3', text: '确认顺序后发布祝福'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '当前为框架演示，图片未真实保存，也不会自动打开微信。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: '我知道了',
              onPressed: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
