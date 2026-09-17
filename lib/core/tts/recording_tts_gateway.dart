import 'package:blessing_share/core/tts/tts_gateway.dart';

/// In-memory TTS used by widget tests and demos without native plugins.
class RecordingTtsGateway implements TtsGateway {
  final List<String> spoken = <String>[];

  @override
  Future<bool> speak(String text) async {
    final value = text.trim();
    if (value.isEmpty) return false;
    spoken.add(value);
    return true;
  }

  @override
  Future<void> stop() async {}
}
