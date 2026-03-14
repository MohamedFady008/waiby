class VoicePreviewWebPlayer {
  bool get isAvailable => false;
  bool get isPlaying => false;

  void setOnEnded(void Function()? onEnded) {}

  Future<void> play(String url) async {
    throw UnsupportedError('Web audio player is not available.');
  }

  Future<void> pause() async {}

  Future<void> resume() async {}

  Future<void> stop() async {}

  Future<void> dispose() async {}
}
