import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_common/ui_common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ImageDecode uses display × DPR without undersampling', () {
    final dims = ImageDecode.forConstraints(
      const BoxConstraints.tightFor(width: 100, height: 80),
      3,
    );
    expect(dims.width, 300);
    expect(dims.height, 240);
  });

  test('ImageDecode respects scale for zoom surfaces', () {
    final dims = ImageDecode.forConstraints(
      const BoxConstraints.tightFor(width: 100, height: 100),
      2,
      scale: 2,
    );
    expect(dims.width, 400);
    expect(dims.height, 400);
  });

  test('ImageMemoryPolicy configures live cache budget', () {
    ImageMemoryPolicy.apply();
    expect(
      PaintingBinding.instance.imageCache.maximumSize,
      ImageMemoryPolicy.maxLiveImages,
    );
    expect(
      PaintingBinding.instance.imageCache.maximumSizeBytes,
      ImageMemoryPolicy.maxLiveBytes,
    );
  });
}
