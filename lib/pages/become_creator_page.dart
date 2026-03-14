import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waiby/widgets/waiby_footer.dart';

import '../widgets/common/waiby_common.dart';

class BecomeCreatorPage extends StatelessWidget {
  const BecomeCreatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xFF0C0C13),
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1920),
                  child: Column(
                    children: const [
                      HeroSection(),
                      CreatorCards(),
                      HowItWorks(),
                      TrustSection(),
                      WaibyFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          right: 24,
          bottom: 24,
          child: SafeArea(child: SupportChatFab()),
        ),
      ],
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final appBarHeight = Scaffold.maybeOf(context)?.appBarMaxHeight ?? 0.0;
        final w = c.maxWidth;
        final h = (426.0 - appBarHeight).clamp(260.0, 426.0).toDouble();
        final isCompact = w < 1200;

        double sx(double designPx) => designPx * (w / 1920.0);
        double sy(double designPx) => designPx; // design is absolute px

        if (isCompact) {
          final padding = pageHorizontalPadding(w);
          final maxArtWidth = (w - (padding * 2)).clamp(280.0, 760.0);
          final artScale = (maxArtWidth / 593.0).clamp(0.55, 1.25);
          final artWidth = 593.0 * artScale;
          final artHeight = 326.0 * artScale;

          return Padding(
            padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Become a Waiby Creator",
                  style: GoogleFonts.notoSans(
                    fontSize: w < 700 ? 32 : 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: w < 700 ? w : 680),
                  child: Text(
                    "Play and meet new people. Become a Waiby buddy and earn by doing what you enjoy!",
                    style: GoogleFonts.notoSans(
                      fontSize: w < 700 ? 18 : 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                WaibyGradientButton(
                  width: w < 700 ? 190 : 209,
                  height: 44,
                  label: 'Apply as Creator',
                  onTap: () => context.go('/become-creator/creator-form'),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: artWidth,
                    height: artHeight + (42 * artScale),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -170 * artScale,
                          top: 112 * artScale,
                          child: FlippedBlurEllipse(
                            width: 1135 * artScale,
                            height: 223 * artScale,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: _HeroPanelsCluster(scale: artScale),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          );
        }

        return SizedBox(
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Ellipse 2 (behind cards)
              Positioned(
                left: sx(858),
                top: sy(143) - appBarHeight,
                child: FlippedBlurEllipse(width: sx(1135), height: sy(223)),
              ),

              // Left content
              Positioned(
                left: sx(140),
                top: sy(157) - appBarHeight,
                child: SizedBox(
                  width: sx(887),
                  child: Text(
                    "Become a Waiby Creator",
                    style: GoogleFonts.notoSans(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 49 / 36,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sx(140),
                top: sy(208) - appBarHeight,
                child: SizedBox(
                  width: sx(887),
                  child: Text(
                    "Play and meet new people. Become a Waiby buddy and earn by doing what you enjoy!",
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 27 / 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: sx(140),
                top: sy(299) - appBarHeight,
                child: WaibyGradientButton(
                  width: sx(209),
                  height: sy(44),
                  label: 'Apply as Creator',
                  onTap: () => context.go('/become-creator/creator-form'),
                ),
              ),

              Positioned(
                left: sx(1153),
                top: sy(64) - appBarHeight,
                child: _HeroPanelsCluster(scale: sx(351) / 351.0),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPanelsCluster extends StatelessWidget {
  const _HeroPanelsCluster({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 593 * scale,
      height: 326 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _PatternCard(w: 351 * scale, h: 319 * scale),
          ),
          Positioned(
            left: 242 * scale,
            top: 7 * scale,
            child: _PatternCard(
              w: 351 * scale,
              h: 319 * scale,
              variant: _PatternCardVariant.right,
            ),
          ),
          Positioned(
            left: 87 * scale,
            top: 68 * scale,
            child: _BunnyImage(
              asset: "assets/bunny1.png",
              cropAlignment: Alignment.centerRight,
              width: 176 * scale,
              height: 247 * scale,
            ),
          ),
          Positioned(
            left: 362 * scale,
            top: 30 * scale,
            child: _BunnyImage(
              asset: "assets/bunny2.png",
              cropAlignment: Alignment.centerLeft,
              width: 186 * scale,
              height: 296 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.w,
    required this.h,
    this.variant = _PatternCardVariant.left,
  });

  final double w;
  final double h;
  final _PatternCardVariant variant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      height: h,
      child: _SlantedStripePanel(width: w, height: h, variant: variant),
    );
  }
}

enum _PatternCardVariant { left, right }

class _SlantedStripePanel extends StatelessWidget {
  const _SlantedStripePanel({
    required this.width,
    required this.height,
    required this.variant,
  });

  final double width;
  final double height;
  final _PatternCardVariant variant;

  @override
  Widget build(BuildContext context) {
    // Figma/CSS positions place the second panel at x + 242 (351 - 109).
    // Use a slightly larger slant than 109px to create the visible gap between panels.
    final slant = width * 0.345;
    final noiseLeft = variant == _PatternCardVariant.left ? 0.4236 : 0.5503;
    final noiseRight = variant == _PatternCardVariant.left ? 0.1124 : -0.0143;
    final noiseTop = variant == _PatternCardVariant.left ? -0.1539 : -0.1502;
    final noiseBottom = variant == _PatternCardVariant.left ? 0.7079 : 0.7043;

    return SizedBox(
      width: width,
      height: height,
      child: ClipPath(
        clipper: _ParallelogramClipper(slant: slant),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _PatternPanelPainter(variant: variant)),
            CustomPaint(
              painter: _PanelStripesPainter(
                lineColor: const Color(0xFFB8FFB4).withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              left: width * noiseLeft,
              right: width * noiseRight,
              top: height * noiseTop,
              bottom: height * noiseBottom,
              child: Transform.rotate(
                angle: -1.19, // approx matrix(0.37, -0.93, 0.89, 0.46)
                child: Image.asset(
                  'assets/noise_lines.png',
                  fit: BoxFit.cover,
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.55),
                  colorBlendMode: BlendMode.screen,
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.14,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.05, 0.7),
                      radius: 1.05,
                      colors: [
                        const Color(0xFF38F8C4).withValues(alpha: 0.26),
                        const Color(0xFF2DF15D).withValues(alpha: 0.45),
                        const Color(0x002DF15D),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x120C0C13), Color(0x7A0C0C13)],
                  stops: [0.25, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternPanelPainter extends CustomPainter {
  const _PatternPanelPainter({required this.variant});

  final _PatternCardVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Rectangle 36 base (dark gradient)
    final basePaint = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF222430), Color(0xFF15161E)],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Rectangle 35 overlay (fade to darker center/bottom)
    final overlayPaint = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x001A1F29), Color(0xE60B1013), Color(0xFF0B1013)],
        stops: [0.0639, 0.4052, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, overlayPaint);

    final glowPaint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: const Alignment(-0.15, 0.82),
        radius: 1.05,
        colors: [
          const Color(0xFF47FFD1).withValues(alpha: 0.72),
          const Color(0xFF2BEE56).withValues(alpha: 0.64),
          const Color(0x0031E04A),
        ],
        stops: const [0.0, 0.52, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);

    // Blobs (blurred)
    final blob1 = _blobRect(
      size,
      left: variant == _PatternCardVariant.left ? 0.5502 : 0.677,
      right: variant == _PatternCardVariant.left ? 0.3032 : 0.1765,
      top: variant == _PatternCardVariant.left ? 0.0904 : 0.094,
      bottom: variant == _PatternCardVariant.left ? 0.7486 : 0.745,
    );
    final blob2 = _blobRect(
      size,
      left: variant == _PatternCardVariant.left ? 0.6708 : 0.7975,
      right: variant == _PatternCardVariant.left ? 0.2579 : 0.1312,
      top: variant == _PatternCardVariant.left ? 0.0824 : 0.086,
      bottom: variant == _PatternCardVariant.left ? 0.7362 : 0.7326,
    );
    final blob3 = _blobRect(
      size,
      left: variant == _PatternCardVariant.left ? 0.684 : 0.8107,
      right: variant == _PatternCardVariant.left ? 0.2324 : 0.1057,
      top: variant == _PatternCardVariant.left ? 0.0523 : 0.0559,
      bottom: variant == _PatternCardVariant.left ? 0.7663 : 0.7627,
    );

    _drawBlurOval(
      canvas,
      blob1,
      const Color(0xFF26AD7C),
      sigma: 36,
      blendMode: BlendMode.srcOver,
    );
    _drawBlurOval(
      canvas,
      blob2,
      const Color(0xFF2DB533),
      sigma: 36,
      blendMode: BlendMode.plus, // plus-lighter
    );
    _drawBlurOval(
      canvas,
      blob3,
      const Color(0xFF4EF154),
      sigma: 36,
      blendMode: BlendMode.overlay,
    );

    // Group highlight ellipses (subtle, blurred)
    _drawBlurOval(
      canvas,
      Rect.fromLTWH(32.29, 240.52, 313.09, 76.97),
      const Color(0xFFD9D9D9).withValues(alpha: 0.12),
      sigma: 29.3304,
      blendMode: BlendMode.screen,
    );
    _drawBlurOval(
      canvas,
      Rect.fromLTWH(96.41, 7.09, 272.26, 124.73),
      const Color(0xFFD9D9D9).withValues(alpha: 0.08),
      sigma: 29.3304,
      blendMode: BlendMode.screen,
    );

    // Rectangle 34628418 streak (blurred + overlay blend)
    canvas.save();
    canvas.translate(-113.72, -36.46);
    canvas.transform(
      Float64List.fromList([
        0.65, 0.76, 0, 0, //
        -0.71, 0.7, 0, 0, //
        0, 0, 1, 0, //
        0, 0, 0, 1, //
      ]),
    );
    final streakPaint = Paint()
      ..color = const Color(0xFFA7E328).withValues(alpha: 0.6)
      ..blendMode = BlendMode.overlay
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 37)
      ..isAntiAlias = true;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 68.48, 639.58), streakPaint);
    canvas.restore();

    // Rectangle 37 border strip
    final borderPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.8)
      ..blendMode = BlendMode.overlay
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..isAntiAlias = true;
    canvas.drawRect(Rect.fromLTWH(0, 0, 135.04, size.height), borderPaint);
  }

  static Rect _blobRect(
    Size size, {
    required double left,
    required double right,
    required double top,
    required double bottom,
  }) {
    final w = size.width;
    final h = size.height;
    final x = left * w;
    final y = top * h;
    final width = (1 - left - right) * w;
    final height = (1 - top - bottom) * h;
    return Rect.fromLTWH(x, y, width, height);
  }

  static void _drawBlurOval(
    Canvas canvas,
    Rect rect,
    Color color, {
    required double sigma,
    required BlendMode blendMode,
  }) {
    final paint = Paint()
      ..color = color
      ..blendMode = blendMode
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma)
      ..isAntiAlias = true;
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _PatternPanelPainter oldDelegate) {
    return oldDelegate.variant != variant;
  }
}

class _PanelStripesPainter extends CustomPainter {
  const _PanelStripesPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..isAntiAlias = true;

    const spacing = 14.0;
    for (double x = -size.height; x <= size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height * 0.38, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PanelStripesPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _ParallelogramClipper extends CustomClipper<Path> {
  const _ParallelogramClipper({required this.slant});

  final double slant;

  @override
  Path getClip(Size size) {
    final s = slant.clamp(0.0, size.width).toDouble();
    return Path()
      ..moveTo(s, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - s, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _ParallelogramClipper oldClipper) {
    return oldClipper.slant != slant;
  }
}

class FlippedBlurEllipse extends StatelessWidget {
  const FlippedBlurEllipse({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scaleX = width / height;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0), // matrix(1,0,0,-1)
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: ClipOval(
          child: SizedBox(
            width: width,
            height: height,
            child: OverflowBox(
              alignment: Alignment.center,
              minWidth: height,
              maxWidth: height,
              minHeight: height,
              maxHeight: height,
              child: Transform.scale(
                alignment: Alignment.center,
                scaleX: scaleX,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.488), // 50% 25.6%
                      radius: 0.744,
                      colors: [Color(0xFF1ABE2D), Color(0x0024214B)],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  child: SizedBox(width: height, height: height),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreatorCards extends StatelessWidget {
  const CreatorCards({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = pageHorizontalPadding(constraints.maxWidth);
        final spacing = constraints.maxWidth >= 1440 ? 85.0 : 24.0;
        final contentWidth = constraints.maxWidth - (padding * 2);
        final cardWidth = contentWidth < 340 ? contentWidth : 320.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What Waiby Creators do",
                style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 44 / 32,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: spacing,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: cardWidth,
                    height: 190,
                    child: const FeatureCard(
                      title: 'Play games with customers',
                      desc:
                          'Join games and interactive sessions with customers.',
                      icon: 'assets/play.png',
                      iconSize: Size(87, 60),
                      borderGradient: [Color(0xFF0C0C13), Color(0xFF4CC9FF)],
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: 190,
                    child: const FeatureCard(
                      title: 'Live Interaction',
                      desc:
                          'Chat, react and connect during sessions to create real engagement',
                      icon: 'assets/live.png',
                      iconSize: Size(72, 64),
                      borderGradient: [Color(0xFF0C0C13), Color(0xFFF8C34A)],
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: 190,
                    child: const FeatureCard(
                      title: 'Earn rewards & payouts',
                      desc:
                          'Get paid through orders, gifts and platform rewards.',
                      icon: 'assets/earn.png',
                      iconSize: Size(70, 71),
                      borderGradient: [Color(0xFF0C0C13), Color(0xFFB86BFF)],
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: 190,
                    child: const FeatureCard(
                      title: 'Level up & unlock perks',
                      desc:
                          'Gain visibility, animated frames and exclusive creator benefits as you grow',
                      icon: 'assets/level.png',
                      iconSize: Size(70, 69),
                      borderGradient: [Color(0xFF0C0C13), Color(0xFFC6FF5A)],
                    ),
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

class FeatureCard extends StatelessWidget {
  final String title;
  final String desc;
  final String icon;
  final Size iconSize;
  final List<Color> borderGradient;

  const FeatureCard({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    required this.iconSize,
    required this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final accent = borderGradient.last;
    return GradientBorderCard(
      borderColors: borderGradient,
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: RadialGradient(
            radius: 1.2,
            colors: [accent.withAlpha(64), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  icon,
                  width: iconSize.width,
                  height: iconSize.height,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              desc,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 20 / 13,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final List<Color> borderColors;

  const GradientBorderCard({
    super.key,
    required this.child,
    required this.borderColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: borderColors,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F1A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}

class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = pageHorizontalPadding(constraints.maxWidth);
        final contentWidth = constraints.maxWidth - (padding * 2);
        final isWide = contentWidth >= (360.0 * 4);
        final isCompact = constraints.maxWidth < 700;
        final topSpace = isWide ? 120.0 : 70.0;
        final stepWidth = isCompact ? contentWidth : 360.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topSpace),
              Text(
                "How it works",
                style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 44 / 32,
                ),
              ),
              const SizedBox(height: 28),
              if (isWide)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HowStep(
                      number: 1,
                      title: "Set up your account",
                      desc: "Sign up, select and add your services",
                    ),
                    _HowStep(
                      number: 2,
                      title: "Get orders",
                      desc: "Connect and get customers book you",
                    ),
                    _HowStep(
                      number: 3,
                      title: "Play & Engage",
                      desc: "Play, interact and complete sessions",
                    ),
                    _HowStep(
                      number: 4,
                      title: "Get paid",
                      desc: "Withdraw securely",
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _HowStep(
                      width: stepWidth,
                      compact: isCompact,
                      number: 1,
                      title: "Set up your account",
                      desc: "Sign up, select and add your services",
                    ),
                    _HowStep(
                      width: stepWidth,
                      compact: isCompact,
                      number: 2,
                      title: "Get orders",
                      desc: "Connect and get customers book you",
                    ),
                    _HowStep(
                      width: stepWidth,
                      compact: isCompact,
                      number: 3,
                      title: "Play & Engage",
                      desc: "Play, interact and complete sessions",
                    ),
                    _HowStep(
                      width: stepWidth,
                      compact: isCompact,
                      number: 4,
                      title: "Get paid",
                      desc: "Withdraw securely",
                    ),
                  ],
                ),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
    );
  }
}

class _HowStep extends StatelessWidget {
  final int number;
  final String title;
  final String desc;
  final double width;
  final bool compact;

  const _HowStep({
    required this.number,
    required this.title,
    required this.desc,
    this.width = 360,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 68 : 79,
            height: compact ? 68 : 79,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                "$number",
                style: GoogleFonts.inter(
                  fontSize: compact ? 34 : 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? 12 : 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 22 : 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 15 : 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
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

class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = pageHorizontalPadding(constraints.maxWidth);
        final contentWidth = (constraints.maxWidth - (padding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final showTwoColumns = contentWidth >= 980;
        final horizontalGap = showTwoColumns
            ? (contentWidth >= 1500 ? 99.0 : 32.0)
            : 0.0;
        final cardWidth = showTwoColumns
            ? (contentWidth - horizontalGap) / 2
            : contentWidth;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Trust & requirements",
                style: GoogleFonts.notoSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 44 / 32,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: horizontalGap,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: const _TrustBox(
                      title: "Requirements",
                      items: [
                        _TrustItem(
                          text: "18+ years old only",
                          type: _TrustItemType.check,
                        ),
                        _TrustItem(
                          text: "Completed registration",
                          type: _TrustItemType.check,
                        ),
                        _TrustItem(
                          text: "Mandatory ID & face verification",
                          type: _TrustItemType.check,
                        ),
                        _TrustItem(
                          text: "Follow community guidelines",
                          type: _TrustItemType.check,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const _TrustBox(
                      title: "Trust & Safety",
                      items: [
                        _TrustItem(
                          text: "Secure payments & withdrawals",
                          type: _TrustItemType.shield,
                        ),
                        _TrustItem(
                          text: "Identity-verified creators",
                          type: _TrustItemType.verified,
                        ),
                        _TrustItem(
                          text: "Block & report system",
                          type: _TrustItemType.report,
                        ),
                        _TrustItem(
                          text: "Privacy & safety tools",
                          type: _TrustItemType.privacy,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 198),
            ],
          ),
        );
      },
    );
  }
}

class _TrustBox extends StatelessWidget {
  final String title;
  final List<_TrustItem> items;

  const _TrustBox({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x7D1B234B),
            ), // rgba(27,35,75,0.49)
            boxShadow: const [
              BoxShadow(
                color: Color(0x33FFFFFF), // soft glow like drop-shadow
                blurRadius: 40,
                offset: Offset(0, 0),
              ),
            ],
            color: const Color(0xFF0B0F1A),
          ),
          padding: EdgeInsets.all(compact ? 18 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: compact ? 22 : 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0x7D1B234B), thickness: 0.5),
              for (var i = 0; i < items.length; i++) ...[
                _TrustRow(item: items[i], compact: compact),
                if (i != items.length - 1)
                  const Divider(
                    color: Color(0x7D1B234B),
                    thickness: 0.5,
                    height: 18,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

enum _TrustItemType { check, shield, verified, report, privacy }

class _TrustItem {
  final String text;
  final _TrustItemType type;
  const _TrustItem({required this.text, required this.type});
}

class _TrustRow extends StatelessWidget {
  final _TrustItem item;
  final bool compact;
  const _TrustRow({required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.text,
            style: GoogleFonts.poppins(
              fontSize: compact ? 20 : 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _TrustIcon(type: item.type, size: compact ? 20 : 22),
      ],
    );
  }
}

class _TrustIcon extends StatelessWidget {
  final _TrustItemType type;
  final double size;
  const _TrustIcon({required this.type, this.size = 22});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case _TrustItemType.check:
        icon = Icons.check_circle;
        color = const Color(0xFF51D76E);
        break;
      case _TrustItemType.shield:
        icon = Icons.shield_outlined;
        color = Colors.white;
        break;
      case _TrustItemType.verified:
        icon = Icons.verified;
        color = const Color(0xFF51D76E);
        break;
      case _TrustItemType.report:
        icon = Icons.report;
        color = const Color(0xFFFF0000);
        break;
      case _TrustItemType.privacy:
        icon = Icons.privacy_tip_outlined;
        color = Colors.white;
        break;
    }

    return Icon(icon, size: size, color: color);
  }
}

class FooterIcons extends StatelessWidget {
  const FooterIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: compact ? 24 : 34),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: compact ? 24 : 90,
            runSpacing: compact ? 16 : 0,
            children: const [
              _FooterIcon(
                icon: FontAwesomeIcons.google,
                iconColor: Color(0xFFEA4335),
                background: Colors.white,
              ),
              _FooterIcon(
                icon: FontAwesomeIcons.discord,
                iconColor: Colors.white,
                background: Color(0xFF5865F2),
              ),
              _FooterIcon(
                icon: FontAwesomeIcons.youtube,
                iconColor: Color(0xFFFF0000),
                background: Colors.white,
              ),
              _FooterIcon(
                icon: FontAwesomeIcons.xTwitter,
                iconColor: Colors.white,
                background: Color(0xFF101010),
              ),
              _FooterIcon(
                icon: FontAwesomeIcons.instagram,
                iconColor: Colors.white,
                backgroundGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF833AB4),
                    Color(0xFFF77737),
                    Color(0xFFE1306C),
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

class _FooterIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? background;
  final Gradient? backgroundGradient;

  const _FooterIcon({
    required this.icon,
    required this.iconColor,
    this.background,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: background,
        gradient: backgroundGradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: FaIcon(icon, size: 28, color: iconColor)),
    );
  }
}

class _BunnyImage extends StatelessWidget {
  final String asset;
  final Alignment cropAlignment;
  final double width;
  final double height;

  const _BunnyImage({
    required this.asset,
    required this.cropAlignment,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Align(
          alignment: cropAlignment,
          widthFactor: 0.5,
          child: Transform.scale(
            alignment: cropAlignment,
            scale: 2.0,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
