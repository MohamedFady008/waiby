import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

const Color _kWeeklyCardBackground = Color(0xFF070F2B);
const Color _kWeeklyBorder = Color(0xFF29E37B);
const Color _kWeeklyMuted = Color(0xFF949DB8);

class CalendarSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const CalendarSettingsBody({super.key, required this.entry});

  static const List<_WeeklyEventColumnData>
  _mvpColumns = <_WeeklyEventColumnData>[
    _WeeklyEventColumnData(
      heading: 'Eligibility',
      bullets: <String>[
        'Emerald Tier only',
        'Active account with no penalties',
      ],
    ),
    _WeeklyEventColumnData(
      heading: 'How it’s calculated',
      paragraphs: <String>['Based on combined performance:'],
      bullets: <String>[
        'Total earnings generated during the week',
        'High number of completed orders',
        'Only successfully completed orders count',
      ],
      emphasis:
          'This event rewards elite consistency + revenue, not partial activity.',
    ),
    _WeeklyEventColumnData(
      heading: 'Rewards',
      bullets: <String>[
        'Weekly MVP badge (7 days)',
        '+20 income Buds',
        'Bonus gems / credits',
      ],
      emphasis: 'Only 1 winner per week',
      emphasisColor: _kWeeklyBorder,
    ),
  ];

  static const List<_WeeklyEventColumnData>
  _risingStarColumns = <_WeeklyEventColumnData>[
    _WeeklyEventColumnData(
      heading: 'Eligibility',
      bullets: <String>[
        'Silver Tier or higher',
        'Active during the current and previous weeks',
      ],
    ),
    _WeeklyEventColumnData(
      heading: 'How it’s calculated',
      paragraphs: <String>[
        'The winner is the user who shows the strongest growth compared to previous weeks, based on:',
      ],
      bullets: <String>[
        'Highest number of new customers (unique clients)',
        'Clear upward trend in:',
        'Total earnings',
        'Total clients',
        'Tier or level progression compared to previous weeks',
      ],
    ),
    _WeeklyEventColumnData(
      heading: 'Rewards',
      bullets: <String>[
        'Rising Star badge (7 days)',
        '+20 income Buds',
        '+10 Bonus gems',
      ],
      emphasis: 'Only 1 winner per week',
      emphasisColor: _kWeeklyBorder,
    ),
  ];

  static const List<_WeeklyEventColumnData>
  _mostGiftedColumns = <_WeeklyEventColumnData>[
    _WeeklyEventColumnData(
      heading: 'How it’s calculated',
      paragraphs: <String>['Based on the total combined value of:'],
      bullets: <String>[
        'Gifts received',
        'Active subscriptions gained during the week',
      ],
      emphasis: 'Both subscriptions and gifts count toward the final score.',
    ),
    _WeeklyEventColumnData(
      heading: 'Rules',
      bullets: <String>[
        'Fraudulent or artificial gifting/subscriptions result in disqualification',
        'Only valid, completed transactions are counted',
      ],
    ),
    _WeeklyEventColumnData(
      heading: 'Rewards',
      bullets: <String>[
        'Most Gifted badge (7 days)',
        '+20 income Buds',
        '+10 Bonus gems',
      ],
      emphasis: 'Only 1 winner per week',
      emphasisColor: _kWeeklyBorder,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _WeeklyIntro(),
        SizedBox(height: 22),
        _WeeklyEventCard(
          icon: '🏆',
          title: 'Weekly MVP',
          subtitle: 'Top overall performer (Emerald Tier only)',
          description:
              'The Weekly MVP represents the highest-level performance on the platform.  Only 1 winner per week',
          columns: _mvpColumns,
          bannerAsset: 'assets/weekly_mvp.png',
        ),
        SizedBox(height: 22),
        _WeeklyEventCard(
          icon: '🌱',
          title: 'Rising Star',
          subtitle: 'Fastest-growing profile of the week',
          description: 'Focused on growth, momentum, and expansion.',
          columns: _risingStarColumns,
          bannerAsset: 'assets/rising_star.png',
        ),
        SizedBox(height: 22),
        _WeeklyEventCard(
          icon: '🎁',
          title: 'Most Gifted',
          subtitle: 'Most supported by the community',
          description: 'Rewards the profile with the highest community support',
          columns: _mostGiftedColumns,
          bannerAsset: 'assets/most_gifted.png',
        ),
        SizedBox(height: 24),
        _WeeklyRulesStrip(),
      ],
    );
  }
}

class _WeeklyIntro extends StatelessWidget {
  const _WeeklyIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 Weekly Events — How It Works',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Our weekly events reward performance, growth, and community engagement.',
          style: GoogleFonts.nunitoSans(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        Text(
          'Events run automatically every week and reset on Sunday.',
          style: GoogleFonts.nunitoSans(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '⏱ Event period:',
          style: GoogleFonts.nunitoSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        Text(
          'Monday 00:00 → Sunday 23:59 (UTC)',
          style: GoogleFonts.nunitoSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        Text(
          'Only Buddies Tier Silver+ are eligible.',
          style: GoogleFonts.nunitoSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _WeeklyEventCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final List<_WeeklyEventColumnData> columns;
  final String bannerAsset;

  const _WeeklyEventCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.columns,
    required this.bannerAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: _kWeeklyCardBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _kWeeklyBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.nunitoSans(
              color: _kWeeklyMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: GoogleFonts.nunitoSans(
              color: _kWeeklyMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 980;

              if (compact) {
                return Column(
                  children: columns
                      .map(
                        (column) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _WeeklyColumnBlock(data: column),
                        ),
                      )
                      .toList(growable: false),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns
                    .map(
                      (column) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: _WeeklyColumnBlock(data: column),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: 18),
          _EventBanner(imageAsset: bannerAsset),
        ],
      ),
    );
  }
}

class _WeeklyColumnBlock extends StatelessWidget {
  final _WeeklyEventColumnData data;

  const _WeeklyColumnBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.heading,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (data.paragraphs.isNotEmpty) const SizedBox(height: 10),
        ...data.paragraphs.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              line,
              style: GoogleFonts.nunitoSans(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
        if (data.bullets.isNotEmpty) const SizedBox(height: 6),
        ...data.bullets.map(
          (bullet) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '•  $bullet',
              style: GoogleFonts.nunitoSans(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
        if (data.emphasis != null) const SizedBox(height: 10),
        if (data.emphasis != null)
          Text(
            data.emphasis!,
            style: GoogleFonts.nunitoSans(
              color: data.emphasisColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
      ],
    );
  }
}

class _EventBanner extends StatelessWidget {
  final String imageAsset;

  const _EventBanner({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 980),
        height: 108,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: const Color(0xFF0B1739),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF0B1739),
              alignment: Alignment.center,
              child: Text(
                'Missing banner',
                style: GoogleFonts.nunitoSans(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WeeklyRulesStrip extends StatelessWidget {
  const _WeeklyRulesStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        const minCardWidth = 360.0;
        final totalMinWidth = (minCardWidth * 3) + (spacing * 2);

        const cards = <_WeeklyRulesCard>[
          _WeeklyRulesCard(
            title: 'General Event Rules',
            content:
                '- Events reset every week\n'
                '- One Category per Winner\n'
                '  A user can win only one Weekly Event category per week.\n'
                '  If a user ranks first in multiple categories, the highest-priority category is assigned, and the next eligible user receives the remaining reward.\n'
                '- Ties are resolved by:\n'
                '  a. Higher completed orders\n'
                '  b. Higher account rating\n'
                '  c. Account health score',
          ),
          _WeeklyRulesCard(
            title: 'Fair Play & Integrity',
            content:
                'To keep events fair:\n'
                '- Suspicious activity is filtered or excluded\n'
                '- Multi-account behavior = disqualification\n'
                '- Active reports or penalties = automatic exclusion\n'
                '- All stats are logged and audited',
          ),
          _WeeklyRulesCard(
            title: 'Progress & Visibility',
            content:
                'Users can track:\n'
                '- Live rankings\n'
                '- Weekly progress\n'
                '- Clear feedback on performance\n'
                'Winners are showcased across:\n'
                '- Events page\n'
                '- Profile badges\n'
                '- Discovery & featured sections',
          ),
        ];

        if (constraints.maxWidth >= totalMinWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: spacing),
              Expanded(child: cards[1]),
              const SizedBox(width: spacing),
              Expanded(child: cards[2]),
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: minCardWidth, child: cards[0]),
              const SizedBox(width: spacing),
              SizedBox(width: minCardWidth, child: cards[1]),
              const SizedBox(width: spacing),
              SizedBox(width: minCardWidth, child: cards[2]),
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyRulesCard extends StatelessWidget {
  final String title;
  final String content;

  const _WeeklyRulesCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _kWeeklyCardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: GoogleFonts.nunitoSans(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _WeeklyEventColumnData {
  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? emphasis;
  final Color? emphasisColor;

  const _WeeklyEventColumnData({
    required this.heading,
    this.paragraphs = const <String>[],
    this.bullets = const <String>[],
    this.emphasis,
    this.emphasisColor,
  });
}
