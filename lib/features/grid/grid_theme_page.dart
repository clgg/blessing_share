import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/app_empty_state.dart';
import 'package:blessing_share/core/widgets/app_scaffold.dart';
import 'package:blessing_share/features/catalog/domain/blessing_repository.dart';
import 'package:blessing_share/features/catalog/domain/grid_theme.dart';
import 'package:blessing_share/features/grid/grid_preview_page.dart';
import 'package:blessing_share/features/grid/grid_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GridThemePage extends StatefulWidget {
  const GridThemePage({super.key});

  @override
  State<GridThemePage> createState() => _GridThemePageState();
}

class _GridThemePageState extends State<GridThemePage> {
  late final Future<List<GridTheme>> _themes =
      context.read<BlessingRepository>().getGridThemes();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '选择九宫格主题',
      body: FutureBuilder<List<GridTheme>>(
        future: _themes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const AppEmptyState(
              icon: Icons.grid_off_rounded,
              title: '主题暂时没有加载出来',
              message: '请返回首页后重新打开九宫格。',
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              children: [
                for (final theme in snapshot.requireData) ...[
                  _ThemeCard(theme: theme, onTap: () => _select(theme)),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _select(GridTheme theme) {
    context.read<GridProvider>().selectTheme(theme);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GridPreviewPage()),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.theme, required this.onTap});

  final GridTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.blessingColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: Image.asset(theme.previewAssets.first, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(theme.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('点击查看九格预览',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
