import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class ScoreRateSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const ScoreRateSettingsBody({super.key, required this.entry});

  static const List<_ActionMetricCardData>
  _metricCards = <_ActionMetricCardData>[
    _ActionMetricCardData(
      title: 'PROFILE POWER',
      icon: Icons.person_outline_rounded,
      score: '6/6',
      status: _MetricStatus.completed,
      rows: <_ActionMetricRowData>[
        _ActionMetricRowData(label: 'Get verified', value: '1/1'),
        _ActionMetricRowData(label: 'Add 2 picture to gallery', value: '2/2'),
        _ActionMetricRowData(label: 'Set up 2 or more services', value: '2/2'),
        _ActionMetricRowData(label: 'Follow 2 or more creators', value: '2/2'),
      ],
      rulesTitle: 'PROFILE POWER RULES',
      rules: <String>[
        'Add your bio to earn 2 score ratings.',
        'Upload at least 2 photos to your gallery to earn 2 score rating points.',
        'Activate at least 2 services and earn 2 store rating points.',
        'Follow at least 2 or more creators.',
      ],
    ),
    _ActionMetricCardData(
      title: 'VISIBILITY ENGINE',
      icon: Icons.visibility_rounded,
      score: '8/8',
      status: _MetricStatus.completed,
      rows: <_ActionMetricRowData>[
        _ActionMetricRowData(label: 'Weekly post made', value: '2/2'),
        _ActionMetricRowData(label: 'Weekly live lauched', value: '3/3'),
        _ActionMetricRowData(label: 'Weekly shared profile', value: '3/3'),
      ],
      rulesTitle: 'VISIBILITY ENGINE RULES',
      rules: <String>[
        'Create posts and earn 1 rating each (max. 3 in 7 days).',
        'Create Playground Live rooms and earn 1 rating per launch (up to 3 in 7 days).',
        'Earn 1 rating per profile share (last 7 days, max. 3).',
      ],
    ),
    _ActionMetricCardData(
      title: 'RELIABILITY RANK',
      icon: Icons.person_outline_rounded,
      score: '13/20',
      status: _MetricStatus.pending,
      rows: <_ActionMetricRowData>[
        _ActionMetricRowData(label: 'Fast reply time', value: '5/5'),
        _ActionMetricRowData(label: 'Fast order take', value: '5/5'),
        _ActionMetricRowData(label: 'Non refund/cancel order', value: '3/3'),
        _ActionMetricRowData(label: 'Weekly active days', value: '2/7'),
      ],
      rulesTitle: 'RELIABILITY RANK RULES',
      rules: <String>[
        'Reply to messages quickly to maintain a fast reply time score.',
        'Accept orders promptly to earn fast order take points.',
        'Avoid refunds and cancellations to keep your score intact.',
        'Stay active on the platform every day of the week.',
      ],
    ),
    _ActionMetricCardData(
      title: 'BUSINESS IMPACT',
      icon: Icons.person_outline_rounded,
      score: '6/6',
      status: _MetricStatus.pending,
      rows: <_ActionMetricRowData>[
        _ActionMetricRowData(label: 'Total Income', value: '0/25'),
        _ActionMetricRowData(label: 'Monthly Subscription/Tip', value: '0/10'),
        _ActionMetricRowData(
          label: 'Monthly repeat purchases from new customers',
          value: '0/10',
        ),
        _ActionMetricRowData(
          label: 'Monthly repeat purchases from old customers',
          value: '0/10',
        ),
        _ActionMetricRowData(
          label: 'Monthly rating from new customers',
          value: '0/10',
        ),
      ],
      rulesTitle: 'BUSINESS IMPACT RULES',
      rules: <String>[
        'Earn income on the platform to boost your business impact score.',
        'Get monthly subscriptions or tips from followers.',
        'Encourage repeat purchases from new and returning customers.',
        'Collect ratings from new customers each month.',
      ],
    ),
  ];

  static const List<_TierCardData> _tierCards = <_TierCardData>[
    _TierCardData(
      title: 'Bronze <24',
      visibility: '20% Visibility',
      iconAsset: 'assets/bronze.png',
      cardColor: Color(0xFF382B1C),
      borderColor: Color(0xFFC88B3A),
      headerColor: Color(0xFF675139),
      body:
          'For new or low-activity users.\n'
          'Benefits\n'
          '- Profile is visible and searchable\n'
          '- 30 days wait time for withdraw\n'
          '- Entry level exposure\n\n'
          'Bronze is the starting point to build trust and activity.',
    ),
    _TierCardData(
      title: 'Silver 25 - 49',
      visibility: '40% Visibility',
      iconAsset: 'assets/silver.png',
      cardColor: Color(0xFF14171D),
      borderColor: Color(0xFF9AA4C7),
      headerColor: Color(0xFF3A4251),
      body:
          'For new or low-activity users.\n'
          'Benefits\n'
          '- Profile is visible and searchable\n'
          '- 20 days wait time for withdraw\n'
          '- Entry level exposure\n\n'
          'Bronze is the starting point to build trust and activity.',
    ),
    _TierCardData(
      title: 'Gold 50 - 64',
      visibility: '60% Visibility',
      iconAsset: 'assets/gold.png',
      cardColor: Color(0xFF5E4F20),
      borderColor: Color(0xFFF5C542),
      headerColor: Color(0xFFD2AB41),
      body:
          'For active and trusted users.\n'
          'Benefits\n'
          '- Strong search visibility\n'
          '- 12 days wait time for withdraw\n'
          '- Favored in recommendations\n\n'
          'Gold represents solid performance and platform trust.',
    ),
    _TierCardData(
      title: 'Platinium 65 - 79',
      visibility: '80% Visibility',
      iconAsset: 'assets/platinum.png',
      cardColor: Color(0xFF101F2A),
      borderColor: Color(0xFF8FD3FF),
      headerColor: Color(0xFF203543),
      body:
          'For high-consistency top performers.\n'
          'Benefits\n'
          '- High priority in search and discovery\n'
          '- Frequent homepage exposure\n'
          '- 7 days wait time for withdraw\n'
          '- Preferred for internal promotions and pilots\n\n'
          'Platinum profiles are considered premium and highly reliable.',
    ),
    _TierCardData(
      title: 'Emerald <80',
      visibility: '95-100% Visibility',
      iconAsset: 'assets/emerald.png',
      cardColor: Color(0xFF12271B),
      borderColor: Color(0xFF3B9D4C),
      headerColor: Color(0xFF1C3D2A),
      body:
          'For elite, long-term top performers.\n'
          'Benefits\n'
          '- Maximum platform exposure\n'
          '- 4 days wait time for withdraw\n'
          '- Strong recommendation boost\n'
          '- Priority for sponsor and brand collaborations\n\n'
          'Emerald represents the highest level of trust and performance.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionHubPanel(cards: _metricCards),
        const SizedBox(height: 32),
        Text(
          'Scoreboard & Visibility System',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 32,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        const _VisibilitySystemInfo(),
        const SizedBox(height: 24),
        _TierCardsSection(cards: _tierCards),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action Hub Panel
// ---------------------------------------------------------------------------

class _ActionHubPanel extends StatelessWidget {
  final List<_ActionMetricCardData> cards;

  const _ActionHubPanel({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF070B1D),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 920) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ActionProgressRing(progress: 0.35),
                    SizedBox(height: 18),
                    _ActionHubHeadline(),
                  ],
                );
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ActionProgressRing(progress: 0.35),
                  SizedBox(width: 28),
                  Expanded(child: _ActionHubHeadline()),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final width = constraints.maxWidth;

              int columns;
              if (width >= 1080) {
                columns = 4;
              } else if (width >= 760) {
                columns = 2;
              } else {
                columns = 1;
              }

              final cardWidth = (width - ((columns - 1) * spacing)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: cardWidth,
                        child: _ActionMetricCard(data: card),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Headline & Progress Ring
// ---------------------------------------------------------------------------

class _ActionHubHeadline extends StatelessWidget {
  const _ActionHubHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action Hub',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              'Complete actions',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF8C34A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.05,
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFFF8C34A),
              size: 18,
            ),
            Text(
              'unlock Silver',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF8C34A),
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 1.05,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _PrimaryActionChip(label: 'View Creators guide', onTap: () {}),
      ],
    );
  }
}

class _ActionProgressRing extends StatelessWidget {
  final double progress;

  const _ActionProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF51D76E),
              ),
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2F88FF),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 8,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 8,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metric Card — simple setState toggle, NO 3-D Transform on Y axis
// ---------------------------------------------------------------------------

class _ActionMetricCard extends StatefulWidget {
  final _ActionMetricCardData data;

  const _ActionMetricCard({required this.data});

  @override
  State<_ActionMetricCard> createState() => _ActionMetricCardState();
}

class _ActionMetricCardState extends State<_ActionMetricCard> {
  bool _showRules = false;

  void _toggleRules() => setState(() => _showRules = !_showRules);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _showRules
          ? _buildBackFace(key: const ValueKey('back'))
          : _buildFrontFace(key: const ValueKey('front')),
    );
  }

  // ---- front ----

  Widget _buildFrontFace({Key? key}) {
    return _buildCardShell(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(title: widget.data.title),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            child: Row(
              children: [
                Text(
                  widget.data.score,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                _MetricStatusBadge(status: widget.data.status),
              ],
            ),
          ),
          Divider(
            color: const Color(0xFF1D2537).withValues(alpha: 0.9),
            height: 1,
          ),
          ...widget.data.rows.map((row) => _ActionMetricRow(data: row)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                _TinyTagButton(
                  label: 'Rules',
                  icon: Icons.settings,
                  backgroundColor: const Color(0xFF2F88FF),
                  onTap: _toggleRules,
                ),
                const Spacer(),
                _TinyTagButton(
                  label: 'Check',
                  icon: Icons.chevron_right_rounded,
                  backgroundColor: const Color(0xFF19B375),
                  iconAfterLabel: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- back ----

  Widget _buildBackFace({Key? key}) {
    final rules = widget.data.rules;
    return _buildCardShell(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(title: 'Rules'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Text(
              widget.data.rulesTitle ?? '${widget.data.title} RULES',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          Divider(
            color: const Color(0xFF1D2537).withValues(alpha: 0.9),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: rules.isEmpty
                ? Text(
                    'Rules will be available soon.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < rules.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == rules.length - 1 ? 0 : 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${i + 1}.',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFF8C34A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  rules[i],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                _TinyTagButton(
                  label: 'Back',
                  icon: Icons.undo_rounded,
                  backgroundColor: const Color(0xFF2F88FF),
                  onTap: _toggleRules,
                ),
                const Spacer(),
                _TinyTagButton(
                  label: 'Check',
                  icon: Icons.chevron_right_rounded,
                  backgroundColor: const Color(0xFF19B375),
                  iconAfterLabel: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- helpers ----

  Widget _buildCardHeader({required String title}) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF192030),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(widget.data.icon, color: const Color(0xFF51D76E), size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardShell({required Widget child, Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xFF121826),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _ActionMetricRow extends StatelessWidget {
  final _ActionMetricRowData data;

  const _ActionMetricRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1D2537).withValues(alpha: 0.9),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              data.label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            data.value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricStatusBadge extends StatelessWidget {
  final _MetricStatus status;

  const _MetricStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == _MetricStatus.completed;
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? const <Color>[Color(0xFF0E3A2F), Color(0xFF134E3A)]
              : const <Color>[Color(0xFFBCA46E), Color(0xFFB99645)],
        ),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF1F6F5A)
              : const Color(0xFFC5B483),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          isCompleted ? 'Completed' : 'Pending steps',
          style: GoogleFonts.nunitoSans(
            color: isCompleted
                ? const Color(0xFF25866D)
                : const Color(0xFF7C6329),
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Small tag-style action button with explicit button semantics and
/// mouse cursor feedback for web/desktop.
class _TinyTagButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool iconAfterLabel;
  final VoidCallback? onTap;

  const _TinyTagButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.iconAfterLabel = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, color: Colors.white, size: 10);
    final labelWidget = Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 10,
        height: 1,
      ),
    );

    final rowChildren = iconAfterLabel
        ? <Widget>[labelWidget, const SizedBox(width: 4), iconWidget]
        : <Widget>[iconWidget, const SizedBox(width: 4), labelWidget];

    return SizedBox(
      height: 26,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Visibility System Info
// ---------------------------------------------------------------------------

class _VisibilitySystemInfo extends StatelessWidget {
  const _VisibilitySystemInfo();

  static const String _infoText =
      'Our tier system reflects activity, reliability, and consistency on the '
      'platform. Higher tiers receive greater visibility, meaning profiles '
      'appear more often and in better positions across the platform.\n\n'
      'Visibility affects:\n'
      '- Search result ranking\n'
      '- Recommendation frequency\n'
      '- Homepage and discovery sections\n'
      '- Eligibility for platform and sponsor features';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1422),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0, 0.86],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _infoText,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                height: 1.48,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tier Cards
// ---------------------------------------------------------------------------

class _TierCardsSection extends StatelessWidget {
  final List<_TierCardData> cards;

  const _TierCardsSection({required this.cards});

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;
    final children = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      if (i > 0) children.add(const SizedBox(width: spacing));
      children.add(Expanded(child: _TierCard(data: cards[i])));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _TierCard extends StatelessWidget {
  final _TierCardData data;

  const _TierCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      decoration: BoxDecoration(
        color: data.cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: data.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 62,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: data.headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    data.iconAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) => const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        data.visibility,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Text(
              data.body,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models & enums
// ---------------------------------------------------------------------------

enum _MetricStatus { completed, pending }

@immutable
class _ActionMetricCardData {
  final String title;
  final IconData icon;
  final String score;
  final _MetricStatus status;
  final List<_ActionMetricRowData> rows;
  final String? rulesTitle;
  final List<String> rules;

  const _ActionMetricCardData({
    required this.title,
    required this.icon,
    required this.score,
    required this.status,
    required this.rows,
    this.rulesTitle,
    this.rules = const <String>[],
  });
}

@immutable
class _ActionMetricRowData {
  final String label;
  final String value;

  const _ActionMetricRowData({required this.label, required this.value});
}

@immutable
class _TierCardData {
  final String title;
  final String visibility;
  final String iconAsset;
  final Color cardColor;
  final Color borderColor;
  final Color headerColor;
  final String body;

  const _TierCardData({
    required this.title,
    required this.visibility,
    required this.iconAsset,
    required this.cardColor,
    required this.borderColor,
    required this.headerColor,
    required this.body,
  });
}
