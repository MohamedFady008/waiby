import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class VipSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const VipSettingsBody({super.key, required this.entry});

  @override
  State<VipSettingsBody> createState() => _VipSettingsBodyState();
}

class _VipSettingsBodyState extends State<VipSettingsBody> {
  bool _vipEnabled = false;

  static const List<String> _howItWorksLines = <String>[
    'Members enjoy a discounted price when booking your service, but this discount will not apply to "First Order Free" or "Buy X Get Y Free" deals.',
    'Subscribers can contact you via IM as often as they like, without any restrictions.',
    'Exclusive albums are available only to users with an active subscription.',
    'Subscribers will get alerts whenever you create new rooms or share updates through Live and Posts.',
    'A 10% fee is deducted from every Waiby subscription purchase.',
    'If you update your subscription pricing, current subscribers will keep their existing rate.',
  ];

  static const List<_VipBenefitData> _benefits = <_VipBenefitData>[
    _VipBenefitData(
      title: 'Exclusive VIP Icon',
      description: 'Highlight your nickname with an exclusive VIP icon',
      imageAsset: 'assets/medals/vip.png',
      useGreenArtBackground: true,
    ),
    _VipBenefitData(
      title: 'Colored Nickname',
      description:
          'Get a VIP-only colored nickname in Waiby green or any color to make your name pop',
    ),
    _VipBenefitData(
      title: 'Animated Avatars',
      description: 'VIP members can set dynamic GIF avatars on their profile',
    ),
    _VipBenefitData(
      title: 'Exclusive Crown Frame',
      description: 'Adorn your profile with a VIP-exclusive Crown avatar frame',
    ),
    _VipBenefitData(
      title: 'Exclusive Banner Customization',
      description:
          'Create a unique look with a custom profile banner, either static or animated',
    ),
    _VipBenefitData(
      title: 'Chat Backgrounds',
      description: 'Give your chats a fresh look with a custom background',
    ),
    _VipBenefitData(
      title: 'VIP Emojis',
      description:
          'Use Waiby-exclusive emojis in chats and unlock animated emojis in LIVE Rooms',
    ),
    _VipBenefitData(
      title: 'VIP Store',
      description: 'Unlock VIP-only deals on Waiby frames and emojis',
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
            const _SubscriptionHeader(),
            const SizedBox(height: 28),
            _SubscriptionStatsCard(
              enabled: _vipEnabled,
              onChanged: (value) => setState(() => _vipEnabled = value),
            ),
            const SizedBox(height: 30),
            _HowItWorksSection(lines: _howItWorksLines),
            const SizedBox(height: 36),
            const _VipActionBar(),
            const SizedBox(height: 44),
            Text(
              'Unlock 10 Prestige Status Benefits',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
                fontSize: 24,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 24),
            _BenefitsGrid(benefits: _benefits),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionHeader extends StatelessWidget {
  const _SubscriptionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientText(
          text: 'Waiby Subscription',
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFF2BBEA),
              Color(0xFF952475),
              Color(0xFFC34751),
              Color(0xFF700707),
            ],
          ),
          style: GoogleFonts.getFont(
            'Alexandria',
            fontWeight: FontWeight.w600,
            fontSize: 48,
            height: 1.03,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Turn clients into subscribers and grow your recurring income.',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.47),
            fontWeight: FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.3,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SubscriptionStatsCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SubscriptionStatsCard({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 24, 24, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF080D26), Color(0xFF0A1338)],
        ),
        border: Border.all(color: const Color(0x2E1869CC), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x809D9D9D),
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          final metrics = <Widget>[
            _StatsMetric(
              label: 'Current Subscribers',
              value: Text('7', style: _StatsMetric.valueStyle),
            ),
            _StatsMetric(
              label: 'Discount',
              value: Text.rich(
                TextSpan(
                  text: '20%',
                  style: _StatsMetric.valueStyle,
                  children: [
                    TextSpan(
                      text: 'OFF',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StatsMetric(
              label: 'Price',
              value: Text.rich(
                TextSpan(
                  text: '\$9.99',
                  style: _StatsMetric.valueStyle,
                  children: [
                    TextSpan(
                      text: '/monthly',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0x8CFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StatsMetric(
              label: 'Income',
              value: Text.rich(
                TextSpan(
                  text: '\$69.93',
                  style: _StatsMetric.valueStyle,
                  children: [
                    TextSpan(
                      text: '/monthly',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0x8CFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < metrics.length; i++) ...[
                  Expanded(child: metrics[i]),
                  if (i < metrics.length - 1) const SizedBox(width: 20),
                ],
                const SizedBox(width: 16),
                _EnableToggle(value: enabled, onChanged: onChanged),
              ],
            );
          }

          final itemWidth = constraints.maxWidth >= 700
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: metrics
                    .map((metric) => SizedBox(width: itemWidth, child: metric))
                    .toList(growable: false),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: _EnableToggle(value: enabled, onChanged: onChanged),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsMetric extends StatelessWidget {
  static final TextStyle labelStyle = GoogleFonts.getFont(
    'Mulish',
    color: Colors.white.withValues(alpha: 0.47),
    fontWeight: FontWeight.w600,
    fontSize: 19,
    height: 1.18,
  );

  static final TextStyle valueStyle = GoogleFonts.poppins(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 36,
    height: 1.1,
  );

  final String label;
  final Widget value;

  const _StatsMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 10),
        FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: value,
        ),
      ],
    );
  }
}

class _EnableToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _EnableToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Enable',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 54,
          height: 30,
          child: Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeTrackColor: const Color(0xFF51D76E),
            inactiveTrackColor: const Color(0xFFEEEEEE),
            inactiveThumbColor: const Color(0xFFECECEC),
            activeThumbColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  final List<String> lines;

  const _HowItWorksSection({required this.lines});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How it works',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 47,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 16),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '- $line',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.3,
                  ),
                ),
              ),
          ],
        );

        final mascot = SizedBox(
          width: 260,
          height: 260,
          child: Image.asset(
            'assets/struggling_to_get_clients.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 28),
              Padding(padding: const EdgeInsets.only(top: 10), child: mascot),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            details,
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerRight, child: mascot),
          ],
        );
      },
    );
  }
}

class _VipActionBar extends StatelessWidget {
  const _VipActionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x1FD1E9D0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x809D9D9D),
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;

          final buttons = Wrap(
            spacing: 16,
            runSpacing: 10,
            children: const [
              _VipActionButton(
                label: 'Gift VIP',
                background: Color(0xFF0D912A),
              ),
              _VipActionButton(
                label: 'Become VIP',
                background: Color(0xFF51D76E),
              ),
            ],
          );

          if (wide) {
            return Row(
              children: [
                _GradientText(
                  text: 'Waiby VIP',
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF00FFB2),
                      Color(0xFF51D76E),
                      Color(0xFF38FFC7),
                    ],
                  ),
                  style: GoogleFonts.getFont(
                    'Alexandria',
                    fontWeight: FontWeight.w600,
                    fontSize: 40,
                    height: 1,
                  ),
                ),
                const Spacer(),
                buttons,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientText(
                text: 'Waiby VIP',
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF00FFB2),
                    Color(0xFF51D76E),
                    Color(0xFF38FFC7),
                  ],
                ),
                style: GoogleFonts.getFont(
                  'Alexandria',
                  fontWeight: FontWeight.w600,
                  fontSize: 36,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 14),
              buttons,
            ],
          );
        },
      ),
    );
  }
}

class _VipActionButton extends StatelessWidget {
  final String label;
  final Color background;

  const _VipActionButton({required this.label, required this.background});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 152),
          child: Ink(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitsGrid extends StatelessWidget {
  final List<_VipBenefitData> benefits;

  const _BenefitsGrid({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const gap = 18.0;
        final columns = width >= 980 ? 2 : 1;
        final cardWidth = columns == 1 ? width : (width - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: benefits
              .map(
                (benefit) => SizedBox(
                  width: cardWidth,
                  child: _VipBenefitCard(data: benefit),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _VipBenefitCard extends StatelessWidget {
  final _VipBenefitData data;

  const _VipBenefitCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 152,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF51D76E), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 540;
            final textPanel = Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );

            final artPanel = data.imageAsset == null
                ? Container(color: const Color(0xFFB7B7B7))
                : Container(
                    decoration: BoxDecoration(
                      gradient: data.useGreenArtBackground
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6BE53F),
                                Color(0xFFBFFF7A),
                                Color(0xFF4FB029),
                              ],
                            )
                          : null,
                      color: data.useGreenArtBackground
                          ? null
                          : const Color(0xFFB7B7B7),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          data.imageAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(),
                        ),
                      ),
                    ),
                  );

            if (compact) {
              return Column(
                children: [
                  Expanded(flex: 3, child: textPanel),
                  Expanded(flex: 2, child: artPanel),
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 5, child: textPanel),
                Expanded(flex: 3, child: artPanel),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const _GradientText({
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}

@immutable
class _VipBenefitData {
  final String title;
  final String description;
  final String? imageAsset;
  final bool useGreenArtBackground;

  const _VipBenefitData({
    required this.title,
    required this.description,
    this.imageAsset,
    this.useGreenArtBackground = false,
  });
}
