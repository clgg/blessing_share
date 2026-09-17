import 'package:blessing_share/core/tts/tts_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlutterTtsGateway implements TtsGateway {
  FlutterTtsGateway();

  final FlutterTts _tts = FlutterTts();
  Future<void>? _ready;

  Future<void> _ensureReady() {
    return _ready ??= _configure().catchError((Object error, StackTrace stack) {
      // Allow a later speak() to retry initialization.
      _ready = null;
      Error.throwWithStackTrace(error, stack);
    });
  }

  Future<void> _configure() async {
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    if (isIos) {
      // Shared instance + playback category: TTS still audibles with Silent switch on.
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }

    await _setPreferredChineseLanguage();
    // Slightly slower speech helps older users follow along.
    await _tts.setSpeechRate(isIos ? 0.45 : 0.42);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _setPreferredChineseLanguage() async {
    const candidates = <String>[
      'zh-CN',
      'zh_CN',
      'zh-Hans',
      'zh-Hans-CN',
      'cmn-Hans-CN',
      'zh',
    ];

    for (final language in candidates) {
      if (await _isAvailable(language)) {
        await _tts.setLanguage(language);
        return;
      }
    }

    // Fall back to any installed Chinese voice the engine reports.
    try {
      final languages = await _tts.getLanguages;
      if (languages is Iterable) {
        for (final raw in languages) {
          final language = raw.toString();
          final normalized = language.toLowerCase();
          if (normalized.startsWith('zh') || normalized.startsWith('cmn')) {
            await _tts.setLanguage(language);
            return;
          }
        }
      }
    } catch (error, stackTrace) {
      debugPrint('TTS 枚举语言失败: $error\n$stackTrace');
    }

    // Last resort — some devices still speak with the system default voice.
    await _tts.setLanguage('zh-CN');
  }

  Future<bool> _isAvailable(String language) async {
    try {
      final result = await _tts.isLanguageAvailable(language);
      return result == true || result == 1;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> speak(String text) async {
    final value = text.trim();
    if (value.isEmpty) return false;
    try {
      await _ensureReady();
      await _tts.stop();
      final result = await _tts.speak(value);
      return result == 1 || result == true;
    } catch (error, stackTrace) {
      debugPrint('TTS 朗读失败: $error\n$stackTrace');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
