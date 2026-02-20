import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class StoreSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const StoreSettingsBody({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1820),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _StoreHeroBanner(),
            SizedBox(height: 26),
            _StoreHeader(),
            SizedBox(height: 24),
            _StoreFramesGrid(),
          ],
        ),
      ),
    );
  }
}

class _StoreHeroBanner extends StatelessWidget {
  const _StoreHeroBanner();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 901 / 141,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF69C87E), Color(0xFFA3C5AA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CarouselDot(active: true),
                    SizedBox(width: 11),
                    _CarouselDot(),
                    SizedBox(width: 11),
                    _CarouselDot(),
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

class _CarouselDot extends StatelessWidget {
  final bool active;

  const _CarouselDot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF0C1AAD) : const Color(0xFF8A7C7C),
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 860;
        final compact = constraints.maxWidth < 620;
        final titleSize = compact ? 30.0 : 40.0;
        final balanceSize = compact ? 23.0 : 31.0;

        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frames',
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFFDFD),
                fontWeight: FontWeight.w700,
                fontSize: titleSize,
                height: 1.03,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 12,
                  color: Color(0xFF51D76E),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Activate VIP to unlock an extra discount on cosmetic '
                    'items',
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        final right = Column(
          crossAxisAlignment: wide
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Buds Balance:',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: balanceSize,
                    height: 1.05,
                  ),
                ),
                const SizedBox(width: 8),
                const _CoinGlyph(size: 15),
                const SizedBox(width: 6),
                Text(
                  '13.59',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: balanceSize,
                    height: 1.05,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recharge',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF51D76E),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF51D76E),
                ),
              ],
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              right,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(height: 16), right],
        );
      },
    );
  }
}

class _StoreFramesGrid extends StatelessWidget {
  const _StoreFramesGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const gap = 18.0;

        int columns;
        if (width >= 1500) {
          columns = 5;
        } else if (width >= 1200) {
          columns = 4;
        } else if (width >= 860) {
          columns = 3;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = ((width - (gap * (columns - 1))) / columns).clamp(
          200.0,
          244.0,
        );

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _storeFrames
              .map(
                (frame) => SizedBox(
                  width: cardWidth,
                  child: _StoreFrameCard(data: frame),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _StoreFrameCard extends StatelessWidget {
  final _StoreFrameData data;

  const _StoreFrameCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 232,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141D35),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: data.selected
                  ? const Color(0xFF51D76E)
                  : Colors.white.withValues(alpha: 0.14),
              width: data.selected ? 1.1 : 0.7,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(2, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Container(
                            width: 74,
                            height: 74,
                            color: const Color(0xFF263351),
                            child: Image.asset(
                              'assets/bunny1.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.pets_rounded,
                                color: Color(0xFF8ADE57),
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        Image.asset(
                          data.frameAsset,
                          width: 110,
                          height: 110,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 13),
              _BuyButtons(data: data),
            ],
          ),
        ),
        if (data.selected)
          const Positioned(
            left: 7,
            top: 4,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 12,
              color: Color(0xFF51D76E),
            ),
          ),
      ],
    );
  }
}

class _BuyButtons extends StatelessWidget {
  final _StoreFrameData data;

  const _BuyButtons({required this.data});

  @override
  Widget build(BuildContext context) {
    final buyButton = Expanded(
      child: Container(
        height: 29,
        decoration: BoxDecoration(
          color: const Color(0xFF2F88FF),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Buy for',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 1,
              ),
            ),
            const SizedBox(width: 5),
            const _CoinGlyph(size: 12),
            const SizedBox(width: 5),
            Text(
              data.priceLabel,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );

    if (data.selected || !data.showGiftButton) {
      return Row(children: [buyButton]);
    }

    return Row(
      children: [
        buyButton,
        const SizedBox(width: 6),
        Container(
          width: 24,
          height: 29,
          decoration: BoxDecoration(
            color: const Color(0xFF2F88FF),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Icon(
            Icons.card_giftcard_rounded,
            size: 13,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CoinGlyph extends StatelessWidget {
  final double size;

  const _CoinGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8FBFFA), Color(0xFF2859C5)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.circle_outlined,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}

@immutable
class _StoreFrameData {
  final String name;
  final String frameAsset;
  final String priceLabel;
  final bool selected;
  final bool showGiftButton;

  const _StoreFrameData({
    required this.name,
    required this.frameAsset,
    required this.priceLabel,
    this.selected = false,
    this.showGiftButton = true,
  });
}

const List<_StoreFrameData> _storeFrames = <_StoreFrameData>[
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/nautic_ring.png',
    priceLabel: '9.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/goldbutterfly.png',
    priceLabel: '9.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/happy_sprinkles.png',
    priceLabel: '9.99',
    showGiftButton: false,
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/lotus_aura.png',
    priceLabel: '15.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/lolita_pearl.png',
    priceLabel: '9.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/steam_pipe.png',
    priceLabel: '9.99',
    showGiftButton: false,
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/golden.png',
    priceLabel: '9.99',
    selected: true,
    showGiftButton: false,
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/aqua_ring.png',
    priceLabel: '9.99',
    showGiftButton: false,
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/luminova.png',
    priceLabel: '9.99',
    selected: true,
    showGiftButton: false,
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/kittybloom.png',
    priceLabel: '15.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/aurealux_emblem.png',
    priceLabel: '15.99',
    selected: true,
    showGiftButton: false,
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/moumou.png',
    priceLabel: '9.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/boblin_treasure.png',
    priceLabel: '9.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/demon1.png',
    priceLabel: '9.99',
  ),
  _StoreFrameData(
    name: 'Nautic Ring',
    frameAsset: 'assets/medals/sugarland.png',
    priceLabel: '15.99',
  ),
];
