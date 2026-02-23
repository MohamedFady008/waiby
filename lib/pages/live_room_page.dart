import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_sidebar.dart';

class LiveRoomPage extends StatelessWidget {
  final bool isHost;

  const LiveRoomPage({super.key, this.isHost = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final showRail = w >= 1320;
        const railWidth = 84.0;
        const railGap = 12.0;
        final pad = w >= 1500
            ? 20.0
            : w >= 1100
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
                    height: h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(pad, 22, pad, 16),
                      child: _LiveShell(isHost: isHost),
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
  final bool isHost;

  const _LiveShell({required this.isHost});

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
          final desktop = w >= 1200;
          final tightDesktop = desktop && w < 1500;
          final tablet = w >= 980 && !desktop;

          if (desktop) {
            final shellHeight = math.min(805.0, c.maxHeight);
            return SizedBox(
              height: shellHeight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  tightDesktop ? 18 : 30,
                  20,
                  tightDesktop ? 14 : 18,
                  18,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: tightDesktop ? 292 : 312,
                      child: _LeftColumn(compact: tightDesktop),
                    ),
                    SizedBox(width: tightDesktop ? 14 : 24),
                    Expanded(
                      child: _CenterColumn(
                        compact: tightDesktop,
                        narrow: tightDesktop,
                        isHost: isHost,
                      ),
                    ),
                    SizedBox(width: tightDesktop ? 14 : 24),
                    SizedBox(
                      width: tightDesktop ? 420 : 470,
                      child: _RightColumn(
                        compact: tightDesktop,
                        fillHeight: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (tablet) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _CenterColumn(compact: true, isHost: isHost),
                  const SizedBox(height: 16),
                  const Row(
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
              children: [
                _CenterColumn(compact: true, narrow: true, isHost: isHost),
                const SizedBox(height: 14),
                const _LeftColumn(compact: true),
                const SizedBox(height: 14),
                const _RightColumn(compact: true),
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
    final titleSize = compact ? 22.0 : 27.0;
    final subSize = compact ? 14.0 : 18.0;
    final gifterNameSize = compact ? 16.0 : 18.0;
    final gifterCountSize = compact ? 15.0 : 17.0;
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
              _Avatar(
                asset: 'assets/pp2.png',
                size: compact ? 56 : 64,
                frame: 'assets/medals/lolita_pearl.png',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'MAtalks joinn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: titleSize,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _liveBadge(),
                      ],
                    ),
                    Text(
                      'CallmeMA | 9 viewers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        SizedBox(height: compact ? 12 : 18),
        _neonCard(
          width: compact ? 292 : 312,
          child: Column(
            children: [
              _sectionHeader(
                'Top Gifters',
                Icons.emoji_events_rounded,
                compact: compact,
              ),
              for (final g in topGifters)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                  child: Container(
                    height: compact ? 40 : 44,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: gifterNameSize,
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
                            fontSize: gifterCountSize,
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
        SizedBox(height: compact ? 12 : 18),
        _neonCard(
          width: compact ? 292 : 312,
          child: Column(
            children: [
              _sectionHeader('Suggested Gifts', null, compact: compact),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Wrap(
                  spacing: compact ? 6 : 8,
                  runSpacing: compact ? 8 : 10,
                  children: [
                    for (final gift in gifts)
                      SizedBox(
                        width: compact ? 80 : 88,
                        child: Column(
                          children: [
                            SizedBox(
                              width: compact ? 46 : 52,
                              height: compact ? 46 : 52,
                              child: Image.asset(gift.$3, fit: BoxFit.contain),
                            ),
                            Text(
                              gift.$1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: compact ? 12 : 13,
                              ),
                            ),
                            Text(
                              gift.$2,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                                fontSize: compact ? 11 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: compact ? 128 : 136,
                height: compact ? 30 : 28,
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

class _CenterColumn extends StatefulWidget {
  final bool compact;
  final bool narrow;
  final bool isHost;

  const _CenterColumn({
    this.compact = false,
    this.narrow = false,
    this.isHost = false,
  });

  @override
  State<_CenterColumn> createState() => _CenterColumnState();
}

class _CenterColumnState extends State<_CenterColumn> {
  final LayerLink _settingsMenuLink = LayerLink();
  final LayerLink _micSettingsMenuLink = LayerLink();
  final GlobalKey _micSettingsEntryKey = GlobalKey();
  Timer? _micSettingsCloseTimer;
  OverlayEntry? _settingsOverlayEntry;

  bool _showSettingsMenu = false;
  bool _showMicSettingsMenu = false;
  bool _openMicSettingsUpward = false;
  bool _speakerOn = true;
  bool _micOn = true;

  bool _enableUserChat = true;
  bool _entranceSound = false;
  bool _micRequest = false;
  bool _noiseSuppression = false;
  bool _moderation = false;
  bool _giftsAnimation = false;
  String _selectedMicProfile = 'Default';

  static const List<String> _micProfiles = <String>[
    'Default',
    'Studio',
    'Noise reduction',
    'Voice boost',
  ];

  void _setStateAndRefresh(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _settingsOverlayEntry?.markNeedsBuild();
  }

  void _ensureSettingsOverlay() {
    if (_settingsOverlayEntry != null) {
      _settingsOverlayEntry!.markNeedsBuild();
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _settingsOverlayEntry = OverlayEntry(builder: _buildSettingsOverlay);
    overlay.insert(_settingsOverlayEntry!);
  }

  void _removeSettingsOverlay() {
    _settingsOverlayEntry?.remove();
    _settingsOverlayEntry = null;
  }

  bool _shouldOpenMicSettingsUpward() {
    final targetContext = _micSettingsEntryKey.currentContext;
    if (targetContext == null) return false;
    final renderObject = targetContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;

    final media = MediaQuery.of(context);
    const estimatedSubMenuHeight = 280.0;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    final bottomY = topLeft.dy + renderObject.size.height;
    final safeTop = media.padding.top + 8;
    final safeBottom = media.padding.bottom + 8;
    final spaceBelow = media.size.height - safeBottom - bottomY;
    final spaceAbove = topLeft.dy - safeTop;
    return spaceBelow < estimatedSubMenuHeight && spaceAbove > spaceBelow;
  }

  Widget _buildSettingsOverlay(BuildContext context) {
    if (!_showSettingsMenu) return const SizedBox.shrink();
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeSettingsMenu,
          ),
          CompositedTransformFollower(
            link: _settingsMenuLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.bottomLeft,
            offset: Offset(0, widget.compact ? -8 : -12),
            child: widget.isHost
                ? _buildHostSettingsMenu()
                : _buildJoinerSettingsMenu(),
          ),
          if (_showMicSettingsMenu)
            CompositedTransformFollower(
              link: _micSettingsMenuLink,
              showWhenUnlinked: false,
              targetAnchor: _openMicSettingsUpward
                  ? Alignment.bottomRight
                  : Alignment.topRight,
              followerAnchor: _openMicSettingsUpward
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: const Offset(8, 0),
              child: _buildMicSettingsSubMenu(),
            ),
        ],
      ),
    );
  }

  void _toggleSettingsMenu() {
    if (_showSettingsMenu) {
      _micSettingsCloseTimer?.cancel();
      _setStateAndRefresh(() {
        _showSettingsMenu = false;
        _showMicSettingsMenu = false;
      });
      _removeSettingsOverlay();
      return;
    }

    _setStateAndRefresh(() {
      _showSettingsMenu = true;
      _showMicSettingsMenu = false;
    });
    _ensureSettingsOverlay();
  }

  void _closeSettingsMenu() {
    if (!_showSettingsMenu) return;
    _micSettingsCloseTimer?.cancel();
    _setStateAndRefresh(() {
      _showSettingsMenu = false;
      _showMicSettingsMenu = false;
    });
    _removeSettingsOverlay();
  }

  void _openMicSettingsMenu() {
    _micSettingsCloseTimer?.cancel();
    final openUpward = _shouldOpenMicSettingsUpward();
    if (_showMicSettingsMenu && _openMicSettingsUpward == openUpward) return;
    _setStateAndRefresh(() {
      _showMicSettingsMenu = true;
      _openMicSettingsUpward = openUpward;
    });
    _ensureSettingsOverlay();
  }

  void _closeMicSettingsMenu() {
    _micSettingsCloseTimer?.cancel();
    if (!_showMicSettingsMenu) return;
    _setStateAndRefresh(() {
      _showMicSettingsMenu = false;
    });
  }

  void _scheduleCloseMicSettingsMenu() {
    _micSettingsCloseTimer?.cancel();
    _micSettingsCloseTimer = Timer(const Duration(milliseconds: 140), () {
      if (!mounted || !_showMicSettingsMenu) return;
      _setStateAndRefresh(() {
        _showMicSettingsMenu = false;
      });
    });
  }

  Widget _settingRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool premium = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: const Color(0x1E3C7DFF),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: widget.compact ? 28 : 30,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF2F5FF),
                              fontWeight: FontWeight.w500,
                              fontSize: widget.compact ? 12 : 13,
                            ),
                          ),
                        ),
                        if (premium) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFF51D76E),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: widget.compact ? 0.70 : 0.76,
                    child: Switch(
                      value: value,
                      onChanged: onChanged,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeTrackColor: const Color(0xFF58D86F),
                      activeThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF30343C),
                      inactiveThumbColor: const Color(0xFFD2D6DF),
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicSettingsEntry() {
    return CompositedTransformTarget(
      key: _micSettingsEntryKey,
      link: _micSettingsMenuLink,
      child: MouseRegion(
        onEnter: (_) => _openMicSettingsMenu(),
        onExit: (_) => _scheduleCloseMicSettingsMenu(),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            hoverColor: const Color(0x1E3C7DFF),
            onTap: () {
              if (_showMicSettingsMenu) {
                _closeMicSettingsMenu();
              } else {
                _openMicSettingsMenu();
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mic settings',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: widget.compact ? 14 : 15,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Colors.white.withValues(alpha: 0.86),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicSettingsSubMenu() {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => _openMicSettingsMenu(),
        onExit: (_) => _scheduleCloseMicSettingsMenu(),
        child: Container(
          width: widget.compact ? 286 : 320,
          padding: EdgeInsets.fromLTRB(16, widget.compact ? 12 : 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF020826),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room settings',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.compact ? 17 : 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mic settings',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: widget.compact ? 15 : 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: widget.compact ? 50 : 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF171D34),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: PopupMenuButton<String>(
                  tooltip: '',
                  initialValue: _selectedMicProfile,
                  onSelected: (v) =>
                      _setStateAndRefresh(() => _selectedMicProfile = v),
                  color: const Color(0xFF171D34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  itemBuilder: (context) => [
                    for (final p in _micProfiles)
                      PopupMenuItem<String>(
                        value: p,
                        child: Text(
                          p,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedMicProfile,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF2F88FF),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 96,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _closeMicSettingsMenu,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2F88FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 96,
                    height: 44,
                    child: FilledButton(
                      onPressed: _closeMicSettingsMenu,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2F88FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostSettingsMenu() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.compact ? 272 : 300,
        padding: EdgeInsets.fromLTRB(14, widget.compact ? 12 : 13, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF020826),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room settings',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: widget.compact ? 17 : 18,
              ),
            ),
            SizedBox(height: widget.compact ? 6 : 8),
            _settingRow(
              label: 'Enable User Chat',
              value: _enableUserChat,
              onChanged: (v) => _setStateAndRefresh(() => _enableUserChat = v),
            ),
            _settingRow(
              label: 'Entrance Sound',
              value: _entranceSound,
              onChanged: (v) => _setStateAndRefresh(() => _entranceSound = v),
            ),
            _settingRow(
              label: 'Mic Request',
              value: _micRequest,
              onChanged: (v) => _setStateAndRefresh(() => _micRequest = v),
            ),
            _settingRow(
              label: 'Noise Suppression',
              value: _noiseSuppression,
              onChanged: (v) =>
                  _setStateAndRefresh(() => _noiseSuppression = v),
              premium: true,
            ),
            _settingRow(
              label: 'Moderation',
              value: _moderation,
              onChanged: (v) => _setStateAndRefresh(() => _moderation = v),
              premium: true,
            ),
            _settingRow(
              label: 'Gifts animation',
              value: _giftsAnimation,
              onChanged: (v) => _setStateAndRefresh(() => _giftsAnimation = v),
              premium: true,
            ),
            const SizedBox(height: 4),
            _buildMicSettingsEntry(),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinerSettingsMenu() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.compact ? 272 : 300,
        padding: EdgeInsets.fromLTRB(14, widget.compact ? 12 : 13, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF020826),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room settings',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: widget.compact ? 17 : 18,
              ),
            ),
            SizedBox(height: widget.compact ? 8 : 10),
            _settingRow(
              label: 'Noise Suppression',
              value: _noiseSuppression,
              onChanged: (v) =>
                  _setStateAndRefresh(() => _noiseSuppression = v),
              premium: true,
            ),
            _settingRow(
              label: 'Gifts animation',
              value: _giftsAnimation,
              onChanged: (v) => _setStateAndRefresh(() => _giftsAnimation = v),
              premium: true,
            ),
            const SizedBox(height: 4),
            _buildMicSettingsEntry(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _micSettingsCloseTimer?.cancel();
    _removeSettingsOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageW = widget.narrow
        ? double.infinity
        : (widget.compact ? 470.0 : 520.0);
    final hostName = widget.compact ? 32.0 : 36.0;
    final nameSize = widget.compact ? 14.0 : 16.0;
    final roleLabel = widget.isHost ? 'Host' : 'Joiner';
    final roleColor = widget.isHost
        ? const Color(0xFF4880FF)
        : const Color(0xFF51D76E);
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Icon(
              Icons.logout_rounded,
              color: const Color(0xFF942424),
              size: widget.compact ? 24 : 28,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _glowBubble(
          width: widget.compact ? 220 : 234,
          height: widget.compact ? 206 : 209,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Avatar(
                asset: 'assets/pp2.png',
                size: widget.compact ? 96 : 105,
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
                  color: roleColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Text(
                  roleLabel,
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
        SizedBox(height: widget.compact ? 16 : 22),
        _voiceRow(
          stageW,
          const [true, true, false, false],
          const ['Makehna', 'Saori'],
          nameSize,
          compact: widget.compact,
        ),
        SizedBox(height: widget.compact ? 10 : 12),
        _voiceRow(
          stageW,
          const [false, false, false, false],
          const [],
          nameSize,
          compact: widget.compact,
        ),
        SizedBox(height: widget.compact ? 18 : 24),
        _pillControls(
          [
            _ctrl(Icons.redeem_rounded, const Color(0xFFEA7B21), Colors.white),
            _ctrl(
              _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
              _micOn ? const Color(0x1FA84AA6) : const Color(0xFF262222),
              _micOn ? const Color(0xFF2F88FF) : Colors.white,
              border: _micOn ? const Color(0xFFA84AA6) : null,
              size: 26,
              w: 40,
              h: 40,
              onTap: () => _setStateAndRefresh(() => _micOn = !_micOn),
            ),
            _ctrl(
              Icons.call_end_rounded,
              const Color(0xFF691D1D),
              Colors.white,
            ),
          ],
          h: widget.compact ? 40 : 42,
          w: widget.compact ? 210 : 224,
        ),
        SizedBox(height: widget.compact ? 10 : 12),
        _pillControls(
          [
            CompositedTransformTarget(
              link: _settingsMenuLink,
              child: _ctrl(
                Icons.settings_rounded,
                const Color(0xFF262222),
                Colors.white,
                size: 17,
                onTap: _toggleSettingsMenu,
              ),
            ),
            _ctrl(
              _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              const Color(0xFF262222),
              _speakerOn ? Colors.white : const Color(0xFFBFC5D4),
              size: 17,
              onTap: () => _setStateAndRefresh(() => _speakerOn = !_speakerOn),
            ),
            _ctrl(
              Icons.report_rounded,
              const Color(0xFF262222),
              const Color(0xFFFF1010),
              size: 17,
            ),
          ],
          h: widget.compact ? 36 : 40,
          w: widget.compact ? 210 : 224,
        ),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  final bool compact;
  final bool fillHeight;

  const _RightColumn({this.compact = false, this.fillHeight = false});

  @override
  Widget build(BuildContext context) {
    final logHeight = compact ? 430.0 : 607.0;
    return Column(
      children: [
        Container(
          height: compact ? 184 : 198,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF241F4C)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.fromLTRB(10, compact ? 16 : 22, 10, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tab('Chat', compact: compact),
                  SizedBox(width: compact ? 56 : 86),
                  _tab('Viewers', compact: compact),
                ],
              ),
              SizedBox(height: compact ? 12 : 16),
              Container(
                width: double.infinity,
                height: compact ? 98 : 107,
                padding: EdgeInsets.fromLTRB(14, compact ? 8 : 10, 14, 12),
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
                        Icon(
                          Icons.redeem_rounded,
                          color: Color(0xFF51D76E),
                          size: compact ? 22 : 25,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Gift Goal',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 22 : 26,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '45/100 Buds',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w500,
                            fontSize: compact ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: compact ? 10 : 12,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.45,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF51D76E),
                              borderRadius: BorderRadius.circular(50),
                            ),
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
        if (fillHeight)
          Expanded(child: _chatLogPanel(compact: compact))
        else
          SizedBox(
            height: logHeight,
            child: _chatLogPanel(compact: compact),
          ),
      ],
    );
  }
}

Widget _chatLogPanel({required bool compact}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xA81F1635),
      border: Border.all(color: const Color(0xFF241F4C)),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
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
                  height: compact ? 30 : 33,
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
                      fontSize: compact ? 14 : 16,
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
            height: compact ? 40 : 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  'Say hi',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                    fontSize: compact ? 14 : 16,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: compact ? 22 : 25,
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.redeem_rounded,
                  color: const Color(0xD151D76E),
                  size: compact ? 22 : 25,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
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

Widget _sectionHeader(String text, IconData? icon, {bool compact = false}) {
  return Container(
    width: double.infinity,
    height: compact ? 38 : 43,
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
            fontSize: compact ? 22 : 24,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFFEFA315), size: compact ? 20 : 24),
        ],
      ],
    ),
  );
}

Widget _neonCard({required Widget child, double width = 312}) {
  return Container(
    width: width,
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
  double nameSize, {
  bool compact = false,
}) {
  return _glowBubble(
    width: width,
    height: compact ? 102 : 116,
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
                      size: compact ? 44 : 50,
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
                  width: compact ? 44 : 50,
                  height: compact ? 44 : 51,
                  decoration: const BoxDecoration(
                    color: Color(0xFF262222),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mic_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: compact ? 24 : 28,
                  ),
                ),
      ],
    ),
  );
}

Widget _pillControls(
  List<Widget> children, {
  required double h,
  double w = 224,
}) {
  return Container(
    width: w,
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
  VoidCallback? onTap,
}) {
  final control = Container(
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
  if (onTap == null) return control;
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(onTap: onTap, child: control),
  );
}

Widget _tab(String label, {bool compact = false}) {
  return Container(
    width: compact ? 100 : 120,
    height: compact ? 22 : 24,
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
        fontSize: compact ? 14 : 15,
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
        fontSize: 14,
        height: 1.2,
      ),
    ),
  );
}

Widget _rich(String green, String rest) {
  final base = GoogleFonts.poppins(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 14,
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
