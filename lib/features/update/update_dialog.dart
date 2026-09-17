import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/features/update/app_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showAppUpdateDialog(BuildContext context) {
  final update = context.read<AppUpdateProvider>().availableUpdate;
  if (update == null) {
    AppToast.show(
      context,
      type: AppToastType.info,
      message: '当前已是最新版本',
    );
    return Future<void>.value();
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _AppUpdateDialog(),
  );
}

class _AppUpdateDialog extends StatelessWidget {
  const _AppUpdateDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppUpdateProvider>();
    final info = provider.availableUpdate;
    final colors = context.blessingColors;
    if (info == null) {
      return const SizedBox.shrink();
    }

    final percent = (provider.downloadProgress * 100).clamp(0, 100).round();

    return AlertDialog(
      key: const Key('app-update-dialog'),
      title: Text('发现新版本 ${info.versionName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.releaseNotes,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (provider.isDownloading) ...[
            const SizedBox(height: 20),
            Text(
              '正在下载安装包 $percent%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                key: const Key('app-update-progress'),
                value: provider.downloadProgress <= 0
                    ? null
                    : provider.downloadProgress,
                minHeight: 10,
                backgroundColor: colors.border,
                color: colors.primary,
              ),
            ),
          ],
          if (provider.lastError != null) ...[
            const SizedBox(height: 12),
            Text(
              provider.lastError!,
              style: TextStyle(color: colors.danger, fontSize: 15),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          key: const Key('app-update-cancel'),
          onPressed: () {
            if (provider.isDownloading) {
              provider.cancelDownload();
            }
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        if (!provider.isDownloading)
          FilledButton(
            key: const Key('app-update-start'),
            onPressed: () async {
              final path = await provider.downloadUpdate();
              if (!context.mounted) return;
              if (path == null) {
                if (provider.lastError == null) {
                  // Cancelled while dialog still open.
                  return;
                }
                return;
              }
              Navigator.of(context).pop();
              AppToast.show(
                context,
                type: AppToastType.success,
                message: '安装包已下载完成（演示）',
              );
              provider.clearDownloadedPath();
            },
            child: const Text('立即更新'),
          ),
      ],
    );
  }
}
