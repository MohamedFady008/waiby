import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class InfluencerSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const InfluencerSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0E0F15),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _InfluencerHeroBanner(),
              SizedBox(height: 28),
              _ProgramSteps(),
              SizedBox(height: 30),
              _RewardsSection(),
              SizedBox(height: 34),
              _GuidelinesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfluencerHeroBanner extends StatelessWidget {
  const _InfluencerHeroBanner();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        final tiny = constraints.maxWidth < 560;
        final bannerHeight = tiny ? 195.0 : (compact ? 188.0 : 180.0);
        final titleSize = tiny ? 18.0 : (compact ? 21.0 : 24.0);
        final copySize = tiny ? 11.0 : (compact ? 13.0 : 16.0);
        final horizontalPadding = tiny ? 14.0 : 24.0;
        final verticalPadding = tiny ? 14.0 : 16.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: double.infinity,
            height: bannerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/influencer_program.png', fit: BoxFit.cover),
                Container(color: Colors.black.withValues(alpha: 0.12)),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waiby Official Social Feature\nProgram',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: titleSize,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 980),
                            child: Text(
                              'WAIBY invites creators to submit short introduction '
                              'videos to be featured on the official WAIBY social '
                              'media channels\n'
                              'Selected videos will be edited and published by the '
                              'WAIBY team\n'
                              'This program is designed to increase creator '
                              'visibility while maintaining brand consistency and '
                              'platform safety',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: copySize,
                                height: 1.25,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgramSteps extends StatelessWidget {
  const _ProgramSteps();

  static const List<_ProgramStepCard> _steps = <_ProgramStepCard>[
    _ProgramStepCard(
      number: 1,
      title: 'Record Your video',
      subtitle: '15-30s Intro video',
      iconAsset: 'assets/record_your_video.svg',
    ),
    _ProgramStepCard(
      number: 2,
      title: 'Send it to Waiby Staff',
      subtitle: 'Email it with your profile link\n+ referral link + consent',
      iconAsset: 'assets/send_it_to_waiby_staff.svg',
    ),
    _ProgramStepCard(
      number: 3,
      title: 'Review & edit',
      subtitle: 'Our team reviews and edits\nif necessary',
      iconAsset: 'assets/review_edit.svg',
    ),
    _ProgramStepCard(
      number: 4,
      title: 'Get Featured!',
      subtitle: 'Approved videos are\npublished on WAIBY\'s official\naccounts',
      iconAsset: 'assets/get_featured.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _steps[0]),
              const _StepConnector(),
              Expanded(child: _steps[1]),
              const _StepConnector(),
              Expanded(child: _steps[2]),
              const _StepConnector(),
              Expanded(child: _steps[3]),
            ],
          );
        }

        final stepWidth = constraints.maxWidth >= 680
            ? ((constraints.maxWidth - 16) / 2)
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 18,
          children: _steps
              .map((step) => SizedBox(width: stepWidth, child: step))
              .toList(growable: false),
        );
      },
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 10,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _ProgramStepCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final String iconAsset;

  const _ProgramStepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: const BoxDecoration(
            color: Color(0xFF2F88FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: 34,
            height: 34,
            child: SvgPicture.asset(iconAsset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$number. $title',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _RewardsSection extends StatelessWidget {
  const _RewardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Rewards',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final useRow = width >= 860;
            final rewardItems = const <Widget>[
              _RewardBadge(
                label: 'Bonus Gems/VIP',
                iconAsset: 'assets/bonus_gems.png',
                colors: [
                  Color(0xFFFF00E6),
                  Color(0xFFFF7274),
                  Color(0xFFBF3A83),
                  Color(0xFFCC00FF),
                  Color(0xFFFF00E6),
                ],
              ),
              _RewardBadge(
                label: 'Visibility Boost',
                iconAsset: 'assets/visibility_boost.png',
                colors: [
                  Color(0xFF5557D7),
                  Color(0xFF5557D7),
                  Color(0xFF8D67FF),
                  Color(0xFF5557D7),
                  Color(0xFF5557D7),
                ],
              ),
              _RewardBadge(
                label: 'Featured Badge',
                iconAsset: 'assets/featured_badge.png',
                colors: [
                  Color(0xFFED4245),
                  Color(0xFFE96F71),
                  Color(0xFFFF4B7E),
                  Color(0xFFED4245),
                  Color(0xFFE96F71),
                ],
              ),
            ];

            if (useRow) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < rewardItems.length; i++) ...[
                    rewardItems[i],
                    if (i < rewardItems.length - 1) const SizedBox(width: 96),
                  ],
                ],
              );
            }

            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 30,
              runSpacing: 20,
              children: rewardItems,
            );
          },
        ),
      ],
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String label;
  final String iconAsset;
  final List<Color> colors;

  const _RewardBadge({
    required this.label,
    required this.iconAsset,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(colors: colors),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(iconAsset, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GuidelinesSection extends StatelessWidget {
  const _GuidelinesSection();

  void _openGuidelines(BuildContext context) {
    context.go('/settings/influencer-guidelines');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full ranking rules available in Guidelines',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            fontSize: 13,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 122,
          height: 32,
          child: ElevatedButton(
            onPressed: () => _openGuidelines(context),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: const Color(0xFF2F88FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Center(
              child: Text(
                'View Guidelines',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
