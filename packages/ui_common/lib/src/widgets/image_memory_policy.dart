import 'package:flutter/painting.dart';

/// Caps how many decoded bitmaps stay resident.
///
/// Visible images keep full on-screen sharpness; older off-screen bitmaps are
/// evicted sooner so large catalog assets do not accumulate in RAM.
abstract final class ImageMemoryPolicy {
  static const int maxLiveImages = 80;
  static const int maxLiveBytes = 64 << 20; // 64 MiB

  static void apply() {
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = maxLiveImages;
    cache.maximumSizeBytes = maxLiveBytes;
  }
}
