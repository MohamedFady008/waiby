import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final showRail = w >= 1680;
        final threeCol = w >= 1380;
        final twoCol = w >= 1080 && !threeCol;
        const railRightInset = 8.0;
        const railWidth = 76.0;
        const railGap = 8.0;
        final pad = w >= 1200
            ? 28.0
            : w >= 900
            ? 20.0
            : 12.0;
        final railReserve = showRail
            ? railWidth + railRightInset + railGap
            : 0.0;
        final contentW = math.min(
          1680.0,
          math.max(0.0, w - (pad * 2) - (railReserve * 2)),
        );
        final sideW = w >= 1540 ? 300.0 : 272.0;
        final feedW = threeCol
            ? math.min(803.0, contentW - (sideW * 2) - 48.0)
            : twoCol
            ? math.min(803.0, contentW - sideW - 20.0)
            : math.min(803.0, contentW);

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C122D), Color(0xFF050816)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _BgGlow()),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  pad + railReserve,
                  22,
                  pad + railReserve,
                  220,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Hero(feedW: feedW, w: w),
                        const SizedBox(height: 26),
                        if (threeCol)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: sideW,
                                child: const _SuggestedAndPromo(),
                              ),
                              const SizedBox(width: 24),
                              SizedBox(width: feedW, child: const _Feed()),
                              const SizedBox(width: 24),
                              SizedBox(width: sideW, child: const _LivePanel()),
                            ],
                          )
                        else if (twoCol)
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: feedW, child: const _Feed()),
                                  const SizedBox(width: 20),
                                  SizedBox(
                                    width: sideW,
                                    child: const _LivePanel(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: sideW,
                                  child: const _SuggestedAndPromo(),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: math.max(280, feedW),
                                child: const _Feed(),
                              ),
                              const SizedBox(height: 18),
                              LayoutBuilder(
                                builder: (context, cc) {
                                  final split = cc.maxWidth >= 860;
                                  final cardW = split
                                      ? (cc.maxWidth - 16) / 2
                                      : math.min(440.0, cc.maxWidth);
                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: cardW,
                                        child: const _SuggestedAndPromo(),
                                      ),
                                      SizedBox(
                                        width: cardW,
                                        child: const _LivePanel(),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showRail)
                Positioned(
                  right: railRightInset,
                  top: 10,
                  bottom: 10,
                  child: const _RightRail(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BgGlow extends StatelessWidget {
  const _BgGlow();

  @override
  Widget build(BuildContext context) {
    Widget orb(double s, Color c) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)]),
      ),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -260,
            top: -180,
            child: orb(760, const Color(0x662E1C8D)),
          ),
          Positioned(
            left: -220,
            top: 540,
            child: orb(980, const Color(0x553E26B2)),
          ),
          Positioned(
            right: -280,
            top: 180,
            child: orb(920, const Color(0x40348BFF)),
          ),
          Positioned(
            right: -320,
            bottom: -180,
            child: orb(1040, const Color(0x222F88FF)),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final double feedW;
  final double w;
  const _Hero({required this.feedW, required this.w});

  @override
  Widget build(BuildContext context) {
    final compact = w < 700;
    final title = w >= 1200
        ? 58.0
        : w >= 900
        ? 48.0
        : 36.0;
    final sub = compact ? 24.0 : 30.0;
    final phoneW = compact
        ? feedW
        : math.min(580.0, math.max(350.0, feedW * 0.78));
    final phoneH = phoneW * 0.36;

    TextStyle titleStyle([Color? c]) => GoogleFonts.inter(
      fontSize: title,
      fontWeight: FontWeight.w700,
      color: c ?? Colors.white,
      letterSpacing: -1.0,
    );

    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "Explore and discover our ", style: titleStyle()),
              TextSpan(
                text: "Influ-Buddies",
                style: titleStyle(const Color(0xFF2ED35F)),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          "Upload, follow and share!",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: sub,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: phoneW,
          height: phoneH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0xFF6A2AF7), width: 5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A2AF7).withValues(alpha: 0.35),
                blurRadius: 32,
                spreadRadius: -12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset("assets/login.png", fit: BoxFit.cover),
                Container(color: Colors.black.withValues(alpha: 0.25)),
                Positioned(
                  left: 12,
                  top: 10,
                  child: _Avatar(asset: "assets/pp7.png", size: phoneW * 0.12),
                ),
                Positioned(
                  right: 12,
                  top: 8,
                  child: Row(
                    children: const [
                      _PhoneBtn(icon: Icons.replay_rounded),
                      SizedBox(width: 8),
                      _PhoneBtn(icon: Icons.speed_rounded, label: "1x"),
                      SizedBox(width: 8),
                      _PhoneBtn(icon: Icons.camera_alt_outlined),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneBtn extends StatelessWidget {
  final IconData icon;
  final String? label;
  const _PhoneBtn({required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xCC2B2D31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      alignment: Alignment.center,
      child: label != null
          ? Text(
              label!,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            )
          : Icon(icon, color: Colors.white, size: 19),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 30,
                color: Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search for games, services or custom...",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const _Tabs(),
        const SizedBox(height: 10),
        _Composer(),
        const SizedBox(height: 10),
        const _PostCard(
          user: "Arvkiny",
          time: "10h",
          text:
              "Would you quit your job if your side hustle matched your salary?",
          avatar: "assets/pp1.png",
          likes: 56,
          comments: 2,
          gifts: 0,
        ),
        const SizedBox(height: 0.5),
        const _PostCard(
          user: "Bowieews",
          time: "1h",
          text: "It was super spicy omg",
          avatar: "assets/pp2.png",
          image: "assets/login.png",
          likes: 6,
          comments: 2,
          gifts: 1,
        ),
        const SizedBox(height: 0.5),
        const _PostCard(
          user: "puliz",
          time: "10h",
          text: "hi im lf girls to play with dm me",
          avatar: "assets/pp3.png",
          likes: 1,
          comments: 2,
          gifts: 0,
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 560;
        final fs = compact ? 18.0 : 24.0;
        Widget tab(String t, bool active) => Expanded(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: active
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.96),
                        width: 1.3,
                      ),
                    )
                  : null,
            ),
            child: Text(
              t,
              style: GoogleFonts.inter(
                fontSize: fs,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
        return Container(
          height: compact ? 46 : 50,
          decoration: BoxDecoration(
            color: const Color(0xFF232755),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              tab("Following", false),
              tab("For you", true),
              tab("Live", false),
              tab("Official", false),
            ],
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 111),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const _Avatar(asset: "assets/pp6.png", size: 74),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LaKimi",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Share with the world what you re into",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.70),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_outlined,
            size: 24,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String user;
  final String time;
  final String text;
  final String avatar;
  final String? image;
  final int likes;
  final int comments;
  final int gifts;

  const _PostCard({
    required this.user,
    required this.time,
    required this.text,
    required this.avatar,
    this.image,
    required this.likes,
    required this.comments,
    required this.gifts,
  });

  @override
  Widget build(BuildContext context) {
    final countStyle = GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.62),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.17)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(asset: avatar, size: 54),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (image != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1.18,
                child: Image.asset(image!, fit: BoxFit.cover),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 20, color: Colors.white),
              const SizedBox(width: 3),
              Text("$likes", style: countStyle),
              const SizedBox(width: 14),
              Transform.flip(
                flipX: true,
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 3),
              Text("$comments", style: countStyle),
              const SizedBox(width: 14),
              const Icon(
                Icons.card_giftcard_outlined,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 3),
              Text("$gifts", style: countStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestedAndPromo extends StatelessWidget {
  const _SuggestedAndPromo();

  @override
  Widget build(BuildContext context) {
    Widget user(String name, String tag, String asset, bool following) =>
        Container(
          height: 53,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _Avatar(asset: asset, size: 43),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: following ? 59 : 51,
                height: 15,
                decoration: BoxDecoration(
                  color: following
                      ? const Color(0xCC51D76E)
                      : Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  following ? "Following" : "Follow",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D111F),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Suggested",
                style: GoogleFonts.inter(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              user("JayLoL", "FORTNITE", "assets/pp4.png", false),
              const SizedBox(height: 8),
              user("MJ", "CALL OF DUTY", "assets/pp5.png", true),
              const SizedBox(height: 8),
              user("munaria", "FORTNITE", "assets/pp6.png", false),
              const SizedBox(height: 8),
              user("IdenY", "VALORANT", "assets/pp7.png", false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D111F),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              Container(
                height: 53,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xE6DBC91A), Color(0x738F8C2C)],
                    stops: [0.39, 1.0],
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Play with Waiby!",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Get amazing rewards!",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Image.asset("assets/logo.png", width: 52, height: 52),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 53,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF07A0FF)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.discord,
                      color: Color(0xFF5865F2),
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Join to our community",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 55,
                      height: 19,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5865F2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Join",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LivePanel extends StatelessWidget {
  const _LivePanel();

  @override
  Widget build(BuildContext context) {
    Widget row(String name, String status, String asset) => Container(
      height: 94,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _Avatar(asset: asset, size: 53),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 12,
                  height: 9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0052B4), Color(0xFFD80027)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 51,
            height: 15,
            decoration: BoxDecoration(
              color: const Color(0xA3FF0202),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              "Live",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3050),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Live",
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          row("JayLoL", "1sub = 1win", "assets/pp4.png"),
          const SizedBox(height: 9),
          row("kandimax", "come and say hi", "assets/pp5.png"),
          const SizedBox(height: 9),
          row("CallmeMA", "3/10buds HELP", "assets/pp6.png"),
          const SizedBox(height: 9),
          row("Mr.Big", "noodles night", "assets/pp7.png"),
        ],
      ),
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail();

  @override
  Widget build(BuildContext context) {
    const entries = [
      ("assets/pp1.png", true, 1),
      ("assets/pp2.png", false, null),
      ("assets/pp3.png", true, 1),
      ("assets/pp4.png", true, 1),
      ("assets/pp5.png", true, 1),
      ("assets/pp6.png", false, null),
      ("assets/pp7.png", false, null),
      ("assets/pp1.png", false, null),
      ("assets/pp2.png", false, null),
    ];

    return SizedBox(
      width: 76,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            for (final e in entries) ...[
              SizedBox(
                width: 64,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (e.$2)
                      Positioned(
                        left: 0,
                        top: 20,
                        child: Container(
                          width: 4,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    Center(child: _Avatar(asset: e.$1, size: 48)),
                    if (e.$3 != null)
                      Positioned(
                        right: 0,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFED4245),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF202225),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${e.$3}",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String asset;
  final double size;
  const _Avatar({required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: ClipOval(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.white.withValues(alpha: 0.1),
            alignment: Alignment.center,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: size * 0.48,
            ),
          ),
        ),
      ),
    );
  }
}
