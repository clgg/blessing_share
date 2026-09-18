import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_common/ui_common.dart';

export 'package:ui_common/ui_common.dart'
    show
        AppDimens,
        AppThemeId,
        AppThemeIdX,
        BlessingPalette,
        BlessingThemeContext;

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
        titleTextStyle: TextStyle(
          fontFamily: 'NotoSansSC',
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: palette.title,
        ),
      ),
      cardTheme: CardTheme(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
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
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.border),
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 18,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: palette.primary.withOpacity(0.16),
        backgroundColor: palette.card,
        side: BorderSide(color: palette.border),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 15,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: palette.onPrimary,
          fontSize: 15,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
        checkmarkColor: palette.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppDimens.spaceMd,
        minTileHeight: AppDimens.listTileMinHeight,
        iconColor: palette.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 15,
          height: 1.35,
          color: palette.textSecondary,
        ),
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
