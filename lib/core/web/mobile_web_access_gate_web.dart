// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

final RegExp _mobileUserAgentPattern = RegExp(
  r'android|iphone|ipod|ipad|mobile|blackberry|iemobile|opera mini',
  caseSensitive: false,
);

bool shouldRestrictMobileWebAccess() {
  final navigator = html.window.navigator;
  final userAgent = navigator.userAgent ?? '';
  final platform = navigator.platform ?? '';
  final maxTouchPoints = navigator.maxTouchPoints ?? 0;
  final isIpadOsDesktopMode =
      platform.toLowerCase().contains('mac') && maxTouchPoints > 1;

  return _mobileUserAgentPattern.hasMatch(userAgent) || isIpadOsDesktopMode;
}
