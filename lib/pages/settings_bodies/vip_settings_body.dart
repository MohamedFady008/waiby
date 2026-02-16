import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class VipSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const VipSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description: 'Configure subscription tiers and VIP access controls.',
    );
  }
}
