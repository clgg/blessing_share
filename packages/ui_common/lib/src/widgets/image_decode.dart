import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Helpers for decoding images at on-screen resolution.
///
/// Decoding at `logicalSize × devicePixelRatio` keeps full display sharpness
/// while avoiding multi-megapixel bitmaps that waste memory.
abstract final class ImageDecode {
  /// Soft ceiling so a mis-sized constraint cannot allocate huge bitmaps.
  static const int maxEdgePx = 4096;

  /// Physical pixel size for a layout box. Prefers both edges when bounded
  /// (typical for [BoxFit.cover] tiles); otherwise a single edge is enough.
  static ({int? width, int? height}) forConstraints(
    BoxConstraints constraints,
    double devicePixelRatio, {
    double scale = 1,
  }) {
    final dpr = math.max(devicePixelRatio, 1) * math.max(scale, 1);
    int? width;
    int? height;
    if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite) {
      width = _px(constraints.maxWidth * dpr);
    }
    if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
      height = _px(constraints.maxHeight * dpr);
    }
    return (width: width, height: height);
  }

  static int _px(double value) =>
      value.ceil().clamp(1, maxEdgePx).toInt();
}
