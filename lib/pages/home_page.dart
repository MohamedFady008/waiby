import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  final AuthController auth;

  const HomePage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) => _HomeBody(loggedIn: auth.loggedIn),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final bool loggedIn;

  const _HomeBody({required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    const backgroundTop = Color(0xFF0E1631);
    const backgroundBottom = Color(0xFF080C1D);
    const railWidth = 88.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 900 ? 16.0 : 28.0;
        final showRail = loggedIn && constraints.maxWidth >= 1100;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [backgroundTop, backgroundBottom],
            ),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        18,
                        horizontalPadding,
                        120,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _HeroBanner(),
                            const SizedBox(height: 22),
                            _SectionHeader(title: "All Services"),
                            const SizedBox(height: 12),
                            const _ServicesRow(),
                            const SizedBox(height: 14),
                            const _SearchRow(),
                            const SizedBox(height: 26),
                            _SectionHeader(
                              title: "The Best buddies",
                              actionText: "View all",
                            ),
                            const SizedBox(height: 12),
                            const _BuddyRow(),
                            const SizedBox(height: 26),
                            _SectionHeader(
                              title: "Pro Gamers",
                              actionText: "View all",
                            ),
                            const SizedBox(height: 12),
                            const _BuddyRow(variant: _BuddyVariant.pro),
                            const SizedBox(height: 26),
                            _SectionHeader(
                              title: "New Buddies - Discover",
                              actionText: "View all",
                            ),
                            const SizedBox(height: 12),
                            const _BuddyRow(variant: _BuddyVariant.discover),
                            const SizedBox(height: 26),
                            _SectionHeader(
                              title: "High Potential match",
                              actionText: "View all",
                            ),
                            const SizedBox(height: 12),
                            const _BuddyRow(variant: _BuddyVariant.match),
                            const SizedBox(height: 34),
                            const _HowItWorks(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showRail) const _FriendsRail(width: railWidth),
                ],
              ),
              Positioned(
                left: 0,
                right: showRail ? railWidth : 0,
                bottom: 16,
                child: const Center(child: _BottomDock()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    const accentBlue = Color(0xFF2F88FF);

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A64), Color(0xFF0A0F23)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: GoogleFonts.poppins(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PANDIPARXADE",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.6,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "WEEKLY MVP",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 44,
                      height: 1.0,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Find your perfect buddy, anytime",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Gaming • Chat • Lessons • Companions",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [accentBlue, Color(0xFF7B3CFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentBlue.withOpacity(0.35),
                      blurRadius: 26,
                      spreadRadius: -6,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF0B1023),
                  child: Icon(
                    Icons.sports_esports_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: 44,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF51D76E),
                    border: Border.all(
                      color: const Color(0xFF0B1023),
                      width: 3,
                    ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;

  const _SectionHeader({required this.title, this.actionText});

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    return Row(
      children: [
        Expanded(child: Text(title, style: titleStyle)),
        if (actionText != null)
          TextButton(
            onPressed: () {},
            child: Text(
              actionText!,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: const Color(0xFF2F88FF),
              ),
            ),
          ),
      ],
    );
  }
}

class _ServicesRow extends StatelessWidget {
  const _ServicesRow();

  @override
  Widget build(BuildContext context) {
    const services = <_ServiceItem>[
      _ServiceItem(
        "Chat",
        Icons.chat_bubble_outline_rounded,
        Color(0xFF2F88FF),
      ),
      _ServiceItem("Gaming", Icons.sports_esports_rounded, Color(0xFF7B3CFF)),
      _ServiceItem("Lessons", Icons.school_outlined, Color(0xFF51D76E)),
      _ServiceItem("Streaming", Icons.videocam_outlined, Color(0xFFFF5AA5)),
      _ServiceItem("Coaching", Icons.track_changes, Color(0xFFFFB020)),
      _ServiceItem("More", Icons.grid_view_rounded, Color(0xFF5ED0FF)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final service in services) ...[
            _ServiceCard(item: service),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search for games, buddies, services...",
        hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.white.withOpacity(0.7),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2F88FF), width: 1.2),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final String label;
  final IconData icon;
  final Color accent;

  const _ServiceItem(this.label, this.icon, this.accent);
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;

  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: item.accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.accent.withOpacity(0.35)),
            ),
            child: Icon(item.icon, color: item.accent, size: 18),
          ),
          const Spacer(),
          Text(
            item.label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BuddyVariant { best, pro, discover, match }

class _BuddyRow extends StatelessWidget {
  final _BuddyVariant variant;

  const _BuddyRow({this.variant = _BuddyVariant.best});

  List<String> _names() {
    switch (variant) {
      case _BuddyVariant.best:
        return const ["Rosemary", "Imani", "Lynn", "Mervah", "Cerest7"];
      case _BuddyVariant.pro:
        return const ["League", "Apex", "Saori", "Nickiex", "Fortnite"];
      case _BuddyVariant.discover:
        return const ["Drip", "Waiby", "Chizar", "Lilly", "Jenny"];
      case _BuddyVariant.match:
        return const ["nathiNAT", "Lohar", "ENNAK", "Ori", "lawae1"];
    }
  }

  @override
  Widget build(BuildContext context) {
    final names = _names();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final name in names) ...[
            _BuddyCard(name: name),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final String name;

  const _BuddyCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final seed = name.codeUnits.fold<int>(0, (a, b) => a + b);
    final colorA = Color(0xFF2F88FF + (seed % 0x00300000));
    final colorB = Color(0xFF080C1D + (seed % 0x00100000));

    return Container(
      width: 168,
      height: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA.withOpacity(0.38), colorB],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -36,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 14,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.08),
              child: Text(
                name.characters.first.toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F88FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2F88FF).withOpacity(0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 18,
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

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "How it works",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Find a perfect buddy in a few steps.",
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.65),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _HowItWorksStep(
              number: "1",
              title: "Setup your account",
              description: "Sign up and choose your interests.",
            ),
            _HowItWorksStep(
              number: "2",
              title: "Secure Payment",
              description: "Pay safely with your preferred method.",
            ),
            _HowItWorksStep(
              number: "3",
              title: "Order and start!",
              description: "Pick a buddy and enjoy the experience.",
            ),
          ],
        ),
      ],
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: const Color(0xFF0B1023),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
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

class _BottomDock extends StatelessWidget {
  const _BottomDock();

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B1023);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 18,
              spreadRadius: -10,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _DockIcon(icon: FontAwesomeIcons.google, tooltip: "Google"),
            _DockIcon(icon: FontAwesomeIcons.discord, tooltip: "Discord"),
            _DockIcon(icon: FontAwesomeIcons.youtube, tooltip: "YouTube"),
            _DockIcon(icon: FontAwesomeIcons.tiktok, tooltip: "TikTok"),
            _DockIcon(icon: FontAwesomeIcons.instagram, tooltip: "Instagram"),
          ],
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;

  const _DockIcon({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

class _FriendsRail extends StatelessWidget {
  final double width;

  const _FriendsRail({required this.width});

  @override
  Widget build(BuildContext context) {
    const top = Color(0xFF101A36);
    const bottom = Color(0xFF090E21);

    final entries = List.generate(9, (index) => index);

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 18),
          child: Column(
            children: [
              IconButton(
                tooltip: "Messages",
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                color: Colors.white,
                splashRadius: 22,
              ),
              IconButton(
                tooltip: "Contacts",
                onPressed: () {},
                icon: const Icon(Icons.group_outlined),
                color: Colors.white,
                splashRadius: 22,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final hue = (index * 38) % 360;
                    final color = HSLColor.fromAHSL(
                      1,
                      hue.toDouble(),
                      0.65,
                      0.6,
                    ).toColor();
                    final online = index % 2 == 0;

                    return _RailAvatar(
                      color: color,
                      online: online,
                      label: String.fromCharCode(65 + (index % 26)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              IconButton(
                tooltip: "Settings",
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
                color: Colors.white.withOpacity(0.85),
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailAvatar extends StatelessWidget {
  final Color color;
  final bool online;
  final String label;

  const _RailAvatar({
    required this.color,
    required this.online,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundColor: color.withOpacity(0.25),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: online ? const Color(0xFF51D76E) : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0B1023), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
