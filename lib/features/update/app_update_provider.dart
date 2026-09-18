import 'package:blessing_network/blessing_network.dart';
import 'package:blessing_share/core/error/app_exception.dart';
import 'package:blessing_share/features/update/app_update_gateway.dart';
import 'package:blessing_share/features/update/app_update_info.dart';
import 'package:flutter/foundation.dart';

class AppUpdateProvider extends ChangeNotifier {
  AppUpdateProvider({required AppUpdateGateway gateway}) : _gateway = gateway;

  final AppUpdateGateway _gateway;

  AppUpdateInfo? _available;
  bool _checking = false;
  bool _downloading = false;
  double _downloadProgress = 0;
  String? _lastError;
  String? _downloadedPath;
  CancelToken? _downloadCancelToken;
  Future<void>? _checkOperation;

  AppUpdateInfo? get availableUpdate => _available;
  bool get hasUpdate => _available != null;
  bool get isChecking => _checking;
  bool get isDownloading => _downloading;
  double get downloadProgress => _downloadProgress;
  String? get lastError => _lastError;
  String? get downloadedPath => _downloadedPath;

  Future<void> checkForUpdate({bool force = false}) {
    if (!force && _checkOperation != null) return _checkOperation!;
    final operation = _runCheck();
    _checkOperation = operation;
    return operation.whenComplete(() {
      if (identical(_checkOperation, operation)) {
        _checkOperation = null;
      }
    });
  }

  Future<void> _runCheck() async {
    if (_checking) return;
    _checking = true;
    _lastError = null;
    notifyListeners();
    try {
      _available = await _gateway.checkForUpdate(
        currentVersionName: AppVersion.name,
        currentVersionCode: AppVersion.code,
      );
    } catch (error, stackTrace) {
      debugPrint('检查更新失败: $error\n$stackTrace');
      _lastError = error is AppException ? error.message : '检查更新失败，请稍后重试';
      _available = null;
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  Future<String?> downloadUpdate() async {
    final info = _available;
    if (info == null || _downloading) return null;

    _downloading = true;
    _downloadProgress = 0;
    _downloadedPath = null;
    _lastError = null;
    _downloadCancelToken = CancelToken();
    notifyListeners();

    try {
      final path = await _gateway.downloadApk(
        info,
        cancelToken: _downloadCancelToken,
        onProgress: (progress) {
          _downloadProgress = progress.clamp(0.0, 1.0);
          notifyListeners();
        },
      );
      _downloadedPath = path;
      _downloadProgress = 1;
      return path;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.cancel) {
        _lastError = null;
        return null;
      }
      _lastError = NetworkFailureMapper.fromDio(error).message;
      return null;
    } catch (error, stackTrace) {
      debugPrint('下载更新失败: $error\n$stackTrace');
      _lastError = error is AppException ? error.message : '下载失败，请稍后重试';
      return null;
    } finally {
      _downloading = false;
      _downloadCancelToken = null;
      notifyListeners();
    }
  }

  void cancelDownload() {
    final token = _downloadCancelToken;
    if (token == null || token.isCancelled) return;
    token.cancel('user_cancelled');
  }

  void clearDownloadedPath() {
    _downloadedPath = null;
  }
}
