import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Available visual themes for the blessing app.
enum AppThemeId {
  festiveRed,
  freshGreen,
  nobleGold,
}

extension AppThemeIdX on AppThemeId {
  String get label => switch (this) {
        AppThemeId.festiveRed => '喜庆红',
        AppThemeId.freshGreen => '清新绿',
        AppThemeId.nobleGold => '高贵金',
      };

  String get subtitle => switch (this) {
        AppThemeId.festiveRed => '热闹喜庆，适合节日与团圆',
        AppThemeId.freshGreen => '清爽自然，适合日常问候',
        AppThemeId.nobleGold => '沉稳典雅，适合郑重祝福',
      };
}

/// Semantic colors for the product. Always read via [BuildContext.blessingColors].
@immutable
class BlessingPalette extends ThemeExtension<BlessingPalette> {
  const BlessingPalette({
    required this.background,
    required this.card,
    required this.primary,
    required this.title,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.border,
    required this.onPrimary,
    required this.onOverlay,
    required this.overlayStrong,
    required this.overlaySoft,
    required this.scrim,
    required this.success,
    required this.successContainer,
    required this.info,
    required this.infoContainer,
    required this.danger,
    required this.dangerContainer,
    required this.warning,
    required this.warningContainer,
    required this.confirmIdle,
    required this.confirmReady,
  });

  final Color background;
  final Color card;
  final Color primary;
  final Color title;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color border;
  final Color onPrimary;
  final Color onOverlay;
  final Color overlayStrong;
  final Color overlaySoft;
  final Color scrim;
  final Color success;
  final Color successContainer;
  final Color info;
  final Color infoContainer;
  final Color danger;
  final Color dangerContainer;
  final Color warning;
  final Color warningContainer;
  final Color confirmIdle;
  final Color confirmReady;

  static const festiveRed = BlessingPalette(
    background: Color(0xFFFFF8EE),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFFC9252E),
    title: Color(0xFF6F1515),
    textPrimary: Color(0xFF3D1B18),
    textSecondary: Color(0xFF815F54),
    accent: Color(0xFFD6A15C),
    border: Color(0xFFE9D9C7),
    onPrimary: Color(0xFFFFFFFF),
    onOverlay: Color(0xFFFFFFFF),
    overlayStrong: Color(0xCC5B1010),
    overlaySoft: Color(0x335B1010),
    scrim: Color(0x8A000000),
    success: Color(0xFF2E8B62),
    successContainer: Color(0xFFE6F4EE),
    info: Color(0xFF337AB7),
    infoContainer: Color(0xFFEAF3FB),
    danger: Color(0xFFC9252E),
    dangerContainer: Color(0xFFFCEBED),
    warning: Color(0xFFB56A10),
    warningContainer: Color(0xFFFFF3DD),
    confirmIdle: Color(0xFFB8A79A),
    confirmReady: Color(0xFF2F9E44),
  );

  static const freshGreen = BlessingPalette(
    background: Color(0xFFF3FAF4),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF2F8F5B),
    title: Color(0xFF1B5E3A),
    textPrimary: Color(0xFF1E3328),
    textSecondary: Color(0xFF5A7364),
    accent: Color(0xFFC4A35A),
    border: Color(0xFFD5E6DA),
    onPrimary: Color(0xFFFFFFFF),
    onOverlay: Color(0xFFFFFFFF),
    overlayStrong: Color(0xCC143D28),
    overlaySoft: Color(0x33143D28),
    scrim: Color(0x8A000000),
    success: Color(0xFF2F8F5B),
    successContainer: Color(0xFFE3F5EA),
    info: Color(0xFF3A7CA5),
    infoContainer: Color(0xFFE8F3F8),
    danger: Color(0xFFC45C4A),
    dangerContainer: Color(0xFFFCEDEA),
    warning: Color(0xFFA67B2B),
    warningContainer: Color(0xFFFFF4E0),
    confirmIdle: Color(0xFF9AB5A8),
    confirmReady: Color(0xFF2F9E44),
  );

  static const nobleGold = BlessingPalette(
    background: Color(0xFFFBF6EA),
    card: Color(0xFFFFFCF5),
    primary: Color(0xFFC9A227),
    title: Color(0xFF7A5C14),
    textPrimary: Color(0xFF3D3218),
    textSecondary: Color(0xFF8A7350),
    accent: Color(0xFF8B6914),
    border: Color(0xFFE8DCC0),
    onPrimary: Color(0xFF2A220C),
    onOverlay: Color(0xFFFFF8E7),
    overlayStrong: Color(0xCC5C4814),
    overlaySoft: Color(0x335C4814),
    scrim: Color(0x8A000000),
    success: Color(0xFF4F8A5B),
    successContainer: Color(0xFFE8F3EA),
    info: Color(0xFF6A7FA0),
    infoContainer: Color(0xFFEEF2F7),
    danger: Color(0xFFB85C45),
    dangerContainer: Color(0xFFF8ECE8),
    warning: Color(0xFFB8860B),
    warningContainer: Color(0xFFFFF6DF),
    confirmIdle: Color(0xFFC4B495),
    confirmReady: Color(0xFF4F8A5B),
  );

  static BlessingPalette of(AppThemeId id) => switch (id) {
        AppThemeId.festiveRed => festiveRed,
        AppThemeId.freshGreen => freshGreen,
        AppThemeId.nobleGold => nobleGold,
      };

  @override
  BlessingPalette copyWith({
    Color? background,
    Color? card,
    Color? primary,
    Color? title,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? border,
    Color? onPrimary,
    Color? onOverlay,
    Color? overlayStrong,
    Color? overlaySoft,
    Color? scrim,
    Color? success,
    Color? successContainer,
    Color? info,
    Color? infoContainer,
    Color? danger,
    Color? dangerContainer,
    Color? warning,
    Color? warningContainer,
    Color? confirmIdle,
    Color? confirmReady,
  }) {
    return BlessingPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      title: title ?? this.title,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      border: border ?? this.border,
      onPrimary: onPrimary ?? this.onPrimary,
      onOverlay: onOverlay ?? this.onOverlay,
      overlayStrong: overlayStrong ?? this.overlayStrong,
      overlaySoft: overlaySoft ?? this.overlaySoft,
      scrim: scrim ?? this.scrim,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      confirmIdle: confirmIdle ?? this.confirmIdle,
      confirmReady: confirmReady ?? this.confirmReady,
    );
  }

  @override
  BlessingPalette lerp(ThemeExtension<BlessingPalette>? other, double t) {
    if (other is! BlessingPalette) return this;
    return BlessingPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      title: Color.lerp(title, other.title, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      border: Color.lerp(border, other.border, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onOverlay: Color.lerp(onOverlay, other.onOverlay, t)!,
      overlayStrong: Color.lerp(overlayStrong, other.overlayStrong, t)!,
      overlaySoft: Color.lerp(overlaySoft, other.overlaySoft, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      confirmIdle: Color.lerp(confirmIdle, other.confirmIdle, t)!,
      confirmReady: Color.lerp(confirmReady, other.confirmReady, t)!,
    );
  }
}

extension BlessingThemeContext on BuildContext {
  BlessingPalette get blessingColors =>
      Theme.of(this).extension<BlessingPalette>()!;
}

abstract final class AppSystemUi {
  static SystemUiOverlayStyle overlayStyleFor(BlessingPalette palette) {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
    );
  }

  /// Default overlay used before the first theme frame.
  static const overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
  );
}

abstract final class AppTheme {
  static ThemeData of(AppThemeId id) => fromPalette(BlessingPalette.of(id));

  /// Defaults to the festive red theme.
  static ThemeData light() => of(AppThemeId.festiveRed);

  static ThemeData fromPalette(BlessingPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.light,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.accent,
      surface: palette.card,
      onSurface: palette.textPrimary,
      error: palette.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      extensions: <ThemeExtension<dynamic>>[palette],
      appBarTheme: AppBarTheme(
        systemOverlayStyle: AppSystemUi.overlayStyleFor(palette),
        foregroundColor: palette.title,
      ),
      cardTheme: CardTheme(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: palette.border,
      iconTheme: IconThemeData(color: palette.textPrimary),
      fontFamily: 'NotoSansSC',
      textTheme: TextTheme(
        displaySmall: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontSize: 32,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: palette.title,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: palette.title,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          height: 1.4,
          color: palette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: palette.textSecondary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.border),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: palette.primary.withOpacity(0.16),
        labelStyle: TextStyle(color: palette.textPrimary),
        secondaryLabelStyle: TextStyle(color: palette.onPrimary),
        checkmarkColor: palette.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return null;
        }),
      ),
    );
  }
}
