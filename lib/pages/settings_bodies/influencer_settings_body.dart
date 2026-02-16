import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class InfluencerSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const InfluencerSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description:
          'Manage influencer program eligibility and campaign settings.',
    );
  }
}
