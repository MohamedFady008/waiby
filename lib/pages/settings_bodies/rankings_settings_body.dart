import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

const String _leaderboardWallpaperAsset = 'assets/leaderboard_wallpaper.png';

class RankingsSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const RankingsSettingsBody({super.key, required this.entry});

  @override
  State<RankingsSettingsBody> createState() => _RankingsSettingsBodyState();
}

class _RankingsSettingsBodyState extends State<RankingsSettingsBody> {
  _LeaderboardMode _selectedMode = _LeaderboardMode.topEarner;
  int _currentPage = 1;

  static const Map<_LeaderboardMode, _LeaderboardData> _leaderboardByMode =
      <_LeaderboardMode, _LeaderboardData>{
        _LeaderboardMode.scoreRate: _LeaderboardData(
          podium: <_PodiumUser>[
            _PodiumUser(
              name: 'CallmeMA',
              avatarAsset: 'assets/pp2.png',
              rewardLabel: 'Earn 500 orbs',
              rewardTone: _RewardTone.silver,
            ),
            _PodiumUser(
              name: 'Medusa',
              avatarAsset: 'assets/pp1.png',
              rewardLabel: 'Earn 1,000 orbs',
              rewardTone: _RewardTone.gold,
            ),
            _PodiumUser(
              name: 'Lilianat',
              avatarAsset: 'assets/pp3.png',
              rewardLabel: 'Earn 250 orbs',
              rewardTone: _RewardTone.bronze,
            ),
          ],
          rows: <_LeaderboardRow>[
            _LeaderboardRow(
              rank: '7',
              userName: 'broomi',
              avatarAsset: 'assets/pp1.png',
              point: '72',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '5',
              userName: 'Ori ·◇',
              avatarAsset: 'assets/pp2.png',
              point: '78',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '6',
              userName: 'Insane Work',
              avatarAsset: 'assets/pp3.png',
              point: '75',
            ),
            _LeaderboardRow(
              rank: '7',
              userName: 'Hidden',
              avatarAsset: 'assets/bunny1.png',
              point: '71',
            ),
            _LeaderboardRow(
              rank: '7',
              userName: 'Hidden',
              avatarAsset: 'assets/bunny2.png',
              point: '71',
            ),
            _LeaderboardRow(
              rank: '8',
              userName: 'vampy.6969',
              avatarAsset: 'assets/pp4.png',
              point: '69',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '9',
              userName: 'chrimk',
              avatarAsset: 'assets/pp5.png',
              point: '66',
              showOnlineDot: true,
            ),
            _LeaderboardRow(
              rank: '11',
              userName: '\'Marin~♡',
              avatarAsset: 'assets/pp6.png',
              point: '64',
              showOnlineDot: true,
            ),
          ],
          currentUser: _LeaderboardRow(
            rank: '490',
            userName: 'KIMI',
            avatarAsset: 'assets/pp7.png',
            point: '31',
            highlighted: true,
          ),
        ),
        _LeaderboardMode.topEarner: _LeaderboardData(
          podium: <_PodiumUser>[
            _PodiumUser(
              name: 'CallmeMA',
              avatarAsset: 'assets/pp2.png',
              rewardLabel: 'Earn 500 orbs',
              rewardTone: _RewardTone.silver,
            ),
            _PodiumUser(
              name: 'Medusa',
              avatarAsset: 'assets/pp1.png',
              rewardLabel: 'Earn 1,000 orbs',
              rewardTone: _RewardTone.gold,
            ),
            _PodiumUser(
              name: 'Lilianat',
              avatarAsset: 'assets/pp3.png',
              rewardLabel: 'Earn 250 orbs',
              rewardTone: _RewardTone.bronze,
            ),
          ],
          rows: <_LeaderboardRow>[
            _LeaderboardRow(
              rank: '7',
              userName: 'broomi',
              avatarAsset: 'assets/pp1.png',
              point: '72',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '5',
              userName: 'Ori ·◇',
              avatarAsset: 'assets/pp2.png',
              point: '78',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '6',
              userName: 'Insane Work',
              avatarAsset: 'assets/pp3.png',
              point: '75',
            ),
            _LeaderboardRow(
              rank: '7',
              userName: 'Hidden',
              avatarAsset: 'assets/bunny1.png',
              point: '71',
            ),
            _LeaderboardRow(
              rank: '7',
              userName: 'Hidden',
              avatarAsset: 'assets/bunny2.png',
              point: '71',
            ),
            _LeaderboardRow(
              rank: '8',
              userName: 'vampy.6969',
              avatarAsset: 'assets/pp4.png',
              point: '69',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '9',
              userName: 'chrimk',
              avatarAsset: 'assets/pp5.png',
              point: '66',
              showOnlineDot: true,
            ),
            _LeaderboardRow(
              rank: '11',
              userName: '\'Marin~♡',
              avatarAsset: 'assets/pp6.png',
              point: '64',
              showOnlineDot: true,
            ),
          ],
          currentUser: _LeaderboardRow(
            rank: '490',
            userName: 'KIMI',
            avatarAsset: 'assets/pp7.png',
            point: '31',
            highlighted: true,
          ),
        ),
        _LeaderboardMode.giftSubscription: _LeaderboardData(
          podium: <_PodiumUser>[
            _PodiumUser(
              name: 'CallmeMA',
              avatarAsset: 'assets/pp4.png',
              rewardLabel: 'Earn 500 orbs',
              rewardTone: _RewardTone.silver,
            ),
            _PodiumUser(
              name: 'Medusa',
              avatarAsset: 'assets/pp6.png',
              rewardLabel: 'Earn 1,000 orbs',
              rewardTone: _RewardTone.gold,
            ),
            _PodiumUser(
              name: 'Lilianat',
              avatarAsset: 'assets/pp5.png',
              rewardLabel: 'Earn 250 orbs',
              rewardTone: _RewardTone.bronze,
            ),
          ],
          rows: <_LeaderboardRow>[
            _LeaderboardRow(
              rank: '7',
              userName: 'broomi',
              avatarAsset: 'assets/pp1.png',
              point: '68',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '5',
              userName: 'Ori ·◇',
              avatarAsset: 'assets/pp2.png',
              point: '70',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '6',
              userName: 'Insane Work',
              avatarAsset: 'assets/pp3.png',
              point: '69',
            ),
            _LeaderboardRow(
              rank: '7',
              userName: 'Hidden',
              avatarAsset: 'assets/bunny1.png',
              point: '66',
            ),
            _LeaderboardRow(
              rank: '7',
              userName: 'Hidden',
              avatarAsset: 'assets/bunny2.png',
              point: '66',
            ),
            _LeaderboardRow(
              rank: '8',
              userName: 'vampy.6969',
              avatarAsset: 'assets/pp4.png',
              point: '64',
              showBadges: true,
            ),
            _LeaderboardRow(
              rank: '9',
              userName: 'chrimk',
              avatarAsset: 'assets/pp5.png',
              point: '61',
              showOnlineDot: true,
            ),
            _LeaderboardRow(
              rank: '11',
              userName: '\'Marin~♡',
              avatarAsset: 'assets/pp6.png',
              point: '60',
              showOnlineDot: true,
            ),
          ],
          currentUser: _LeaderboardRow(
            rank: '490',
            userName: 'KIMI',
            avatarAsset: 'assets/pp7.png',
            point: '31',
            highlighted: true,
          ),
        ),
      };

  _LeaderboardData get _activeData => _leaderboardByMode[_selectedMode]!;
  int get _totalPages => _activeData.totalPages;

  List<_LeaderboardRow> get _visibleRows =>
      _rowsForPage(_activeData.rows, _currentPage);

  List<_LeaderboardRow> _rowsForPage(List<_LeaderboardRow> baseRows, int page) {
    if (page <= 1 || baseRows.isEmpty) {
      return baseRows;
    }

    final shift = (page - 1) % baseRows.length;
    final rankOffset = (page - 1) * baseRows.length;
    final pointOffset = (page - 1) * 2;

    return List<_LeaderboardRow>.generate(baseRows.length, (index) {
      final row = baseRows[(index + shift) % baseRows.length];
      final rankValue = int.tryParse(row.rank);
      final pointValue = int.tryParse(row.point);

      final adjustedRank = rankValue == null
          ? row.rank
          : (rankValue + rankOffset).toString();
      final adjustedPoint = pointValue == null
          ? row.point
          : ((pointValue - pointOffset) < 1 ? 1 : (pointValue - pointOffset))
                .toString();

      return row.copyWith(rank: adjustedRank, point: adjustedPoint);
    });
  }

  void _selectMode(_LeaderboardMode mode) {
    setState(() {
      _selectedMode = mode;
      _currentPage = 1;
    });
  }

  void _goToPage(int page) {
    final clampedPage = page.clamp(1, _totalPages);
    if (clampedPage == _currentPage) {
      return;
    }
    setState(() => _currentPage = clampedPage);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F15),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _LeaderboardBackgroundFX()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _ModeTabs(
                  selected: _selectedMode,
                  onSelect: _selectMode,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: _PodiumSection(data: _activeData),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _LeaderboardTable(
                    rows: _visibleRows,
                    currentUser: _activeData.currentUser,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: _PaginationStrip(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: _goToPage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardBackgroundFX extends StatelessWidget {
  const _LeaderboardBackgroundFX();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Stack(
        children: [
          Positioned(
            left: -120,
            right: -120,
            top: -336,
            height: 474,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF293047).withValues(alpha: 0.42),
                    const Color(0xFF0E0F15),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 28,
            child: Center(
              child: _BlurGlowEllipse(
                color: const Color(0xFF004288),
                width: 988,
                height: 109,
                blurRadius: 82,
                opacity: 0.42,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -204,
            child: Center(
              child: Transform.rotate(
                angle: -1.57,
                child: const _BlurGlowEllipse(
                  color: Color(0xFF215D9D),
                  width: 392,
                  height: 104,
                  blurRadius: 22,
                  opacity: 0.42,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 46,
            child: Center(
              child: const _BlurGlowEllipse(
                color: Color(0xFF6AC8FF),
                width: 199,
                height: 442,
                blurRadius: 122,
                opacity: 0.26,
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: 196,
            child: const _BlurGlowEllipse(
              color: Color(0xFF6AC8FF),
              width: 199,
              height: 171,
              blurRadius: 122,
              opacity: 0.24,
            ),
          ),
          Positioned(
            right: -24,
            top: 218,
            child: const _BlurGlowEllipse(
              color: Color(0xFF6AC8FF),
              width: 199,
              height: 171,
              blurRadius: 122,
              opacity: 0.24,
            ),
          ),
          Positioned(
            left: -200,
            right: -200,
            top: -220,
            height: 360,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.05,
                  colors: [
                    const Color(0xFF35406A).withValues(alpha: 0.55),
                    const Color(0xFF0E0F15),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              _leaderboardWallpaperAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/noise.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurGlowEllipse extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double blurRadius;
  final double opacity;

  const _BlurGlowEllipse({
    required this.color,
    required this.width,
    required this.height,
    required this.blurRadius,
    this.opacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blurRadius,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  final _LeaderboardMode selected;
  final ValueChanged<_LeaderboardMode> onSelect;

  const _ModeTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 421),
      child: SizedBox(
        width: double.infinity,
        height: 39,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF181C2A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0C0F1B),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: _LeaderboardMode.values
                  .map(
                    (mode) => Expanded(
                      flex: mode.flex,
                      child: _ModeTabButton(
                        label: mode.label,
                        selected: selected == mode,
                        onTap: () => onSelect(mode),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTabButton({
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
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 31,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF293047) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PodiumSection extends StatelessWidget {
  final _LeaderboardData data;

  const _PodiumSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        if (compact) {
          return Column(
            children: [
              _PodiumCard(profile: data.podium[1], center: true),
              const SizedBox(height: 18),
              _PodiumCard(profile: data.podium[0]),
              const SizedBox(height: 14),
              _PodiumCard(profile: data.podium[2]),
            ],
          );
        }

        final width = constraints.maxWidth;
        final scale = (width / 1120).clamp(0.78, 1.0);
        double px(double value) => value * scale;

        final avatarSize = px(108);
        final centerCardWidth = px(240);
        final sideCardWidth = px(220);

        final leftCenterX = width * 0.246;
        final centerX = width * 0.506;
        final rightCenterX = width * 0.762;

        final centerTop = px(18);
        final leftTop = centerTop + px(46);
        final rightTop = centerTop + px(74);

        final centerRewardTop = px(258);
        final leftRewardTop = centerRewardTop + px(28);
        final rightRewardTop = centerRewardTop + px(50);

        return SizedBox(
          height: px(430),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: centerX - (centerCardWidth / 2),
                top: centerTop,
                child: _PodiumOverlayUser(
                  profile: data.podium[1],
                  cardWidth: centerCardWidth,
                  avatarSize: avatarSize,
                  fontSize: px(24),
                ),
              ),
              Positioned(
                left: leftCenterX - (sideCardWidth / 2),
                top: leftTop,
                child: _PodiumOverlayUser(
                  profile: data.podium[0],
                  cardWidth: sideCardWidth,
                  avatarSize: avatarSize,
                  fontSize: px(24),
                ),
              ),
              Positioned(
                left: rightCenterX - (sideCardWidth / 2),
                top: rightTop,
                child: _PodiumOverlayUser(
                  profile: data.podium[2],
                  cardWidth: sideCardWidth,
                  avatarSize: avatarSize,
                  fontSize: px(24),
                ),
              ),
              Positioned(
                left: centerX - (centerCardWidth / 2),
                top: centerRewardTop,
                child: _PodiumTopPointsLabel(
                  text: data.podium[1].rewardLabel,
                  width: centerCardWidth,
                  fontSize: px(14),
                ),
              ),
              Positioned(
                left: leftCenterX - (sideCardWidth / 2),
                top: leftRewardTop,
                child: _PodiumTopPointsLabel(
                  text: data.podium[0].rewardLabel,
                  width: sideCardWidth,
                  fontSize: px(14),
                ),
              ),
              Positioned(
                left: rightCenterX - (sideCardWidth / 2),
                top: rightRewardTop,
                child: _PodiumTopPointsLabel(
                  text: data.podium[2].rewardLabel,
                  width: sideCardWidth,
                  fontSize: px(14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PodiumOverlayUser extends StatelessWidget {
  final _PodiumUser profile;
  final double cardWidth;
  final double avatarSize;
  final double fontSize;

  const _PodiumOverlayUser({
    required this.profile,
    required this.cardWidth,
    required this.avatarSize,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FramedAvatar(
            avatarAsset: profile.avatarAsset,
            size: avatarSize,
            frameTone: profile.rewardTone,
          ),
          const SizedBox(height: 10),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumTopPointsLabel extends StatelessWidget {
  final String text;
  final double width;
  final double fontSize;

  const _PodiumTopPointsLabel({
    required this.text,
    required this.width,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: fontSize,
          height: 1.2,
        ),
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  final _PodiumUser profile;
  final bool center;

  const _PodiumCard({required this.profile, this.center = false});

  @override
  Widget build(BuildContext context) {
    const avatarSize = 108.0;
    const stageHeight = 394.0;
    final stageTop = center ? 168.0 : 210.0;
    final totalHeight = stageTop + stageHeight;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 333),
        child: SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: stageTop,
                child: _PodiumPedestal(
                  tone: profile.rewardTone,
                  rewardLabel: profile.rewardLabel,
                  center: center,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FramedAvatar(
                    avatarAsset: profile.avatarAsset,
                    size: avatarSize,
                    frameTone: profile.rewardTone,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumPedestal extends StatelessWidget {
  final _RewardTone tone;
  final String rewardLabel;
  final bool center;

  const _PodiumPedestal({
    required this.tone,
    required this.rewardLabel,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    const topCapHeight = 30.0;
    const bodyHeight = 364.0;
    const bodyRadius = BorderRadius.only(
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(4),
    );

    return SizedBox(
      height: topCapHeight + bodyHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 22,
            right: 22,
            bottom: -14,
            child: Container(
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x8A000000),
                    blurRadius: 26,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: topCapHeight - 1,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF181D2B),
                    Color(0xFF0F1118),
                    Color(0xFF0E0F15),
                  ],
                  stops: [0, 0.37, 0.82],
                ),
                borderRadius: bodyRadius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66111B38),
                    blurRadius: 26,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: topCapHeight,
            child: ClipPath(
              clipper: const _PodiumTopCapClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1C2232), Color(0xFF111827)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: topCapHeight + 8,
            bottom: 8,
            width: 26,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF355084).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: topCapHeight + 8,
            bottom: 8,
            width: 26,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(14),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF06080F).withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            top: topCapHeight + 45,
            child: Divider(
              color: Colors.white.withValues(alpha: 0.07),
              height: 1,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: topCapHeight + 62,
            child: Column(
              children: [
                _PodiumRewardIcon(tone: tone),
                const SizedBox(height: 8),
                Text(
                  rewardLabel,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumTopCapClipper extends CustomClipper<Path> {
  const _PodiumTopCapClipper();

  @override
  Path getClip(Size size) {
    final inset = size.width * 0.18;
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.6)
      ..lineTo(inset, 0)
      ..lineTo(size.width - inset, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FramedAvatar extends StatelessWidget {
  final String avatarAsset;
  final double size;
  final _RewardTone frameTone;

  const _FramedAvatar({
    required this.avatarAsset,
    required this.size,
    required this.frameTone,
  });

  @override
  Widget build(BuildContext context) {
    final frameColor = switch (frameTone) {
      _RewardTone.gold => const Color(0xFFD7A928),
      _RewardTone.silver => const Color(0xFFCACACA),
      _RewardTone.bronze => const Color(0xFF8B6A2C),
    };

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: frameColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: frameColor.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          avatarAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF1A2030),
            alignment: Alignment.center,
            child: Icon(
              Icons.person,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _PodiumRewardIcon extends StatelessWidget {
  final _RewardTone tone;

  const _PodiumRewardIcon({required this.tone});

  @override
  Widget build(BuildContext context) {
    final (background, iconColor) = switch (tone) {
      _RewardTone.gold => (const Color(0xFFFFD365), const Color(0xFF5F5434)),
      _RewardTone.silver => (const Color(0xFFCDCDCD), const Color(0xFF585858)),
      _RewardTone.bronze => (const Color(0xFF634514), const Color(0xFFCACACA)),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.emoji_events_rounded, color: iconColor, size: 24),
    );
  }
}

class _LeaderboardTable extends StatelessWidget {
  final List<_LeaderboardRow> rows;
  final _LeaderboardRow currentUser;

  const _LeaderboardTable({required this.rows, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 110),
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const SizedBox(width: 70, child: _TableHeaderLabel('Rank')),
                Expanded(child: Center(child: _TableHeaderLabel('User name'))),
                const SizedBox(
                  width: 80,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _TableHeaderLabel('Point'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map((row) => _LeaderboardRowCard(data: row)),
          const SizedBox(height: 8),
          _LeaderboardRowCard(data: currentUser),
        ],
      ),
    );
  }
}

class _TableHeaderLabel extends StatelessWidget {
  final String text;

  const _TableHeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.6),
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
    );
  }
}

class _LeaderboardRowCard extends StatelessWidget {
  final _LeaderboardRow data;

  const _LeaderboardRowCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final rowColor = data.highlighted
        ? const Color(0xFF2F88FF)
        : const Color(0xFF171C29);

    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              data.rank,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RowAvatar(asset: data.avatarAsset),
                const SizedBox(width: 10),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          data.userName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (data.showBadges) ...const [
                        SizedBox(width: 6),
                        _TinyStatusIcon(asset: 'assets/level.png'),
                        SizedBox(width: 3),
                        _TinyStatusIcon(asset: 'assets/live.png'),
                      ],
                      if (data.showOnlineDot) ...const [
                        SizedBox(width: 6),
                        _OnlineDot(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                data.point,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowAvatar extends StatelessWidget {
  final String asset;

  const _RowAvatar({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x66FFFFFF), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF111726),
          alignment: Alignment.center,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }
}

class _TinyStatusIcon extends StatelessWidget {
  final String asset;

  const _TinyStatusIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF51D76E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PaginationStrip extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _PaginationStrip({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<int?> _visiblePages() {
    if (totalPages <= 6) {
      return List<int?>.generate(totalPages, (index) => index + 1);
    }

    if (currentPage <= 3) {
      return <int?>[1, 2, 3, 4, null, totalPages];
    }

    if (currentPage >= totalPages - 2) {
      return <int?>[
        1,
        null,
        totalPages - 3,
        totalPages - 2,
        totalPages - 1,
        totalPages,
      ];
    }

    return <int?>[
      1,
      null,
      currentPage - 1,
      currentPage,
      currentPage + 1,
      null,
      totalPages,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _PagerArrow(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        SizedBox(width: 8),
        for (final page in pages)
          _PagerChip(
            label: page == null ? '...' : page.toString(),
            active: page == currentPage,
            ellipsis: page == null,
            onTap: page == null ? null : () => onPageChanged(page),
          ),
        const SizedBox(width: 8),
        _PagerArrow(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }
}

class _PagerArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PagerArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _PagerChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool ellipsis;
  final VoidCallback? onTap;

  const _PagerChip({
    required this.label,
    this.active = false,
    this.ellipsis = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 27,
          height: 32,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2D3959) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: ellipsis ? 0.42 : 0.6),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

enum _LeaderboardMode {
  scoreRate('Score Rate', 129),
  topEarner('Top Earner', 123),
  giftSubscription('Gift & Subscription', 165);

  const _LeaderboardMode(this.label, this.flex);
  final String label;
  final int flex;
}

@immutable
class _LeaderboardData {
  final List<_PodiumUser> podium;
  final List<_LeaderboardRow> rows;
  final _LeaderboardRow currentUser;
  final int totalPages = 11;

  const _LeaderboardData({
    required this.podium,
    required this.rows,
    required this.currentUser,
  });
}

@immutable
class _PodiumUser {
  final String name;
  final String avatarAsset;
  final String rewardLabel;
  final _RewardTone rewardTone;

  const _PodiumUser({
    required this.name,
    required this.avatarAsset,
    required this.rewardLabel,
    required this.rewardTone,
  });
}

@immutable
class _LeaderboardRow {
  final String rank;
  final String userName;
  final String avatarAsset;
  final String point;
  final bool showBadges;
  final bool showOnlineDot;
  final bool highlighted;

  const _LeaderboardRow({
    required this.rank,
    required this.userName,
    required this.avatarAsset,
    required this.point,
    this.showBadges = false,
    this.showOnlineDot = false,
    this.highlighted = false,
  });

  _LeaderboardRow copyWith({
    String? rank,
    String? userName,
    String? avatarAsset,
    String? point,
    bool? showBadges,
    bool? showOnlineDot,
    bool? highlighted,
  }) {
    return _LeaderboardRow(
      rank: rank ?? this.rank,
      userName: userName ?? this.userName,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      point: point ?? this.point,
      showBadges: showBadges ?? this.showBadges,
      showOnlineDot: showOnlineDot ?? this.showOnlineDot,
      highlighted: highlighted ?? this.highlighted,
    );
  }
}

enum _RewardTone { gold, silver, bronze }
