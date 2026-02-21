import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

const List<String> _tabs = <String>[
  'My Profile',
  'Edit Profile',
  'Notifications',
  'Privacy',
  'Language',
  'Referrals',
  'IM Settings',
];

class ProfileSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const ProfileSettingsBody({super.key, required this.entry});

  @override
  State<ProfileSettingsBody> createState() => _ProfileSettingsBodyState();
}

class _ProfileSettingsBodyState extends State<ProfileSettingsBody> {
  int _selected = 0;
  String _selectedLanguage = 'English';

  Widget _currentView() {
    switch (_selected) {
      case 0:
        return const _MyProfileTab();
      case 1:
        return const _EditProfileTab();
      case 2:
        return const _NotificationsTab();
      case 3:
        return const _PrivacyTab();
      case 4:
        return _LanguageTab(
          selectedLanguage: _selectedLanguage,
          onSelectLanguage: (language) =>
              setState(() => _selectedLanguage = language),
        );
      case 5:
        return const _ReferralsTab();
      default:
        return _PlaceholderTab(title: _tabs[_selected]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1650),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1220;
            final left = Column(
              children: [
                _SidebarCard(
                  tabs: _tabs,
                  selected: _selected,
                  onTap: (i) => setState(() => _selected = i),
                ),
                if (_selected == 1) ...[
                  const SizedBox(height: 26),
                  const _PromoCard(),
                ],
              ],
            );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [left, const SizedBox(height: 20), _currentView()],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 420, child: left),
                const SizedBox(width: 44),
                Expanded(child: _currentView()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  const _SidebarCard({
    required this.tabs,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 286),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 31, 34, 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            _SidebarTile(
              label: tabs[i],
              selected: i == selected,
              onTap: () => onTap(i),
            ),
            if (i < tabs.length - 1) const SizedBox(height: 3),
          ],
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromRGBO(255, 255, 255, 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF2F88FF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: child,
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final Widget trailing;
  final Widget body;

  const _HeroCard({
    required this.title,
    required this.trailing,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 188,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/influencer_program.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ColoredBox(
                    color: Color(0xFF081133),
                    child: SizedBox(height: 72),
                  ),
                ),
                const Positioned(left: 22, top: 82, child: _Avatar()),
                Positioned(
                  left: 154,
                  top: 138,
                  child: Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: const Color(0xFFF2F3F5),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(right: 16, bottom: 16, child: trailing),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D31),
              borderRadius: BorderRadius.circular(8),
            ),
            child: body,
          ),
        ],
      ),
    );
  }
}

class _MyProfileTab extends StatelessWidget {
  const _MyProfileTab();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Account',
            style: GoogleFonts.notoSans(
              color: const Color(0xFFF2F3F5),
              fontWeight: FontWeight.w700,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 20),
          _HeroCard(
            title: 'LaKimi',
            trailing: _Btn.blue('Edit Profile'),
            body: const Column(
              children: [
                _Line('NAME', 'Lakimi'),
                SizedBox(height: 14),
                _Line('EMAIL', '************@gmail.com', reveal: true),
                SizedBox(height: 14),
                _Line(
                  'PHONE NUMBER',
                  '*********8182',
                  reveal: true,
                  delete: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _section('Password and Authentication', 'Change Password'),
          const SizedBox(height: 18),
          _section('Account Removal', 'Delete Account', red: true),
        ],
      ),
    );
  }

  Widget _section(String title, String action, {bool red = false}) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          red ? _Btn.red(action) : _Btn.blue(action),
        ],
      ),
    );
  }
}

class _EditProfileTab extends StatelessWidget {
  const _EditProfileTab();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: _HeroCard(
        title: 'LaKimi',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn.blue('Change Frame'),
            const SizedBox(width: 6),
            _Btn.gray('Remove Frame'),
          ],
        ),
        body: const Column(
          children: [
            _EditRow('Display Name', 'LaKimi'),
            SizedBox(height: 10),
            _EditRow('Profile URL', 'Waiby.gg/LaKimi'),
            SizedBox(height: 10),
            _EditRow('Gender', 'Choose your gender'),
            SizedBox(height: 10),
            _EditRow('Languages', 'Choose your languages'),
            SizedBox(height: 14),
            Align(alignment: Alignment.centerRight, child: _Btn.blue('Save')),
          ],
        ),
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Banner(
            title: 'Enable push notifications',
            subtitle: 'Never miss an update with real-time alerts',
            action: 'Enable',
          ),
          SizedBox(height: 20),
          _RowItem(
            title: 'Enable email notifications',
            subtitle:
                'Get notified about orders, platform news, major updates, and special promotions.',
            on: false,
          ),
          SizedBox(height: 14),
          _RowItem(
            title: 'Buddy Recommendations',
            subtitle:
                'Receive creator recommendations selected by the platform.',
            on: false,
          ),
          SizedBox(height: 18),
          _Divider(),
          SizedBox(height: 18),
          _RowItem(title: 'Sounds', subtitle: '', header: true),
          SizedBox(height: 10),
          _RowItem(title: 'New Message', subtitle: '', on: true),
          SizedBox(height: 10),
          _RowItem(title: 'Order', subtitle: '', on: true),
          SizedBox(height: 10),
          _RowItem(title: 'Incoming Call ring', subtitle: '', on: false),
        ],
      ),
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  const _PrivacyTab();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _RowItem(
            title: 'Incognito Browsing',
            subtitle: 'View profiles anonymously without notifying users',
            on: false,
            premium: true,
          ),
          SizedBox(height: 14),
          _RowItem(
            title: 'Hide activity interactions',
            subtitle:
                'Hide your Following, likes, and pet activity from other users.',
            on: false,
            premium: true,
          ),
          SizedBox(height: 14),
          _RowItem(
            title: 'Hide identity on leaderboard',
            subtitle: 'Hide your avatar and nickname on leaderboards.',
            on: true,
          ),
          SizedBox(height: 14),
          _RowItem(
            title: 'Disable profile suggestions',
            subtitle: 'Hide your profile from recommendations.',
            on: true,
          ),
          SizedBox(height: 18),
          _Divider(),
          SizedBox(height: 18),
          _BlockedRow(),
          SizedBox(height: 18),
          _Divider(),
          SizedBox(height: 18),
          _RowItem(title: 'Social Permissions', subtitle: '', header: true),
          SizedBox(height: 14),
          _RowItem(
            title: 'Direct Message',
            subtitle:
                'Only allow messages after an order is placed or when you start the conversation',
            on: false,
            premium: true,
          ),
        ],
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;

  const _LanguageTab({
    required this.selectedLanguage,
    required this.onSelectLanguage,
  });

  static const List<String> _leftColumnLanguages = <String>[
    'English',
    'Deutsch',
    '中文',
    '日本語',
    'العربية',
    'Hrvatski',
  ];

  static const List<String> _rightColumnLanguages = <String>[
    'Español',
    'Français',
    'русский',
    'Português',
    'Türkçe',
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Language',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20 * 2.0,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your preferred display language.',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.46),
              fontWeight: FontWeight.w500,
              fontSize: 10,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(43, 45, 49, 0.52),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 560;

                if (stacked) {
                  return Column(
                    children: [
                      for (final language in _leftColumnLanguages) ...[
                        _LanguageChip(
                          label: language,
                          selected: language == selectedLanguage,
                          onTap: () => onSelectLanguage(language),
                        ),
                        const SizedBox(height: 12),
                      ],
                      for (
                        var i = 0;
                        i < _rightColumnLanguages.length;
                        i++
                      ) ...[
                        _LanguageChip(
                          label: _rightColumnLanguages[i],
                          selected:
                              _rightColumnLanguages[i] == selectedLanguage,
                          onTap: () =>
                              onSelectLanguage(_rightColumnLanguages[i]),
                        ),
                        if (i < _rightColumnLanguages.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < _leftColumnLanguages.length;
                            i++
                          ) ...[
                            _LanguageChip(
                              label: _leftColumnLanguages[i],
                              selected:
                                  _leftColumnLanguages[i] == selectedLanguage,
                              onTap: () =>
                                  onSelectLanguage(_leftColumnLanguages[i]),
                            ),
                            if (i < _leftColumnLanguages.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 38),
                    Expanded(
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < _rightColumnLanguages.length;
                            i++
                          ) ...[
                            _LanguageChip(
                              label: _rightColumnLanguages[i],
                              selected:
                                  _rightColumnLanguages[i] == selectedLanguage,
                              onTap: () =>
                                  onSelectLanguage(_rightColumnLanguages[i]),
                            ),
                            if (i < _rightColumnLanguages.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_outline_rounded
                      : Icons.circle_outlined,
                  size: 32,
                  color: selected ? const Color(0xFF51D76E) : Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * 2.1,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralsTab extends StatelessWidget {
  const _ReferralsTab();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 28, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Waiby Referral Program',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: Text(
              'Earn cashback when your friends pay on Waiby!\n'
              'Invite friends to Waiby and earn cashback every time they place an order.\n'
              'The more they stay, the more you earn.',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 34 / 2.1,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1050;
              if (!wide) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferralProgramDetails(),
                    SizedBox(height: 18),
                    _ImportantRulesCard(),
                  ],
                );
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _ReferralProgramDetails()),
                  SizedBox(width: 26),
                  SizedBox(width: 440, child: _ImportantRulesCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          const _ReferralMetricsGrid(),
          const SizedBox(height: 24),
          Text(
            'Invite & Earn',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 46 / 1.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your referral link and unlock rewards.',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 30 / 2.1,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 500;
              if (compact) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferralLinkField(),
                    SizedBox(height: 10),
                    _CopyLinkButton(),
                  ],
                );
              }
              return const Row(
                children: [
                  SizedBox(width: 360, child: _ReferralLinkField()),
                  SizedBox(width: 10),
                  _CopyLinkButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReferralProgramDetails extends StatelessWidget {
  const _ReferralProgramDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenTag(label: 'Cashback rates'),
        const SizedBox(height: 10),
        Text(
          '-Non-Verified users: earn 0.5% cashback\n'
          '-Verified users: earn 1.5% cashback',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cashback is calculated on every completed order made by your invited customer.',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 31 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        const _GreenTag(label: 'How it works'),
        const SizedBox(height: 10),
        Text(
          '1. Share your personal referral link\n'
          '2. Your friend signs up and completes their first order\n'
          '3. From their second order onward, you earn cashback automatically',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'That\'s it. No limits, no tricks.',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const _GreenTag(label: 'Bonus for your friend'),
        const SizedBox(height: 10),
        Text(
          'Your invited friend gets:\n   -5% fee on their first order',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Applied automatically at checkout.',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GreenTag extends StatelessWidget {
  final String label;

  const _GreenTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF308211),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _ImportantRulesCard extends StatelessWidget {
  const _ImportantRulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        border: Border.all(color: const Color(0xFFFF0000), width: 0.8),
      ),
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important rules',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
              fontSize: 20 * 1.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '\u2022 Cashback starts from the 2nd order\n'
            '\u2022 Only completed orders count\n'
            '\u2022 Refunds or charge backs are excluded\n'
            '\u2022 Abuse, self-buying, or off-platform activity will cancel the\n'
            '  referral and both account banned, creator & customer.',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralMetricsGrid extends StatelessWidget {
  const _ReferralMetricsGrid();

  static const List<_ReferralMetricData> _metrics = <_ReferralMetricData>[
    _ReferralMetricData(
      title: 'Earnings',
      value: '72,20 EUR',
      accent: Color(0xFF1FC27B),
      glow: Color.fromRGBO(27, 199, 166, 0.42),
      bars: <int>[3, 5, 4, 3, 4, 5, 7, 6, 8, 11, 10, 14],
    ),
    _ReferralMetricData(
      title: 'Link Opens',
      value: '100',
      accent: Color(0xFF5E95F6),
      glow: Color.fromRGBO(59, 130, 255, 0.42),
      bars: <int>[6, 9, 7, 10, 5, 6, 8, 7, 9, 10, 13, 16],
    ),
    _ReferralMetricData(
      title: 'Registrations',
      value: '29',
      accent: Color(0xFFD94BEB),
      glow: Color.fromRGBO(251, 222, 255, 0.42),
      bars: <int>[8, 6, 4, 7, 5, 5, 6, 8, 4, 6, 10, 16],
    ),
    _ReferralMetricData(
      title: 'Completed Orders',
      value: '29',
      accent: Color(0xFFEEB24C),
      glow: Color.fromRGBO(235, 186, 104, 0.42),
      bars: <int>[4, 8, 10, 12, 5, 8, 6, 7, 8, 6, 7, 9],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final width = constraints.maxWidth;

        int columns;
        if (width >= 1200) {
          columns = 4;
        } else if (width >= 680) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in _metrics)
              SizedBox(
                width: cardWidth,
                child: _ReferralMetricCard(data: metric),
              ),
          ],
        );
      },
    );
  }
}

class _ReferralMetricCard extends StatelessWidget {
  final _ReferralMetricData data;

  const _ReferralMetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: data.glow.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: data.glow, blurRadius: 18, spreadRadius: 2),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: data.accent.withValues(alpha: 0.65),
            width: 0.7,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: GoogleFonts.notoSans(
                      color: data.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * 1.3,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.value,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * 1.3,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 112,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _SparkBars(accent: data.accent, values: data.bars),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkBars extends StatelessWidget {
  final Color accent;
  final List<int> values;

  const _SparkBars({required this.accent, required this.values});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          Container(
            width: 6,
            height: (values[i].toDouble().clamp(3, 18) * 2.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent, const Color(0xFFC4E0DC)],
              ),
            ),
          ),
          if (i < values.length - 1) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

class _ReferralLinkField extends StatelessWidget {
  const _ReferralLinkField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        'https://Waiby.gg/?ref=lakimi',
        style: GoogleFonts.notoSans(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
          fontSize: 12 * 1.2,
        ),
      ),
    );
  }
}

class _CopyLinkButton extends StatelessWidget {
  const _CopyLinkButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.copy_rounded, size: 14),
        label: Text(
          'Copy link',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 10 * 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF2F88FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}

@immutable
class _ReferralMetricData {
  final String title;
  final String value;
  final Color accent;
  final Color glow;
  final List<int> bars;

  const _ReferralMetricData({
    required this.title,
    required this.value,
    required this.accent,
    required this.glow,
    required this.bars,
  });
}

class _Banner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;

  const _Banner({
    required this.title,
    required this.subtitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D31),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.46),
                    fontWeight: FontWeight.w500,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          _Btn.blue(action),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool header;
  final bool premium;
  final bool? on;

  const _RowItem({
    required this.title,
    required this.subtitle,
    this.header = false,
    this.premium = false,
    this.on,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: header ? 15 : 12,
          ),
        ),
        if (premium) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.workspace_premium_rounded,
            size: 11,
            color: Color(0xFF51D76E),
          ),
        ],
      ],
    );

    if (on == null) {
      return titleWidget;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.46),
                    fontWeight: FontWeight.w500,
                    fontSize: 7,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Toggle(on: on!),
      ],
    );
  }
}

class _BlockedRow extends StatelessWidget {
  const _BlockedRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RowItem(
            title: 'Blocked users',
            subtitle: 'View and manage users you\'ve blocked.',
          ),
        ),
        _Btn.blue('View'),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool reveal;
  final bool delete;

  const _Line(
    this.label,
    this.value, {
    this.reveal = false,
    this.delete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  color: const Color(0xFFB5BAC1),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  if (reveal)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Reveal',
                        style: GoogleFonts.notoSans(
                          color: const Color(0xFF00A8FC),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (delete)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              'Delete',
              style: GoogleFonts.notoSans(
                color: const Color(0xFFFF0000),
                fontSize: 13,
              ),
            ),
          ),
        _Btn.gray('Edit'),
      ],
    );
  }
}

class _EditRow extends StatelessWidget {
  final String label;
  final String value;

  const _EditRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.21)),
            ),
            child: Text(
              value,
              style: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool on;

  const _Toggle({required this.on});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33,
      height: 13,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: on ? const Color(0xFF51D76E) : const Color(0xFF303030),
        borderRadius: BorderRadius.circular(212),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Align(
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 0.5,
      color: Colors.white.withValues(alpha: 0.14),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final EdgeInsets padding;

  const _Btn._(this.label, this.color, this.padding);

  const _Btn.blue(String label)
    : this._(
        label,
        const Color(0xFF2F88FF),
        const EdgeInsets.symmetric(horizontal: 18),
      );
  const _Btn.gray(String label)
    : this._(
        label,
        const Color(0xFF2B2D31),
        const EdgeInsets.symmetric(horizontal: 16),
      );
  const _Btn.red(String label)
    : this._(
        label,
        const Color(0xFFFF0000),
        const EdgeInsets.symmetric(horizontal: 16),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8EFA4E), Color(0xFF3CA52E)],
            ),
          ),
          child: ClipOval(
            child: Image.asset('assets/pp4.png', fit: BoxFit.cover),
          ),
        ),
        Positioned(
          left: 2,
          top: -8,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2F88FF),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.star, size: 11, color: Color(0xFFF6E27A)),
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 86,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/leaderboard_wallpaper.png', fit: BoxFit.cover),
            Positioned(
              left: 112,
              top: 12,
              child: Text(
                'Style your profile',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              left: 112,
              top: 34,
              child: Text(
                'Unlock exclusive avatar decorations and more',
                style: GoogleFonts.notoSans(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 7,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -16,
              child: SizedBox(
                width: 120,
                child: Image.asset('assets/bunny1.png'),
              ),
            ),
            const Positioned(
              right: 10,
              bottom: 8,
              child: _Btn.blue('Open shop'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x12000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
        ),
        child: Text(
          '$title view is ready for the next mock.',
          style: GoogleFonts.notoSans(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
