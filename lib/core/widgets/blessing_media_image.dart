import 'package:flutter/material.dart';

/// Displays a blessing image from a CDN when available, with an offline asset
/// fallback for the bundled catalog.
class BlessingMediaImage extends StatelessWidget {
  const BlessingMediaImage({
    this.assetPath,
    this.networkUrl,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.imageKey,
    super.key,
  }) : assert(assetPath != null || networkUrl != null);

  final String? assetPath;
  final String? networkUrl;
  final BoxFit fit;
  final String? semanticLabel;
  final Key? imageKey;

  @override
  Widget build(BuildContext context) {
    final url = networkUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        key: imageKey,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) => _assetOrPlaceholder(),
      );
    }
    return _assetOrPlaceholder();
  }

  Widget _assetOrPlaceholder() {
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
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: Color(0xFFE8E2D8),
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
