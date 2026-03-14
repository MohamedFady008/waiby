import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/models/live_room_models.dart';
import '../services/live_room_service.dart';
import '../widgets/common/responsive_layout.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key});

  static final LiveRoomService _liveRoomService = LiveRoomService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final compact = pageWidth < WaibyBreakpoints.mobile;
        final outerPadding = pageWidth >= 1300
            ? 26.0
            : pageWidth >= 900
            ? 20.0
            : 12.0;
        final contentWidth = math.min(
          1400.0,
          math.max(280.0, pageWidth - (outerPadding * 2)),
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
              Align(
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
                        _PlaygroundHeader(compact: compact),
                        SizedBox(height: compact ? 18 : 24),
                        _LiveRoomsSection(
                          liveRoomService: _liveRoomService,
                          compact: compact,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaygroundHeader extends StatelessWidget {
  final bool compact;

  const _PlaygroundHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 760;
        final title = Column(
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
            const SizedBox(height: 6),
            Text(
              'Real live rooms only. Start one and it appears here automatically.',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                fontSize: compact ? 14 : 15,
                height: 1.35,
              ),
            ),
          ],
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 16),
              const _CreateRoomButton(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 20),
            const _CreateRoomButton(),
          ],
        );
      },
    );
  }
}

class _CreateRoomButton extends StatelessWidget {
  const _CreateRoomButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () => context.go('/playground/create-room'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F88FF),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _LiveRoomsSection extends StatelessWidget {
  final LiveRoomService liveRoomService;
  final bool compact;

  const _LiveRoomsSection({
    required this.liveRoomService,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B1D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18, compact ? 18 : 22, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Rooms',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 24 : 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join rooms that are currently live in Firestore.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.64),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          StreamBuilder<List<LiveRoomRecord>>(
            stream: liveRoomService.watchPublicLiveRooms(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _SectionMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load live rooms.',
                  subtitle: snapshot.error.toString(),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final rooms = snapshot.data ?? const <LiveRoomRecord>[];
              if (rooms.isEmpty) {
                return const _SectionMessage(
                  icon: Icons.wifi_tethering_off_rounded,
                  title: 'No one is live right now.',
                  subtitle: 'Create a room and it will show up here.',
                );
              }

              return _LiveRoomGrid(
                rooms: rooms,
                liveRoomService: liveRoomService,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: const Color(0xFF2F88FF)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.68),
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveRoomGrid extends StatelessWidget {
  final List<LiveRoomRecord> rooms;
  final LiveRoomService liveRoomService;

  const _LiveRoomGrid({required this.rooms, required this.liveRoomService});

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
                child: _LiveRoomCard(
                  room: room,
                  liveRoomService: liveRoomService,
                ),
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
  final LiveRoomRecord room;
  final LiveRoomService liveRoomService;

  const _LiveRoomCard({required this.room, required this.liveRoomService});

  String _tagline() {
    if (room.tagline.isNotEmpty) return room.tagline;
    if (room.language.isNotEmpty) return room.language;
    return 'Join the conversation live.';
  }

  String _footerMeta(int participantCount) {
    final meta = <String>['$participantCount joined'];
    if (room.language.isNotEmpty) meta.add(room.language);
    if (room.tags.isNotEmpty) meta.add(room.tags.take(2).join(' '));
    return meta.join(' | ');
  }

  /// Navigate to the live room passing ALL available room data so that
  /// LiveRoomPage can fully reconstruct room context (gift goal, pinned
  /// message, visibility, etc.) without extra Firestore reads on entry.
  void _joinRoom(BuildContext context) {
    context.go(
      Uri(
        path: '/playground/live-room',
        queryParameters: <String, String>{
          'role': 'joiner',
          'roomId': room.id,
          'roomName': room.roomName,
          if (room.tagline.isNotEmpty) 'tagline': room.tagline,
          if (room.language.isNotEmpty) 'language': room.language,
          if (room.tags.isNotEmpty) 'tags': room.tags.join(' '),
          if (room.atmosphereImageUrl.isNotEmpty)
            'atmosphereImageUrl': room.atmosphereImageUrl,
          if (room.overviewImageUrl.isNotEmpty)
            'overviewImageUrl': room.overviewImageUrl,
          // Visibility
          'visibility': room.visibility.isNotEmpty ? room.visibility : 'public',
          // Pinned message
          if (room.pinnedMessage.isNotEmpty)
            'pinnedMessage': room.pinnedMessage,
          // Gift goal
          if (room.giftGoalEnabled) 'giftGoalEnabled': 'true',
          if (room.giftGoalEnabled && room.giftGoalBuds != null)
            'giftGoalBuds': room.giftGoalBuds!.toStringAsFixed(2),
        },
      ).toString(),
    );
  }

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
      child: StreamBuilder<int>(
        stream: liveRoomService.watchParticipantCount(room.id),
        initialData: 0,
        builder: (context, snapshot) {
          final participantCount = snapshot.data ?? 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: AspectRatio(
                  aspectRatio: 1.92,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B2858), Color(0xFF0B1126)],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (room.overviewImageUrl.isNotEmpty)
                          Image.network(
                            room.overviewImageUrl,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.fallback,
                            errorBuilder: (_, _, _) => _cardFallbackArt(),
                          )
                        else
                          _cardFallbackArt(),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.12),
                                  Colors.black.withValues(alpha: 0.18),
                                  const Color(
                                    0xFF050816,
                                  ).withValues(alpha: 0.9),
                                ],
                                stops: const [0, 0.45, 1],
                              ),
                            ),
                          ),
                        ),
                        // LIVE badge
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
                        // Host name pill
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.26),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              room.hostName.isEmpty ? 'Host' : room.hostName,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        // Room name + tagline overlay
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.roomName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _tagline(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Host row + join button
              Row(
                children: [
                  _HostAvatar(
                    avatarUrl: room.hostAvatarUrl,
                    displayName: room.hostName,
                    size: 42,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.hostName.isEmpty ? 'Host' : room.hostName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          room.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => _joinRoom(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF51D76E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Footer meta
              Row(
                children: [
                  Icon(
                    Icons.group_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _footerMeta(participantCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cardFallbackArt() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B2858), Color(0xFF0B1126)],
            ),
          ),
        ),
        Positioned(
          left: -40,
          bottom: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x5537A3FF), Color(0x0037A3FF)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HostAvatar extends StatelessWidget {
  final String avatarUrl;
  final String displayName;
  final double size;

  const _HostAvatar({
    required this.avatarUrl,
    required this.displayName,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initials = displayName.trim().isEmpty
        ? '?'
        : displayName.trim().substring(0, 1).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: ClipOval(
        child: avatarUrl.isEmpty
            ? Container(
                color: const Color(0xFF1A2443),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: size * 0.38,
                  ),
                ),
              )
            : Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF1A2443),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: size * 0.38,
                    ),
                  ),
                ),
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
