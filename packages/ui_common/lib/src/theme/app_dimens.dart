import 'package:flutter/material.dart';

/// Shared layout metrics for a consistent 50+ friendly UI.
abstract final class AppDimens {
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spacePageBottom = 32;

  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;

  static const double buttonHeight = 56;
  static const double listTileMinHeight = 68;
  static const double categoryCardHeight = 132;
  static const double gridEntryHeight = 148;
  static const double bottomNavHeight = 76;

  static const double iconSm = 20;
  static const double iconMd = 28;
  static const double iconLg = 30;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    spaceLg,
    spaceMd,
    spaceLg,
    spacePageBottom,
  );

  static const EdgeInsets pagePaddingTab = EdgeInsets.fromLTRB(
    spaceLg,
    22,
    spaceLg,
    spacePageBottom,
  );

  static BorderRadius get radiusLgAll => BorderRadius.circular(radiusLg);
  static BorderRadius get radiusMdAll => BorderRadius.circular(radiusMd);
}
