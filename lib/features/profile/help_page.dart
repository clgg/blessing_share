import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '使用帮助',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HelpCard(
            title: '怎样找到祝福素材？',
            body: '在首页选择日常、生日、节日或节气分类，也可以直接打开今日推荐。',
          ),
          _HelpCard(
            title: '怎样收藏？',
            body: '进入图片详情后点击右上角爱心；收藏页支持按分类筛选和撤销误删。',
          ),
          _HelpCard(
            title: '为什么没有真的分享到微信？',
            body: '当前是完整演示框架，只记录操作。后续配置微信开放平台后可替换为真实分享。',
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
