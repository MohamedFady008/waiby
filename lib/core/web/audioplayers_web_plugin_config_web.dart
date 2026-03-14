// ignore_for_file: depend_on_referenced_packages

import 'package:audioplayers_web/audioplayers_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

bool _isAudioplayersPluginRegistered = false;

void ensureAudioplayersWebPluginRegistered() {
  if (_isAudioplayersPluginRegistered) {
    return;
  }
  AudioplayersPlugin.registerWith(webPluginRegistrar);
  _isAudioplayersPluginRegistered = true;
}
