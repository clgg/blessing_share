import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/app/theme_provider.dart';
import 'package:ui_common/ui_common.dart';
import 'package:blessing_share/features/profile/accessibility_settings_provider.dart';
import 'package:blessing_share/features/profile/theme_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AccessibilitySettingsProvider>();
    final themeId = context.watch<ThemeProvider>().themeId;
    final colors = context.blessingColors;

    return AppScaffold(
      title: '设置',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              key: const Key('settings-theme-style'),
              minTileHeight: 68,
              leading: Icon(
                Icons.palette_outlined,
                color: colors.primary,
                size: 30,
              ),
              title: Text(
                '主题风格',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              subtitle: Text('当前：${themeId.label}'),
              trailing: const Icon(Icons.chevron_right_rounded, size: 28),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ThemeSettingsPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              key: const Key('settings-long-press-speak'),
              contentPadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              secondary: Icon(
                Icons.record_voice_over_outlined,
                color: colors.primary,
                size: 30,
              ),
              title: Text(
                '语音开关控制',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              subtitle: const Text(
                '开启后，长按标题、分类和祝福图片可朗读内容；关闭后长按不再朗读。',
              ),
              value: settings.longPressSpeakEnabled,
              onChanged: (value) => context
                  .read<AccessibilitySettingsProvider>()
                  .setLongPressSpeakEnabled(value),
            ),
          ),
        ],
      ),
    );
  }
}
