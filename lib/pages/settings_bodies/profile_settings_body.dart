import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class ProfileSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const ProfileSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Update profile presentation and account identity details.',
    );
  }
}
