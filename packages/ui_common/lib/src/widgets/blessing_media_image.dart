import 'package:flutter/material.dart';
import 'package:ui_common/src/widgets/image_decode.dart';

/// Displays a blessing image from a CDN when available, with an offline asset
/// fallback for the bundled catalog.
///
/// When [cacheWidth]/[cacheHeight] are omitted, decodes at the laid-out size ×
/// device pixel ratio so on-screen sharpness is full while memory stays low.
class BlessingMediaImage extends StatelessWidget {
  const BlessingMediaImage({
    this.assetPath,
    this.networkUrl,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.imageKey,
    this.cacheWidth,
    this.cacheHeight,
    this.decodeScale = 1,
    this.filterQuality = FilterQuality.medium,
    super.key,
  }) : assert(assetPath != null || networkUrl != null);

  final String? assetPath;
  final String? networkUrl;
  final BoxFit fit;
  final String? semanticLabel;
  final Key? imageKey;

  /// Explicit decode size in physical pixels. Prefer omitting these so layout
  /// drives decode size automatically.
  final int? cacheWidth;
  final int? cacheHeight;

  /// `1` = screen sharpness; use `>1` for pinch-zoom surfaces.
  final double decodeScale;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    if (cacheWidth != null || cacheHeight != null) {
      return _build(cacheWidth, cacheHeight);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final dims = ImageDecode.forConstraints(
          constraints,
          MediaQuery.devicePixelRatioOf(context),
          scale: decodeScale,
        );
        return _build(dims.width, dims.height);
      },
    );
  }

  Widget _build(int? width, int? height) {
    final url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        key: imageKey,
        fit: fit,
        semanticLabel: semanticLabel,
        cacheWidth: width,
        cacheHeight: height,
        filterQuality: filterQuality,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _assetOrPlaceholder(
          width,
          height,
        ),
      );
    }
    return _assetOrPlaceholder(width, height);
  }

  Widget _assetOrPlaceholder(int? width, int? height) {
    final asset = assetPath?.trim();
    if (asset == null || asset.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFE8E2D8),
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      );
    }
    return Image.asset(
      asset,
      key: imageKey,
      fit: fit,
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
