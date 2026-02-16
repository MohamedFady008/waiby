import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class OrdersSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const OrdersSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description:
          'Track open orders and configure order handling preferences.',
    );
  }
}
