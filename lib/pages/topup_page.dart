import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/topup_checkout_service.dart';
import '../widgets/chat_sidebar.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/waiby_footer.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final TopupCheckoutService _checkoutService = TopupCheckoutService();

  String? _pendingPackId;
  bool _handledCheckoutReturnStatus = false;
  String? _syncedUserId;
  bool _syncingWalletBalance = false;
  TopupWalletSnapshot? _walletFallback;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledCheckoutReturnStatus) {
      return;
    }
    _handledCheckoutReturnStatus = true;
    _handleCheckoutReturnStatus();
  }

  Future<void> _buyPack(User user, _RechargePack pack) async {
    if (_pendingPackId != null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmPurchaseDialog(pack: pack),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _pendingPackId = pack.id);

    try {
      final topupPageUrl = _buildWebReturnUrl();
      final session = await _checkoutService.createCheckoutSession(
        packId: pack.id,
        successUrl: topupPageUrl,
        cancelUrl: topupPageUrl,
      );

      await _checkoutService.openCheckout(session.checkoutUrl);
      if (!kIsWeb && mounted) {
        _showSnackbar(
          'Stripe checkout opened in your browser. Your Buds balance updates after payment success.',
        );
      }
    } on TopupCheckoutException catch (error) {
      if (!mounted) return;
      _showSnackbar(error.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackbar('Could not start checkout. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _pendingPackId = null);
      }
    }
  }

  Uri? _buildWebReturnUrl() {
    if (!kIsWeb) {
      return null;
    }
    return Uri.base.replace(path: '/wallet/topup', query: null, fragment: null);
  }

  void _handleCheckoutReturnStatus() {
    final uri = GoRouterState.of(context).uri;
    final status = uri.queryParameters['status'];
    if (status == null || status.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_processCheckoutReturnStatus(uri));
    });
  }

  Future<void> _processCheckoutReturnStatus(Uri uri) async {
    if (!mounted) {
      return;
    }

    final checkoutStatus = (uri.queryParameters['status'] ?? '')
        .trim()
        .toLowerCase();
    switch (checkoutStatus) {
      case 'success':
        final sessionId = (uri.queryParameters['session_id'] ?? '').trim();
        if (sessionId.isEmpty) {
          _showSnackbar(
            'Payment submitted. Buds are added only after Stripe confirms success.',
            isError: false,
          );
          break;
        }

        try {
          final confirmation = await _checkoutService.confirmCheckoutSession(
            checkoutSessionId: sessionId,
          );
          if (!mounted) {
            return;
          }

          if (confirmation.fulfilled) {
            final addedBudsLabel = _formatBuds(confirmation.totalBuds);
            if (confirmation.wallet != null) {
              setState(() => _walletFallback = confirmation.wallet);
            } else {
              setState(() {
                _walletFallback = TopupWalletSnapshot(
                  budsBalance: confirmation.balanceBuds,
                  incomeBalanceUsd: _walletFallback?.incomeBalanceUsd ?? 0,
                  onHoldUsd: _walletFallback?.onHoldUsd ?? 0,
                  gemsBalance: _walletFallback?.gemsBalance ?? 0,
                  gemDustBalance: _walletFallback?.gemDustBalance ?? 0,
                );
              });
            }
            _showSnackbar(
              'Payment confirmed. $addedBudsLabel Buds were added successfully.',
              isError: false,
            );
            try {
              final syncedWallet = await _checkoutService.syncMyWallet();
              if (mounted) {
                setState(() => _walletFallback = syncedWallet);
              }
            } catch (_) {
              // Ignore temporary sync errors after successful confirmation.
            }
          } else {
            switch (confirmation.status) {
              case 'pending':
              case 'processing':
                _showSnackbar(
                  'Payment is processing. Buds will be added after Stripe confirms it.',
                  isError: false,
                );
                break;
              case 'failed':
              case 'cancelled':
              case 'expired':
                _showSnackbar(
                  'Payment was not successful (${confirmation.status}). No Buds were added.',
                );
                break;
              default:
                _showSnackbar('Payment status: ${confirmation.status}');
            }
          }
        } on TopupCheckoutException catch (error) {
          if (!mounted) {
            return;
          }
          _showSnackbar(error.message);
        } catch (_) {
          if (!mounted) {
            return;
          }
          _showSnackbar(
            'Could not confirm payment status yet. Please refresh.',
          );
        }
        break;
      case 'cancelled':
        _showSnackbar('Payment was cancelled. No Buds were added.');
        break;
      default:
        _showSnackbar('Payment status: $checkoutStatus');
    }

    if (!mounted) {
      return;
    }
    if (uri.queryParameters.isNotEmpty) {
      context.replace('/wallet/topup');
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB43A3A)
            : const Color(0xFF2E7D32),
      ),
    );
  }

  double _walletBalanceFromData(Map<String, dynamic>? data) {
    final raw = data?['buds_balance'] ?? data?['balance_buds'];
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw) ?? 0;
    }
    return 0;
  }

  Widget _buildRechargeBody() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          _syncedUserId = null;
          _walletFallback = null;
          return _RechargeBody(
            budsBalance: 0,
            pendingPackId: _pendingPackId,
            walletStreamIssue: false,
            onBuyTap: (_) {
              _showSnackbar('Please sign in before buying Buds.');
              context.go('/login');
            },
          );
        }

        _syncWalletBalanceOnce(user);

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('wallets')
              .doc(user.uid)
              .snapshots(includeMetadataChanges: true),
          builder: (context, walletSnapshot) {
            final walletDoc = walletSnapshot.data;
            final walletData = walletDoc?.data();
            final liveBudsBalance = _walletBalanceFromData(walletData);
            final hasLiveWalletData = walletDoc != null && walletData != null;
            final useFallback =
                _walletFallback != null &&
                (walletSnapshot.hasError ||
                    !hasLiveWalletData ||
                    walletDoc.metadata.isFromCache);
            final budsBalance = useFallback
                ? _walletFallback!.budsBalance
                : liveBudsBalance;

            return _RechargeBody(
              budsBalance: budsBalance,
              pendingPackId: _pendingPackId,
              walletStreamIssue: walletSnapshot.hasError,
              onBuyTap: (pack) => unawaited(_buyPack(user, pack)),
            );
          },
        );
      },
    );
  }

  void _syncWalletBalanceOnce(User user) {
    if (_syncingWalletBalance) {
      return;
    }
    if (_syncedUserId == user.uid) {
      return;
    }

    _syncedUserId = user.uid;
    _syncingWalletBalance = true;
    unawaited(() async {
      try {
        final syncedWallet = await _checkoutService.syncMyWallet();
        if (mounted) {
          setState(() => _walletFallback = syncedWallet);
        }
      } catch (_) {
        // Keep UI responsive even if sync endpoint is temporarily unavailable.
      } finally {
        _syncingWalletBalance = false;
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final showChatSidebar = screenWidth >= 1100;
        const sidebarWidth = 84.0;
        const sidebarGap = 12.0;
        final reservedSidebarSpace = showChatSidebar
            ? sidebarWidth + sidebarGap
            : 0.0;
        final horizontalPadding = waibyHorizontalPaddingForWidth(screenWidth);

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F1220), Color(0xFF050816)],
            ),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WaibyConstrainedContent(
                      maxWidth: 1320,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        56,
                        horizontalPadding + reservedSidebarSpace,
                        72,
                      ),
                      child: _buildRechargeBody(),
                    ),
                    const WaibyFooter(),
                  ],
                ),
              ),
              if (showChatSidebar)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: sidebarWidth,
                      height: math.max(360, constraints.maxHeight - 16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ChatSidebar(width: sidebarWidth),
                      ),
                    ),
                  ),
                ),
              if (showChatSidebar)
                Positioned(
                  right: sidebarWidth + 24,
                  top: constraints.maxHeight * 0.53,
                  child: const _FloatingChatButton(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RechargeBody extends StatelessWidget {
  final double budsBalance;
  final String? pendingPackId;
  final bool walletStreamIssue;
  final ValueChanged<_RechargePack> onBuyTap;

  const _RechargeBody({
    required this.budsBalance,
    required this.pendingPackId,
    required this.walletStreamIssue,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    final nonFeaturedPacks = _rechargePacks
        .where((pack) => !pack.isFeatured)
        .toList(growable: false);
    final featuredPack = _rechargePacks.firstWhere((pack) => pack.isFeatured);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < WaibyBreakpoints.mobile;
        final wideLayout = width >= 980;
        final titleSize = compact ? 38.0 : 46.0;
        final subtitleSize = compact ? 16.0 : 20.0;
        final checkoutInProgress = pendingPackId != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: 'Buds Balance: ',
                children: [
                  TextSpan(
                    text: budsBalance.toStringAsFixed(2),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF51D76E),
                      fontWeight: FontWeight.w700,
                      fontSize: titleSize,
                      height: 1.08,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
                height: 1.08,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Buds to unlock sessions with buddies and exclusive perks',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w500,
                fontSize: subtitleSize,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '1 USD = 1 Bud | 0% deposit fee | Buds are non-withdrawable',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.62),
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.2,
              ),
            ),
            if (walletStreamIssue) ...[
              const SizedBox(height: 10),
              Text(
                'Live wallet updates are temporarily unavailable. Showing server-synced balance.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFFD180),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
            if (checkoutInProgress) ...[
              const SizedBox(height: 14),
              Text(
                'Opening Stripe checkout...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF51D76E),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
            ],
            SizedBox(height: compact ? 28 : 42),
            if (wideLayout)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RechargeGrid(
                      packs: nonFeaturedPacks,
                      pendingPackId: pendingPackId,
                      onBuyTap: onBuyTap,
                    ),
                  ),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 290,
                    child: _FeaturedRechargeCard(
                      pack: featuredPack,
                      pendingPackId: pendingPackId,
                      onBuyTap: onBuyTap,
                    ),
                  ),
                ],
              )
            else ...[
              _RechargeGrid(
                packs: nonFeaturedPacks,
                pendingPackId: pendingPackId,
                onBuyTap: onBuyTap,
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: _FeaturedRechargeCard(
                  pack: featuredPack,
                  pendingPackId: pendingPackId,
                  onBuyTap: onBuyTap,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RechargeGrid extends StatelessWidget {
  final List<_RechargePack> packs;
  final String? pendingPackId;
  final ValueChanged<_RechargePack> onBuyTap;

  const _RechargeGrid({
    required this.packs,
    required this.pendingPackId,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final useTwoColumns = width >= 520;
        final spacing = 22.0;
        final idealWidth = useTwoColumns ? (width - spacing) / 2 : width;
        final cardWidth = idealWidth.clamp(220.0, 300.0).toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: packs
              .map(
                (pack) => SizedBox(
                  width: cardWidth,
                  child: _RechargePackCard(
                    pack: pack,
                    pendingPackId: pendingPackId,
                    onBuyTap: onBuyTap,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _RechargePackCard extends StatelessWidget {
  final _RechargePack pack;
  final String? pendingPackId;
  final ValueChanged<_RechargePack> onBuyTap;

  const _RechargePackCard({
    required this.pack,
    required this.pendingPackId,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 303 / 223,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final isThisPackPending = pendingPackId == pack.id;
          final isAnyPackPending = pendingPackId != null;

          return Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  'assets/small_voucher.svg',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    w * 0.1,
                    h * 0.12,
                    w * 0.1,
                    h * 0.18,
                  ),
                  child: const _DashedInnerFrame(radius: 5),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    w * 0.40,
                    h * 0.3,
                    w * 0.20,
                    h * 0.30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${pack.budsLabel} Buds',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD8D8FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: -0.24,
                          height: 1.08,
                        ),
                      ),
                      if (pack.bonusBuds > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '+${pack.bonusLabel}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: -0.2,
                            height: 1.08,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Divider(
                        color: const Color(0xFF202042).withValues(alpha: 0.85),
                        thickness: 1,
                        height: 1,
                      ),
                      SizedBox(height: h * 0.09),
                      SizedBox(
                        width: 116,
                        child: _BuyChipButton(
                          label: isThisPackPending
                              ? 'Processing...'
                              : 'Buy ${pack.priceLabel}',
                          onTap: isAnyPackPending ? null : () => onBuyTap(pack),
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FeaturedRechargeCard extends StatelessWidget {
  final _RechargePack pack;
  final String? pendingPackId;
  final ValueChanged<_RechargePack> onBuyTap;

  const _FeaturedRechargeCard({
    required this.pack,
    required this.pendingPackId,
    required this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isThisPackPending = pendingPackId == pack.id;
    final isAnyPackPending = pendingPackId != null;

    return AspectRatio(
      aspectRatio: 387 / 594,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset('assets/big_voucher.svg', fit: BoxFit.fill),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(64, 52, 64, 66),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(65, 64, 65, 72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Best\nValue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF5F5FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      letterSpacing: -0.45,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: const Color(0xFF202042).withValues(alpha: 0.75),
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${pack.budsLabel} Buds',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      letterSpacing: -0.35,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${pack.bonusLabel}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      letterSpacing: -0.2,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _FeaturedBuyButton(
                    label: isThisPackPending
                        ? 'Processing...'
                        : 'Buy ${pack.priceLabel}',
                    onTap: isAnyPackPending ? null : () => onBuyTap(pack),
                  ),
                  const SizedBox(height: 66),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBuyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FeaturedBuyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          width: 140,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0x006E5CFF), Color(0x1A7D6BFF), Color(0x339B7CFF)],
            ),
            border: Border.all(color: const Color(0x667D6BFF), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x338B5CFF),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.65,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.22,
                  height: 1.08,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuyChipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool compact;

  const _BuyChipButton({
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Ink(
          height: compact ? 30 : 26,
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: compact
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x002A2950), Color(0x591E1C3F)],
                  )
                : const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x006E5CFF),
                      Color(0x1A7D6BFF),
                      Color(0x339B7CFF),
                    ],
                  ),
            border: Border.all(color: const Color(0x664A4AFF), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: compact ? 10 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.65,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: compact ? -0.15 : -0.1,
                  height: 1.05,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedInnerFrame extends StatelessWidget {
  final double radius;

  const _DashedInnerFrame({this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedRectPainter(radius: radius));
  }
}

class _DashedRectPainter extends CustomPainter {
  final double radius;

  const _DashedRectPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.14);

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    const dashWidth = 5.0;
    const dashGap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}

class _FloatingChatButton extends StatelessWidget {
  const _FloatingChatButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF51D76E),
      ),
      child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
    );
  }
}

class _ConfirmPurchaseDialog extends StatelessWidget {
  final _RechargePack pack;

  const _ConfirmPurchaseDialog({required this.pack});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 647),
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 42, 30, 28),
          decoration: BoxDecoration(
            color: const Color(0xFF171C29),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm Your Purchase',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  letterSpacing: -0.3,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'You will recharge ${pack.totalBudsLabel} Buds in your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: -0.15,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Buds are platform prepaid credits and cannot be withdrawn or refunded to card.',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  letterSpacing: -0.1,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF3B834B), Color(0xFF51D76E)],
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      'Buy now',
                      style: GoogleFonts.notoSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        letterSpacing: -0.2,
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

class _RechargePack {
  final String id;
  final double buds;
  final double bonusBuds;
  final double priceUsd;
  final bool isFeatured;

  const _RechargePack({
    required this.id,
    required this.buds,
    required this.priceUsd,
    this.bonusBuds = 0,
    this.isFeatured = false,
  });

  double get totalBuds => buds + bonusBuds;

  String get budsLabel => _formatBuds(buds);
  String get bonusLabel => _formatBuds(bonusBuds);
  String get totalBudsLabel => _formatBuds(totalBuds);
  String get priceLabel => '${priceUsd.toStringAsFixed(2)}\$';
}

String _formatBuds(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

const List<_RechargePack> _rechargePacks = <_RechargePack>[
  _RechargePack(id: 'mini', buds: 9.99, priceUsd: 9.99),
  _RechargePack(id: 'small', buds: 30, priceUsd: 30),
  _RechargePack(id: 'medium', buds: 250, bonusBuds: 5, priceUsd: 250),
  _RechargePack(id: 'large', buds: 500, bonusBuds: 10, priceUsd: 500),
  _RechargePack(
    id: 'featured',
    buds: 100,
    bonusBuds: 2,
    priceUsd: 100,
    isFeatured: true,
  ),
];
