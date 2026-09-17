import 'package:blessing_share/features/update/app_update_info.dart';
import 'package:dio/dio.dart';

abstract interface class AppUpdateGateway {
  /// Returns update info when a newer version exists; otherwise `null`.
  Future<AppUpdateInfo?> checkForUpdate({
    required String currentVersionName,
    required int currentVersionCode,
  });

  /// Downloads the APK and reports progress in `[0, 1]`.
  /// Throws [DioException] with type cancel when [cancelToken] is cancelled.
  Future<String> downloadApk(
    AppUpdateInfo info, {
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
  });
}
