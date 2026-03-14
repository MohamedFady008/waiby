import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class SettingsSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const SettingsSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Edit global account and platform level configuration.',
    );
  }
}
