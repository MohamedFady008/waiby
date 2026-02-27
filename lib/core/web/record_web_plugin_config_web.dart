// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:record_web/record_web.dart';

bool _isRecordPluginRegistered = false;

void ensureRecordWebPluginRegistered() {
  if (_isRecordPluginRegistered) {
    return;
  }
  RecordPluginWeb.registerWith(webPluginRegistrar);
  _isRecordPluginRegistered = true;
}
