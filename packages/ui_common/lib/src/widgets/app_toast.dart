import 'dart:async';

import 'package:ui_common/src/theme/blessing_palette.dart';
import 'package:flutter/material.dart';

enum AppToastType { success, info, error, undo }

extension on AppToastType {
  String get label => switch (this) {
        AppToastType.success => '成功',
        AppToastType.info => '信息',
        AppToastType.error => '错误',
        AppToastType.undo => '可撤销',
      };

  Duration get duration => switch (this) {
        AppToastType.success => const Duration(milliseconds: 3500),
        AppToastType.info => const Duration(milliseconds: 4500),
        AppToastType.error => const Duration(milliseconds: 8000),
        AppToastType.undo => const Duration(milliseconds: 6000),
      };

  IconData get icon => switch (this) {
        AppToastType.success => Icons.check_circle_outline,
        AppToastType.info => Icons.info_outline,
        AppToastType.error => Icons.error_outline,
        AppToastType.undo => Icons.undo_rounded,
      };

  Color foreground(BlessingPalette colors) => switch (this) {
        AppToastType.success => colors.success,
        AppToastType.info => colors.info,
        AppToastType.error => colors.danger,
        AppToastType.undo => colors.warning,
      };

  Color container(BlessingPalette colors) => switch (this) {
        AppToastType.success => colors.successContainer,
        AppToastType.info => colors.infoContainer,
        AppToastType.error => colors.dangerContainer,
        AppToastType.undo => colors.warningContainer,
      };
}

abstract final class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required AppToastType type,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    dismiss();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) {
        final colors = context.blessingColors;
        final tone = type.foreground(colors);
        final fill = type.container(colors);
        return Positioned(
          left: 16,
          right: 16,
          bottom: 88,
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 358, minHeight: 64),
                child: IgnorePointer(
                  ignoring: actionLabel == null || onAction == null,
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    label: '${type.label}：$message',
                    excludeSemantics: true,
                    child: Material(
                      color: fill,
                      borderRadius: BorderRadius.circular(16),
                      elevation: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border:
                              Border(left: BorderSide(color: tone, width: 8)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(type.icon, color: tone, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: tone,
                                    fontSize: 18,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (actionLabel != null && onAction != null)
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      dismiss();
                                      onAction();
                                    },
                                    child: Text(
                                      actionLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: tone,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    _currentEntry = entry;
    overlay.insert(entry);
    _timer = Timer(type.duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
