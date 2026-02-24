import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repository.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/common/responsive_layout.dart';
import '../data/models/profile_tab_models.dart';
import '../data/repositories/profile_tabs_repository.dart';

enum _ProfileTab { services, wishlist, gallery, posts }

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfileTab _selectedTab = _ProfileTab.services;
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  @override
  Widget build(BuildContext context) {
    final profileUserId = _resolveProfileUserId(widget.userId);
    final fallbackUserName = _resolveUserName(widget.userId);
    final isViewingOtherAccount = _isViewingOtherAccount(profileUserId);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showRail = width >= 1500;
        const railWidth = 76.0;
        const railInset = 8.0;
        const railGap = 12.0;
        final pagePadding = width >= 1200
            ? 28.0
            : waibyHorizontalPaddingForWidth(width);
        final railReserve = showRail ? railWidth + railInset + railGap : 0.0;
        final contentWidth = math.min(
          1380.0,
          math.max(0.0, width - (pagePadding * 2) - (railReserve * 2)),
        );

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B1230), Color(0xFF040816)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _BackdropGlow()),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  pagePadding + railReserve,
                  18,
                  pagePadding + railReserve,
                  36,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: profileUserId == null
                        ? _ProfileBody(
                            userName: fallbackUserName,
                            profileUserId: null,
                            width: width,
                            isViewingOtherAccount: isViewingOtherAccount,
                            selectedTab: _selectedTab,
                            onSelectTab: (tab) =>
                                setState(() => _selectedTab = tab),
                          )
                        : StreamBuilder<UserProfile?>(
                            stream: _userProfileRepository.watchById(
                              profileUserId,
                            ),
                            builder: (context, snapshot) {
                              final resolvedName = snapshot.data?.fullName
                                  ?.trim();
                              final userName =
                                  resolvedName != null &&
                                      resolvedName.isNotEmpty
                                  ? resolvedName
                                  : fallbackUserName;

                              return _ProfileBody(
                                userName: userName,
                                profileUserId: profileUserId,
                                width: width,
                                isViewingOtherAccount: isViewingOtherAccount,
                                selectedTab: _selectedTab,
                                onSelectTab: (tab) =>
                                    setState(() => _selectedTab = tab),
                              );
                            },
                          ),
                  ),
                ),
              ),
              if (showRail)
                const Positioned(
                  right: railInset,
                  top: 10,
                  bottom: 10,
                  child: _RightRail(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final String userName;
  final String? profileUserId;
  final double width;
  final bool isViewingOtherAccount;
  final _ProfileTab selectedTab;
  final ValueChanged<_ProfileTab> onSelectTab;

  const _ProfileBody({
    required this.userName,
    required this.profileUserId,
    required this.width,
    required this.isViewingOtherAccount,
    required this.selectedTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = width >= 1260;
    final tablet = width >= 920 && !desktop;

    final middleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ServiceDetailsCard(profileUserId: profileUserId),
        const SizedBox(height: 14),
        _ReviewsCard(profileUserId: profileUserId),
      ],
    );

    final servicesLayout = desktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 280,
                child: _ServicesMenuPanel(profileUserId: profileUserId),
              ),
              const SizedBox(width: 20),
              Expanded(child: middleColumn),
              const SizedBox(width: 20),
              SizedBox(
                width: 310,
                child: _ActionPanel(
                  isViewingOtherAccount: isViewingOtherAccount,
                ),
              ),
            ],
          )
        : tablet
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 242,
                    child: _ServicesMenuPanel(profileUserId: profileUserId),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: middleColumn),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 310,
                  child: _ActionPanel(
                    isViewingOtherAccount: isViewingOtherAccount,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ServicesMenuPanel(profileUserId: profileUserId),
              const SizedBox(height: 12),
              _ServiceDetailsCard(profileUserId: profileUserId),
              const SizedBox(height: 12),
              _ActionPanel(isViewingOtherAccount: isViewingOtherAccount),
              const SizedBox(height: 12),
              _ReviewsCard(profileUserId: profileUserId),
            ],
          );

    Widget tabBody;
    switch (selectedTab) {
      case _ProfileTab.services:
        tabBody = servicesLayout;
        break;
      case _ProfileTab.wishlist:
        tabBody = _WishlistTabContent(
          isViewingOtherAccount: isViewingOtherAccount,
          profileUserId: profileUserId,
        );
        break;
      case _ProfileTab.gallery:
        tabBody = _GalleryTabContent(
          isViewingOtherAccount: isViewingOtherAccount,
          profileUserId: profileUserId,
        );
        break;
      case _ProfileTab.posts:
        tabBody = _PostsTabContent(
          isViewingOtherAccount: isViewingOtherAccount,
          profileUserId: profileUserId,
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Hero(userName: userName, isViewingOtherAccount: isViewingOtherAccount),
        const SizedBox(height: 22),
        _Tabs(selectedTab: selectedTab, onSelect: onSelectTab),
        const SizedBox(height: 16),
        tabBody,
      ],
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    Widget orb(double size, Color color) => Container(
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
            left: -260,
            top: -220,
            child: orb(860, const Color(0x442977FF)),
          ),
          Positioned(
            right: -300,
            top: 100,
            child: orb(980, const Color(0x223EA2FF)),
          ),
          Positioned(
            left: -340,
            bottom: -340,
            child: orb(1120, const Color(0x332244D6)),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String userName;
  final bool isViewingOtherAccount;

  const _Hero({required this.userName, required this.isViewingOtherAccount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 760;
        final veryWide = width >= 1120;
        final avatarSize = compact ? 96.0 : 138.0;
        final viewerActionsWidth = math.max(
          240.0,
          math.min(340.0, width * 0.30),
        );

        return Container(
          height: compact ? 330 : 248,
          decoration: BoxDecoration(
            color: const Color(0xFF050C20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.36),
                blurRadius: 28,
                spreadRadius: -10,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                const Color(0xFF173B67),
                                const Color(0xFF0A163A),
                                const Color(0xFF091335).withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: compact ? 152 : 86,
                        color: const Color(0xFF050B23),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        stops: const [0.5, 0.77, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? 18 : 24,
                  right: compact ? 18 : 24,
                  bottom: compact ? 18 : 16,
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ProfileAvatar(size: avatarSize),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _ProfileIdentity(
                                    userName: userName,
                                    compact: true,
                                    isViewingOtherAccount:
                                        isViewingOtherAccount,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            isViewingOtherAccount
                                ? const _VisitorHeroActions(compact: true)
                                : const _HeroActions(compact: true),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _ProfileAvatar(size: avatarSize),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _ProfileIdentity(
                                userName: userName,
                                compact: !veryWide,
                                showActionsUnderBio: !veryWide,
                                isViewingOtherAccount: isViewingOtherAccount,
                              ),
                            ),
                            if (veryWide) ...[
                              const SizedBox(width: 16),
                              isViewingOtherAccount
                                  ? SizedBox(
                                      width: viewerActionsWidth,
                                      child: const _VisitorHeroActions(
                                        compact: false,
                                      ),
                                    )
                                  : const _HeroActions(compact: false),
                            ],
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

class _ProfileAvatar extends StatelessWidget {
  final double size;

  const _ProfileAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFA2D0), width: 3),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/pp6.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF213258),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: size * 0.48,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/medals/lolita_pearl.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  final String userName;
  final bool compact;
  final bool showActionsUnderBio;
  final bool isViewingOtherAccount;

  const _ProfileIdentity({
    required this.userName,
    required this.compact,
    this.showActionsUnderBio = false,
    required this.isViewingOtherAccount,
  });

  @override
  Widget build(BuildContext context) {
    final nameSize = compact ? 31.0 : 37.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: nameSize,
                  letterSpacing: -0.3,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x222BD760),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2BD760)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2BD760),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Online',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'GMT+01:00 - Espanol/English - 44 Served - 5.0 Rating',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.74),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 12.5 : 13.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'From Asia to ur heart, drop an order! Always wholesome.',
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 14 : 16,
            height: 1.28,
          ),
        ),
        if (showActionsUnderBio) ...[
          const SizedBox(height: 10),
          isViewingOtherAccount
              ? const _VisitorHeroActions(compact: true)
              : const _HeroActions(compact: true),
        ],
      ],
    );
  }
}

class _VisitorHeroActions extends StatelessWidget {
  final bool compact;

  const _VisitorHeroActions({required this.compact});

  @override
  Widget build(BuildContext context) {
    final iconPanelWidth = compact ? 72.0 : 84.0;
    final iconPanelHeight = compact ? 34.0 : 36.0;
    final iconSize = compact ? 18.0 : 20.0;
    final subscribeHeight = compact ? 42.0 : 46.0;
    final subscribeInset = compact ? 0.0 : iconPanelWidth + 8;

    Widget topRow() {
      return Row(
        children: [
          SizedBox(
            width: iconPanelWidth,
            height: iconPanelHeight,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.block_rounded, color: Colors.red, size: iconSize),
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: const Color(0xFF34E36D),
                  size: iconSize,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                '5 Following  70 Followers  200 Visitors',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11.5 : 12.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget subscribeButton() {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF33E665).withValues(alpha: 0.58),
              blurRadius: 18,
              spreadRadius: 1.2,
            ),
            BoxShadow(
              color: const Color(0xFF4AF57C).withValues(alpha: 0.34),
              blurRadius: 30,
              spreadRadius: 2.2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showSubscribeDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: subscribeHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF42CA64), Color(0xFF67E07E)],
                ),
              ),
              child: Text(
                'Subscribe 20% OFF',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 16 : 18,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        topRow(),
        SizedBox(height: compact ? 8 : 10),
        Padding(
          padding: EdgeInsets.only(left: subscribeInset),
          child: subscribeButton(),
        ),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  final bool compact;

  const _HeroActions({required this.compact});

  @override
  Widget build(BuildContext context) {
    final statsChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        '5 Following  70 Followers  200 Visitors',
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.92),
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11.5 : 12.5,
        ),
      ),
    );

    Widget iconButton(IconData icon) => Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );

    if (compact) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          statsChip,
          iconButton(Icons.ios_share_outlined),
          iconButton(Icons.open_in_new_rounded),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        statsChip,
        const SizedBox(width: 8),
        iconButton(Icons.ios_share_outlined),
        const SizedBox(width: 6),
        iconButton(Icons.open_in_new_rounded),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  final _ProfileTab selectedTab;
  final ValueChanged<_ProfileTab> onSelect;

  const _Tabs({required this.selectedTab, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (_ProfileTab.services, 'Services'),
      (_ProfileTab.wishlist, 'Wishlist'),
      (_ProfileTab.gallery, 'Gallery'),
      (_ProfileTab.posts, 'Posts'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            _TabButton(
              label: tabs[i].$2,
              active: selectedTab == tabs[i].$1,
              onTap: () => onSelect(tabs[i].$1),
            ),
            if (i < tabs.length - 1) const SizedBox(width: 18),
          ],
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: active
                ? const Border(
                    bottom: BorderSide(color: Colors.white, width: 2),
                  )
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: active ? 1 : 0.85),
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

enum _WishlistSubtab { wishes, gifters }

class _WishlistTabContent extends StatefulWidget {
  final bool isViewingOtherAccount;
  final String? profileUserId;

  const _WishlistTabContent({
    required this.isViewingOtherAccount,
    required this.profileUserId,
  });

  @override
  State<_WishlistTabContent> createState() => _WishlistTabContentState();
}

class _WishlistTabContentState extends State<_WishlistTabContent> {
  _WishlistSubtab _selectedSubtab = _WishlistSubtab.wishes;
  final ProfileTabsRepository _repository = ProfileTabsRepository();

  Future<void> _handleCreateWish() async {
    final profileUserId = widget.profileUserId;
    if (profileUserId == null || profileUserId.trim().isEmpty) {
      _showProfileDataUnavailable(context);
      return;
    }

    final draft = await _showAddWishDialog(context);
    if (draft == null) {
      return;
    }

    try {
      await _repository.createWishlistItem(
        profileUserId,
        ProfileWishlistItem(
          id: '',
          title: draft.title,
          subtitle: draft.subtitle,
          price: draft.price,
          progress: 0,
          imageAsset: 'assets/login.png',
          highlighted: draft.highlighted,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showProfileActionError(context, 'Failed to save wish.');
    }
  }

  Future<void> _handleEditWish(_WishlistItem item) async {
    final profileUserId = widget.profileUserId;
    if (profileUserId == null ||
        profileUserId.trim().isEmpty ||
        item.id == null) {
      _showProfileDataUnavailable(context);
      return;
    }

    final draft = await _showEditWishDialog(context, item);
    if (draft == null) {
      return;
    }

    try {
      await _repository.updateWishlistItem(
        profileUserId,
        item.id!,
        title: draft.title,
        subtitle: draft.subtitle,
        price: draft.price,
        highlighted: draft.highlighted,
      );
    } catch (_) {
      if (!mounted) return;
      _showProfileActionError(context, 'Failed to update wish.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final addWishButton = SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: _handleCreateWish,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5AD977),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
        child: Text(
          'Add Wish',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compactToolbar = constraints.maxWidth < 760;

            final subtabRow = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _WishlistSubtabButton(
                  label: 'Wishes',
                  active: _selectedSubtab == _WishlistSubtab.wishes,
                  onTap: () =>
                      setState(() => _selectedSubtab = _WishlistSubtab.wishes),
                ),
                const SizedBox(width: 10),
                _WishlistSubtabButton(
                  label: 'Gifters',
                  active: _selectedSubtab == _WishlistSubtab.gifters,
                  onTap: () =>
                      setState(() => _selectedSubtab = _WishlistSubtab.gifters),
                ),
              ],
            );

            if (compactToolbar) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  subtabRow,
                  if (!widget.isViewingOtherAccount &&
                      _selectedSubtab == _WishlistSubtab.wishes) ...[
                    const SizedBox(height: 10),
                    addWishButton,
                  ],
                ],
              );
            }

            return Row(
              children: [
                subtabRow,
                const Spacer(),
                if (!widget.isViewingOtherAccount &&
                    _selectedSubtab == _WishlistSubtab.wishes)
                  addWishButton,
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (_selectedSubtab == _WishlistSubtab.wishes)
          _WishesGrid(
            isViewingOtherAccount: widget.isViewingOtherAccount,
            profileUserId: widget.profileUserId,
            repository: _repository,
            onEditWish: _handleEditWish,
          )
        else
          const _GiftersGrid(),
      ],
    );
  }
}

class _WishlistSubtabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _WishlistSubtabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF3A4263) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _WishesGrid extends StatelessWidget {
  final bool isViewingOtherAccount;
  final String? profileUserId;
  final ProfileTabsRepository repository;
  final ValueChanged<_WishlistItem> onEditWish;

  const _WishesGrid({
    required this.isViewingOtherAccount,
    required this.profileUserId,
    required this.repository,
    required this.onEditWish,
  });

  @override
  Widget build(BuildContext context) {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      return const _EmptyProfileTab(
        title: 'Wishlist',
        message: 'Sign in to load wishlist items.',
      );
    }

    return StreamBuilder<List<ProfileWishlistItem>>(
      stream: repository.watchWishlist(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _EmptyProfileTab(
            title: 'Wishlist',
            message: 'Could not load wishlist data right now.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ProfileTabLoading();
        }

        final items = (snapshot.data ?? const <ProfileWishlistItem>[])
            .map(_WishlistItem.fromProfileWishlistItem)
            .toList();

        if (items.isEmpty) {
          return const _EmptyProfileTab(
            title: 'Wishlist',
            message: 'No wishes posted yet.',
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 20.0;
            final maxWidth = constraints.maxWidth;
            final columns = maxWidth >= 1560
                ? 4
                : maxWidth >= 1160
                ? 3
                : maxWidth >= 760
                ? 2
                : 1;
            final cardWidth = (maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final item in items)
                  SizedBox(
                    width: cardWidth,
                    child: _WishCard(
                      item: item,
                      isViewingOtherAccount: isViewingOtherAccount,
                      onEdit: isViewingOtherAccount
                          ? null
                          : () => onEditWish(item),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GiftersGrid extends StatelessWidget {
  const _GiftersGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_gifterEntries.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'No gifters yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        }

        const horizontalSpacing = 16.0;
        const verticalSpacing = 8.0;
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 620 ? 2 : 1;
        final gridWidth = columns == 2 ? math.min(640.0, maxWidth) : maxWidth;
        final cardWidth =
            (gridWidth - (horizontalSpacing * (columns - 1))) / columns;

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: gridWidth,
            child: Wrap(
              spacing: horizontalSpacing,
              runSpacing: verticalSpacing,
              children: [
                for (final entry in _gifterEntries)
                  SizedBox(
                    width: cardWidth,
                    child: _GifterCard(entry: entry),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GifterCard extends StatelessWidget {
  final _GifterEntry entry;

  const _GifterCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _GifterAvatar(entry: entry),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.96),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contributed with ${entry.budsLabel} Buds',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.6,
                    height: 1.25,
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

class _GifterAvatar extends StatelessWidget {
  final _GifterEntry entry;

  const _GifterAvatar({required this.entry});

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Icon(entry.avatarIcon, color: entry.avatarIconColor, size: 30),
    );

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: entry.avatarBackground,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipOval(
        child: entry.avatarAsset == null
            ? fallback
            : Image.asset(
                entry.avatarAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

Future<_WishDraft?> _showAddWishDialog(BuildContext context) {
  return showDialog<_WishDraft>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => const _AddWishDialog(),
  );
}

Future<_WishDraft?> _showEditWishDialog(
  BuildContext context,
  _WishlistItem item,
) {
  return showDialog<_WishDraft>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => _EditWishDialog(item: item),
  );
}

void _showProfileDataUnavailable(BuildContext context) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Profile is not ready for editing yet.',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFFAD2E2E),
    ),
  );
}

void _showProfileActionError(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFFAD2E2E),
    ),
  );
}

class _WishDraft {
  final String title;
  final String subtitle;
  final int price;
  final bool highlighted;

  const _WishDraft({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.highlighted,
  });
}

Future<void> _showSubscribeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.74),
    builder: (context) => const _SubscribeDialog(),
  );
}

class _SubscribeDialog extends StatefulWidget {
  const _SubscribeDialog();

  @override
  State<_SubscribeDialog> createState() => _SubscribeDialogState();
}

class _SubscribeDialogState extends State<_SubscribeDialog> {
  static const _availableBalance = 9.99;

  int _selectedPlanMonths = 3;
  bool _autoRenewFromBuds = false;

  _SubscriptionPlan get _selectedPlan => _subscriptionPlans.firstWhere(
    (plan) => plan.months == _selectedPlanMonths,
    orElse: () => _subscriptionPlans[1],
  );

  String _money(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final viewportSize = MediaQuery.sizeOf(context);
    final compact = viewportSize.width < 920;
    final total = _selectedPlan.price;
    final lowBalance = total > _availableBalance;
    final dialogWidth = compact ? 760.0 : 860.0;

    Widget perkRow(_SubscriptionPerk perk) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF2D8FFF),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  perk.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.94),
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 19 : 21,
                    height: 1.08,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              perk.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.76),
                fontWeight: FontWeight.w500,
                fontSize: compact ? 14 : 15,
                height: 1.22,
              ),
            ),
          ],
        ),
      );
    }

    Widget planCard(_SubscriptionPlan plan) {
      final selected = plan.months == _selectedPlanMonths;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedPlanMonths = plan.months),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 154),
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF0A2B2F).withValues(alpha: 0.8)
                  : const Color(0xFF121F46),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF45DD7E)
                    : Colors.white.withValues(alpha: 0.14),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  plan.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFF62A6FF),
                      size: 20,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _money(plan.price),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.98),
                        fontWeight: FontWeight.w700,
                        fontSize: 35,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Renews every ${plan.renewDays} days',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 26,
        vertical: 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: viewportSize.height - 24,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: dialogWidth,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF010A2B),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3F91FF), Color(0xFF194A95)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 136,
                            height: 136,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.65),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/pp6.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFF214A88),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white70,
                                    size: 52,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'LaKimi',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w700,
                              fontSize: 38,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Unlock exclusive perks',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.96),
                              fontWeight: FontWeight.w600,
                              fontSize: compact ? 30 : 34,
                              height: 1.07,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                color: Color(0xFF62A6FF),
                                size: 28,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '9.99/Month 20% OFF',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.96),
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 26 : 29,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Billed every 20 days + Cancel anytime',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontWeight: FontWeight.w500,
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 18 : 26,
                        24,
                        compact ? 18 : 26,
                        20,
                      ),
                      color: const Color(0xFF010829),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Discounted Session Prices',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: compact ? 30 : 33,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Enjoy 20% OFF when booking this Buddy's services",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: compact ? 14 : 15,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 22),
                          for (final perk in _subscriptionPerks) perkRow(perk),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.12),
                            thickness: 1,
                          ),
                          const SizedBox(height: 22),
                          if (compact)
                            Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < _subscriptionPlans.length;
                                  i++
                                ) ...[
                                  planCard(_subscriptionPlans[i]),
                                  if (i < _subscriptionPlans.length - 1)
                                    const SizedBox(height: 10),
                                ],
                              ],
                            )
                          else
                            Row(
                              children: [
                                for (
                                  var i = 0;
                                  i < _subscriptionPlans.length;
                                  i++
                                ) ...[
                                  Expanded(
                                    child: planCard(_subscriptionPlans[i]),
                                  ),
                                  if (i < _subscriptionPlans.length - 1)
                                    const SizedBox(width: 12),
                                ],
                              ],
                            ),
                          const SizedBox(height: 34),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(
                                () => _autoRenewFromBuds = !_autoRenewFromBuds,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                          color: const Color(0xFF55DA7A),
                                          width: 2.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _autoRenewFromBuds
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Color(0xFF55DA7A),
                                              size: 18,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Auto-renew using available Buds balance',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withValues(
                                                alpha: 0.92,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17.5,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'You can disable this anytime in dashboard',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withValues(
                                                alpha: 0.66,
                                              ),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.8,
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
                          SizedBox(height: compact ? 42 : 150),
                          Divider(
                            color: Colors.white.withValues(alpha: 0.12),
                            thickness: 1,
                          ),
                          const SizedBox(height: 18),
                          if (compact) ...[
                            Text(
                              'Total: ${_money(total)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.93),
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Balance: ',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.93),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  _money(_availableBalance),
                                  style: GoogleFonts.poppins(
                                    color: lowBalance
                                        ? const Color(0xFFE55757)
                                        : const Color(0xFF5AD977),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Recharge',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF3FA1FF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF3D9BFF,
                                        ).withValues(alpha: 0.85),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3D95FF),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Confirm and Pay',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Total: ',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withValues(
                                              alpha: 0.94,
                                            ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 35,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.monetization_on_rounded,
                                          color: Color(0xFF62A6FF),
                                          size: 28,
                                        ),
                                        Text(
                                          _money(total),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withValues(
                                              alpha: 0.95,
                                            ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          'Balance: ',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withValues(
                                              alpha: 0.94,
                                            ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 36,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.monetization_on_rounded,
                                          color: Color(0xFF62A6FF),
                                          size: 26,
                                        ),
                                        Text(
                                          _money(_availableBalance),
                                          style: GoogleFonts.poppins(
                                            color: lowBalance
                                                ? const Color(0xFFE55757)
                                                : const Color(0xFF5AD977),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 36,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Recharge',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF3FA1FF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 31,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 112,
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: const Color(
                                          0xFF3D9BFF,
                                        ).withValues(alpha: 0.85),
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3D95FF),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Confirm and Pay',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
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
}

class _AddWishDialog extends StatefulWidget {
  const _AddWishDialog();

  @override
  State<_AddWishDialog> createState() => _AddWishDialogState();
}

class _AddWishDialogState extends State<_AddWishDialog> {
  final _wishNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _highlight = false;

  _WishDraft? _buildDraft() {
    final title = _wishNameController.text.trim();
    final subtitle = _descriptionController.text.trim();
    final normalizedPrice = _priceController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final parsedPrice = int.tryParse(normalizedPrice);

    if (title.isEmpty || parsedPrice == null || parsedPrice <= 0) {
      _showProfileActionError(
        context,
        'Enter a title and a valid price to save this wish.',
      );
      return null;
    }

    return _WishDraft(
      title: title,
      subtitle: subtitle,
      price: parsedPrice,
      highlighted: _highlight,
    );
  }

  @override
  void dispose() {
    _wishNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF7B7E86),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFC6CAD3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final compact = viewportWidth < 760;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: BoxConstraints(maxWidth: compact ? 680 : 740),
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7E7),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DialogImagePlaceholder(compact: compact),
                        const SizedBox(height: 14),
                        _DialogWishInputs(
                          compact: compact,
                          wishNameController: _wishNameController,
                          priceController: _priceController,
                          fieldDecoration: _fieldDecoration,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DialogImagePlaceholder(compact: compact),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogWishInputs(
                            compact: compact,
                            wishNameController: _wishNameController,
                            priceController: _priceController,
                            fieldDecoration: _fieldDecoration,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 14),
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                  fontSize: compact ? 20 : 24,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                minLines: 1,
                maxLines: 2,
                decoration: _fieldDecoration(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF101010),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF17D00),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Read the Wishlist - Purpose & Rules before posting',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFF17D00),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        fontSize: compact ? 18 : 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _highlight = !_highlight);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _highlight
                            ? const Color(0xFF1B4A9A)
                            : const Color(0xFF163A78),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Highlight',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final draft = _buildDraft();
                        if (draft == null) {
                          return;
                        }
                        Navigator.of(context).pop(draft);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F81EE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      _wishNameController.clear();
                      _priceController.clear();
                      _descriptionController.clear();
                    },
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Color(0xFFFE0000),
                      size: 34,
                    ),
                    splashRadius: 20,
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

class _EditWishDialog extends StatefulWidget {
  final _WishlistItem item;

  const _EditWishDialog({required this.item});

  @override
  State<_EditWishDialog> createState() => _EditWishDialogState();
}

class _EditWishDialogState extends State<_EditWishDialog> {
  late final TextEditingController _wishNameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _highlight = false;

  @override
  void initState() {
    super.initState();
    _wishNameController = TextEditingController(text: widget.item.title);
    _priceController = TextEditingController(text: '${widget.item.price}');
    _descriptionController = TextEditingController(text: widget.item.subtitle);
    _highlight = widget.item.highlighted;
  }

  @override
  void dispose() {
    _wishNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _WishDraft? _buildDraft() {
    final title = _wishNameController.text.trim();
    final subtitle = _descriptionController.text.trim();
    final normalizedPrice = _priceController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final parsedPrice = int.tryParse(normalizedPrice);

    if (title.isEmpty || parsedPrice == null || parsedPrice <= 0) {
      _showProfileActionError(
        context,
        'Enter a title and a valid price to save this wish.',
      );
      return null;
    }

    return _WishDraft(
      title: title,
      subtitle: subtitle,
      price: parsedPrice,
      highlighted: _highlight,
    );
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF7B7E86),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFC6CAD3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final compact = viewportWidth < 760;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: BoxConstraints(maxWidth: compact ? 680 : 740),
        decoration: BoxDecoration(
          color: const Color(0xFFE7E7E7),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DialogImageAsset(
                          compact: compact,
                          asset: widget.item.imageAsset,
                          imageUrl: widget.item.imageUrl,
                        ),
                        const SizedBox(height: 14),
                        _DialogWishInputs(
                          compact: compact,
                          wishNameController: _wishNameController,
                          priceController: _priceController,
                          fieldDecoration: _fieldDecoration,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DialogImageAsset(
                          compact: compact,
                          asset: widget.item.imageAsset,
                          imageUrl: widget.item.imageUrl,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogWishInputs(
                            compact: compact,
                            wishNameController: _wishNameController,
                            priceController: _priceController,
                            fieldDecoration: _fieldDecoration,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 14),
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111111),
                  fontWeight: FontWeight.w500,
                  fontSize: compact ? 20 : 24,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                minLines: 1,
                maxLines: 2,
                decoration: _fieldDecoration(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF101010),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFF17D00),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Started wishes cannot be edited or deleted until completion',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFF17D00),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        fontSize: compact ? 18 : 19,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _highlight = !_highlight);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _highlight
                            ? const Color(0xFF1B4A9A)
                            : const Color(0xFF163A78),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Highlight',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final draft = _buildDraft();
                        if (draft == null) {
                          return;
                        }
                        Navigator.of(context).pop(draft);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F81EE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      _wishNameController.clear();
                      _priceController.clear();
                      _descriptionController.clear();
                    },
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Color(0xFFFE0000),
                      size: 34,
                    ),
                    splashRadius: 20,
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

class _DialogImagePlaceholder extends StatelessWidget {
  final bool compact;

  const _DialogImagePlaceholder({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 320,
      height: compact ? 180 : 236,
      decoration: BoxDecoration(
        color: const Color(0xFF9E9E9E),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.add_photo_alternate_outlined,
        color: Colors.white.withValues(alpha: 0.85),
        size: compact ? 38 : 46,
      ),
    );
  }
}

class _DialogImageAsset extends StatelessWidget {
  final bool compact;
  final String asset;
  final String? imageUrl;

  const _DialogImageAsset({
    required this.compact,
    required this.asset,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 320,
      height: compact ? 180 : 236,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF9E9E9E),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: compact ? 38 : 46,
                ),
              ),
            )
          : Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF9E9E9E),
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: compact ? 38 : 46,
                ),
              ),
            ),
    );
  }
}

class _ProfileTabLoading extends StatelessWidget {
  const _ProfileTabLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF060E2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}

class _GalleryPostDraft {
  final String? imageUrl;
  final String? imageAsset;
  final bool isPrivate;

  const _GalleryPostDraft({
    required this.imageUrl,
    required this.imageAsset,
    required this.isPrivate,
  });
}

Future<_GalleryPostDraft?> _showAddGalleryPostDialog(BuildContext context) {
  return showDialog<_GalleryPostDraft>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => const _AddGalleryPostDialog(),
  );
}

class _AddGalleryPostDialog extends StatefulWidget {
  const _AddGalleryPostDialog();

  @override
  State<_AddGalleryPostDialog> createState() => _AddGalleryPostDialogState();
}

class _AddGalleryPostDialogState extends State<_AddGalleryPostDialog> {
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _imageAssetController = TextEditingController(
    text: 'assets/pp6.png',
  );
  bool _isPrivate = false;

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageAssetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A1435),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Gallery Post',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageAssetController,
                decoration: InputDecoration(
                  labelText: 'Fallback asset path',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
                activeThumbColor: const Color(0xFF56D97A),
                title: Text(
                  'Private post (subscribers)',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final imageUrl = _imageUrlController.text.trim();
                      final imageAsset = _imageAssetController.text.trim();
                      if (imageUrl.isEmpty && imageAsset.isEmpty) {
                        _showProfileActionError(
                          context,
                          'Add an image URL or fallback asset path.',
                        );
                        return;
                      }
                      Navigator.of(context).pop(
                        _GalleryPostDraft(
                          imageUrl: imageUrl.isEmpty ? null : imageUrl,
                          imageAsset: imageAsset.isEmpty ? null : imageAsset,
                          isPrivate: _isPrivate,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF56D97A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
}

class _DialogWishInputs extends StatelessWidget {
  final bool compact;
  final TextEditingController wishNameController;
  final TextEditingController priceController;
  final InputDecoration Function({String? hintText}) fieldDecoration;

  const _DialogWishInputs({
    required this.compact,
    required this.wishNameController,
    required this.priceController,
    required this.fieldDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Wish name',
          style: GoogleFonts.poppins(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 24 : 26,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: wishNameController,
          decoration: fieldDecoration(),
          style: GoogleFonts.poppins(
            color: const Color(0xFF101010),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Price',
          style: GoogleFonts.poppins(
            color: const Color(0xFF111111),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 24 : 26,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFF4B7FE8),
              size: 38,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: fieldDecoration(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF101010),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WishCard extends StatelessWidget {
  final _WishlistItem item;
  final bool isViewingOtherAccount;
  final VoidCallback? onEdit;

  const _WishCard({
    required this.item,
    required this.isViewingOtherAccount,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(
                aspectRatio: 1.95,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFD0D0D0),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                      )
                    : Image.asset(
                        item.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFD0D0D0),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF6A6A6A),
                          ),
                        ),
                      ),
              ),
            ),
            if (item.highlighted) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BBB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Highlighted',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF101010),
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Color(0xFF4B7FE8),
                      size: 23,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${item.price}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF101010),
                        fontWeight: FontWeight.w700,
                        fontSize: 41,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6C6C6C),
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          minHeight: 20,
                          backgroundColor: const Color(0xFFD2D2D2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF4BCE6D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${(item.progress * 100).round()}%',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isViewingOtherAccount) ...[
                      IconButton(
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        splashRadius: 18,
                        icon: const Icon(
                          Icons.settings,
                          color: Color(0xFF080808),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    SizedBox(
                      width: 86,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F81EE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isViewingOtherAccount ? 'Contribute' : 'Invite',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTabContent extends StatelessWidget {
  final bool isViewingOtherAccount;
  final String? profileUserId;
  final ProfileTabsRepository _repository = ProfileTabsRepository();

  _GalleryTabContent({
    required this.isViewingOtherAccount,
    required this.profileUserId,
  });

  Future<void> _handleAddGalleryPost(BuildContext context) async {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      _showProfileDataUnavailable(context);
      return;
    }

    final draft = await _showAddGalleryPostDialog(context);
    if (!context.mounted) {
      return;
    }
    if (draft == null) {
      return;
    }

    try {
      await _repository.createGalleryPost(
        userId,
        ProfileGalleryItem(
          id: '',
          imageAsset: draft.imageAsset ?? 'assets/pp6.png',
          imageUrl: draft.imageUrl,
          isPrivate: draft.isPrivate,
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showProfileActionError(context, 'Failed to add gallery post.');
    }
  }

  Future<void> _handleDeleteGalleryPost(
    BuildContext context,
    String postId,
  ) async {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      _showProfileDataUnavailable(context);
      return;
    }

    try {
      await _repository.deleteGalleryPost(userId, postId);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showProfileActionError(context, 'Failed to remove gallery post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isViewingOtherAccount) ...[
          const _GalleryLockedHeader(),
          const SizedBox(height: 26),
          _GalleryGrid(
            showDeleteBadge: false,
            includePrivate: false,
            profileUserId: profileUserId,
            repository: _repository,
          ),
        ] else ...[
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                onPressed: () => _handleAddGalleryPost(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56D97A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Text(
                  'Add Post',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _GalleryGrid(
            showDeleteBadge: true,
            includePrivate: true,
            profileUserId: profileUserId,
            repository: _repository,
            onDelete: (itemId) => _handleDeleteGalleryPost(context, itemId),
          ),
        ],
      ],
    );
  }
}

class _GalleryLockedHeader extends StatelessWidget {
  const _GalleryLockedHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Subscribe to unlock all private moments from this creator',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
            fontSize: 23,
          ),
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF33E665).withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 1.2,
              ),
            ],
          ),
          child: SizedBox(
            width: 210,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _showSubscribeDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56D97A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Subscribe',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final bool showDeleteBadge;
  final bool includePrivate;
  final String? profileUserId;
  final ProfileTabsRepository repository;
  final ValueChanged<String>? onDelete;

  const _GalleryGrid({
    required this.showDeleteBadge,
    required this.includePrivate,
    required this.profileUserId,
    required this.repository,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      return const _EmptyProfileTab(
        title: 'Gallery',
        message: 'Profile gallery is not available.',
      );
    }

    return StreamBuilder<List<ProfileGalleryItem>>(
      stream: repository.watchGallery(userId, includePrivate: includePrivate),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _EmptyProfileTab(
            title: 'Gallery',
            message: 'Could not load gallery right now.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _ProfileTabLoading();
        }

        final items = (snapshot.data ?? const <ProfileGalleryItem>[])
            .map(_GalleryItem.fromProfileGalleryItem)
            .toList();
        if (items.isEmpty) {
          return const _EmptyProfileTab(
            title: 'Gallery',
            message: 'No gallery posts yet.',
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 22.0;
            final maxWidth = constraints.maxWidth;
            final columns = maxWidth >= 1240
                ? 4
                : maxWidth >= 940
                ? 3
                : maxWidth >= 620
                ? 2
                : 1;
            final cardWidth = (maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final item in items)
                  SizedBox(
                    width: cardWidth,
                    child: _GalleryCard(
                      item: item,
                      showDeleteBadge: showDeleteBadge,
                      onDelete: item.id == null
                          ? null
                          : () => onDelete?.call(item.id!),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final _GalleryItem item;
  final bool showDeleteBadge;
  final VoidCallback? onDelete;

  const _GalleryCard({
    required this.item,
    required this.showDeleteBadge,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AspectRatio(
          aspectRatio: 0.77,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFF0A1536)),
              ),
              item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 34,
                        ),
                      ),
                    )
                  : Image.asset(
                      item.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 34,
                        ),
                      ),
                    ),
              if (item.overlayAsset != null) ...[
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: item.overlayWidthFactor,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.asset(
                        item.overlayAsset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
              if (showDeleteBadge)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE01E2F),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 9,
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
  }
}

class _PostsTabContent extends StatelessWidget {
  final bool isViewingOtherAccount;
  final String? profileUserId;
  final ProfileTabsRepository _repository = ProfileTabsRepository();

  _PostsTabContent({
    required this.isViewingOtherAccount,
    required this.profileUserId,
  });

  Future<void> _handleCreatePost(BuildContext context) async {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      _showProfileDataUnavailable(context);
      return;
    }

    final draft = await _showCreatePostDialog(context);
    if (!context.mounted) {
      return;
    }
    if (draft == null) {
      return;
    }

    try {
      await _repository.createPost(
        userId,
        ProfilePostEntry(
          id: '',
          text: draft.text,
          imageUrl: draft.imageUrl,
          imageAsset: draft.imageAsset,
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showProfileActionError(context, 'Failed to publish post.');
    }
  }

  Future<void> _handleDeletePost(BuildContext context, String postId) async {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      _showProfileDataUnavailable(context);
      return;
    }

    try {
      await _repository.deletePost(userId, postId);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showProfileActionError(context, 'Failed to remove post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      return const _EmptyProfileTab(
        title: 'Posts',
        message: 'Profile posts are not available.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isViewingOtherAccount)
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => _handleCreatePost(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56D97A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Create Post',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        if (!isViewingOtherAccount) const SizedBox(height: 12),
        StreamBuilder<List<ProfilePostEntry>>(
          stream: _repository.watchPosts(userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _EmptyProfileTab(
                title: 'Posts',
                message: 'Could not load posts right now.',
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _ProfileTabLoading();
            }

            final posts = snapshot.data ?? const <ProfilePostEntry>[];
            if (posts.isEmpty) {
              return const _EmptyProfileTab(
                title: 'Posts',
                message: 'No posts yet.',
              );
            }

            return Column(
              children: [
                for (final post in posts) ...[
                  _PostCard(
                    post: post,
                    onDelete: isViewingOtherAccount
                        ? null
                        : () => _handleDeletePost(context, post.id),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final ProfilePostEntry post;
  final VoidCallback? onDelete;

  const _PostCard({required this.post, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060E2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatPostDate(post.createdAt),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE05161),
                  ),
                  splashRadius: 20,
                ),
            ],
          ),
          if (post.text.trim().isNotEmpty)
            Text(
              post.text,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          if (post.text.trim().isNotEmpty) const SizedBox(height: 10),
          if ((post.imageUrl?.isNotEmpty ?? false) ||
              (post.imageAsset?.isNotEmpty ?? false))
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: (post.imageUrl?.isNotEmpty ?? false)
                    ? Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _postImageFallback(),
                      )
                    : Image.asset(
                        post.imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _postImageFallback(),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _postImageFallback() {
    return Container(
      color: const Color(0xFF17254F),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white54,
      ),
    );
  }
}

class _CreatePostDraft {
  final String text;
  final String? imageUrl;
  final String? imageAsset;

  const _CreatePostDraft({required this.text, this.imageUrl, this.imageAsset});
}

Future<_CreatePostDraft?> _showCreatePostDialog(BuildContext context) {
  return showDialog<_CreatePostDraft>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => const _CreatePostDialog(),
  );
}

class _CreatePostDialog extends StatefulWidget {
  const _CreatePostDialog();

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _imageAssetController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    _imageAssetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A1435),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Post',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Post text',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL (optional)',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _imageAssetController,
                decoration: InputDecoration(
                  labelText: 'Fallback asset path (optional)',
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final text = _textController.text.trim();
                      final imageUrl = _imageUrlController.text.trim();
                      final imageAsset = _imageAssetController.text.trim();
                      if (text.isEmpty &&
                          imageUrl.isEmpty &&
                          imageAsset.isEmpty) {
                        _showProfileActionError(
                          context,
                          'Post text or image is required.',
                        );
                        return;
                      }

                      Navigator.of(context).pop(
                        _CreatePostDraft(
                          text: text,
                          imageUrl: imageUrl.isEmpty ? null : imageUrl,
                          imageAsset: imageAsset.isEmpty ? null : imageAsset,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF56D97A),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Publish',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
}

String _formatPostDate(DateTime? value) {
  if (value == null) {
    return 'Just now';
  }
  final local = value.toLocal();
  final month = _monthLabel(local.month);
  return '$month ${local.day}, ${local.year}';
}

String _monthLabel(int month) {
  const labels = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) {
    return 'Jan';
  }
  return labels[month - 1];
}

class _EmptyProfileTab extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyProfileTab({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF060E2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.74),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesMenuPanel extends StatelessWidget {
  final String? profileUserId;
  final ProfileTabsRepository _repository = ProfileTabsRepository();

  _ServicesMenuPanel({required this.profileUserId});

  @override
  Widget build(BuildContext context) {
    final userId = profileUserId?.trim();

    Widget servicesList(List<_ServiceItem> items) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF060E2B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _ServiceTile(item: items[i]),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
            ],
          ],
        ),
      );
    }

    Widget content;
    if (userId == null || userId.isEmpty) {
      content = servicesList(_services);
    } else {
      content = StreamBuilder<List<ProfileServiceItem>>(
        stream: _repository.watchServices(userId),
        builder: (context, snapshot) {
          final backendItems = (snapshot.data ?? const <ProfileServiceItem>[])
              .map(_ServiceItem.fromProfileServiceItem)
              .toList();
          final resolved = backendItems.isEmpty ? _services : backendItems;
          return servicesList(resolved);
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x120A1A45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              'Services',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 31,
                height: 1,
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _ServiceItem item;

  const _ServiceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: item.selected ? const Color(0xFF2D3448) : Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 25),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 21,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.price}/${item.unit}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1,
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

class _ServiceDetailsCard extends StatelessWidget {
  final String? profileUserId;
  final ProfileTabsRepository _repository = ProfileTabsRepository();

  _ServiceDetailsCard({required this.profileUserId});

  @override
  Widget build(BuildContext context) {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      final defaultService = _services.firstWhere(
        (item) => item.selected,
        orElse: () => _services.first,
      );
      return _buildCard(defaultService, defaultService.options);
    }

    return StreamBuilder<List<ProfileServiceItem>>(
      stream: _repository.watchServices(userId),
      builder: (context, snapshot) {
        final backendItems = (snapshot.data ?? const <ProfileServiceItem>[])
            .map(_ServiceItem.fromProfileServiceItem)
            .toList();
        final resolvedItems = backendItems.isEmpty ? _services : backendItems;
        final selectedService = resolvedItems.firstWhere(
          (item) => item.selected,
          orElse: () => resolvedItems.first,
        );
        return _buildCard(selectedService, selectedService.options);
      },
    );
  }

  Widget _buildCard(
    _ServiceItem selectedService,
    List<_ServiceOption> options,
  ) {
    final resolvedDescription = selectedService.description.trim().isEmpty
        ? 'If you are looking for a chill and open-minded talking companion, '
              'I am your girl. I am always ready to hear your stories and share mine too.'
        : selectedService.description;
    final resolvedOptions = options.isEmpty ? _options : options;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060E2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedService.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 37,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${selectedService.servedCount} Served - '
                        '${selectedService.ratingPercent}% Rating',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F86F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 6,
                child: selectedService.bannerImageUrl != null
                    ? Image.network(
                        selectedService.bannerImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _serviceImageFallback(),
                      )
                    : Image.asset(
                        selectedService.bannerImageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _serviceImageFallback(),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              resolvedDescription,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
                height: 1.45,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Column(
              children: [
                for (var i = 0; i < resolvedOptions.length; i++) ...[
                  _OptionTile(item: resolvedOptions[i]),
                  if (i < resolvedOptions.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceImageFallback() {
    return Container(
      color: const Color(0xFF1A274D),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white54, size: 40),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _ServiceOption item;

  const _OptionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.brightness_1,
                color: Color(0xFF57A0FF),
                size: 12,
              ),
              const SizedBox(width: 6),
              Text(
                '${item.price}/${item.unit}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  final String? profileUserId;
  final ProfileTabsRepository _repository = ProfileTabsRepository();

  _ReviewsCard({required this.profileUserId});

  @override
  Widget build(BuildContext context) {
    final userId = profileUserId?.trim();
    if (userId == null || userId.isEmpty) {
      return _buildCard(_reviews);
    }

    return StreamBuilder<List<ProfileReviewEntry>>(
      stream: _repository.watchReviews(userId),
      builder: (context, snapshot) {
        final backendReviews = (snapshot.data ?? const <ProfileReviewEntry>[])
            .map(_ReviewEntry.fromProfileReviewEntry)
            .toList();
        final resolved = backendReviews.isEmpty ? _reviews : backendReviews;
        return _buildCard(resolved);
      },
    );
  }

  Widget _buildCard(List<_ReviewEntry> entries) {
    final totalReviews = entries.length;
    final averageRating = entries.isEmpty
        ? 0
        : entries
                  .map((entry) => entry.rating)
                  .reduce((value, element) => value + element) /
              entries.length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060E2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Reviews $totalReviews',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 33,
                    ),
                  ),
                  TextSpan(
                    text: '  -  ${averageRating.toStringAsFixed(1)} Rating',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < entries.length; i++) ...[
              _ReviewTile(entry: entries[i]),
              if (i < entries.length - 1) const SizedBox(height: 14),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF243D73),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '1',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '1  ...  10  11',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
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

class _ReviewTile extends StatelessWidget {
  final _ReviewEntry entry;

  const _ReviewTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: ClipOval(
            child: entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty
                ? Image.network(
                    entry.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _reviewAvatarFallback(),
                  )
                : Image.asset(
                    entry.avatarAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _reviewAvatarFallback(),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.name}  -  ${entry.date}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.83),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${entry.rating.toStringAsFixed(1)}  ${entry.title}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9BEA64),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.text,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontWeight: FontWeight.w500,
                  fontSize: 11.8,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewAvatarFallback() {
    return Container(
      color: const Color(0xFF1E2E5A),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, color: Colors.white70, size: 18),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final bool isViewingOtherAccount;

  const _ActionPanel({required this.isViewingOtherAccount});

  @override
  Widget build(BuildContext context) {
    final buttonText = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF060E2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: Image.asset(
                    'assets/pp6.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF253A63),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white70,
                        size: 46,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Chat', style: buttonText),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58D56E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Order |->', style: buttonText),
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                Icons.info_outline,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        if (!isViewingOtherAccount) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.go('/settings?tab=services'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF58D56E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Edit service',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const ChatSidebar(
          width: 76,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 8),
          avatarSize: 48,
          frameSize: 66,
          itemSpacing: 12,
          unreadBadgeSize: 20,
          unreadBadgeFontSize: 11,
        ),
      ),
    );
  }
}

bool _isViewingOtherAccount(String? targetUserId) {
  final normalizedTarget = targetUserId?.trim();
  if (normalizedTarget == null || normalizedTarget.isEmpty) {
    return false;
  }

  if (!Get.isRegistered<AuthController>()) {
    return true;
  }

  final auth = Get.find<AuthController>();
  final currentId = auth.userId.trim();
  if (currentId.isEmpty || currentId == 'U-00000') {
    return true;
  }

  return normalizedTarget != currentId;
}

String? _resolveProfileUserId(String? raw) {
  final routeId = _resolveTargetUserId(raw);
  if (routeId != null) {
    return routeId;
  }

  if (!Get.isRegistered<AuthController>()) {
    return null;
  }

  final auth = Get.find<AuthController>();
  final currentId = auth.userId.trim();
  if (currentId.isEmpty || currentId == 'U-00000') {
    return null;
  }
  return currentId;
}

String? _resolveTargetUserId(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  try {
    final decoded = Uri.decodeComponent(trimmed).trim();
    return decoded.isEmpty ? null : decoded;
  } catch (_) {
    return trimmed;
  }
}

String _resolveUserName(String? raw) {
  final normalized = _resolveTargetUserId(raw);
  if (normalized != null) {
    return normalized;
  }

  if (Get.isRegistered<AuthController>()) {
    final name = Get.find<AuthController>().userName.trim();
    if (name.isNotEmpty && name != 'User') {
      return name;
    }
  }

  return 'LaKimi';
}

class _ServiceItem {
  final String title;
  final String price;
  final String unit;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final bool selected;
  final int servedCount;
  final int ratingPercent;
  final String description;
  final String bannerImageAsset;
  final String? bannerImageUrl;
  final List<_ServiceOption> options;

  const _ServiceItem({
    required this.title,
    required this.price,
    required this.unit,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.selected = false,
    this.servedCount = 0,
    this.ratingPercent = 0,
    this.description = '',
    this.bannerImageAsset = 'assets/login.png',
    this.bannerImageUrl,
    this.options = const <_ServiceOption>[],
  });

  factory _ServiceItem.fromProfileServiceItem(ProfileServiceItem item) {
    final parsedOptions = item.options
        .map(_ServiceOption.fromProfileServiceOption)
        .toList();
    return _ServiceItem(
      title: item.title,
      price: item.price,
      unit: item.unit,
      icon: _iconFromKey(item.iconKey),
      iconBackground: Color(item.iconBackgroundColor),
      iconColor: Color(item.iconColor),
      selected: item.selected,
      servedCount: item.servedCount,
      ratingPercent: item.ratingPercent,
      description: item.description,
      bannerImageAsset: item.bannerImageAsset,
      bannerImageUrl: item.bannerImageUrl,
      options: parsedOptions.isEmpty ? _options : parsedOptions,
    );
  }
}

class _ServiceOption {
  final String label;
  final String price;
  final String unit;

  const _ServiceOption({
    required this.label,
    required this.price,
    required this.unit,
  });

  factory _ServiceOption.fromProfileServiceOption(ProfileServiceOption option) {
    return _ServiceOption(
      label: option.label,
      price: option.price,
      unit: option.unit,
    );
  }
}

IconData _iconFromKey(String key) {
  switch (key.trim().toLowerCase()) {
    case 'chat':
    case 'chat_rounded':
      return Icons.chat_rounded;
    case 'shield':
    case 'shield_moon':
      return Icons.shield_moon_rounded;
    case 'gift':
    case 'redeem':
      return Icons.redeem_rounded;
    case 'triangle':
    case 'change_history':
      return Icons.change_history_rounded;
    case 'game':
    case 'sports_esports':
      return Icons.sports_esports_rounded;
    case 'magic':
    case 'sparkles':
    case 'tarot':
      return Icons.auto_awesome_rounded;
    default:
      return Icons.miscellaneous_services_rounded;
  }
}

class _ReviewEntry {
  final String name;
  final String date;
  final String title;
  final String text;
  final double rating;
  final String avatarAsset;
  final String? avatarUrl;

  const _ReviewEntry({
    required this.name,
    required this.date,
    required this.title,
    required this.text,
    this.rating = 5,
    this.avatarAsset = 'assets/pp6.png',
    this.avatarUrl,
  });

  factory _ReviewEntry.fromProfileReviewEntry(ProfileReviewEntry entry) {
    return _ReviewEntry(
      name: entry.name,
      date: _formatPostDate(entry.createdAt),
      title: entry.title,
      text: entry.text,
      rating: entry.rating,
      avatarAsset: entry.avatarAsset,
      avatarUrl: entry.avatarUrl,
    );
  }
}

class _WishlistItem {
  final String? id;
  final String title;
  final String subtitle;
  final int price;
  final double progress;
  final String imageAsset;
  final String? imageUrl;
  final bool highlighted;

  const _WishlistItem({
    this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.progress,
    required this.imageAsset,
    this.imageUrl,
    this.highlighted = false,
  });

  factory _WishlistItem.fromProfileWishlistItem(ProfileWishlistItem item) {
    return _WishlistItem(
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      price: item.price,
      progress: item.progress,
      imageAsset: item.imageAsset,
      imageUrl: item.imageUrl,
      highlighted: item.highlighted,
    );
  }
}

class _GalleryItem {
  final String? id;
  final String imageAsset;
  final String? imageUrl;
  final String? overlayAsset;
  final double overlayWidthFactor;
  final bool isPrivate;

  const _GalleryItem({
    this.id,
    required this.imageAsset,
    this.imageUrl,
    this.overlayAsset,
    this.overlayWidthFactor = 0.42,
    this.isPrivate = false,
  });

  factory _GalleryItem.fromProfileGalleryItem(ProfileGalleryItem item) {
    return _GalleryItem(
      id: item.id,
      imageAsset: item.imageAsset,
      imageUrl: item.imageUrl,
      overlayAsset: item.overlayAsset,
      overlayWidthFactor: item.overlayWidthFactor,
      isPrivate: item.isPrivate,
    );
  }
}

class _SubscriptionPlan {
  final int months;
  final double price;
  final int renewDays;
  final String title;

  const _SubscriptionPlan({
    required this.months,
    required this.price,
    required this.renewDays,
    required this.title,
  });
}

class _SubscriptionPerk {
  final String title;
  final String description;

  const _SubscriptionPerk({required this.title, required this.description});
}

class _GifterEntry {
  final String name;
  final String budsLabel;
  final String? avatarAsset;
  final IconData avatarIcon;
  final Color avatarBackground;
  final Color avatarIconColor;

  const _GifterEntry({
    required this.name,
    required this.budsLabel,
    this.avatarAsset,
    this.avatarIcon = Icons.person_rounded,
    this.avatarBackground = const Color(0xFF1A2A55),
    this.avatarIconColor = Colors.white,
  });
}

const _subscriptionPlans = <_SubscriptionPlan>[
  _SubscriptionPlan(
    months: 1,
    price: 9.99,
    renewDays: 30,
    title: '1 Month Access',
  ),
  _SubscriptionPlan(
    months: 3,
    price: 29.97,
    renewDays: 30,
    title: '3 Months Access',
  ),
  _SubscriptionPlan(
    months: 12,
    price: 119.88,
    renewDays: 30,
    title: '12 Months Access',
  ),
];

const _subscriptionPerks = <_SubscriptionPerk>[
  _SubscriptionPerk(
    title: 'Unlimited Private Messages',
    description:
        'Chat freely without restrictions while your subscription is active',
  ),
  _SubscriptionPerk(
    title: 'Members-Only Content',
    description:
        'Access exclusive albums and posts available only to subscribers',
  ),
  _SubscriptionPerk(
    title: 'Priority Notifications',
    description:
        'Be the first to know about new Live Rooms, updates, and special announcements',
  ),
];

const _gifterEntries = <_GifterEntry>[
  _GifterEntry(
    name: 'issacthetuff',
    budsLabel: '10',
    avatarAsset: 'assets/pp7.png',
  ),
  _GifterEntry(name: 'itsfam', budsLabel: '5', avatarAsset: 'assets/pp6.png'),
  _GifterEntry(
    name: 'Hidden',
    budsLabel: '5.67',
    avatarIcon: Icons.visibility_off_rounded,
    avatarBackground: Color(0xFFB8F35A),
    avatarIconColor: Color(0xFF244F1C),
  ),
  _GifterEntry(
    name: 'issacthetuff',
    budsLabel: '10',
    avatarAsset: 'assets/pp7.png',
  ),
];

const _services = <_ServiceItem>[
  _ServiceItem(
    title: 'Echat',
    price: '7.99',
    unit: '15 Min',
    icon: Icons.chat_rounded,
    iconBackground: Color(0xFF5A90F8),
    iconColor: Color(0xFF06163A),
    selected: true,
    servedCount: 4,
    ratingPercent: 100,
    description:
        'If you are looking for a chill and open-minded talking companion, '
        'I am your girl. I am always ready to hear your stories and share mine too.',
    bannerImageAsset: 'assets/login.png',
    options: _options,
  ),
  _ServiceItem(
    title: 'League Of Legends',
    price: '4.99',
    unit: 'Game',
    icon: Icons.shield_moon_rounded,
    iconBackground: Color(0xFFD6A748),
    iconColor: Color(0xFF1A152C),
  ),
  _ServiceItem(
    title: 'Watch Together',
    price: '22.22',
    unit: 'Time',
    icon: Icons.redeem_rounded,
    iconBackground: Color(0xFFE74949),
    iconColor: Colors.white,
  ),
  _ServiceItem(
    title: 'Valorant',
    price: '6.99',
    unit: 'Game',
    icon: Icons.change_history_rounded,
    iconBackground: Color(0xFFFF3D49),
    iconColor: Color(0xFF360810),
  ),
  _ServiceItem(
    title: 'Teamfight Tactics',
    price: '4.99',
    unit: 'Game',
    icon: Icons.sports_esports_rounded,
    iconBackground: Color(0xFFD6A748),
    iconColor: Color(0xFF201028),
  ),
  _ServiceItem(
    title: 'Tarot',
    price: '4.99',
    unit: 'Game',
    icon: Icons.auto_awesome_rounded,
    iconBackground: Color(0xFFAF1CF4),
    iconColor: Color(0xFF190433),
  ),
];

const _options = <_ServiceOption>[
  _ServiceOption(label: 'Voice calling', price: '7.99', unit: '15 Min'),
  _ServiceOption(label: 'Video calling', price: '9.99', unit: '15 Min'),
  _ServiceOption(label: 'Texting', price: '2.99', unit: '15 Min'),
];

const _reviews = <_ReviewEntry>[
  _ReviewEntry(
    name: 'Hidden',
    date: 'Feb 15th, 2026',
    title: 'Great Service',
    text:
        'Very friendly and calm. Conversation flowed naturally and felt easy.',
    avatarAsset: 'assets/pp7.png',
  ),
  _ReviewEntry(
    name: 'kr****ny',
    date: 'Feb 10th, 2026',
    title: 'Amazing order',
    text:
        'She had a very nice conversation and definitely made my time worth it.',
    avatarAsset: 'assets/pp1.png',
  ),
  _ReviewEntry(
    name: 'kr****ny',
    date: 'Feb 10th, 2026',
    title: 'Fun session',
    text:
        'I was new to buddy chats, but this session was fun and very welcoming.',
    avatarAsset: 'assets/pp2.png',
  ),
  _ReviewEntry(
    name: 'So*****s',
    date: 'Jan 23rd, 2024',
    title: 'Was good',
    text: 'Solid experience overall and quick response time.',
    avatarAsset: 'assets/pp5.png',
  ),
];
