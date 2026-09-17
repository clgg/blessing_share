import 'package:blessing_share/core/tts/tts_gateway.dart';
import 'package:blessing_share/core/widgets/app_toast.dart';
import 'package:blessing_share/features/profile/accessibility_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> speakForAccessibility(
  BuildContext context,
  String text, {
  bool showToast = false,
}) async {
  final value = text.trim();
  if (value.isEmpty || !context.mounted) return;
  final speakEnabled =
      context.read<AccessibilitySettingsProvider>().longPressSpeakEnabled;
  if (!speakEnabled) return;

  final tts = context.read<TtsGateway>();
  // Do not await haptics: some test/host environments never complete the future.
  HapticFeedback.lightImpact();
  if (showToast && context.mounted) {
    AppToast.show(
      context,
      type: AppToastType.info,
      message: '正在朗读',
    );
  }
  final ok = await tts.speak(value);
  if (!ok && context.mounted) {
    AppToast.show(
      context,
      type: AppToastType.error,
      message: '朗读失败，请检查系统语音或音量',
    );
  }
}

/// Long-press to hear [text]. Useful for titles, captions, and image labels.
class Speakable extends StatelessWidget {
  const Speakable({
    required this.text,
    required this.child,
    this.enabled = true,
    this.showToast = false,
    this.borderRadius,
    super.key,
  });

  final String text;
  final Widget child;
  final bool enabled;
  final bool showToast;
  /// Clips the long-press ink highlight to match rounded cards.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final value = text.trim();
    final speakEnabled =
        context.watch<AccessibilitySettingsProvider>().longPressSpeakEnabled;
    if (!enabled || !speakEnabled || value.isEmpty) return child;
    return Semantics(
      label: value,
      hint: '长按朗读',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borderRadius,
          onLongPress: () {
            speakForAccessibility(
              context,
              value,
              showToast: showToast,
            );
          },
          child: child,
        ),
      ),
    );
  }
}
