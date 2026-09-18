import 'package:blessing_share/app/app_theme.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:blessing_share/features/grid/grid_guide_page.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
import 'package:blessing_share/features/profile/activity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GridPreviewPage extends StatelessWidget {
  const GridPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final grid = context.watch<GridProvider>();
    final theme = grid.selectedTheme;
    return AppScaffold(
      title: '九宫格预览',
      body: theme == null
          ? const AppEmptyState(
              icon: Icons.grid_off_rounded,
              title: '还没有选择主题',
              message: '请返回上一步选择一个九宫格主题。',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(theme.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text('中间第 5 格为您的照片位置',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) =>
                          _GridCell(theme: theme, index: index),
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => _selectPhoto(context),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(grid.hasDemoPhoto ? '已选择演示照片' : '选择照片（演示）'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryActionButton(
                    label: '保存九宫格',
                    icon: Icons.save_alt_rounded,
                    onPressed: () => _complete(context, theme),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '演示版不会写入相册；完成后会生成一条本地记录并展示发布步骤。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
    );
  }

  void _selectPhoto(BuildContext context) {
    context.read<GridProvider>().selectDemoPhoto();
    AppToast.show(
      context,
      type: AppToastType.info,
      message: '已使用演示人物图作为第 5 格照片',
    );
  }

  Future<void> _complete(BuildContext context, GridTheme theme) async {
    context.read<GridProvider>().complete();
    await context.read<ActivityProvider>().recordGrid(theme.id);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GridGuidePage()),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.theme, required this.index});

  final GridTheme theme;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    final position = index + 1;
    final isCenter = position == 5;
    final asset = isCenter
        ? theme.centerPlaceholderAsset
        : theme.previewAssets[index < 4 ? index : index - 1];
    return Stack(
      key: isCenter ? const Key('grid-cell-5-user-photo') : null,
      fit: StackFit.expand,
      children: [
        AppAssetImage(asset, fit: BoxFit.cover),
        Positioned(
          left: 5,
          top: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isCenter ? colors.primary : colors.scrim,
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: 28,
              child: Center(
                child: Text(
                  '$position',
                  style: TextStyle(
                    color: isCenter ? colors.onPrimary : colors.onOverlay,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
