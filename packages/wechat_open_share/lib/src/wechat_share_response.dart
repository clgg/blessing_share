/// Result of a WeChat share (or related) request after the user returns from WeChat.
class WechatShareResponse {
  const WechatShareResponse({
    required this.type,
    required this.errCode,
    this.errStr,
  });

  factory WechatShareResponse.fromMap(Map<Object?, Object?> map) {
    return WechatShareResponse(
      type: map['type'] as String? ?? 'unknown',
      errCode: (map['errCode'] as num?)?.toInt() ?? -1,
      errStr: map['errStr'] as String?,
    );
  }

  /// e.g. `share`, `auth`, `unknown`
  final String type;

  /// 0 success, -2 cancel, -1 common error (see WeChat docs).
  final int errCode;
  final String? errStr;

  bool get isSuccess => errCode == 0;
  bool get isCancelled => errCode == -2;
  bool get isFailed => !isSuccess && !isCancelled;
}
