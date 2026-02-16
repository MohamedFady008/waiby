import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'base_settings_body.dart';

class WalletSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const WalletSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return BaseSettingsBody(
      entry: entry,
      description:
          'Inspect wallet balances, payouts, and transaction settings.',
    );
  }
}
