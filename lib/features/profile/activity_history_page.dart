import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:blessing_share/features/profile/domain/activity_record.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage(
      {required this.title, required this.type, super.key});

  final String title;
  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    final records = context
        .watch<ActivityProvider>()
        .records
        .where((record) => record.type == type)
        .toList();
    return AppScaffold(
      title: title,
      body: records.isEmpty
          ? AppEmptyState(
              icon: type == ActivityType.grid
                  ? Icons.grid_view_rounded
                  : Icons.history_rounded,
              title: '暂无$title',
              message: '完成一次对应的演示操作后，记录会显示在这里。',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  child: ListTile(
                    minVerticalPadding: 14,
                    leading: Icon(_icon(record.type), size: 30),
                    title: Text(_description(record)),
                    subtitle: Text(_formatTime(record.createdAt)),
                  ),
                );
              },
            ),
    );
  }

  IconData _icon(ActivityType value) => switch (value) {
        ActivityType.save => Icons.download_done_rounded,
        ActivityType.share => Icons.ios_share_rounded,
        ActivityType.grid => Icons.grid_view_rounded,
      };

  String _description(ActivityRecord record) => switch (record.type) {
        ActivityType.save => '保存演示记录 · ${record.itemId}',
        ActivityType.share => '分享演示记录 · ${record.itemId}',
        ActivityType.grid => '九宫格演示记录 · ${record.itemId}',
      };

  String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
