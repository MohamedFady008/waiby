import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_sidebar.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/waiby_footer.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  double _budsBalance = 0;

  Future<void> _buyPack(_RechargePack pack) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmPurchaseDialog(pack: pack),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _budsBalance += pack.totalBuds);
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
                      child: _RechargeBody(
                        budsBalance: _budsBalance,
                        onBuyTap: _buyPack,
                      ),
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
  final ValueChanged<_RechargePack> onBuyTap;

  const _RechargeBody({required this.budsBalance, required this.onBuyTap});

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
            SizedBox(height: compact ? 28 : 42),
            if (wideLayout)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _RechargeGrid(
                      packs: nonFeaturedPacks,
                      onBuyTap: onBuyTap,
                    ),
                  ),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 290,
                    child: _FeaturedRechargeCard(
                      pack: featuredPack,
                      onBuyTap: onBuyTap,
                    ),
                  ),
                ],
              )
            else ...[
              _RechargeGrid(packs: nonFeaturedPacks, onBuyTap: onBuyTap),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: _FeaturedRechargeCard(
                  pack: featuredPack,
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
  final ValueChanged<_RechargePack> onBuyTap;

  const _RechargeGrid({required this.packs, required this.onBuyTap});

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
                  child: _RechargePackCard(pack: pack, onBuyTap: onBuyTap),
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
  final ValueChanged<_RechargePack> onBuyTap;

  const _RechargePackCard({required this.pack, required this.onBuyTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 303 / 223,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

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
                          label: 'Buy ${pack.priceLabel}',
                          onTap: () => onBuyTap(pack),
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
  final ValueChanged<_RechargePack> onBuyTap;

  const _FeaturedRechargeCard({required this.pack, required this.onBuyTap});

  @override
  Widget build(BuildContext context) {
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
                    label: 'Buy ${pack.priceLabel}',
                    onTap: () => onBuyTap(pack),
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
  final VoidCallback onTap;

  const _FeaturedBuyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}

class _BuyChipButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const _BuyChipButton({
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
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
  final String priceLabel;
  final bool isFeatured;

  const _RechargePack({
    required this.id,
    required this.buds,
    required this.priceLabel,
    this.bonusBuds = 0,
    this.isFeatured = false,
  });

  double get totalBuds => buds + bonusBuds;

  String get budsLabel => _formatBuds(buds);
  String get bonusLabel => _formatBuds(bonusBuds);
  String get totalBudsLabel => _formatBuds(totalBuds);
}

String _formatBuds(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

const List<_RechargePack> _rechargePacks = <_RechargePack>[
  _RechargePack(id: 'mini', buds: 9.99, priceLabel: '10.00\$'),
  _RechargePack(id: 'small', buds: 30, priceLabel: '30.00\$'),
  _RechargePack(id: 'medium', buds: 250, bonusBuds: 5, priceLabel: '250.00\$'),
  _RechargePack(id: 'large', buds: 500, bonusBuds: 10, priceLabel: '250.00\$'),
  _RechargePack(
    id: 'featured',
    buds: 100,
    bonusBuds: 2,
    priceLabel: '100.00\$',
    isFeatured: true,
  ),
];
