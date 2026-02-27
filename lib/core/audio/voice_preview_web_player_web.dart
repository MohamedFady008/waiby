// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class VoicePreviewWebPlayer {
  html.AudioElement? _audio;
  bool _isPlaying = false;
  bool _listenersBound = false;
  void Function()? _onEnded;

  bool get isAvailable => true;
  bool get isPlaying => _isPlaying;

  void setOnEnded(void Function()? onEnded) {
    _onEnded = onEnded;
  }

  Future<void> play(String url) async {
    final audio = _audio ??= html.AudioElement();
    audio.src = url;
    audio.preload = 'auto';
    if (!_listenersBound) {
      _listenersBound = true;
      audio.onEnded.listen((_) {
        _isPlaying = false;
        _onEnded?.call();
      });
      audio.onPause.listen((_) {
        if ((audio.currentTime > 0) && !audio.ended) {
          _isPlaying = false;
        }
      });
    }
    await audio.play();
    _isPlaying = true;
  }

  Future<void> pause() async {
    _audio?.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    final audio = _audio;
    if (audio == null) {
      return;
    }
    await audio.play();
    _isPlaying = true;
  }

  Future<void> stop() async {
    final audio = _audio;
    if (audio == null) {
      return;
    }
    audio.pause();
    audio.currentTime = 0;
    _isPlaying = false;
  }

  Future<void> dispose() async {
    await stop();
    final audio = _audio;
    if (audio != null) {
      audio.src = '';
      audio.remove();
    }
    _audio = null;
    _listenersBound = false;
  }
}
