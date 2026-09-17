abstract interface class TtsGateway {
  /// Speaks [text]. Returns `true` when the platform accepted the utterance.
  Future<bool> speak(String text);

  Future<void> stop();
}
