import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_sidebar.dart';

class LiveRoomPage extends StatelessWidget {
  const LiveRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final showRail = w >= 1320;
        const railWidth = 84.0;
        const railGap = 12.0;
        final pad = w >= 1400
            ? 20.0
            : w >= 980
            ? 14.0
            : 8.0;
        final contentW = math.min(
          1720.0,
          math.max(300.0, w - (pad * 2) - (showRail ? railWidth + railGap : 0)),
        );

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C122D), Color(0xFF050816)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentW,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(pad, 34, pad, 24),
                      child: const _LiveShell(),
                    ),
                  ),
                ),
              ),
              if (showRail)
                Padding(
                  padding: EdgeInsets.only(right: pad),
                  child: const _LiveRail(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveShell extends StatelessWidget {
  const _LiveShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B1D),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 22,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final desktop = w >= 1420;
          final tablet = w >= 980 && !desktop;

          if (desktop) {
            return SizedBox(
              height: 805,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 24, 18, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(width: 312, child: _LeftColumn()),
                    SizedBox(width: 26),
                    Expanded(child: _CenterColumn()),
                    SizedBox(width: 26),
                    SizedBox(width: 470, child: _RightColumn()),
                  ],
                ),
              ),
            );
          }

          if (tablet) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _CenterColumn(compact: true),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _LeftColumn(compact: true)),
                      SizedBox(width: 16),
                      Expanded(child: _RightColumn(compact: true)),
                    ],
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                _CenterColumn(compact: true, narrow: true),
                SizedBox(height: 14),
                _LeftColumn(compact: true),
                SizedBox(height: 14),
                _RightColumn(compact: true),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  final bool compact;

  const _LeftColumn({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final titleSize = compact ? 26.0 : 33.0;
    final subSize = compact ? 20.0 : 28.0;
    final headPad = compact ? 10.0 : 0.0;
    const topGifters = <(String, String, String, bool)>[
      ('Makehna', '25 Buds', 'assets/pp1.png', false),
      ('sirmaz', '10 Buds', 'assets/pp4.png', false),
      ('royaking', '5 Buds', 'assets/pp3.png', false),
      ('itsfam', '5 Buds', 'assets/pp7.png', true),
    ];
    const gifts = <(String, String, String)>[
      ('Kiss', '2', 'assets/gifts/kiss.png'),
      ('Kiss', '5', 'assets/gifts/kitty_paw.png'),
      ('Waiby', '10', 'assets/gifts/waiby.png'),
      ('Cake', '25', 'assets/gifts/cake.png'),
      ('Rocket', '100', 'assets/gifts/rocket.png'),
      ('Dream Castle', '1000', 'assets/gifts/dream_castle.png'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: headPad),
          child: Row(
            children: [
              const _Avatar(
                asset: 'assets/pp2.png',
                size: 64,
                frame: 'assets/medals/lolita_pearl.png',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'MAtalks joinn',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: titleSize,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _liveBadge(),
                      ],
                    ),
                    Text(
                      'CallmeMA · 9 viewers ·',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w400,
                        fontSize: subSize,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 20),
        _neonCard(
          child: Column(
            children: [
              _sectionHeader('Top Gifters', Icons.emoji_events_rounded),
              for (final g in topGifters)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1C3E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _Avatar(asset: g.$3, size: 35),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                g.$1,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                ),
                              ),
                              if (g.$4)
                                const Padding(
                                  padding: EdgeInsets.only(left: 3),
                                  child: Icon(
                                    Icons.eco_rounded,
                                    size: 10,
                                    color: Color(0xFF51D76E),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          g.$2,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w500,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 20),
        _neonCard(
          child: Column(
            children: [
              _sectionHeader('Suggested Gifts', null),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    for (final gift in gifts)
                      SizedBox(
                        width: 88,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: Image.asset(gift.$3, fit: BoxFit.contain),
                            ),
                            Text(
                              gift.$1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              gift.$2,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 136,
                height: 28,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F88FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Send gift',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterColumn extends StatelessWidget {
  final bool compact;
  final bool narrow;

  const _CenterColumn({this.compact = false, this.narrow = false});

  @override
  Widget build(BuildContext context) {
    final stageW = narrow ? double.infinity : (compact ? 520.0 : 495.0);
    final hostName = compact ? 35.0 : 40.0;
    final nameSize = compact ? 26.0 : 16.0;
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Icon(
              Icons.logout_rounded,
              color: const Color(0xFF942424),
              size: compact ? 24 : 30,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _glowBubble(
          width: compact ? 240 : 234,
          height: compact ? 220 : 209,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Avatar(
                asset: 'assets/pp2.png',
                size: 105,
                frame: 'assets/medals/lolita_pearl.png',
              ),
              const SizedBox(height: 8),
              Text(
                'CallmeMA',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: hostName,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 79,
                height: 23,
                decoration: BoxDecoration(
                  color: const Color(0xFF4880FF),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Host',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _voiceRow(
          stageW,
          const [true, true, false, false],
          const ['Makehna', 'Saori'],
          nameSize,
        ),
        const SizedBox(height: 12),
        _voiceRow(
          stageW,
          const [false, false, false, false],
          const [],
          nameSize,
        ),
        const SizedBox(height: 24),
        _pillControls([
          _ctrl(Icons.redeem_rounded, const Color(0xFFEA7B21), Colors.white),
          _ctrl(
            Icons.mic_rounded,
            const Color(0x1FA84AA6),
            const Color(0xFF2F88FF),
            border: const Color(0xFFA84AA6),
            size: 26,
            w: 40,
            h: 40,
          ),
          _ctrl(Icons.call_end_rounded, const Color(0xFF691D1D), Colors.white),
        ], h: 42),
        const SizedBox(height: 12),
        _pillControls([
          _ctrl(
            Icons.settings_rounded,
            const Color(0xFF262222),
            Colors.white,
            size: 17,
          ),
          _ctrl(
            Icons.volume_up_rounded,
            const Color(0xFF262222),
            Colors.white,
            size: 17,
          ),
          _ctrl(
            Icons.report_rounded,
            const Color(0xFF262222),
            const Color(0xFFFF1010),
            size: 17,
          ),
        ], h: 40),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  final bool compact;

  const _RightColumn({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final logHeight = compact ? 470.0 : 607.0;
    return Column(
      children: [
        Container(
          height: 198,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF241F4C)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tab('Chat'),
                  const SizedBox(width: 86),
                  _tab('Viewers'),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 107,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: BoxDecoration(
                  color: const Color(0x178B0FBD),
                  border: Border.all(color: const Color(0xFF51D76E)),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06FF48).withValues(alpha: 0.3),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.redeem_rounded,
                          color: Color(0xFF51D76E),
                          size: 25,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Gift Goal',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '45/100 Buds',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 195,
                          decoration: BoxDecoration(
                            color: const Color(0xFF51D76E),
                            borderRadius: BorderRadius.circular(50),
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
        Container(
          height: logHeight,
          decoration: BoxDecoration(
            color: const Color(0xA81F1635),
            border: Border.all(color: const Color(0xFF241F4C)),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _msg('itsfam joined', const Color(0xCF51D76E)),
                      _msg('itsfam requested to join', const Color(0xCF51D76E)),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 33,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [Color(0xFFA8BEDD), Color(0xFF4F719F)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome send gifts!',
                          style: GoogleFonts.poppins(
                            color: const Color(0xE60D1024),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _rich('Sirmaz', ' Hello yall'),
                      _rich('Sirmaz gifted CallmeMA Kiss x2', ''),
                      _rich('Sirmaz', ' hows it going'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Say hi',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.redeem_rounded,
                        color: Color(0xD151D76E),
                        size: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveRail extends StatelessWidget {
  const _LiveRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border(
            left: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            right: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
          ),
        ),
        child: const ChatSidebar(
          width: 84,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.only(top: 8, bottom: 12),
          avatarSize: 48,
          frameSize: 62,
          itemSpacing: 12,
          unreadBadgeSize: 20,
          unreadBadgeFontSize: 11,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String asset;
  final double size;
  final String? frame;

  const _Avatar({required this.asset, required this.size, this.frame});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
          if (frame != null)
            Positioned.fill(child: Image.asset(frame!, fit: BoxFit.contain)),
        ],
      ),
    );
  }
}

Widget _sectionHeader(String text, IconData? icon) {
  return Container(
    width: double.infinity,
    height: 43,
    decoration: const BoxDecoration(
      color: Color(0x14000000),
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 29,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFFEFA315)),
        ],
      ],
    ),
  );
}

Widget _neonCard({required Widget child}) {
  return Container(
    width: 312,
    decoration: BoxDecoration(
      color: const Color(0x7D22193A),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFA43CF8)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFD946EF).withValues(alpha: 0.2),
          blurRadius: 30,
        ),
      ],
    ),
    child: child,
  );
}

Widget _glowBubble({
  required double width,
  required double height,
  required Widget child,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(80).copyWith(
        bottomLeft: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFEC4899).withValues(alpha: 0.6),
          blurRadius: 12,
        ),
        BoxShadow(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
          blurRadius: 40,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget _voiceRow(
  double width,
  List<bool> occupied,
  List<String> names,
  double nameSize,
) {
  return _glowBubble(
    width: width,
    height: 116,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < occupied.length; i++)
          occupied[i]
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Avatar(
                      asset: i == 0 ? 'assets/pp1.png' : 'assets/pp2.png',
                      size: 50,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      names[i],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: nameSize,
                        height: 1,
                      ),
                    ),
                  ],
                )
              : Container(
                  width: 50,
                  height: 51,
                  decoration: const BoxDecoration(
                    color: Color(0xFF262222),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 28,
                  ),
                ),
      ],
    ),
  );
}

Widget _pillControls(List<Widget> children, {required double h}) {
  return Container(
    width: 224,
    height: h,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(80),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    ),
  );
}

Widget _ctrl(
  IconData icon,
  Color bg,
  Color color, {
  Color? border,
  double size = 22,
  double w = 32,
  double h = 32,
}) {
  return Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: bg,
      shape: BoxShape.circle,
      border: border == null ? null : Border.all(color: border),
    ),
    alignment: Alignment.center,
    child: Icon(icon, color: color, size: size),
  );
}

Widget _tab(String label) {
  return Container(
    width: 120,
    height: 24,
    decoration: BoxDecoration(
      color: const Color(0xFF1B234B),
      borderRadius: BorderRadius.circular(5),
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    ),
  );
}

Widget _liveBadge() {
  return Container(
    width: 51,
    height: 12,
    decoration: BoxDecoration(
      color: const Color(0xFFFF0202),
      borderRadius: BorderRadius.circular(5),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 4),
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        const Icon(Icons.circle, size: 6, color: Colors.white),
        const SizedBox(width: 2),
        Text(
          'Live',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 10,
            height: 1,
          ),
        ),
      ],
    ),
  );
}

Widget _msg(String text, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 15,
        height: 1.2,
      ),
    ),
  );
}

Widget _rich(String green, String rest) {
  final base = GoogleFonts.poppins(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 1.2,
  );
  return Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(
            text: green,
            style: base.copyWith(color: const Color(0xFF51D76E)),
          ),
          TextSpan(text: rest),
        ],
      ),
    ),
  );
}
