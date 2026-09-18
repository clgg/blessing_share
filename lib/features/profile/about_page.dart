import 'package:blessing_share/app/app_theme.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/features/update/app_update_info.dart';
import 'package:blessing_share/features/update/app_update_provider.dart';
import 'package:blessing_share/features/update/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final update = context.watch<AppUpdateProvider>();

    return AppScaffold(
      title: '关于我们',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: colors.primary,
                  child: Icon(
                    Icons.volunteer_activism_rounded,
                    color: colors.onPrimary,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '祝福素材分享',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '框架演示版 ${AppVersion.name}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Text(
                  '用简单清晰的方式，帮助每个人把祝福送给重要的人。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: ListTile(
              key: const Key('about-check-update'),
              minTileHeight: 68,
              leading: Icon(
                Icons.system_update_alt_rounded,
                color: colors.primary,
                size: 30,
              ),
              title: Text(
                '检测升级',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              subtitle: Text(
                update.hasUpdate
                    ? '有新版本 ${update.availableUpdate!.versionName}'
                    : update.isChecking
                        ? '正在检查更新…'
                        : '当前已是最新版本',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (update.hasUpdate) ...[
                    const _UpdateBadge(),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.chevron_right_rounded, size: 28),
                ],
              ),
              onTap: () => _onCheckUpdate(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCheckUpdate(BuildContext context) async {
    final provider = context.read<AppUpdateProvider>();
    if (!provider.hasUpdate) {
      await provider.checkForUpdate(force: true);
      if (!context.mounted) return;
    }
    if (provider.hasUpdate) {
      await showAppUpdateDialog(context);
      return;
    }
    if (!context.mounted) return;
    AppToast.show(
      context,
      type: AppToastType.info,
      message: provider.lastError ?? '当前已是最新版本',
    );
  }
}

class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: context.blessingColors.danger,
        shape: BoxShape.circle,
      ),
    );
  }
}
