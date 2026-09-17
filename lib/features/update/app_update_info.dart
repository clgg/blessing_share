class AppUpdateInfo {
  const AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.releaseNotes,
    required this.apkUrl,
  });

  final String versionName;
  final int versionCode;
  final String releaseNotes;
  final String apkUrl;
}

/// Matches [pubspec.yaml] `version: 1.0.0+1`.
abstract final class AppVersion {
  static const name = '1.0.0';
  static const code = 1;
}
