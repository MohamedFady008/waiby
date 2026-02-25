import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../data/models/user_profile.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/chat_window.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/waiby_footer.dart';

double _clampDouble(double value, double min, double max) =>
    value.clamp(min, max).toDouble();

const double _desktopMaxContentWidth = WaibyBreakpoints.desktopContentMaxWidth;

double _scaleByWidth(
  double width, {
  required double min,
  required double max,
  double minWidth = 360,
  double maxWidth = 1200,
}) {
  if (max <= min) {
    return min;
  }

  // Use breakpoint-based tokens instead of continuous screen scaling.
  if (width <= WaibyBreakpoints.mobile) {
    return min;
  }
  if (width >= maxWidth) {
    return max;
  }
  return (min + max) / 2;
}

const double _servicesCarouselCardSpacing = WaibySpacing.s16;
const double _servicesCarouselCardAspectRatio = 0.94;
const double _servicesCarouselArrowButtonSize = 38;
const double _servicesCarouselArrowToTrackGap = WaibySpacing.s8;

int _servicesVisibleCardsForWidth(double width) {
  if (width >= WaibyBreakpoints.tablet) {
    return 7;
  }
  if (width >= WaibyBreakpoints.mobile) {
    return 4;
  }
  if (width >= 460) {
    return 3;
  }
  return 2;
}

double _servicesCardWidthForWidth(double width) {
  final visibleCards = _servicesVisibleCardsForWidth(width);
  final trackWidth = math.max(
    0.0,
    width -
        ((_servicesCarouselArrowButtonSize * 2) +
            (_servicesCarouselArrowToTrackGap * 2)),
  );
  return math.max(
    92.0,
    (trackWidth - (_servicesCarouselCardSpacing * (visibleCards - 1))) /
        visibleCards,
  );
}

double _servicesWidthForCardCount(double width, int count) {
  final cardWidth = _servicesCardWidthForWidth(width);
  return (cardWidth * count) + (_servicesCarouselCardSpacing * (count - 1));
}

class HomePage extends StatelessWidget {
  final AuthController auth;

  const HomePage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Obx(
      () =>
          _HomeBody(loggedIn: auth.isLoggedIn, homeController: homeController),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final bool loggedIn;
  final HomeController homeController;

  const _HomeBody({required this.loggedIn, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showChatSidebar = loggedIn && width >= 1000;
        const chatSidebarWidth = 84.0;
        const chatSidebarGap = 12.0;
        final reservedSidebarSpace = showChatSidebar
            ? chatSidebarWidth + chatSidebarGap
            : 0.0;
        final pagePadding = waibyHorizontalPaddingForWidth(width);
        final compact = width < WaibyBreakpoints.mobile;
        final topPadding = compact ? WaibySpacing.s8 : WaibySpacing.s16;
        final heroGap = compact ? WaibySpacing.s16 : WaibySpacing.s24;
        final headingGap = compact ? WaibySpacing.s16 : WaibySpacing.s24;
        final titleGap = compact ? WaibySpacing.s12 : WaibySpacing.s16;
        final servicesGap = compact ? WaibySpacing.s16 : WaibySpacing.s24;
        final searchGap = compact ? WaibySpacing.s24 : WaibySpacing.s32;
        final sectionGap = compact ? WaibySpacing.s24 : WaibySpacing.s32;
        final dividerGapTop = compact ? WaibySpacing.s24 : WaibySpacing.s32;
        final dividerGapBottom = compact ? WaibySpacing.s16 : WaibySpacing.s24;
        final bottomGap = compact ? WaibySpacing.s16 : WaibySpacing.s24;

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
                    WaibyConstrainedContent(
                      maxWidth: _desktopMaxContentWidth,
                      padding: EdgeInsets.fromLTRB(
                        pagePadding,
                        0,
                        pagePadding + reservedSidebarSpace,
                        0,
                      ),
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
                          LayoutBuilder(
                            builder: (context, sectionConstraints) {
                              final sectionWidth = sectionConstraints.maxWidth;
                              final servicesCardHeight =
                                  _servicesCardWidthForWidth(sectionWidth) /
                                  _servicesCarouselCardAspectRatio;
                              final searchStripHeight = servicesCardHeight / 3;
                              final searchStripWidth = math.min(
                                sectionWidth,
                                _servicesWidthForCardCount(sectionWidth, 5),
                              );
                              return Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: searchStripWidth,
                                  child: _SearchStrip(
                                    fixedHeight: searchStripHeight,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: searchGap),
                          _BuddySection(
                            title: 'The Best buddies',
                            items: _bestBuddies,
                            overlayStyle: _BuddyCardOverlayStyle.vibrant,
                          ),
                          SizedBox(height: sectionGap),
                          _ProGamersSection(controller: homeController),
                          SizedBox(height: sectionGap),
                          _NewBuddiesSection(controller: homeController),
                          SizedBox(height: sectionGap),
                          _BuddySection(
                            title: 'High Potential match',
                            items: _matchBuddies,
                            overlayStyle: _BuddyCardOverlayStyle.mutedBlur,
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
                    const WaibyFooter(),
                  ],
                ),
              ),
              if (showChatSidebar)
                Positioned.fill(
                  child: _HomeChatDock(
                    sidebarWidth: chatSidebarWidth,
                    sidebarGap: chatSidebarGap,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeChatDock extends StatefulWidget {
  final double sidebarWidth;
  final double sidebarGap;

  const _HomeChatDock({required this.sidebarWidth, required this.sidebarGap});

  @override
  State<_HomeChatDock> createState() => _HomeChatDockState();
}

class _HomeChatDockState extends State<_HomeChatDock> {
  late final List<WaibyChatThread> _threads;
  String? _activeThreadId;

  @override
  void initState() {
    super.initState();
    _threads = WaibyChatThread.demoThreads();
  }

  bool get _panelOpen => _activeThreadId != null;

  void _openThread(String threadId) {
    setState(() => _activeThreadId = threadId);
  }

  void _closePanel() {
    setState(() => _activeThreadId = null);
  }

  @override
  Widget build(BuildContext context) {
    final sidebarItems = _threads
        .map(
          (thread) => ChatSidebarItem(
            avatarAsset: thread.avatarAsset,
            frameAsset: thread.frameAsset,
            unreadCount: thread.unreadCount,
            showUnreadIndicator: thread.showUnreadIndicator,
            onTap: () => _openThread(thread.id),
          ),
        )
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final dockHeight = math.max(320.0, constraints.maxHeight - 20);
        final rawPanelWidth =
            constraints.maxWidth - widget.sidebarWidth - widget.sidebarGap - 24;
        final maxPanelWidth = rawPanelWidth.clamp(520.0, 860.0).toDouble();
        final visiblePanelWidth = _panelOpen ? maxPanelWidth : 0.0;

        return Stack(
          children: [
            if (_panelOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closePanel,
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeOutCubic,
                      width: visiblePanelWidth,
                      height: dockHeight,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: maxPanelWidth,
                            height: dockHeight,
                            child: IgnorePointer(
                              ignoring: !_panelOpen,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                opacity: _panelOpen ? 1 : 0,
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 340),
                                  curve: Curves.easeOutCubic,
                                  offset: _panelOpen
                                      ? Offset.zero
                                      : const Offset(0.08, 0),
                                  child: WaibyChatWindow(
                                    width: maxPanelWidth,
                                    height: dockHeight,
                                    threads: _threads,
                                    initialThreadId: _activeThreadId,
                                    onClose: _closePanel,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: widget.sidebarGap),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeOutCubic,
                      offset: _panelOpen ? const Offset(-0.02, 0) : Offset.zero,
                      child: SizedBox(
                        width: widget.sidebarWidth,
                        height: dockHeight,
                        child: ChatSidebar(
                          width: widget.sidebarWidth,
                          items: sidebarItems,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        final showAvatar = width >= 880;
        final bannerAspectRatio = width >= 1024
            ? 4.2
            : width >= WaibyBreakpoints.mobile
            ? 3.2
            : 2.0;
        final bannerMinHeight = width >= WaibyBreakpoints.mobile
            ? 210.0
            : 180.0;
        final horizontalPadding = _scaleByWidth(
          width,
          min: 16,
          max: 28,
          minWidth: 320,
          maxWidth: 1200,
        );
        final verticalPadding = _scaleByWidth(
          width,
          min: 12,
          max: 18,
          minWidth: 320,
          maxWidth: 1200,
        );
        final titleFont = _scaleByWidth(
          width,
          min: 18,
          max: 24,
          minWidth: 320,
          maxWidth: 1200,
        );
        final mvpFont = _scaleByWidth(
          width,
          min: 30,
          max: 40,
          minWidth: 320,
          maxWidth: 1200,
        );
        final titleLetterSpacing = _scaleByWidth(
          width,
          min: 0.8,
          max: 1.4,
          minWidth: 320,
          maxWidth: 1200,
        );
        final avatarSize = _scaleByWidth(
          width,
          min: 118,
          max: 156,
          minWidth: 880,
          maxWidth: 1200,
        );
        final avatarBorder = _scaleByWidth(
          width,
          min: 6,
          max: 8,
          minWidth: 880,
          maxWidth: 1200,
        );
        final avatarPadding = _scaleByWidth(
          width,
          min: 4,
          max: 6,
          minWidth: 880,
          maxWidth: 1200,
        );
        final sparkleSize = _scaleByWidth(
          width,
          min: 34,
          max: 48,
          minWidth: 880,
          maxWidth: 1200,
        );

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: bannerMinHeight),
          child: AspectRatio(
            aspectRatio: bannerAspectRatio,
            child: Container(
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
                                            max: 10,
                                            minWidth: 880,
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
        final textTheme = Theme.of(context).textTheme;
        final titleSize = _scaleByWidth(
          width,
          min: 28,
          max: 40,
          maxWidth: 1200,
        );
        final subtitleSize = _scaleByWidth(
          width,
          min: 14,
          max: 16,
          maxWidth: 1200,
        );
        final dividerThickness = _scaleByWidth(
          width,
          min: 2,
          max: 3,
          maxWidth: 1200,
        );

        return Column(
          children: [
            Text(
              'FIND YOUR PERFECT BUDDY. ANYTIME',
              textAlign: TextAlign.center,
              style:
                  textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.15,
                  ) ??
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                    height: 1.15,
                  ),
            ),
            SizedBox(
              height: _scaleByWidth(width, min: 6, max: 8, maxWidth: 1200),
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
              style:
                  textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: subtitleSize,
                    height: 1.3,
                  ) ??
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: subtitleSize,
                    height: 1.3,
                  ),
            ),
            SizedBox(
              height: _scaleByWidth(width, min: 10, max: 14, maxWidth: 1200),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
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
    final textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style:
          textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: _scaleByWidth(width, min: 18, max: 24, maxWidth: 1200),
          ) ??
          GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: _scaleByWidth(width, min: 18, max: 24, maxWidth: 1200),
          ),
    );
  }
}

class _ServicesCarousel extends StatefulWidget {
  const _ServicesCarousel();

  @override
  State<_ServicesCarousel> createState() => _ServicesCarouselState();

  static const _services = <_ServiceEntry>[
    _ServiceEntry(
      asset: 'assets/all_services/valorant.png',
      fallbackColor: Color(0xFF1F2E65),
    ),
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
    _ServiceEntry(
      asset: 'assets/all_services/rivals.png',
      fallbackColor: Color(0xFF1C2B6A),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/lol.png',
      fallbackColor: Color(0xFF222F64),
    ),
    _ServiceEntry(
      title: 'Watch\nTogether',
      icon: Icons.card_giftcard_rounded,
      solidColor: Color(0xFFEA3F40),
      fallbackColor: Color(0xFFEA3F40),
      iconTop: 21,
      iconSize: 84,
      labelBottom: 8,
    ),
    _ServiceEntry(
      asset: 'assets/all_services/clash_royale.png',
      fallbackColor: Color(0xFF2B469D),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/overwatch.png',
      fallbackColor: Color(0xFF75777D),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/cs_go.png',
      fallbackColor: Color(0xFF324267),
    ),
    _ServiceEntry(
      title: 'Video\nCalls',
      icon: Icons.videocam_rounded,
      solidColor: Color(0xFF453AD3),
      fallbackColor: Color(0xFF453AD3),
      iconTop: 18,
      iconSize: 84,
      labelBottom: 8,
    ),
    _ServiceEntry(
      asset: 'assets/all_services/apex.png',
      fallbackColor: Color(0xFF222F64),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/dead_by_daylight.png',
      fallbackColor: Color(0xFF2A334F),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/tft.png',
      fallbackColor: Color(0xFF2D3E70),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/gta.png',
      fallbackColor: Color(0xFF243A6D),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/fall_guys.png',
      fallbackColor: Color(0xFF35364D),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/roblox.png',
      fallbackColor: Color(0xFF35364D),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/minecraft.png',
      fallbackColor: Color(0xFF264275),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/world_warcraft.png',
      fallbackColor: Color(0xFF243A72),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/vr_chat.png',
      fallbackColor: Color(0xFF394056),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/red_dead2.png',
      fallbackColor: Color(0xFF472D24),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/genshin_impact.png',
      fallbackColor: Color(0xFF334560),
    ),
    _ServiceEntry(
      title: 'Photo\nDrop',
      icon: Icons.camera_alt_rounded,
      solidColor: Color(0xFF7625B9),
      fallbackColor: Color(0xFF7625B9),
      iconTop: 23,
      iconSize: 82,
      labelBottom: 8,
    ),
    _ServiceEntry(
      asset: 'assets/all_services/fortnite.png',
      fallbackColor: Color(0xFF313746),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/lethal_company.png',
      fallbackColor: Color(0xFF2D3143),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/dota2.png',
      fallbackColor: Color(0xFF223154),
    ),
    _ServiceEntry(
      asset: 'assets/all_services/honkai_star_rail.png',
      fallbackColor: Color(0xFF273450),
    ),
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
  ];
}

class _ServicesCarouselState extends State<_ServicesCarousel> {
  final ScrollController _scrollController = ScrollController();

  bool _canScrollBackward = false;
  bool _canScrollForward = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncArrowState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncArrowState());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncArrowState)
      ..dispose();
    super.dispose();
  }

  void _syncArrowState() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final canScrollBackward = position.pixels > position.minScrollExtent + 0.5;
    final canScrollForward = position.pixels < position.maxScrollExtent - 0.5;

    if (canScrollBackward == _canScrollBackward &&
        canScrollForward == _canScrollForward) {
      return;
    }

    setState(() {
      _canScrollBackward = canScrollBackward;
      _canScrollForward = canScrollForward;
    });
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    _scrollController.animateTo(
      target.toDouble(),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) {
      return;
    }

    final delta = event.scrollDelta.dy.abs() > event.scrollDelta.dx.abs()
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0) {
      return;
    }

    final position = _scrollController.position;
    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if ((target - position.pixels).abs() < 0.5) {
      return;
    }

    _scrollController.jumpTo(target.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cardWidth = _servicesCardWidthForWidth(width);
        final cardHeight = cardWidth / _servicesCarouselCardAspectRatio;
        final scrollStep = (cardWidth + _servicesCarouselCardSpacing) * 3;

        return SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              _CarouselArrowButton(
                icon: Icons.chevron_left_rounded,
                isEnabled: _canScrollBackward,
                onPressed: () => _scrollBy(-scrollStep),
              ),
              const SizedBox(width: _servicesCarouselArrowToTrackGap),
              Expanded(
                child: NotificationListener<ScrollMetricsNotification>(
                  onNotification: (notification) {
                    _syncArrowState();
                    return false;
                  },
                  child: Listener(
                    onPointerSignal: _onPointerSignal,
                    child: ScrollConfiguration(
                      behavior: const _HorizontalMouseDragScrollBehavior(),
                      child: ListView.separated(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: _ServicesCarousel._services.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: _servicesCarouselCardSpacing),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: cardWidth,
                            child: _ServiceCard(
                              entry: _ServicesCarousel._services[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _servicesCarouselArrowToTrackGap),
              _CarouselArrowButton(
                icon: Icons.chevron_right_rounded,
                isEnabled: _canScrollForward,
                onPressed: () => _scrollBy(scrollStep),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _CarouselArrowButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _servicesCarouselArrowButtonSize,
      height: _servicesCarouselArrowButtonSize,
      child: IconButton(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon, size: 24),
        color: Colors.white.withValues(alpha: isEnabled ? 0.96 : 0.3),
        disabledColor: Colors.white.withValues(alpha: 0.3),
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(
            0xFF1B2348,
          ).withValues(alpha: isEnabled ? 0.82 : 0.45),
          side: BorderSide(
            color: Colors.white.withValues(alpha: isEnabled ? 0.26 : 0.1),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _HorizontalMouseDragScrollBehavior extends MaterialScrollBehavior {
  const _HorizontalMouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}

class _SearchStrip extends StatefulWidget {
  final double? fixedHeight;

  const _SearchStrip({this.fixedHeight});

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
  final LayerLink _searchPanelLayerLink = LayerLink();
  final LayerLink _filterPanelLayerLink = LayerLink();
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
          final showFilterPanel = _isFilterOpen;
          final link = showFilterPanel
              ? _filterPanelLayerLink
              : _searchPanelLayerLink;
          final targetAnchor = showFilterPanel
              ? Alignment.bottomRight
              : Alignment.bottomLeft;
          final followerAnchor = showFilterPanel
              ? Alignment.topRight
              : Alignment.topLeft;

          return CompositedTransformFollower(
            link: link,
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            showWhenUnlinked: false,
            offset: const Offset(0, 8),
            child: TapRegion(
              groupId: _panelTapRegionGroupId,
              child: Material(
                color: Colors.transparent,
                child: _isFilterOpen
                    ? _buildFiltersPanel(width)
                    : _buildSearchResultsPanel(width),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
    final filtersPanelWidth = math.min(560.0, width);
    final languageColumns = filtersPanelWidth >= 580
        ? 4
        : filtersPanelWidth >= 420
        ? 3
        : 2;
    final languageRows = (_visibleLanguages.length / languageColumns).ceil();
    final panelHeight = _showAllLanguages
        ? _clampDouble(260 + (languageRows * 34), 360, 620)
        : 330.0;
    final panelTitleSize = _scaleByWidth(
      width,
      min: 15,
      max: 16,
      minWidth: 320,
      maxWidth: 1200,
    );
    final panelTextSize = _scaleByWidth(
      width,
      min: 12,
      max: 14,
      minWidth: 320,
      maxWidth: 1200,
    );
    final sectionTitleSize = _scaleByWidth(
      width,
      min: 14,
      max: 16,
      minWidth: 320,
      maxWidth: 1200,
    );
    final showMoreSize = _scaleByWidth(
      width,
      min: 10,
      max: 12,
      minWidth: 320,
      maxWidth: 1200,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: math.min(300.0, filtersPanelWidth),
        maxWidth: filtersPanelWidth,
        minHeight: 280,
        maxHeight: panelHeight,
      ),
      child: Container(
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
      ),
    );
  }

  Widget _buildSearchResultsPanel(double width) {
    final searchPanelWidth = math.min(560.0, width);
    final searchPanelHeight = _scaleByWidth(
      width,
      min: 250,
      max: 320,
      minWidth: 320,
      maxWidth: 1200,
    );
    final searchTabTitleSize = _scaleByWidth(
      width,
      min: 15,
      max: 16,
      minWidth: 320,
      maxWidth: 1200,
    );
    final searchTabCountSize = _scaleByWidth(
      width,
      min: 12,
      max: 13,
      minWidth: 320,
      maxWidth: 1200,
    );
    final searchLabelSize = _scaleByWidth(
      width,
      min: 12,
      max: 13,
      minWidth: 320,
      maxWidth: 1200,
    );
    final searchIconSizeInPanel = _scaleByWidth(
      width,
      min: 28,
      max: 30,
      minWidth: 320,
      maxWidth: 1200,
    );
    final searchBadgeSize = _scaleByWidth(
      width,
      min: 11,
      max: 13,
      minWidth: 320,
      maxWidth: 1200,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: math.min(320.0, searchPanelWidth),
        maxWidth: searchPanelWidth,
        minHeight: 220,
        maxHeight: searchPanelHeight,
      ),
      child: Container(
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
            Flexible(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final stripHeight =
            widget.fixedHeight ??
            _scaleByWidth(
              width,
              min: 44,
              max: 52,
              minWidth: 320,
              maxWidth: 1200,
            );
        final outerRadius = _scaleByWidth(
          width,
          min: 12,
          max: 15,
          minWidth: 320,
          maxWidth: 1200,
        );
        final horizontalInset = _scaleByWidth(
          width,
          min: 10,
          max: 14,
          minWidth: 320,
          maxWidth: 1200,
        );
        final verticalInset = _scaleByWidth(
          width,
          min: 8,
          max: 10,
          minWidth: 320,
          maxWidth: 1200,
        );
        final leadingGap = _scaleByWidth(
          width,
          min: 8,
          max: 12,
          minWidth: 320,
          maxWidth: 1200,
        );
        final searchIconSize = _scaleByWidth(
          width,
          min: 20,
          max: 24,
          minWidth: 320,
          maxWidth: 1200,
        );
        final textSize = _scaleByWidth(
          width,
          min: 14,
          max: 16,
          minWidth: 320,
          maxWidth: 1200,
        );
        final filterIconSize = _scaleByWidth(
          width,
          min: 18,
          max: 22,
          minWidth: 320,
          maxWidth: 1200,
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
            link: _searchPanelLayerLink,
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
                        maxWidth: 1200,
                      ),
                    ),
                    CompositedTransformTarget(
                      link: _filterPanelLayerLink,
                      child: Material(
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
  final _BuddyCardOverlayStyle overlayStyle;

  const _BuddySection({
    required this.title,
    required this.items,
    required this.overlayStyle,
  });

  static const double _cardSpacing = WaibySpacing.s16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final titleGap = width < WaibyBreakpoints.mobile
            ? WaibySpacing.s12
            : WaibySpacing.s16;
        final visibleCards = width >= WaibyBreakpoints.tablet
            ? 5
            : width >= WaibyBreakpoints.mobile
            ? 3
            : 2;
        final cardWidth = _clampDouble(
          (width - (_cardSpacing * (visibleCards - 1))) / visibleCards,
          140,
          260,
        );
        final cardHeight = _clampDouble(cardWidth * 0.92, 180, 230);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeaderRow(
              title: title,
              onViewMore: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _BuddyCategoryPage(
                      title: title,
                      items: items,
                      overlayStyle: overlayStyle,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: titleGap),
            SizedBox(
              height: cardHeight,
              child: ScrollConfiguration(
                behavior: const _HorizontalMouseDragScrollBehavior(),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: _cardSpacing),
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    return SizedBox(
                      width: cardWidth,
                      child: _BuddyCard(
                        entry: entry,
                        overlayStyle: overlayStyle,
                        onTap: () => context.go(
                          '/profile/${Uri.encodeComponent(entry.id)}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NewBuddiesSection extends StatelessWidget {
  final HomeController controller;

  const _NewBuddiesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingNewestCreators.value) {
        return const _SectionStateCard(
          title: 'New Buddies',
          message: 'Loading new creators...',
        );
      }

      if (controller.newestCreatorsError.value.isNotEmpty) {
        return _SectionStateCard(
          title: 'New Buddies',
          message: controller.newestCreatorsError.value,
        );
      }

      final entries = controller.newestCreators
          .map(_mapCreatorToBuddyEntry)
          .toList(growable: false);
      if (entries.isEmpty) {
        return const _SectionStateCard(
          title: 'New Buddies',
          message:
              'No new creators yet. Make sure user documents include isCreator=true.',
        );
      }

      return _BuddySection(
        title: 'New Buddies',
        items: entries,
        overlayStyle: _BuddyCardOverlayStyle.mutedBlur,
      );
    });
  }

  _BuddyEntry _mapCreatorToBuddyEntry(UserProfile profile) {
    final displayName = _resolveDisplayName(profile);
    return _BuddyEntry(
      id: profile.id,
      name: displayName,
      rating: 'NEW',
      photoUrl: profile.avatarUrl,
      asset: _creatorFallbackAsset(profile.id),
    );
  }
}

class _ProGamersSection extends StatelessWidget {
  final HomeController controller;

  const _ProGamersSection({required this.controller});

  static const double _cardSpacing = WaibySpacing.s16;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadingProGamers.value) {
        return const _SectionStateCard(
          title: 'Pro Gamers',
          message: 'Loading pro gamers...',
        );
      }

      if (controller.proGamersError.value.isNotEmpty) {
        return _SectionStateCard(
          title: 'Pro Gamers',
          message: controller.proGamersError.value,
        );
      }

      final entries = controller.proGamers
          .map(_mapProfileToProEntry)
          .toList(growable: false);
      if (entries.isEmpty) {
        return const _SectionStateCard(
          title: 'Pro Gamers',
          message: 'No pro gamers are available right now.',
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final titleGap = width < WaibyBreakpoints.mobile
              ? WaibySpacing.s12
              : WaibySpacing.s16;
          final cardWidth = _clampDouble(
            (width - (_cardSpacing * 2)) / 3,
            230,
            420,
          );
          final cardHeight = cardWidth * 0.6;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeaderRow(
                title: 'Pro Gamers',
                onViewMore: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          _ProCategoryPage(title: 'Pro Gamers', items: entries),
                    ),
                  );
                },
              ),
              SizedBox(height: titleGap),
              SizedBox(
                height: cardHeight,
                child: ScrollConfiguration(
                  behavior: const _HorizontalMouseDragScrollBehavior(),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: entries.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: _cardSpacing),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return SizedBox(
                        width: cardWidth,
                        child: _ProCard(
                          entry: entry,
                          onTap: () => context.go(
                            '/profile/${Uri.encodeComponent(entry.id)}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  _ProEntry _mapProfileToProEntry(UserProfile profile) {
    final metadata = profile.metadata;
    final game = metadata['favorite_game']?.toString() ?? 'WAIBY';
    final rank = metadata['rank']?.toString() ?? 'Pro Gamer';
    return _ProEntry(
      id: profile.id,
      name: _resolveDisplayName(profile),
      game: game.toUpperCase(),
      rank: rank,
      asset: _creatorFallbackAsset(profile.id),
    );
  }
}

class _BuddyCategoryPage extends StatelessWidget {
  final String title;
  final List<_BuddyEntry> items;
  final _BuddyCardOverlayStyle overlayStyle;

  const _BuddyCategoryPage({
    required this.title,
    required this.items,
    required this.overlayStyle,
  });

  @override
  Widget build(BuildContext context) {
    const cardSpacing = WaibySpacing.s16;
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1631),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = waibyHorizontalPaddingForWidth(width);
          final contentWidth = math.min(
            _desktopMaxContentWidth,
            width - (horizontalPadding * 2),
          );
          final visibleCards = width >= WaibyBreakpoints.tablet
              ? 5
              : width >= WaibyBreakpoints.mobile
              ? 3
              : 2;
          final cardWidth = _clampDouble(
            (contentWidth - (cardSpacing * (visibleCards - 1))) / visibleCards,
            140,
            260,
          );
          final cardHeight = _clampDouble(cardWidth * 0.92, 180, 230);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _desktopMaxContentWidth,
              ),
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  WaibySpacing.s16,
                  horizontalPadding,
                  WaibySpacing.s24,
                ),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: cardWidth,
                  mainAxisExtent: cardHeight,
                  crossAxisSpacing: cardSpacing,
                  mainAxisSpacing: cardSpacing,
                ),
                itemBuilder: (context, index) {
                  final entry = items[index];
                  return _BuddyCard(
                    entry: entry,
                    overlayStyle: overlayStyle,
                    onTap: () =>
                        context.go('/profile/${Uri.encodeComponent(entry.id)}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProCategoryPage extends StatelessWidget {
  final String title;
  final List<_ProEntry> items;

  const _ProCategoryPage({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    const cardSpacing = WaibySpacing.s16;
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1631),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = waibyHorizontalPaddingForWidth(width);
          final contentWidth = math.min(
            _desktopMaxContentWidth,
            width - (horizontalPadding * 2),
          );
          final cardWidth = _clampDouble(
            (contentWidth - (cardSpacing * 2)) / 3,
            230,
            420,
          );
          final cardHeight = cardWidth * 0.6;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _desktopMaxContentWidth,
              ),
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  WaibySpacing.s16,
                  horizontalPadding,
                  WaibySpacing.s24,
                ),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: cardWidth,
                  mainAxisExtent: cardHeight,
                  crossAxisSpacing: cardSpacing,
                  mainAxisSpacing: cardSpacing,
                ),
                itemBuilder: (context, index) {
                  final entry = items[index];
                  return _ProCard(
                    entry: entry,
                    onTap: () =>
                        context.go('/profile/${Uri.encodeComponent(entry.id)}'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionStateCard extends StatelessWidget {
  final String title;
  final String message;

  const _SectionStateCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeaderRow(title: title, onViewMore: () {}),
        const SizedBox(height: WaibySpacing.s16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(WaibySpacing.s16),
          decoration: BoxDecoration(
            color: const Color(0x191B234B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

String _resolveDisplayName(UserProfile profile) {
  final fullName = profile.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }

  final email = profile.email?.trim();
  if (email != null && email.isNotEmpty && email.contains('@')) {
    return email.split('@').first;
  }

  return profile.id;
}

String _creatorFallbackAsset(String seed) {
  const assets = <String>[
    'assets/pp1.png',
    'assets/pp2.png',
    'assets/pp3.png',
    'assets/pp4.png',
    'assets/pp5.png',
    'assets/pp6.png',
    'assets/pp7.png',
  ];
  final hash = seed.codeUnits.fold<int>(0, (acc, value) => acc + value);
  return assets[hash % assets.length];
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
        final compact = width < WaibyBreakpoints.tablet;
        final contentWidth = math.min(width, 960.0);
        final headingSize = _scaleByWidth(
          width,
          min: 22,
          max: 28,
          minWidth: 320,
          maxWidth: 1200,
        );
        final subtitleSize = _scaleByWidth(
          width,
          min: 14,
          max: 16,
          minWidth: 320,
          maxWidth: 1200,
        );
        final topPadding = compact ? WaibySpacing.s24 : WaibySpacing.s32;
        final stepsTopGap = compact ? WaibySpacing.s24 : WaibySpacing.s32;

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: topPadding,
            horizontal: compact ? WaibySpacing.s8 : WaibySpacing.s12,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0x1A020305),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned(
                left: -width * 0.18,
                top: -width * 0.18,
                child: _BlurEllipse(
                  width: width * 0.56,
                  height: 160,
                  colors: const [Color(0x33020303), Color(0x338FFDBB)],
                  blurSigma: 60,
                  rotation: 0.7,
                  opacity: 0.2,
                ),
              ),
              Positioned(
                left: -width * 0.28,
                top: 140,
                child: _BlurEllipse(
                  width: width * 0.42,
                  height: 180,
                  colors: const [Color(0x66000000), Color(0x66FF0000)],
                  blurSigma: 70,
                  rotation: 0.55,
                ),
              ),
              Positioned(
                right: -width * 0.16,
                top: 220,
                child: _BlurEllipse(
                  width: width * 0.62,
                  height: 210,
                  colors: const [Color(0x00F8F8F8), Color(0x66F91E94)],
                  blurSigma: 44,
                  rotation: -0.22,
                ),
              ),
              Positioned(
                right: width * 0.02,
                bottom: -30,
                child: _BlurEllipse(
                  width: width * 0.52,
                  height: 120,
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
                      const SizedBox(height: WaibySpacing.s8),
                      Text(
                        'Finding the perfect buddy has never been this easy.\nJust choose a service, connect, and enjoy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: subtitleSize,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: stepsTopGap),
                      for (int i = 0; i < _steps.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == _steps.length - 1
                                ? 0
                                : WaibySpacing.s16,
                          ),
                          child: _HowStepRow(
                            entry: _steps[i],
                            showLine: i != _steps.length - 1,
                            compact: compact,
                          ),
                        ),
                    ],
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

class _SectionHeaderRow extends StatelessWidget {
  final String title;
  final VoidCallback? onViewMore;

  const _SectionHeaderRow({required this.title, this.onViewMore});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 620;
        final titleSize = _scaleByWidth(
          width,
          min: 18,
          max: 24,
          minWidth: 320,
          maxWidth: 1200,
        );
        final buttonHeight = _scaleByWidth(
          width,
          min: 34,
          max: 38,
          minWidth: 320,
          maxWidth: 1200,
        );
        final buttonTextSize = _scaleByWidth(
          width,
          min: 13,
          max: 14,
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
            onPressed: onViewMore,
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

  const _ServiceCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final hasTitle = entry.title.trim().isNotEmpty;
    final titleParts = hasTitle ? entry.title.split('\n') : const <String>[];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 156).clamp(0.72, 1.1).toDouble();
        final radius = _clampDouble(5 * scale, 4, 8);
        final labelFontSize = _clampDouble(20 * scale, 14, 20);

        return Container(
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
      },
    );
  }
}

enum _BuddyCardOverlayStyle { vibrant, mutedBlur }

class _BuddyCard extends StatelessWidget {
  final _BuddyEntry entry;
  final _BuddyCardOverlayStyle overlayStyle;
  final VoidCallback onTap;

  const _BuddyCard({
    required this.entry,
    required this.overlayStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : cardWidth * 0.88;
        final overlayHeight = _clampDouble(cardHeight * 0.25, 50, 66);
        final radius = _clampDouble(cardWidth * 0.035, 7, 10);
        final overlayHorizontalPadding = _clampDouble(cardWidth * 0.045, 8, 12);
        final overlayVerticalPadding = _clampDouble(overlayHeight * 0.14, 5, 8);
        final nameFontSize = _clampDouble(cardWidth * 0.07, 12, 16);
        final ratingFontSize = _clampDouble(cardWidth * 0.048, 10, 13);
        final actionSize = _clampDouble(overlayHeight * 0.52, 24, 32);
        final actionIconSize = _clampDouble(actionSize * 0.58, 14, 18);
        final heartSize = _clampDouble(ratingFontSize * 0.75, 8, 11);
        final overlayDecoration = overlayStyle == _BuddyCardOverlayStyle.vibrant
            ? const BoxDecoration(
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
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1, -0.08),
                  end: Alignment(1, 0.08),
                  colors: [
                    Color(0xE60D1220),
                    Color(0xE61B234B),
                    Color(0xE61A4C9D),
                  ],
                  stops: [0, 0.5959, 0.9684],
                ),
              );

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if ((entry.photoUrl ?? '').trim().isNotEmpty)
                    Image.network(
                      entry.photoUrl!.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: const Color(0xFF141D38),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white.withValues(alpha: 0.72),
                          size: _clampDouble(cardWidth * 0.2, 28, 42),
                        ),
                      ),
                    )
                  else
                    Image.asset(
                      entry.asset ?? 'assets/pp1.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                        color: const Color(0xFF141D38),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white.withValues(alpha: 0.72),
                          size: _clampDouble(cardWidth * 0.2, 28, 42),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: overlayStyle == _BuddyCardOverlayStyle.mutedBlur
                            ? ui.ImageFilter.blur(sigmaX: 7.5, sigmaY: 7.5)
                            : ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          height: overlayHeight,
                          decoration: overlayDecoration,
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
                                          width: _clampDouble(
                                            overlayHeight * 0.06,
                                            3,
                                            4,
                                          ),
                                        ),
                                        Icon(
                                          Icons.favorite,
                                          color: const Color(0xFF51D76E),
                                          size: heartSize,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: _clampDouble(overlayHeight * 0.12, 6, 8),
                              ),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProCard extends StatelessWidget {
  final _ProEntry entry;
  final VoidCallback onTap;

  const _ProCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : cardWidth * 0.6;
        final frameHeight = totalHeight - 34;
        final playButtonSize = _clampDouble(cardWidth * 0.12, 34, 48);
        final playIconSize = _clampDouble(playButtonSize * 0.6, 20, 30);
        final gameFontSize = _clampDouble(cardWidth * 0.043, 12, 18);
        final nameFontSize = _clampDouble(cardWidth * 0.065, 18, 26);
        final rankFontSize = _clampDouble(cardWidth * 0.028, 10, 12);
        final sidePadding = _clampDouble(cardWidth * 0.026, 8, 12);
        final topPadding = _clampDouble(cardWidth * 0.026, 8, 12);
        final bottomPadding = _clampDouble(cardWidth * 0.026, 8, 12);
        final rankHorizontalPadding = _clampDouble(cardWidth * 0.02, 6, 10);
        final rankVerticalPadding = _clampDouble(cardWidth * 0.006, 2, 4);

        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
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
                      border: Border.all(
                        color: const Color(0xFF51D76E),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 54,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  entry.asset,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const ColoredBox(
                                        color: Color(0xFF131A38),
                                      ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: -(playButtonSize / 2),
                                child: Center(
                                  child: Container(
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
                                ),
                              ),
                            ],
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
                                    height: 1.05,
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
                                  height: _clampDouble(cardWidth * 0.01, 3, 6),
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
              ],
            ),
          ),
        );
      },
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
    final markerSize = compact ? (tinyCompact ? 54.0 : 62.0) : 72.0;
    final lineHeight = compact ? (tinyCompact ? 28.0 : 36.0) : 48.0;
    final railWidth = compact ? (tinyCompact ? 64.0 : 76.0) : 110.0;
    final rowHeight = markerSize + (showLine ? lineHeight : 0);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: rowHeight),
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
                      fontSize: compact ? (tinyCompact ? 28 : 32) : 36,
                      height: 1.0,
                    ),
                  ),
                ),
                if (showLine)
                  Container(width: 1, height: lineHeight, color: Colors.white),
              ],
            ),
          ),
          SizedBox(width: compact ? (tinyCompact ? 12 : 16) : 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: compact ? (tinyCompact ? 2 : 4) : 8,
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
                      fontSize: compact ? (tinyCompact ? 18 : 20) : 22,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Text(
                    entry.description,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: compact ? (tinyCompact ? 14 : 15) : 16,
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
  final String id;
  final String name;
  final String rating;
  final String? asset;
  final String? photoUrl;

  const _BuddyEntry({
    required this.id,
    required this.name,
    required this.rating,
    this.asset,
    this.photoUrl,
  });
}

class _ProEntry {
  final String id;
  final String name;
  final String game;
  final String rank;
  final String asset;

  const _ProEntry({
    required this.id,
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
  _BuddyEntry(
    id: 'Roxxany',
    name: 'Roxxany',
    rating: '5.0',
    asset: 'assets/pp1.png',
  ),
  _BuddyEntry(
    id: 'broomi',
    name: 'broomi',
    rating: '4.8',
    asset: 'assets/pp2.png',
  ),
  _BuddyEntry(id: 'Levi', name: 'Levi', rating: '5.0', asset: 'assets/pp3.png'),
  _BuddyEntry(
    id: 'Meaniieh',
    name: 'Meaniieh',
    rating: '5.0',
    asset: 'assets/pp4.png',
  ),
  _BuddyEntry(
    id: 'Carla67',
    name: 'Carla67',
    rating: '4.9',
    asset: 'assets/pp5.png',
  ),
];

const _matchBuddies = <_BuddyEntry>[
  _BuddyEntry(
    id: 'miaTheKAT',
    name: 'miaTheKAT',
    rating: '5.0',
    asset: 'assets/pp4.png',
  ),
  _BuddyEntry(
    id: 'Leflorr',
    name: 'Leflorr',
    rating: '5.0',
    asset: 'assets/pp5.png',
  ),
  _BuddyEntry(
    id: 'SHAYKK',
    name: 'SHAYKK',
    rating: '5.0',
    asset: 'assets/pp6.png',
  ),
  _BuddyEntry(id: 'Ori', name: 'Ori', rating: '5.0', asset: 'assets/pp7.png'),
  _BuddyEntry(
    id: 'shaxral',
    name: 'shaxral',
    rating: '4.0',
    asset: 'assets/pp1.png',
  ),
];
