import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_sidebar.dart';
import '../widgets/common/responsive_layout.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  _PlaygroundSection _activeSection = _PlaygroundSection.liveRooms;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final showSidebar = pageWidth >= 1180;
        final compact = pageWidth < WaibyBreakpoints.mobile;
        final outerPadding = pageWidth >= 1300
            ? 26.0
            : pageWidth >= 900
            ? 20.0
            : 12.0;
        const sidebarWidth = 84.0;
        const sidebarGap = 14.0;
        final contentWidth = math.min(
          1400.0,
          math.max(
            280.0,
            pageWidth -
                (outerPadding * 2) -
                (showSidebar ? sidebarWidth + sidebarGap : 0),
          ),
        );

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
              const Positioned.fill(child: _PlaygroundBackgroundGlow()),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: contentWidth,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            outerPadding,
                            compact ? 20 : 28,
                            outerPadding,
                            compact ? 24 : 30,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Playground',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 30 : 36,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: compact ? 16 : 20),
                              _PlaygroundToolbar(
                                activeSection: _activeSection,
                                onSectionChanged: (section) {
                                  setState(() => _activeSection = section);
                                },
                              ),
                              SizedBox(height: compact ? 18 : 24),
                              _LiveRoomGrid(
                                rooms: _roomsForSection(_activeSection),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showSidebar)
                    Padding(
                      padding: EdgeInsets.only(
                        right: outerPadding,
                        top: 0,
                        bottom: 0,
                      ),
                      child: const _PlaygroundSidebarRail(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaygroundToolbar extends StatelessWidget {
  final _PlaygroundSection activeSection;
  final ValueChanged<_PlaygroundSection> onSectionChanged;

  const _PlaygroundToolbar({
    required this.activeSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final buttonHeight = narrow ? 40.0 : 44.0;
        final sectionButtons = [
          _SectionButtonData(
            label: 'Live Rooms',
            section: _PlaygroundSection.liveRooms,
          ),
          _SectionButtonData(
            label: 'Reward Arena',
            section: _PlaygroundSection.rewardArena,
          ),
          _SectionButtonData(label: 'Shop', section: _PlaygroundSection.shop),
        ];

        final sectionRow = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < sectionButtons.length; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                _SectionButton(
                  label: sectionButtons[index].label,
                  selected: activeSection == sectionButtons[index].section,
                  onTap: () => onSectionChanged(sectionButtons[index].section),
                ),
              ],
            ],
          ),
        );

        if (narrow) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(child: sectionRow),
              const SizedBox(width: 12),
              _CreateRoomButton(height: buttonHeight),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: sectionRow),
            _CreateRoomButton(height: buttonHeight),
          ],
        );
      },
    );
  }
}

class _SectionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SectionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.86);
    final fontWeight = selected ? FontWeight.w600 : FontWeight.w500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF070B1D) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 20,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateRoomButton extends StatelessWidget {
  final double height;

  const _CreateRoomButton({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () => context.go('/playground/create-room'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F88FF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Create Live room'),
      ),
    );
  }
}

class _LiveRoomGrid extends StatelessWidget {
  final List<_LiveRoom> rooms;

  const _LiveRoomGrid({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = _columnsForWidth(constraints.maxWidth);
        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final room in rooms)
              SizedBox(
                width: cardWidth,
                child: _LiveRoomCard(room: room),
              ),
          ],
        );
      },
    );
  }

  int _columnsForWidth(double width) {
    if (width >= 1260) return 4;
    if (width >= 930) return 3;
    if (width >= 620) return 2;
    return 1;
  }
}

class _LiveRoomCard extends StatelessWidget {
  final _LiveRoom room;

  const _LiveRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 300;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: AspectRatio(
                  aspectRatio: 1.92,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        room.coverAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF152041),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.white.withValues(alpha: 0.45),
                            size: 32,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0202),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 7,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${room.title}  ${room.countryCode}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 22 : 28,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                room.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Avatar(asset: room.avatarAsset, size: 42),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.streamer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 58,
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.go('/playground/live-room?role=joiner'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF51D76E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.group_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.viewers}',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.1,
                    ),
                  ),
                  if (room.tags.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        room.tags.join(' '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaygroundSidebarRail extends StatelessWidget {
  const _PlaygroundSidebarRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
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

class _PlaygroundBackgroundGlow extends StatelessWidget {
  const _PlaygroundBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    Widget orb({
      required double size,
      required Color color,
      required double left,
      required double top,
    }) {
      return Positioned(
        left: left,
        top: top,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0)],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        orb(size: 980, color: const Color(0x4D1F3FAA), left: -360, top: -320),
        orb(size: 920, color: const Color(0x3D2F88FF), left: 340, top: -220),
        orb(size: 840, color: const Color(0x262638B9), left: -220, top: 340),
      ],
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
            color: const Color(0xFF1A2443),
            alignment: Alignment.center,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionButtonData {
  final String label;
  final _PlaygroundSection section;

  const _SectionButtonData({required this.label, required this.section});
}

enum _PlaygroundSection { liveRooms, rewardArena, shop }

class _LiveRoom {
  final String title;
  final String countryCode;
  final String subtitle;
  final String streamer;
  final int viewers;
  final List<String> tags;
  final String coverAsset;
  final String avatarAsset;

  const _LiveRoom({
    required this.title,
    required this.countryCode,
    required this.subtitle,
    required this.streamer,
    required this.viewers,
    required this.tags,
    required this.coverAsset,
    required this.avatarAsset,
  });
}

const _roomComeAndSayHi = _LiveRoom(
  title: 'Come and say hi!',
  countryCode: 'US',
  subtitle: 'Pam paaam paam ^-^',
  streamer: 'kandimax',
  viewers: 14,
  tags: <String>['#Gaming', '#Cute'],
  coverAsset: 'assets/login.png',
  avatarAsset: 'assets/pp5.png',
);

const _roomMaTalks = _LiveRoom(
  title: 'MAtalks joinn',
  countryCode: 'ES',
  subtitle: 'Welcome send gifts!',
  streamer: 'CallmeMA',
  viewers: 9,
  tags: <String>['#Chilling', '#Cute'],
  coverAsset: 'assets/login.png',
  avatarAsset: 'assets/pp2.png',
);

const _roomOneSub = _LiveRoom(
  title: '1sub=1win',
  countryCode: 'US',
  subtitle: 'Playing valorant',
  streamer: 'JayLoL',
  viewers: 8,
  tags: <String>['#Gaming', 'Valorant'],
  coverAsset: 'assets/leaderboard_wallpaper.png',
  avatarAsset: 'assets/pp1.png',
);

const _roomNoodles = _LiveRoom(
  title: '1sub=1win',
  countryCode: 'US',
  subtitle: 'Noodles night',
  streamer: 'JayLoL',
  viewers: 1,
  tags: <String>[],
  coverAsset: 'assets/live.png',
  avatarAsset: 'assets/pp1.png',
);

const List<_LiveRoom> _liveRooms = <_LiveRoom>[
  _roomComeAndSayHi,
  _roomMaTalks,
  _roomOneSub,
  _roomNoodles,
  _roomComeAndSayHi,
];

const List<_LiveRoom> _rewardArenaRooms = <_LiveRoom>[
  _roomMaTalks,
  _roomOneSub,
  _roomNoodles,
];

const List<_LiveRoom> _shopRooms = <_LiveRoom>[_roomOneSub, _roomComeAndSayHi];

List<_LiveRoom> _roomsForSection(_PlaygroundSection section) {
  switch (section) {
    case _PlaygroundSection.liveRooms:
      return _liveRooms;
    case _PlaygroundSection.rewardArena:
      return _rewardArenaRooms;
    case _PlaygroundSection.shop:
      return _shopRooms;
  }
}
