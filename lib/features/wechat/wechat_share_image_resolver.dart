import 'dart:io';

import 'package:blessing_share/features/catalog/domain/blessing_item.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Resolves [BlessingItem] media to a local file path for WeChat image share.
class WechatShareImageResolver {
  const WechatShareImageResolver();

  Future<String?> resolveLocalPath(BlessingItem item) async {
    final url = item.imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      // Network images: host app can extend download later; prefer asset for demo.
      // Fall through to asset when both exist.
    }
    final asset = item.imageAsset?.trim() ?? item.thumbnailAsset?.trim();
    if (asset == null || asset.isEmpty) return null;
    return _copyAssetToCache(asset);
  }

  Future<String> _copyAssetToCache(String assetPath) async {
    final dir = await getTemporaryDirectory();
    final name = assetPath.split('/').last;
    final out = File('${dir.path}/wechat_share_$name');
    if (await out.exists() && await out.length() > 0) {
      return out.path;
    }
    final data = await rootBundle.load(assetPath);
    await out.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
    return out.path;
  }
}
