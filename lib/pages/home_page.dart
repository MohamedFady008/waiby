import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';

double _clampDouble(double value, double min, double max) =>
    value.clamp(min, max).toDouble();

double _scaleByWidth(
  double width, {
  required double min,
  required double max,
  double minWidth = 360,
  double maxWidth = 1440,
}) {
  if (maxWidth <= minWidth) {
    return min;
  }
  final factor = ((width - minWidth) / (maxWidth - minWidth)).clamp(0.0, 1.0);
  return min + ((max - min) * factor);
}

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pagePadding = _scaleByWidth(
          width,
          min: 12,
          max: 26,
          maxWidth: 1300,
        );
        final maxContentWidth = 1770.0;
        final contentWidth = math.min(
          maxContentWidth,
          math.max(320.0, width - (pagePadding * 2)),
        );
        final buddyCardWidth = _clampDouble(
          contentWidth < 560
              ? contentWidth * 0.72
              : contentWidth < 880
              ? contentWidth * 0.46
              : contentWidth < 1200
              ? contentWidth * 0.28
              : contentWidth * 0.19,
          172,
          306,
        );
        final proCardWidth = _clampDouble(
          contentWidth < 600
              ? contentWidth * 0.9
              : contentWidth < 980
              ? contentWidth * 0.72
              : contentWidth < 1320
              ? contentWidth * 0.42
              : contentWidth * 0.29,
          300,
          509,
        );
        final topPadding = width < 700 ? 8.0 : 16.0;
        final heroGap = _scaleByWidth(width, min: 20, max: 26, maxWidth: 1500);
        final headingGap = _scaleByWidth(
          width,
          min: 20,
          max: 28,
          maxWidth: 1500,
        );
        final titleGap = _scaleByWidth(width, min: 10, max: 14, maxWidth: 1500);
        final servicesGap = _scaleByWidth(
          width,
          min: 18,
          max: 24,
          maxWidth: 1500,
        );
        final searchGap = _scaleByWidth(
          width,
          min: 30,
          max: 44,
          maxWidth: 1500,
        );
        final sectionGap = _scaleByWidth(
          width,
          min: 24,
          max: 34,
          maxWidth: 1500,
        );
        final dividerGapTop = _scaleByWidth(
          width,
          min: 28,
          max: 38,
          maxWidth: 1500,
        );
        final dividerGapBottom = _scaleByWidth(
          width,
          min: 18,
          max: 26,
          maxWidth: 1500,
        );
        final bottomGap = _scaleByWidth(
          width,
          min: 16,
          max: 24,
          maxWidth: 1500,
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
              const Positioned.fill(child: _PageBackgroundGlow()),
              SingleChildScrollView(
                padding: EdgeInsets.only(top: topPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: pagePadding),
                      child: Center(
                        child: SizedBox(
                          width: contentWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HeroAdBanner(isLoggedIn: loggedIn),
                              SizedBox(height: heroGap),
                              const _HeadlineBlock(),
                              SizedBox(height: headingGap),
                              const _SimpleSectionTitle(text: 'All Services'),
                              SizedBox(height: titleGap),
                              const _ServicesCarousel(),
                              SizedBox(height: servicesGap),
                              const _SearchStrip(),
                              SizedBox(height: searchGap),
                              _BuddySection(
                                title: 'The Best buddies',
                                items: _bestBuddies,
                                cardWidth: buddyCardWidth,
                              ),
                              SizedBox(height: sectionGap),
                              _ProGamersSection(cardWidth: proCardWidth),
                              SizedBox(height: sectionGap),
                              _BuddySection(
                                title: 'New Budies- Discover',
                                items: _discoverBuddies,
                                cardWidth: buddyCardWidth,
                              ),
                              SizedBox(height: sectionGap),
                              _BuddySection(
                                title: 'High Potential match',
                                items: _matchBuddies,
                                cardWidth: buddyCardWidth,
                              ),
                              SizedBox(height: dividerGapTop),
                              Divider(
                                color: const Color(
                                  0xFF51D76E,
                                ).withValues(alpha: 0.5),
                                thickness: 1,
                                height: 1,
                              ),
                              SizedBox(height: dividerGapBottom),
                              const _HowItWorksSection(),
                              SizedBox(height: bottomGap),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const _FooterStrip(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PageBackgroundGlow extends StatelessWidget {
  const _PageBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    Widget orb({required double size, required Color color}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -220,
            top: -240,
            child: orb(size: 840, color: const Color(0x443F8BFF)),
          ),
          Positioned(
            right: -280,
            top: 320,
            child: orb(size: 940, color: const Color(0x33FD3EED)),
          ),
          Positioned(
            left: -360,
            bottom: -280,
            child: orb(size: 980, color: const Color(0x33FF4A2D)),
          ),
          Positioned(
            right: -320,
            bottom: -220,
            child: orb(size: 1040, color: const Color(0x22FFDB00)),
          ),
        ],
      ),
    );
  }
}

class _HeroAdBanner extends StatelessWidget {
  final bool isLoggedIn;

  const _HeroAdBanner({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showAvatar = width >= 760;
        final bannerHeight = _scaleByWidth(
          width,
          min: 170,
          max: 260,
          minWidth: 320,
          maxWidth: 1200,
        );
        final horizontalPadding = _scaleByWidth(
          width,
          min: 16,
          max: 36,
          minWidth: 320,
          maxWidth: 1200,
        );
        final verticalPadding = _scaleByWidth(
          width,
          min: 12,
          max: 20,
          minWidth: 320,
          maxWidth: 1200,
        );
        final titleFont = _scaleByWidth(
          width,
          min: 18,
          max: 44,
          minWidth: 320,
          maxWidth: 1200,
        );
        final mvpFont = _scaleByWidth(
          width,
          min: 30,
          max: 78,
          minWidth: 320,
          maxWidth: 1200,
        );
        final titleLetterSpacing = _scaleByWidth(
          width,
          min: 0.8,
          max: 2.0,
          minWidth: 320,
          maxWidth: 1200,
        );
        final avatarSize = _scaleByWidth(
          width,
          min: 152,
          max: 208,
          minWidth: 760,
          maxWidth: 1200,
        );
        final avatarBorder = _scaleByWidth(
          width,
          min: 8,
          max: 13,
          minWidth: 760,
          maxWidth: 1200,
        );
        final avatarPadding = _scaleByWidth(
          width,
          min: 5,
          max: 7,
          minWidth: 760,
          maxWidth: 1200,
        );
        final sparkleSize = _scaleByWidth(
          width,
          min: 44,
          max: 62,
          minWidth: 760,
          maxWidth: 1200,
        );

        return Container(
          height: bannerHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/login.png', fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xCC102961),
                        const Color(0x80121E46),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PANDIPARXDE',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w700,
                                fontSize: titleFont,
                                letterSpacing: titleLetterSpacing,
                              ),
                            ),
                            SizedBox(
                              height: _scaleByWidth(
                                width,
                                min: 4,
                                max: 8,
                                minWidth: 320,
                                maxWidth: 1200,
                              ),
                            ),
                            Text(
                              'WEEKLY MVP',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF6AD6),
                                fontWeight: FontWeight.w700,
                                fontSize: mvpFont,
                                height: 0.92,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showAvatar)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: avatarBorder,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2F88FF,
                                    ).withValues(alpha: 0.34),
                                    blurRadius: 38,
                                    spreadRadius: -6,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(avatarPadding),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/pp1.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -8,
                              bottom: 8,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF2F88FF),
                                size: sparkleSize,
                              ),
                            ),
                            if (isLoggedIn)
                              Positioned(
                                left: 8,
                                top: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF51D76E),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'ONLINE',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: _scaleByWidth(
                                        width,
                                        min: 9,
                                        max: 11,
                                        minWidth: 760,
                                        maxWidth: 1200,
                                      ),
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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

class _HeadlineBlock extends StatelessWidget {
  const _HeadlineBlock();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final titleSize = _scaleByWidth(
          width,
          min: 24,
          max: 36,
          maxWidth: 1300,
        );
        final subtitleSize = _scaleByWidth(
          width,
          min: 15,
          max: 20,
          maxWidth: 1300,
        );
        final dividerThickness = _scaleByWidth(
          width,
          min: 2,
          max: 3,
          maxWidth: 1300,
        );

        return Column(
          children: [
            Text(
              'FIND YOUR PERFECT BUDDY. ANYTIME',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
                height: 1.15,
              ),
            ),
            SizedBox(
              height: _scaleByWidth(width, min: 6, max: 8, maxWidth: 1300),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Gaming, chilling, and custom experiences with people ',
                  ),
                  TextSpan(
                    text: 'worldwide',
                    style: GoogleFonts.poppins(color: const Color(0xFF51D76E)),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: subtitleSize,
                height: 1.3,
              ),
            ),
            SizedBox(
              height: _scaleByWidth(width, min: 10, max: 14, maxWidth: 1300),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: math.min(764, width * 0.9)),
              child: Divider(
                color: const Color(0xFF51D76E),
                thickness: dividerThickness,
                height: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SimpleSectionTitle extends StatelessWidget {
  final String text;

  const _SimpleSectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: _scaleByWidth(width, min: 24, max: 32, maxWidth: 1300),
      ),
    );
  }
}

class _ServicesCarousel extends StatelessWidget {
  const _ServicesCarousel();

  static const _services = <_ServiceEntry>[
    _ServiceEntry(asset: 'assets/live.png', fallbackColor: Color(0xFF1F2E65)),
    _ServiceEntry(
      title: 'Echat',
      icon: Icons.forum_rounded,
      solidColor: Color(0xB33A7AF9),
      fallbackColor: Color(0xFF3A7AF9),
      iconTop: 19,
      iconSize: 88,
      labelBottom: 11,
      labelWeight: FontWeight.w600,
    ),
    _ServiceEntry(asset: 'assets/play.png', fallbackColor: Color(0xFF1C2B6A)),
    _ServiceEntry(asset: 'assets/level.png', fallbackColor: Color(0xFF222F64)),
    _ServiceEntry(
      title: 'Watch\nTogether',
      icon: Icons.card_giftcard_rounded,
      solidColor: Color(0xFFEA3F40),
      fallbackColor: Color(0xFFEA3F40),
      iconTop: 21,
      iconSize: 84,
      labelBottom: 8,
    ),
    _ServiceEntry(asset: 'assets/earn.png', fallbackColor: Color(0xFF2B469D)),
    _ServiceEntry(asset: 'assets/bunny1.png', fallbackColor: Color(0xFF75777D)),
    _ServiceEntry(asset: 'assets/bunny2.png', fallbackColor: Color(0xFF324267)),
    _ServiceEntry(
      title: 'Video\nCalls',
      icon: Icons.videocam_rounded,
      solidColor: Color(0xFF453AD3),
      fallbackColor: Color(0xFF453AD3),
      iconTop: 18,
      iconSize: 84,
      labelBottom: 8,
    ),
    _ServiceEntry(asset: 'assets/level.png', fallbackColor: Color(0xFF222F64)),
    _ServiceEntry(asset: 'assets/live.png', fallbackColor: Color(0xFF2A334F)),
    _ServiceEntry(asset: 'assets/play.png', fallbackColor: Color(0xFF2D3E70)),
    _ServiceEntry(asset: 'assets/pp3.png', fallbackColor: Color(0xFF243A6D)),
    _ServiceEntry(asset: 'assets/pp5.png', fallbackColor: Color(0xFF35364D)),
    _ServiceEntry(asset: 'assets/pp6.png', fallbackColor: Color(0xFF35364D)),
    _ServiceEntry(asset: 'assets/pp7.png', fallbackColor: Color(0xFF264275)),
    _ServiceEntry(asset: 'assets/login.png', fallbackColor: Color(0xFF243A72)),
    _ServiceEntry(asset: 'assets/pp1.png', fallbackColor: Color(0xFF394056)),
    _ServiceEntry(asset: 'assets/pp2.png', fallbackColor: Color(0xFF472D24)),
    _ServiceEntry(asset: 'assets/pp4.png', fallbackColor: Color(0xFF334560)),
    _ServiceEntry(
      title: 'Photo\nDrop',
      icon: Icons.camera_alt_rounded,
      solidColor: Color(0xFF7625B9),
      fallbackColor: Color(0xFF7625B9),
      iconTop: 23,
      iconSize: 82,
      labelBottom: 8,
    ),
    _ServiceEntry(asset: 'assets/pp5.png', fallbackColor: Color(0xFF313746)),
    _ServiceEntry(asset: 'assets/pp6.png', fallbackColor: Color(0xFF2D3143)),
    _ServiceEntry(asset: 'assets/pp7.png', fallbackColor: Color(0xFF223154)),
    _ServiceEntry(asset: 'assets/pp3.png', fallbackColor: Color(0xFF273450)),
    _ServiceEntry(
      title: 'Wake-up\nCalls',
      icon: Icons.alarm_rounded,
      solidColor: Color(0xFFF7DD88),
      fallbackColor: Color(0xFFF7DD88),
      iconTop: 18,
      iconSize: 90,
      labelBottom: 8,
    ),
    _ServiceEntry(
      title: 'Tarot',
      icon: Icons.auto_awesome_rounded,
      solidColor: Color(0xFFA103F8),
      fallbackColor: Color(0xFFA103F8),
      iconTop: 28,
      iconSize: 78,
      labelBottom: 12,
    ),
    _ServiceEntry(asset: 'assets/pp1.png', fallbackColor: Color(0xFF2B469D)),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardScale = _scaleByWidth(
          width,
          min: 0.72,
          max: 1,
          minWidth: 320,
          maxWidth: 1100,
        );
        final carouselHeight = _scaleByWidth(
          width,
          min: 150,
          max: 186,
          minWidth: 320,
          maxWidth: 1100,
        );
        final horizontalPadding = _scaleByWidth(
          width,
          min: 10,
          max: 24,
          minWidth: 320,
          maxWidth: 1100,
        );
        final verticalPadding = _scaleByWidth(
          width,
          min: 4,
          max: 8,
          minWidth: 320,
          maxWidth: 1100,
        );
        final cardSpacing = _scaleByWidth(
          width,
          min: 16,
          max: 60,
          minWidth: 320,
          maxWidth: 1400,
        );

        return SizedBox(
          height: carouselHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < _services.length; i++) ...[
                    _ServiceCard(entry: _services[i], scale: cardScale),
                    if (i != _services.length - 1) SizedBox(width: cardSpacing),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchStrip extends StatefulWidget {
  const _SearchStrip();

  @override
  State<_SearchStrip> createState() => _SearchStripState();
}

enum _SearchResultsTab { games, services }

class _SearchStripState extends State<_SearchStrip> {
  static const _collapsedLanguageCodes = <String>{
    'en-US',
    'es-ES',
    'tr-TR',
    'de-DE',
    'pt-PT',
    'ru-RU',
    'fr-FR',
    'ar-SA',
  };

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _panelLayerLink = LayerLink();
  final Object _panelTapRegionGroupId = Object();

  bool _isFilterOpen = false;
  bool _isSearchResultsOpen = false;
  _SearchResultsTab _activeSearchTab = _SearchResultsTab.games;
  bool _onlineOnly = false;
  bool _showAllLanguages = false;
  String? _selectedLanguageCode;
  String? _selectedGender;
  String? _selectedAgeRange;
  OverlayEntry? _panelOverlayEntry;
  double _lastAnchorWidth = 0;

  List<_FilterLanguageEntry> get _visibleLanguages {
    if (_showAllLanguages) {
      return _filterLanguages;
    }
    return _filterLanguages
        .where((entry) => _collapsedLanguageCodes.contains(entry.code))
        .toList();
  }

  bool get _hasActiveFilters =>
      _onlineOnly ||
      _selectedLanguageCode != null ||
      _selectedGender != null ||
      _selectedAgeRange != null;

  String? get _selectedLanguageLabel => _filterLanguages
      .where((entry) => entry.code == _selectedLanguageCode)
      .map((entry) => entry.label)
      .firstOrNull;

  List<_QuickSearchEntry> get _activeSearchEntries =>
      _activeSearchTab == _SearchResultsTab.games
      ? _gameQuickSearchEntries
      : _serviceQuickSearchEntries;

  List<_QuickSearchEntry> get _filteredSearchEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _activeSearchEntries;
    }
    return _activeSearchEntries
        .where((entry) => entry.label.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _removePanelOverlay();
    _searchFocusNode
      ..removeListener(_onSearchFocusChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isSearchResultsOpen = _searchFocusNode.hasFocus;
      if (_searchFocusNode.hasFocus) {
        _isFilterOpen = false;
      }
    });
    _syncPanelOverlay();
  }

  void _toggleOpen() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
      if (_isFilterOpen) {
        _searchFocusNode.unfocus();
        _isSearchResultsOpen = false;
      }
    });
    _syncPanelOverlay();
  }

  void _collapsePanels() {
    final hasOpenUi =
        _isFilterOpen || _isSearchResultsOpen || _searchFocusNode.hasFocus;
    if (!hasOpenUi) {
      return;
    }

    _searchFocusNode.unfocus();
    setState(() {
      _isFilterOpen = false;
      _isSearchResultsOpen = false;
    });
    _syncPanelOverlay();
  }

  void _setSearchTab(_SearchResultsTab tab) {
    setState(() {
      _activeSearchTab = tab;
      _isSearchResultsOpen = true;
      _isFilterOpen = false;
    });
    _syncPanelOverlay();
  }

  void _selectSearchEntry(_QuickSearchEntry entry) {
    setState(() {
      _searchController.value = TextEditingValue(
        text: entry.label,
        selection: TextSelection.collapsed(offset: entry.label.length),
      );
      _isSearchResultsOpen = false;
    });
    _searchFocusNode.unfocus();
    _syncPanelOverlay();
  }

  void _toggleShowAllLanguages() {
    setState(() {
      _showAllLanguages = !_showAllLanguages;
    });
    _syncPanelOverlay();
  }

  void _setLanguage(String code) {
    setState(() {
      _selectedLanguageCode = _selectedLanguageCode == code ? null : code;
    });
    _syncPanelOverlay();
  }

  void _setGender(String value) {
    setState(() {
      _selectedGender = _selectedGender == value ? null : value;
    });
    _syncPanelOverlay();
  }

  void _setAgeRange(String value) {
    setState(() {
      _selectedAgeRange = _selectedAgeRange == value ? null : value;
    });
    _syncPanelOverlay();
  }

  void _removePanelOverlay() {
    _panelOverlayEntry?.remove();
    _panelOverlayEntry = null;
  }

  void _syncPanelOverlay() {
    if (!mounted) {
      return;
    }

    final shouldShow = _isFilterOpen || _isSearchResultsOpen;
    if (!shouldShow) {
      _removePanelOverlay();
      return;
    }

    if (_panelOverlayEntry == null) {
      _panelOverlayEntry = OverlayEntry(
        builder: (context) {
          final width = _lastAnchorWidth > 0
              ? _lastAnchorWidth
              : MediaQuery.sizeOf(context).width;
          final stripHeight = _scaleByWidth(
            width,
            min: 58,
            max: 71,
            minWidth: 320,
            maxWidth: 1000,
          );

          return Positioned.fill(
            child: CompositedTransformFollower(
              link: _panelLayerLink,
              showWhenUnlinked: false,
              offset: Offset(0, stripHeight + 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: TapRegion(
                  groupId: _panelTapRegionGroupId,
                  child: Material(
                    color: Colors.transparent,
                    child: _isFilterOpen
                        ? _buildFiltersPanel(width)
                        : _buildSearchResultsPanel(width),
                  ),
                ),
              ),
            ),
          );
        },
      );

      Overlay.of(context, rootOverlay: true).insert(_panelOverlayEntry!);
      return;
    }

    _panelOverlayEntry?.markNeedsBuild();
  }

  Widget _buildFilterOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required double fontSize,
    double indicatorSize = 19,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF283267),
                    width: 1.6,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: indicatorSize * 0.45,
                        height: indicatorSize * 0.45,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF51D76E),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineToggle({
    required bool value,
    required VoidCallback onTap,
  }) {
    const trackWidth = 33.0;
    const trackHeight = 13.0;
    const thumbSize = 9.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            width: trackWidth,
            height: trackHeight,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF1A7B3C) : const Color(0xFF303030),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFECECEC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(-1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionWrap({
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelect,
    required double availableWidth,
    required double textSize,
    int columns = 3,
  }) {
    final effectiveColumns = math.max(1, columns);
    const spacing = 16.0;
    const runSpacing = 10.0;
    final itemWidth = math.max(
      110.0,
      (availableWidth - ((effectiveColumns - 1) * spacing)) / effectiveColumns,
    );

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final option in options)
          SizedBox(
            width: itemWidth,
            child: _buildFilterOption(
              label: option,
              selected: selectedValue == option,
              onTap: () => onSelect(option),
              fontSize: textSize,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchTab({
    required String label,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
    required double titleSize,
    required double countSize,
    required double indicatorWidth,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: titleSize,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: GoogleFonts.notoSans(
                      color: Colors.white.withValues(alpha: 0.64),
                      fontWeight: FontWeight.w500,
                      fontSize: countSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                height: 2,
                width: indicatorWidth,
                color: isActive ? const Color(0xFF51D76E) : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSearchRow({
    required _QuickSearchEntry entry,
    required double iconSize,
    required double labelSize,
    required double badgeSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectSearchEntry(entry),
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 36,
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: entry.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.badge,
                  style: GoogleFonts.notoSans(
                    color: entry.badgeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: badgeSize,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: labelSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(double width) {
    final filtersPanelWidth = math.min(621.0, width);
    final languageColumns = filtersPanelWidth >= 580
        ? 4
        : filtersPanelWidth >= 420
        ? 3
        : 2;
    final languageRows = (_visibleLanguages.length / languageColumns).ceil();
    final panelHeight = _showAllLanguages
        ? _clampDouble(278 + (languageRows * 38), 420, 760)
        : 351.0;
    final panelTitleSize = _scaleByWidth(
      width,
      min: 15,
      max: 16,
      minWidth: 320,
      maxWidth: 1000,
    );
    final panelTextSize = _scaleByWidth(
      width,
      min: 12,
      max: 14,
      minWidth: 320,
      maxWidth: 1000,
    );
    final sectionTitleSize = _scaleByWidth(
      width,
      min: 14,
      max: 16,
      minWidth: 320,
      maxWidth: 1000,
    );
    final showMoreSize = _scaleByWidth(
      width,
      min: 10,
      max: 12,
      minWidth: 320,
      maxWidth: 1000,
    );

    return Container(
      width: filtersPanelWidth,
      height: panelHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose filters',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: panelTitleSize,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'View only online buddies',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: panelTextSize,
                    ),
                  ),
                ),
                _buildOnlineToggle(
                  value: _onlineOnly,
                  onTap: () {
                    setState(() => _onlineOnly = !_onlineOnly);
                    _syncPanelOverlay();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Language',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: sectionTitleSize,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionWrap(
              options: _visibleLanguages.map((e) => e.label).toList(),
              selectedValue: _selectedLanguageLabel,
              onSelect: (value) {
                final code = _filterLanguages
                    .where((entry) => entry.label == value)
                    .map((entry) => entry.code)
                    .firstOrNull;
                if (code != null) {
                  _setLanguage(code);
                }
              },
              availableWidth: filtersPanelWidth - 40,
              textSize: panelTextSize,
              columns: languageColumns,
            ),
            const SizedBox(height: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleShowAllLanguages,
                borderRadius: BorderRadius.circular(3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _showAllLanguages ? 'Show less' : 'Show more',
                    style: GoogleFonts.notoSans(
                      color: const Color(0xFF51D76E),
                      fontWeight: FontWeight.w500,
                      fontSize: showMoreSize,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gender',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: sectionTitleSize,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionWrap(
              options: const ['Female', 'Male', 'Non-binary'],
              selectedValue: _selectedGender,
              onSelect: _setGender,
              availableWidth: filtersPanelWidth - 40,
              textSize: panelTextSize,
              columns: filtersPanelWidth >= 580 ? 3 : 2,
            ),
            const SizedBox(height: 10),
            Text(
              'Age',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: sectionTitleSize,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionWrap(
              options: const ['18-25', '25-30', '30+'],
              selectedValue: _selectedAgeRange,
              onSelect: _setAgeRange,
              availableWidth: filtersPanelWidth - 40,
              textSize: panelTextSize,
              columns: filtersPanelWidth >= 580 ? 3 : 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsPanel(double width) {
    final searchPanelWidth = math.min(445.0, width);
    final searchPanelHeight = _scaleByWidth(
      width,
      min: 290,
      max: 351,
      minWidth: 320,
      maxWidth: 1100,
    );
    final searchTabTitleSize = _scaleByWidth(
      width,
      min: 15,
      max: 16,
      minWidth: 320,
      maxWidth: 1100,
    );
    final searchTabCountSize = _scaleByWidth(
      width,
      min: 12,
      max: 13,
      minWidth: 320,
      maxWidth: 1100,
    );
    final searchLabelSize = _scaleByWidth(
      width,
      min: 12,
      max: 13,
      minWidth: 320,
      maxWidth: 1100,
    );
    final searchIconSizeInPanel = _scaleByWidth(
      width,
      min: 28,
      max: 30,
      minWidth: 320,
      maxWidth: 1100,
    );
    final searchBadgeSize = _scaleByWidth(
      width,
      min: 11,
      max: 13,
      minWidth: 320,
      maxWidth: 1100,
    );

    return Container(
      width: searchPanelWidth,
      height: searchPanelHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 12, right: 20),
            child: Row(
              children: [
                _buildSearchTab(
                  label: 'Games',
                  count: 20,
                  isActive: _activeSearchTab == _SearchResultsTab.games,
                  onTap: () => _setSearchTab(_SearchResultsTab.games),
                  titleSize: searchTabTitleSize,
                  countSize: searchTabCountSize,
                  indicatorWidth: 56,
                ),
                const SizedBox(width: 24),
                _buildSearchTab(
                  label: 'Services',
                  count: 10,
                  isActive: _activeSearchTab == _SearchResultsTab.services,
                  onTap: () => _setSearchTab(_SearchResultsTab.services),
                  titleSize: searchTabTitleSize,
                  countSize: searchTabCountSize,
                  indicatorWidth: 64,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 0, 12, 12),
              itemCount: _filteredSearchEntries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final entry = _filteredSearchEntries[index];
                return _buildQuickSearchRow(
                  entry: entry,
                  iconSize: searchIconSizeInPanel,
                  labelSize: searchLabelSize,
                  badgeSize: searchBadgeSize,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final stripHeight = _scaleByWidth(
          width,
          min: 58,
          max: 71,
          minWidth: 320,
          maxWidth: 1000,
        );
        final outerRadius = _scaleByWidth(
          width,
          min: 12,
          max: 15,
          minWidth: 320,
          maxWidth: 1000,
        );
        final horizontalInset = _scaleByWidth(
          width,
          min: 10,
          max: 14,
          minWidth: 320,
          maxWidth: 1000,
        );
        final verticalInset = _scaleByWidth(
          width,
          min: 8,
          max: 10,
          minWidth: 320,
          maxWidth: 1000,
        );
        final leadingGap = _scaleByWidth(
          width,
          min: 8,
          max: 12,
          minWidth: 320,
          maxWidth: 1000,
        );
        final searchIconSize = _scaleByWidth(
          width,
          min: 24,
          max: 32,
          minWidth: 320,
          maxWidth: 1000,
        );
        final textSize = _scaleByWidth(
          width,
          min: 14,
          max: 20,
          minWidth: 320,
          maxWidth: 1000,
        );
        final filterIconSize = _scaleByWidth(
          width,
          min: 20,
          max: 24,
          minWidth: 320,
          maxWidth: 1000,
        );

        if ((_lastAnchorWidth - width).abs() > 0.1) {
          _lastAnchorWidth = width;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _syncPanelOverlay(),
          );
        }

        return TapRegion(
          groupId: _panelTapRegionGroupId,
          onTapOutside: (event) => _collapsePanels(),
          child: CompositedTransformTarget(
            link: _panelLayerLink,
            child: Container(
              height: stripHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(outerRadius),
                border: Border.all(
                  color: (_isFilterOpen || _isSearchResultsOpen)
                      ? const Color(0xFF51D76E).withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.17),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalInset,
                vertical: verticalInset,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF878A92).withValues(alpha: 0.23),
                  borderRadius: BorderRadius.circular(outerRadius),
                ),
                child: Row(
                  children: [
                    SizedBox(width: leadingGap),
                    Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: searchIconSize,
                    ),
                    SizedBox(width: leadingGap),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: (_) {
                          setState(() {});
                          _syncPanelOverlay();
                        },
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: textSize,
                        ),
                        cursorColor: const Color(0xFF51D76E),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: _hasActiveFilters
                              ? 'Filters selected${_selectedLanguageLabel == null ? '' : ': $_selectedLanguageLabel'}'
                              : 'Search for games, services or Buddies...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.28),
                            fontWeight: FontWeight.w400,
                            fontSize: textSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: _scaleByWidth(
                        width,
                        min: 6,
                        max: 8,
                        minWidth: 320,
                        maxWidth: 1000,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleOpen,
                        borderRadius: BorderRadius.circular(22),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Icon(
                            _isFilterOpen
                                ? Icons.expand_less_rounded
                                : Icons.tune_rounded,
                            color: Colors.white,
                            size: filterIconSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: leadingGap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BuddySection extends StatelessWidget {
  final String title;
  final List<_BuddyEntry> items;
  final double cardWidth;

  const _BuddySection({
    required this.title,
    required this.items,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final titleGap = _scaleByWidth(width, min: 10, max: 14, maxWidth: 1300);
        final cardGap = _scaleByWidth(width, min: 12, max: 22, maxWidth: 1300);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeaderRow(title: title),
            SizedBox(height: titleGap),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _BuddyCard(entry: items[i], cardWidth: cardWidth),
                    if (i != items.length - 1) SizedBox(width: cardGap),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProGamersSection extends StatelessWidget {
  final double cardWidth;

  const _ProGamersSection({required this.cardWidth});

  static const _pros = <_ProEntry>[
    _ProEntry(
      name: 'Meilin',
      game: 'LEAGUE OF LEGENDS',
      rank: 'Grandmaster',
      asset: 'assets/pp2.png',
    ),
    _ProEntry(
      name: 'Saori',
      game: 'APEX LEGENDS',
      rank: 'Apex Predator',
      asset: 'assets/pp3.png',
    ),
    _ProEntry(
      name: 'Nikkiex',
      game: 'FORTNITE',
      rank: 'Unreal',
      asset: 'assets/pp5.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final titleGap = _scaleByWidth(width, min: 10, max: 14, maxWidth: 1300);
        final cardGap = _scaleByWidth(width, min: 14, max: 24, maxWidth: 1300);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeaderRow(title: 'Pro Gamers'),
            SizedBox(height: titleGap),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < _pros.length; i++) ...[
                    _ProCard(entry: _pros[i], cardWidth: cardWidth),
                    if (i != _pros.length - 1) SizedBox(width: cardGap),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const _steps = <_HowStepEntry>[
    _HowStepEntry(
      number: '1',
      title: 'Setup your account.',
      description:
          'Sign in with Discord or email, then select the game or service and customize your order',
    ),
    _HowStepEntry(
      number: '2',
      title: 'Secure Payment',
      description:
          'Top up Buds, on your profile wallet. we accept all major credit cards, PayPal, Apple Pay, Revolut, Crypto, and more!',
    ),
    _HowStepEntry(
      number: '3',
      title: 'Order and start!',
      description:
          'Sit back, relax and enjoy - We appreciate your feedback, so do not forget to share your experience with us.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 980;
        final sectionHeight = compact ? (width < 420 ? 760.0 : 820.0) : 956.0;
        final contentWidth = compact
            ? math.max(300.0, width - 20)
            : math.min(1518.0, width - 20);
        final headingSize = _scaleByWidth(
          width,
          min: 26,
          max: 32,
          minWidth: 320,
          maxWidth: 1300,
        );
        final subtitleSize = _scaleByWidth(
          width,
          min: 15,
          max: 20,
          minWidth: 320,
          maxWidth: 1300,
        );
        final topPadding = _scaleByWidth(
          width,
          min: 18,
          max: 24,
          minWidth: 320,
          maxWidth: 1300,
        );
        final leftPadding = compact
            ? _scaleByWidth(
                width,
                min: 4,
                max: 10,
                minWidth: 320,
                maxWidth: 800,
              )
            : 20.0;
        final stepsTopGap = _scaleByWidth(
          width,
          min: 30,
          max: 54,
          minWidth: 320,
          maxWidth: 1300,
        );

        return SizedBox(
          height: sectionHeight,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0x1A020305)),
                ),
              ),
              Positioned(
                left: width * -0.018,
                top: -sectionHeight * 0.64,
                child: _BlurEllipse(
                  width: width * 0.82,
                  height: sectionHeight * 0.32,
                  colors: const [Color(0x33020303), Color(0x338FFDBB)],
                  blurSigma: 100,
                  rotation: 0.7,
                  opacity: 0.2,
                ),
              ),
              Positioned(
                left: -width * 0.22,
                top: sectionHeight * 0.30,
                child: _BlurEllipse(
                  width: width * 0.66,
                  height: sectionHeight * 0.50,
                  colors: const [Color(0x66000000), Color(0x66FF0000)],
                  blurSigma: 100,
                  rotation: 0.55,
                ),
              ),
              Positioned(
                left: -width * 0.06,
                top: sectionHeight * 0.45,
                child: _BlurEllipse(
                  width: width * 0.86,
                  height: sectionHeight * 0.26,
                  colors: const [Color(0x66FA474A), Color(0x66FFFFFF)],
                  blurSigma: 40,
                  rotation: -0.24,
                ),
              ),
              Positioned(
                left: -width * 0.29,
                top: sectionHeight * 0.61,
                child: _BlurEllipse(
                  width: width * 0.62,
                  height: sectionHeight * 0.24,
                  colors: const [Color(0x66FE492D), Color(0x66F89A67)],
                  blurSigma: 100,
                  rotation: 0.35,
                ),
              ),
              Positioned(
                left: width * 0.29,
                top: sectionHeight * 0.38,
                child: _BlurEllipse(
                  width: width * 0.86,
                  height: sectionHeight * 0.42,
                  colors: const [Color(0x00F8F8F8), Color(0x66F91E94)],
                  blurSigma: 60,
                  rotation: -0.22,
                ),
              ),
              Positioned(
                left: width * 0.24,
                top: sectionHeight * 0.51,
                child: _BlurEllipse(
                  width: width * 0.72,
                  height: sectionHeight * 0.45,
                  colors: const [Color(0x66F50F1A), Color(0x66FB3CEE)],
                  blurSigma: 60,
                  rotation: -0.2,
                ),
              ),
              Positioned(
                left: width * 0.14,
                top: sectionHeight * 0.63,
                child: _BlurEllipse(
                  width: width * 0.71,
                  height: sectionHeight * 0.48,
                  colors: const [Color(0x80F50F1A), Color(0x80FB3CEE)],
                  blurSigma: 150,
                  rotation: -0.2,
                  opacity: 0.7,
                ),
              ),
              Positioned(
                left: width * 0.36,
                top: sectionHeight * 0.67,
                child: _BlurEllipse(
                  width: width * 0.72,
                  height: sectionHeight * 0.27,
                  colors: const [Color(0x00F8F8F8), Color(0x88FFDB00)],
                  blurSigma: 10,
                  rotation: 0.1,
                  extraGlow: true,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.4,
                    child: Image.asset(
                      'assets/noise.png',
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 8 : 0,
                      topPadding,
                      compact ? 8 : 0,
                      0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'How It works',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: headingSize,
                          ),
                        ),
                        SizedBox(
                          height: _scaleByWidth(
                            width,
                            min: 6,
                            max: 8,
                            minWidth: 320,
                            maxWidth: 1300,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: compact ? 560 : 637,
                          ),
                          child: Text(
                            'Finding the perfect buddy has never been this easy.\nJust choose a service, connect, and enjoy',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: subtitleSize,
                              height: 1.35,
                            ),
                          ),
                        ),
                        SizedBox(height: stepsTopGap),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: leftPadding),
                            child: Column(
                              children: [
                                for (int i = 0; i < _steps.length; i++)
                                  _HowStepRow(
                                    entry: _steps[i],
                                    showLine: i != _steps.length - 1,
                                    compact: compact,
                                  ),
                              ],
                            ),
                          ),
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

class _FooterStrip extends StatelessWidget {
  const _FooterStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final iconSpacing = _scaleByWidth(
          width,
          min: 24,
          max: 100,
          maxWidth: 1400,
        );
        final verticalPadding = _scaleByWidth(
          width,
          min: 14,
          max: 20,
          maxWidth: 1400,
        );

        return Container(
          decoration: const BoxDecoration(color: Color(0xFF070B1D)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Wrap(
                  spacing: iconSpacing,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    _FooterIcon(
                      icon: FontAwesomeIcons.google,
                      background: Colors.white,
                    ),
                    _FooterIcon(
                      icon: FontAwesomeIcons.discord,
                      background: Color(0xFF5865F2),
                    ),
                    _FooterIcon(
                      icon: FontAwesomeIcons.youtube,
                      background: Colors.white,
                    ),
                    _FooterIcon(
                      icon: FontAwesomeIcons.xTwitter,
                      background: Color(0xFF111111),
                    ),
                    _FooterIcon(
                      icon: FontAwesomeIcons.instagram,
                      background: Color(0xFFE1306C),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  final String title;

  const _SectionHeaderRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 620;
        final titleSize = _scaleByWidth(
          width,
          min: 24,
          max: 32,
          minWidth: 320,
          maxWidth: 1200,
        );
        final buttonHeight = _scaleByWidth(
          width,
          min: 33,
          max: 40,
          minWidth: 320,
          maxWidth: 1200,
        );
        final buttonTextSize = _scaleByWidth(
          width,
          min: 13,
          max: 16,
          minWidth: 320,
          maxWidth: 1200,
        );
        final buttonHorizontalPadding = _scaleByWidth(
          width,
          min: 12,
          max: 18,
          minWidth: 320,
          maxWidth: 1200,
        );

        final viewMoreButton = SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F88FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: buttonHorizontalPadding,
              ),
            ),
            child: Text(
              'View More',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: buttonTextSize,
              ),
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize,
                ),
              ),
              const SizedBox(height: 12),
              viewMoreButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize,
                ),
              ),
            ),
            const SizedBox(width: 12),
            viewMoreButton,
          ],
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceEntry entry;
  final double scale;

  const _ServiceCard({required this.entry, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    final hasTitle = entry.title.trim().isNotEmpty;
    final titleParts = hasTitle ? entry.title.split('\n') : const <String>[];
    final cardWidth = 159 * scale;
    final cardHeight = 169 * scale;
    final radius = _clampDouble(5 * scale, 4, 7);
    final labelFontSize = _clampDouble(20 * scale, 14, 20);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: entry.solidColor ?? entry.fallbackColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (entry.asset != null)
              Image.asset(
                entry.asset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(color: entry.fallbackColor),
              ),
            if (entry.asset != null && hasTitle)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.58),
                    ],
                  ),
                ),
              ),
            if (entry.icon != null)
              Positioned(
                top: entry.iconTop * scale,
                left: 0,
                right: 0,
                child: Icon(
                  entry.icon,
                  color: Colors.white,
                  size: entry.iconSize * scale,
                ),
              ),
            if (hasTitle)
              Positioned(
                left: 0,
                right: 0,
                bottom: entry.labelBottom * scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final part in titleParts)
                      Text(
                        part,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: entry.labelWeight,
                          fontSize: labelFontSize,
                          height: 1.0,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BuddyCard extends StatelessWidget {
  final _BuddyEntry entry;
  final double cardWidth;

  const _BuddyCard({required this.entry, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final overlayHeight = _clampDouble(cardWidth * 0.24, 52, 70);
    final cardHeight = cardWidth * 0.94;
    final radius = _clampDouble(cardWidth * 0.04, 8, 12);
    final overlayHorizontalPadding = _clampDouble(cardWidth * 0.045, 10, 14);
    final overlayVerticalPadding = _clampDouble(overlayHeight * 0.12, 6, 8);
    final nameFontSize = _clampDouble(cardWidth * 0.082, 15, 20);
    final ratingFontSize = _clampDouble(cardWidth * 0.065, 12, 16);
    final actionSize = _clampDouble(overlayHeight * 0.52, 28, 36);
    final actionIconSize = _clampDouble(actionSize * 0.58, 16, 20);
    final heartSize = _clampDouble(ratingFontSize * 0.75, 10, 12);

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              entry.asset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: const Color(0xFF141D38),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white.withValues(alpha: 0.72),
                  size: 48,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: overlayHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF2F88FF),
                      Color(0xFF1A4C9D),
                      Color(0xFF1B234B),
                    ],
                    stops: [0, 0.37, 0.97],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  overlayHorizontalPadding,
                  overlayVerticalPadding,
                  overlayHorizontalPadding * 0.7,
                  overlayVerticalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: nameFontSize,
                              height: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                entry.rating,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: ratingFontSize,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(
                                width: _clampDouble(overlayHeight * 0.06, 3, 4),
                              ),
                              Icon(
                                Icons.favorite,
                                color: Color(0xFF51D76E),
                                size: heartSize,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: _clampDouble(overlayHeight * 0.12, 6, 8)),
                    Container(
                      width: actionSize,
                      height: actionSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2F88FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: actionIconSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  final _ProEntry entry;
  final double cardWidth;

  const _ProCard({required this.entry, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final totalHeight = _clampDouble(cardWidth * 0.62, 240, 320);
    final frameHeight = totalHeight - 41;
    final playButtonSize = _clampDouble(cardWidth * 0.12, 46, 56);
    final playIconSize = _clampDouble(playButtonSize * 0.6, 26, 34);
    final gameFontSize = _clampDouble(cardWidth * 0.052, 18, 26);
    final nameFontSize = _clampDouble(cardWidth * 0.088, 30, 44);
    final rankFontSize = _clampDouble(cardWidth * 0.03, 12, 15);
    final sidePadding = _clampDouble(cardWidth * 0.034, 12, 16);
    final topPadding = _clampDouble(cardWidth * 0.04, 14, 18);
    final bottomPadding = _clampDouble(cardWidth * 0.035, 12, 16);
    final rankHorizontalPadding = _clampDouble(cardWidth * 0.028, 10, 14);
    final rankVerticalPadding = _clampDouble(cardWidth * 0.006, 2, 4);

    return SizedBox(
      width: cardWidth,
      height: totalHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: frameHeight,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF51D76E), width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 54,
                    child: Image.asset(
                      entry.asset,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Color(0xFF131A38)),
                    ),
                  ),
                  Expanded(
                    flex: 46,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        topPadding,
                        sidePadding,
                        bottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.game,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: gameFontSize,
                              height: 1.02,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            entry.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: nameFontSize,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(
                            height: _clampDouble(cardWidth * 0.016, 4, 8),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: rankHorizontalPadding,
                              vertical: rankVerticalPadding,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x4D261A53),
                              border: Border.all(
                                color: const Color(0xFF5FE635),
                              ),
                            ),
                            child: Text(
                              entry.rank,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF48BE4C),
                                fontWeight: FontWeight.w400,
                                fontSize: rankFontSize,
                                height: 1.2,
                              ),
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
          Container(
            width: playButtonSize,
            height: playButtonSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF51D76E),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: playIconSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowStepRow extends StatelessWidget {
  final _HowStepEntry entry;
  final bool showLine;
  final bool compact;

  const _HowStepRow({
    required this.entry,
    required this.showLine,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final tinyCompact = compact && screenWidth < 420;
    final markerSize = compact ? (tinyCompact ? 70.0 : 84.0) : 118.0;
    final lineHeight = compact ? (tinyCompact ? 40.0 : 56.0) : 98.0;
    final railWidth = compact ? (tinyCompact ? 82.0 : 104.0) : 176.0;
    final rowHeight = markerSize + (showLine ? lineHeight : 0);

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: railWidth,
            child: Column(
              children: [
                Container(
                  width: markerSize,
                  height: markerSize,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Text(
                    entry.number,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? (tinyCompact ? 36 : 46) : 52,
                      height: 1.0,
                    ),
                  ),
                ),
                if (showLine)
                  Container(width: 1, height: lineHeight, color: Colors.white),
              ],
            ),
          ),
          SizedBox(width: compact ? (tinyCompact ? 12 : 18) : 26),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: compact ? (tinyCompact ? 2 : 6) : 10,
                right: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? (tinyCompact ? 18 : 22) : 24,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 6),
                  Text(
                    entry.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: compact ? (tinyCompact ? 14 : 16) : 20,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurEllipse extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final double blurSigma;
  final double rotation;
  final double opacity;
  final bool extraGlow;

  const _BlurEllipse({
    required this.width,
    required this.height,
    required this.colors,
    required this.blurSigma,
    required this.rotation,
    this.opacity = 1,
    this.extraGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: rotation,
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width),
              gradient: LinearGradient(colors: colors),
              boxShadow: extraGlow
                  ? [
                      BoxShadow(
                        color: colors.last.withValues(alpha: 0.24),
                        blurRadius: 80,
                        spreadRadius: 12,
                        offset: const Offset(12, 12),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterIcon extends StatelessWidget {
  final IconData icon;
  final Color background;

  const _FooterIcon({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final boxSize = _scaleByWidth(width, min: 40, max: 44, maxWidth: 1000);
    final borderRadius = _scaleByWidth(width, min: 8, max: 9, maxWidth: 1000);
    final iconSize = _scaleByWidth(width, min: 18, max: 22, maxWidth: 1000);
    final iconColor = background == Colors.white
        ? const Color(0xFF151515)
        : Colors.white;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: FaIcon(icon, color: iconColor, size: iconSize),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}

class _FilterLanguageEntry {
  final String code;
  final String label;

  const _FilterLanguageEntry({required this.code, required this.label});
}

class _QuickSearchEntry {
  final String label;
  final String badge;
  final Color color;
  final Color badgeColor;

  const _QuickSearchEntry({
    required this.label,
    required this.badge,
    required this.color,
    this.badgeColor = Colors.black,
  });
}

class _ServiceEntry {
  final String title;
  final String? asset;
  final IconData? icon;
  final Color fallbackColor;
  final Color? solidColor;
  final double iconTop;
  final double iconSize;
  final double labelBottom;
  final FontWeight labelWeight;

  const _ServiceEntry({
    this.title = '',
    this.asset,
    this.icon,
    required this.fallbackColor,
    this.solidColor,
    this.iconTop = 24,
    this.iconSize = 64,
    this.labelBottom = 12,
    this.labelWeight = FontWeight.w700,
  });
}

const _filterLanguages = <_FilterLanguageEntry>[
  _FilterLanguageEntry(code: 'es-ES', label: '🇪🇸 Español (España)'),
  _FilterLanguageEntry(code: 'en-US', label: '🇺🇸 English (USA)'),
  _FilterLanguageEntry(code: 'de-DE', label: '🇩🇪 Deutsch'),
  _FilterLanguageEntry(code: 'fr-FR', label: '🇫🇷 Français'),
  _FilterLanguageEntry(code: 'it-IT', label: '🇮🇹 Italiano'),
  _FilterLanguageEntry(code: 'pt-PT', label: '🇵🇹 Português (Portugal)'),
  _FilterLanguageEntry(code: 'pt-BR', label: '🇧🇷 Português (Brasil)'),
  _FilterLanguageEntry(code: 'nl-NL', label: '🇳🇱 Nederlands'),
  _FilterLanguageEntry(code: 'pl-PL', label: '🇵🇱 Polski'),
  _FilterLanguageEntry(code: 'cs-CZ', label: '🇨🇿 Retina'),
  _FilterLanguageEntry(code: 'sk-SK', label: '🇸🇰 Slovenčina'),
  _FilterLanguageEntry(code: 'hu-HU', label: '🇭🇺 Magyar'),
  _FilterLanguageEntry(code: 'ro-RO', label: '🇷🇴 Română'),
  _FilterLanguageEntry(code: 'bg-BG', label: '🇧🇬 Български'),
  _FilterLanguageEntry(code: 'el-GR', label: '🇬🇷 Ελληνικά'),
  _FilterLanguageEntry(code: 'sv-SE', label: '🇸🇪 Svenska'),
  _FilterLanguageEntry(code: 'no-NO', label: '🇳🇴 Norsk'),
  _FilterLanguageEntry(code: 'da-DK', label: '🇩🇰 Dansk'),
  _FilterLanguageEntry(code: 'fi-FI', label: '🇫🇮 Suomi'),
  _FilterLanguageEntry(code: 'tr-TR', label: '🇹🇷 Türkçe'),
  _FilterLanguageEntry(code: 'ru-RU', label: '🇷🇺 Русский'),
  _FilterLanguageEntry(code: 'uk-UA', label: '🇺🇦 Українська'),
  _FilterLanguageEntry(code: 'ar-SA', label: '🇸🇦 العربية'),
  _FilterLanguageEntry(code: 'he-IL', label: '🇮🇱 עברית'),
  _FilterLanguageEntry(code: 'hi-IN', label: '🇮🇳 हिन्दी'),
  _FilterLanguageEntry(code: 'bn-BD', label: '🇧🇩 বাংলা'),
  _FilterLanguageEntry(code: 'ur-PK', label: '🇵🇰 اردو'),
  _FilterLanguageEntry(code: 'fa-IR', label: '🇮🇷 فارسی'),
  _FilterLanguageEntry(code: 'zh-CN', label: '🇨🇳 中文 (简体)'),
  _FilterLanguageEntry(code: 'zh-TW', label: '🇹🇼 中文 (繁體)'),
  _FilterLanguageEntry(code: 'ja-JP', label: '🇯🇵 日本語'),
  _FilterLanguageEntry(code: 'ko-KR', label: '🇰🇷 한국어'),
  _FilterLanguageEntry(code: 'vi-VN', label: '🇻🇳 Tiếng Việt'),
  _FilterLanguageEntry(code: 'th-TH', label: '🇹🇭 ไทย'),
  _FilterLanguageEntry(code: 'id-ID', label: '🇮🇩 Bahasa Indonesia'),
  _FilterLanguageEntry(code: 'ms-MY', label: '🇲🇾 Bahasa Melayu'),
];

const _gameQuickSearchEntries = <_QuickSearchEntry>[
  _QuickSearchEntry(
    label: 'Fornite',
    badge: 'F',
    color: Color(0xFF1E81F5),
    badgeColor: Color(0xFF0C1D37),
  ),
  _QuickSearchEntry(label: 'Overatch', badge: 'OW', color: Color(0xFFFF980F)),
  _QuickSearchEntry(label: 'Minecraft', badge: 'MC', color: Color(0xFF6EB84D)),
  _QuickSearchEntry(
    label: 'League Of Legends',
    badge: 'L',
    color: Color(0xFFD7A646),
  ),
  _QuickSearchEntry(
    label: 'Dead by Daylight',
    badge: 'DBD',
    color: Color(0xFFAFB2B8),
  ),
  _QuickSearchEntry(
    label: 'Marvel Rivals',
    badge: 'MR',
    color: Color(0xFFFCE100),
  ),
  _QuickSearchEntry(
    label: 'Apex Legends',
    badge: 'A',
    color: Color(0xFFEE4046),
    badgeColor: Colors.white,
  ),
];

const _serviceQuickSearchEntries = <_QuickSearchEntry>[
  _QuickSearchEntry(label: 'Echat', badge: 'EC', color: Color(0xFF3A7AF9)),
  _QuickSearchEntry(
    label: 'Video Calls',
    badge: 'VC',
    color: Color(0xFF453AD3),
  ),
  _QuickSearchEntry(
    label: 'Watch Together',
    badge: 'WT',
    color: Color(0xFFEA3F40),
  ),
  _QuickSearchEntry(label: 'Photo Drop', badge: 'PD', color: Color(0xFF7625B9)),
  _QuickSearchEntry(
    label: 'Wake-up Calls',
    badge: 'WU',
    color: Color(0xFFF7DD88),
  ),
  _QuickSearchEntry(label: 'Tarot', badge: 'T', color: Color(0xFFA103F8)),
  _QuickSearchEntry(
    label: 'Live Stream',
    badge: 'LS',
    color: Color(0xFF1F2E65),
  ),
  _QuickSearchEntry(
    label: 'Play Session',
    badge: 'PS',
    color: Color(0xFF2B469D),
  ),
  _QuickSearchEntry(label: 'Leveling', badge: 'LV', color: Color(0xFF222F64)),
  _QuickSearchEntry(label: 'Earn Buds', badge: 'EB', color: Color(0xFF324267)),
];

class _BuddyEntry {
  final String name;
  final String rating;
  final String asset;

  const _BuddyEntry({
    required this.name,
    required this.rating,
    required this.asset,
  });
}

class _ProEntry {
  final String name;
  final String game;
  final String rank;
  final String asset;

  const _ProEntry({
    required this.name,
    required this.game,
    required this.rank,
    required this.asset,
  });
}

class _HowStepEntry {
  final String number;
  final String title;
  final String description;

  const _HowStepEntry({
    required this.number,
    required this.title,
    required this.description,
  });
}

const _bestBuddies = <_BuddyEntry>[
  _BuddyEntry(name: 'Roxxany', rating: '5.0', asset: 'assets/pp1.png'),
  _BuddyEntry(name: 'broomi', rating: '4.8', asset: 'assets/pp2.png'),
  _BuddyEntry(name: 'Levi', rating: '5.0', asset: 'assets/pp3.png'),
  _BuddyEntry(name: 'Meaniieh', rating: '5.0', asset: 'assets/pp4.png'),
  _BuddyEntry(name: 'Carla67', rating: '4.9', asset: 'assets/pp5.png'),
];

const _discoverBuddies = <_BuddyEntry>[
  _BuddyEntry(name: 'Drup', rating: '5.0', asset: 'assets/pp6.png'),
  _BuddyEntry(name: 'Winke', rating: '4.9', asset: 'assets/pp7.png'),
  _BuddyEntry(name: 'Khear', rating: '---', asset: 'assets/pp1.png'),
  _BuddyEntry(name: 'Lilith', rating: '---', asset: 'assets/pp2.png'),
  _BuddyEntry(name: 'Jhonny', rating: '5.0', asset: 'assets/pp3.png'),
];

const _matchBuddies = <_BuddyEntry>[
  _BuddyEntry(name: 'miaTheKAT', rating: '5.0', asset: 'assets/pp4.png'),
  _BuddyEntry(name: 'Leflorr', rating: '5.0', asset: 'assets/pp5.png'),
  _BuddyEntry(name: 'SHAYKK', rating: '5.0', asset: 'assets/pp6.png'),
  _BuddyEntry(name: 'Ori', rating: '5.0', asset: 'assets/pp7.png'),
  _BuddyEntry(name: 'shaxral', rating: '4.0', asset: 'assets/pp1.png'),
];
