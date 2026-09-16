import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/features/profile/about_page.dart';
import 'package:blessing_share/features/profile/activity_history_page.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:blessing_share/features/profile/feedback_page.dart';
import 'package:blessing_share/features/profile/help_page.dart';
import 'package:blessing_share/features/profile/privacy_page.dart';
import 'package:blessing_share/features/profile/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('我的', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 18),
            Material(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: context.read<SessionProvider>().toggleDemoLogin,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 31,
                        backgroundImage:
                            AssetImage('assets/images/placeholder_person.jpg'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.isLoggedIn ? '祝福用户' : '游客模式',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.isLoggedIn ? '点击退出演示登录' : '点击体验演示登录',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 30),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _ProfileMenuTile(
              icon: Icons.ios_share_rounded,
              title: '分享历史',
              subtitle: '查看微信好友与朋友圈演示记录',
              onTap: () => _open(
                context,
                const ActivityHistoryPage(
                  title: '分享历史',
                  type: ActivityType.share,
                ),
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.download_done_rounded,
              title: '保存记录',
              subtitle: '查看保存图片的演示记录',
              onTap: () => _open(
                context,
                const ActivityHistoryPage(
                  title: '保存记录',
                  type: ActivityType.save,
                ),
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.grid_view_rounded,
              title: '我的九宫格',
              subtitle: '查看已经完成的九宫格记录',
              onTap: () => _open(
                context,
                const ActivityHistoryPage(
                  title: '我的九宫格',
                  type: ActivityType.grid,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              title: '使用帮助',
              subtitle: '了解收藏、分享与九宫格操作',
              onTap: () => _open(context, const HelpPage()),
            ),
            _ProfileMenuTile(
              icon: Icons.feedback_outlined,
              title: '意见反馈',
              subtitle: '告诉我们您的问题和建议',
              onTap: () => _open(context, const FeedbackPage()),
            ),
            _ProfileMenuTile(
              icon: Icons.privacy_tip_outlined,
              title: '隐私与权限',
              subtitle: '查看本地数据与权限说明',
              onTap: () => _open(context, const PrivacyPage()),
            ),
            _ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              title: '关于我们',
              subtitle: '版本与产品介绍',
              onTap: () => _open(context, const AboutPage()),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        minTileHeight: 68,
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary, size: 30),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded, size: 28),
      ),
    );
  }
}
