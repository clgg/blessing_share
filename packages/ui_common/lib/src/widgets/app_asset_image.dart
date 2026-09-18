import 'package:flutter/material.dart';
import 'package:ui_common/src/widgets/image_decode.dart';

/// [Image.asset] that decodes at display × DPR (sharp on screen, lean in memory).
class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.asset, {
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.decodeScale = 1,
    this.cacheWidth,
    this.cacheHeight,
    super.key,
  });

  final String asset;
  final BoxFit fit;
  final String? semanticLabel;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;

  /// Multiply decode size (e.g. zoomable surfaces). `1` = exact screen sharpness.
  final double decodeScale;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    if (cacheWidth != null || cacheHeight != null) {
      return _image(cacheWidth, cacheHeight);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final dims = ImageDecode.forConstraints(
          constraints,
          MediaQuery.devicePixelRatioOf(context),
          scale: decodeScale,
        );
        return _image(dims.width, dims.height);
      },
    );
  }

  Widget _image(int? width, int? height) {
    return Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      cacheWidth: width,
      cacheHeight: height,
      filterQuality: filterQuality,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0xFFE8E2D8),
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
