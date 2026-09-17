import 'package:blessing_share/app/app_theme.dart';
import 'package:blessing_share/core/widgets/blessing_media_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen asset image viewer with pinch-zoom and pan.
class ZoomableImagePage extends StatefulWidget {
  const ZoomableImagePage({
    this.imageAsset,
    this.imageUrl,
    required this.title,
    super.key,
  }) : assert(imageAsset != null || imageUrl != null);

  final String? imageAsset;
  final String? imageUrl;
  final String title;

  /// Opens this viewer. Safe to call from any surface that shows a full asset.
  static Future<void> open(
    BuildContext context, {
    String? imageAsset,
    String? imageUrl,
    required String title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ZoomableImagePage(
          imageAsset: imageAsset,
          imageUrl: imageUrl,
          title: title,
        ),
      ),
    );
  }

  @override
  State<ZoomableImagePage> createState() => _ZoomableImagePageState();
}

class _ZoomableImagePageState extends State<ZoomableImagePage> {
  static const double _minScale = 1;
  static const double _maxScale = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.blessingColors;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        key: const Key('zoomable-image-page'),
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: colors.onOverlay,
          elevation: 0,
          title: Text(
            widget.title,
            style: TextStyle(color: colors.onOverlay),
          ),
        ),
        body: InteractiveViewer(
          minScale: _minScale,
          maxScale: _maxScale,
          child: Center(
            child: BlessingMediaImage(
              assetPath: widget.imageAsset,
              networkUrl: widget.imageUrl,
              fit: BoxFit.contain,
              semanticLabel: widget.title,
            ),
          ),
        ),
      ),
    );
  }
}
