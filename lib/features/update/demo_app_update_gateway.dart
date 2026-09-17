import 'package:blessing_share/core/network/app_exception.dart';
import 'package:blessing_share/features/update/app_update_gateway.dart';
import 'package:blessing_share/features/update/app_update_info.dart';
import 'package:dio/dio.dart';

/// Demo updater that always reports a newer version and fakes APK download.
class DemoAppUpdateGateway implements AppUpdateGateway {
  const DemoAppUpdateGateway({
    this.checkDelay = Duration.zero,
    this.downloadStepDelay = const Duration(milliseconds: 50),
    this.downloadSteps = 20,
  });

  final Duration checkDelay;
  final Duration downloadStepDelay;
  final int downloadSteps;

  static const demoUpdate = AppUpdateInfo(
    versionName: '1.0.1',
    versionCode: 2,
    releaseNotes: '优化长按朗读体验，并改进分类列表上拉加载。',
    apkUrl: 'https://example.test/blessing_share_1.0.1.apk',
  );

  @override
  Future<AppUpdateInfo?> checkForUpdate({
    required String currentVersionName,
    required int currentVersionCode,
  }) async {
    if (checkDelay > Duration.zero) {
      await Future<void>.delayed(checkDelay);
    }
    if (demoUpdate.versionCode <= currentVersionCode) return null;
    return demoUpdate;
  }

  @override
  Future<String> downloadApk(
    AppUpdateInfo info, {
    required void Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final steps = downloadSteps <= 0 ? 1 : downloadSteps;
    for (var step = 1; step <= steps; step++) {
      if (cancelToken?.isCancelled ?? false) {
        throw DioException(
          requestOptions: RequestOptions(path: info.apkUrl),
          type: DioExceptionType.cancel,
          error: const RequestCancelledException('下载已取消'),
        );
      }
      if (downloadStepDelay > Duration.zero) {
        await Future<void>.delayed(downloadStepDelay);
      }
      onProgress(step / steps);
    }
    return 'demo://blessing_share_${info.versionName}.apk';
  }
}
