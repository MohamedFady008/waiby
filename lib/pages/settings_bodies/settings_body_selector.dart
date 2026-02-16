import 'package:flutter/material.dart';

import '../../widgets/settings_sidebar.dart';
import 'calendar_settings_body.dart';
import 'chat_settings_body.dart';
import 'customers_settings_body.dart';
import 'dashboard_settings_body.dart';
import 'influencer_settings_body.dart';
import 'orders_settings_body.dart';
import 'profile_settings_body.dart';
import 'rankings_settings_body.dart';
import 'score_rate_settings_body.dart';
import 'services_settings_body.dart';
import 'settings_settings_body.dart';
import 'store_settings_body.dart';
import 'tickets_settings_body.dart';
import 'unknown_settings_body.dart';
import 'vip_settings_body.dart';
import 'wallet_settings_body.dart';

typedef SettingsBodyBuilder = Widget Function(SettingsSidebarMenuEntry entry);

final Map<String, SettingsBodyBuilder> settingsBodySelector =
    <String, SettingsBodyBuilder>{
      'dashboard': (entry) => DashboardSettingsBody(entry: entry),
      'services': (entry) => ServicesSettingsBody(entry: entry),
      'customers': (entry) => CustomersSettingsBody(entry: entry),
      'chat': (entry) => ChatSettingsBody(entry: entry),
      'wallet': (entry) => WalletSettingsBody(entry: entry),
      'vip': (entry) => VipSettingsBody(entry: entry),
      'score-rate': (entry) => ScoreRateSettingsBody(entry: entry),
      'calendar': (entry) => CalendarSettingsBody(entry: entry),
      'orders': (entry) => OrdersSettingsBody(entry: entry),
      'rankings': (entry) => RankingsSettingsBody(entry: entry),
      'influencer': (entry) => InfluencerSettingsBody(entry: entry),
      'store': (entry) => StoreSettingsBody(entry: entry),
      'profile': (entry) => ProfileSettingsBody(entry: entry),
      'tickets': (entry) => TicketsSettingsBody(entry: entry),
      'settings': (entry) => SettingsSettingsBody(entry: entry),
    };

Widget buildSettingsBody(SettingsSidebarMenuEntry entry) {
  final builder = settingsBodySelector[entry.key];
  if (builder == null) {
    return UnknownSettingsBody(entry: entry);
  }
  return builder(entry);
}
