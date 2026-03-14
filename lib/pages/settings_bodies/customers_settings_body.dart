import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class CustomersSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const CustomersSettingsBody({super.key, required this.entry});

  static const List<_CustomerProfile> _potentialCustomers = <_CustomerProfile>[
    _CustomerProfile(name: 'Chad', avatarAsset: 'assets/pp7.png'),
    _CustomerProfile(name: 'Keo_', avatarAsset: 'assets/bunny1.png'),
    _CustomerProfile(name: 'HanzoKabami', avatarAsset: 'assets/pp1.png'),
    _CustomerProfile(name: 'ITsGodJ', avatarAsset: 'assets/pp5.png'),
    _CustomerProfile(name: 'puliz', avatarAsset: 'assets/pp6.png'),
    _CustomerProfile(name: 'HaCyyna', avatarAsset: 'assets/pp4.png'),
    _CustomerProfile(name: 'Joel', avatarAsset: 'assets/pp1.png'),
    _CustomerProfile(name: 'Folcan', avatarAsset: 'assets/pp3.png'),
  ];

  static const List<_CustomerGroupData> _orderingGroups = <_CustomerGroupData>[
    _CustomerGroupData(
      title: 'New customers',
      members: <_CustomerProfile>[
        _CustomerProfile(name: 'TJ', avatarAsset: 'assets/pp4.png'),
        _CustomerProfile(name: 'LugoT', avatarAsset: 'assets/pp1.png'),
        _CustomerProfile(name: 'TWNTYY', avatarAsset: 'assets/pp1.png'),
        _CustomerProfile(name: 'EnvyRain', avatarAsset: 'assets/pp7.png'),
        _CustomerProfile(name: 'Miszka', avatarAsset: 'assets/pp5.png'),
      ],
    ),
    _CustomerGroupData(
      title: 'Casual customers',
      members: <_CustomerProfile>[
        _CustomerProfile(name: 'ICE', avatarAsset: 'assets/pp7.png'),
        _CustomerProfile(name: '55555555', avatarAsset: 'assets/pp2.png'),
        _CustomerProfile(name: 'magicchen', avatarAsset: 'assets/pp3.png'),
        _CustomerProfile(name: 'dragoniro795', avatarAsset: 'assets/pp1.png'),
        _CustomerProfile(name: 'havoc', avatarAsset: 'assets/pp4.png'),
      ],
    ),
    _CustomerGroupData(
      title: 'Old customers',
      members: <_CustomerProfile>[
        _CustomerProfile(name: 'Vowt', avatarAsset: 'assets/pp1.png'),
        _CustomerProfile(name: 'tght.', avatarAsset: 'assets/pp6.png'),
        _CustomerProfile(name: 'moisty', avatarAsset: 'assets/bunny2.png'),
        _CustomerProfile(name: 'rttyng', avatarAsset: 'assets/pp4.png'),
        _CustomerProfile(name: 'LegendOk07', avatarAsset: 'assets/pp4.png'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Potential Customers',
              subtitle: 'People who could place an order with you',
            ),
            const SizedBox(height: 22),
            _PotentialCustomersGrid(customers: _potentialCustomers),
            const SizedBox(height: 34),
            const _SectionHeader(
              title: 'Ordering clients',
              subtitle:
                  'People who have completed an order with you in the past 30 days',
            ),
            const SizedBox(height: 22),
            _OrderingCustomersSection(groups: _orderingGroups),
            const SizedBox(height: 56),
            const _InfluenceProgramPanel(),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 42,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.47),
            fontWeight: FontWeight.w500,
            fontSize: 15,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _PotentialCustomersGrid extends StatelessWidget {
  final List<_CustomerProfile> customers;

  const _PotentialCustomersGrid({required this.customers});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const minCardWidth = 250.0;
        const gap = 16.0;
        final columns = ((width + gap) / (minCardWidth + gap)).floor().clamp(
          1,
          4,
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: customers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: 12,
            mainAxisExtent: 64,
          ),
          itemBuilder: (context, index) {
            return _CustomerLeadTile(profile: customers[index], compact: true);
          },
        );
      },
    );
  }
}

class _OrderingCustomersSection extends StatelessWidget {
  final List<_CustomerGroupData> groups;

  const _OrderingCustomersSection({required this.groups});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const minCardWidth = 320.0;
        const gap = 24.0;
        final columns = ((width + gap) / (minCardWidth + gap)).floor().clamp(
          1,
          3,
        );
        final cardWidth = columns == 1
            ? width
            : (width - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: groups
              .map(
                (group) => SizedBox(
                  width: cardWidth,
                  child: _CustomerGroupCard(data: group),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _CustomerGroupCard extends StatelessWidget {
  final _CustomerGroupData data;

  const _CustomerGroupCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x47000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            ...data.members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _CustomerLeadTile(profile: member, compact: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerLeadTile extends StatelessWidget {
  final _CustomerProfile profile;
  final bool compact;

  const _CustomerLeadTile({required this.profile, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: compact ? const Color(0x47050505) : const Color(0x473B3939),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _CustomerAvatar(asset: profile.avatarAsset),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              profile.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.3,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _ChatChip(),
        ],
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final String asset;

  const _CustomerAvatar({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF2A2A2A),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          );
        },
      ),
    );
  }
}

class _ChatChip extends StatelessWidget {
  const _ChatChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2F88FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        'Chat',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.3,
          height: 1.0,
        ),
      ),
    );
  }
}

class _InfluenceProgramPanel extends StatelessWidget {
  const _InfluenceProgramPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final mascot = SizedBox(
          width: wide ? 210 : 160,
          height: wide ? 210 : 160,
          child: Image.asset(
            'assets/struggling_to_get_clients.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        );

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Struggling to get clients?',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We\'ve built tools, tips, and rewards to help you get noticed and grow faster',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.47),
                fontWeight: FontWeight.w500,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F88FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(
                  'Influence Program',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 4, child: copy),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Align(alignment: Alignment.centerRight, child: mascot),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            copy,
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerRight, child: mascot),
          ],
        );
      },
    );
  }
}

@immutable
class _CustomerGroupData {
  final String title;
  final List<_CustomerProfile> members;

  const _CustomerGroupData({required this.title, required this.members});
}

@immutable
class _CustomerProfile {
  final String name;
  final String avatarAsset;

  const _CustomerProfile({required this.name, required this.avatarAsset});
}
