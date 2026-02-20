import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class OrdersSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const OrdersSettingsBody({super.key, required this.entry});

  @override
  State<OrdersSettingsBody> createState() => _OrdersSettingsBodyState();
}

class _OrdersSettingsBodyState extends State<OrdersSettingsBody> {
  String _selectedFilter = _orderFilters.first;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1820),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1300;
            final visibleCards = _selectedFilter == 'All'
                ? _ordersCards
                : _ordersCards
                      .where((card) => card.status == _selectedFilter)
                      .toList(growable: false);

            final listPanel = _OrderFilterPanel(
              selected: _selectedFilter,
              onSelect: (value) => setState(() => _selectedFilter = value),
            );

            if (wide) {
              return _WideOrdersLayout(
                listPanel: listPanel,
                cards: visibleCards,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: listPanel,
                ),
                const SizedBox(height: 20),
                _OrdersCardsWrap(cards: visibleCards),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderFilterPanel extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _OrderFilterPanel({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 259,
      child: Container(
        padding: const EdgeInsets.fromLTRB(19, 35, 19, 35),
        decoration: BoxDecoration(
          color: const Color(0xA61E1F22),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: _orderFilters
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final label = entry.value;
                final active = label == selected;
                final isLast = index == _orderFilters.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 3),
                  child: InkWell(
                    onTap: () => onSelect(label),
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 29,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0x17FFFFFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          if (active)
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: Color(0xFF2F88FF),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _OrdersCardsWrap extends StatelessWidget {
  final List<_OrderCardData> cards;

  const _OrdersCardsWrap({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const gap = 18.0;
        final useTwoColumns = width >= 860;
        final twoColWidth = (width - gap) / 2;
        final cardWidth = useTwoColumns
            ? twoColWidth.clamp(280.0, 393.0)
            : width;

        if (cards.isEmpty) {
          return const _EmptyOrdersCard();
        }

        return Wrap(
          spacing: gap,
          runSpacing: 18,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _OrderCard(data: card),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _WideOrdersLayout extends StatelessWidget {
  final Widget listPanel;
  final List<_OrderCardData> cards;

  const _WideOrdersLayout({required this.listPanel, required this.cards});

  @override
  Widget build(BuildContext context) {
    const panelWidth = 284.0;
    const panelGap = 28.0;
    const cardsGap = 18.0;
    const cardWidth = 393.0;

    final firstRowCards = cards.take(2).toList();
    final remainingCards = cards.skip(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// FIRST ROW
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: panelWidth, child: listPanel),
            const SizedBox(width: panelGap),
            ...firstRowCards.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final isLast = index == firstRowCards.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : cardsGap),
                child: SizedBox(
                  width: cardWidth,
                  child: _OrderCard(data: card),
                ),
              );
            }),
          ],
        ),

        /// SECOND ROW
        if (remainingCards.isNotEmpty) ...[
          const SizedBox(height: 18),
          Wrap(
            spacing: cardsGap,
            runSpacing: 18,
            children: remainingCards
                .map(
                  (card) => SizedBox(
                    width: cardWidth,
                    child: _OrderCard(data: card),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  const _EmptyOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 224,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x990B0E20),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        'No orders in this filter',
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.65),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderCardData data;

  const _OrderCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 224,
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E20),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _OrderThumbnail(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          data.status,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.46),
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'E-Chat',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'x2',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const _MiniCoinIcon(),
                          const SizedBox(width: 6),
                          Text(
                            '12.00',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.code,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF51D76E),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 29,
                height: 29,
                decoration: const BoxDecoration(
                  color: Color(0x33D9D9D9),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.customerName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data.dateLabel,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.46),
                  fontWeight: FontWeight.w500,
                  fontSize: 8,
                ),
              ),
              const Spacer(),
              ...data.actions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _OrderActionButton(
                    label: action.label,
                    style: action.style,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderThumbnail extends StatelessWidget {
  const _OrderThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 97,
      height: 102,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37002C), Color(0xFF1D2D62), Color(0xFF4C1D1D)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 7,
            left: 5,
            right: 5,
            child: Text(
              'E-CHAT',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                height: 1,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 58,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(5),
                ),
                child: Image.asset(
                  'assets/all_services/valorant.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.black.withValues(alpha: 0.18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCoinIcon extends StatelessWidget {
  const _MiniCoinIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8FBFFA), Color(0xFF2859C5)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '\$',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  final String label;
  final _OrderActionStyle style;

  const _OrderActionButton({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    final isOutlined = style == _OrderActionStyle.outlinedGreen;
    final background = switch (style) {
      _OrderActionStyle.solidRed => const Color(0xFF560305),
      _OrderActionStyle.solidGreen => const Color(0xFF51D76E),
      _OrderActionStyle.outlinedGreen => Colors.transparent,
    };
    final border = switch (style) {
      _OrderActionStyle.outlinedGreen => const Color(0xFF51D76E),
      _ => Colors.transparent,
    };

    return Container(
      width: 59,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: border, width: isOutlined ? 1.2 : 0),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          height: 1,
        ),
      ),
    );
  }
}

enum _OrderActionStyle { solidRed, solidGreen, outlinedGreen }

@immutable
class _OrderActionData {
  final String label;
  final _OrderActionStyle style;

  const _OrderActionData({required this.label, required this.style});
}

@immutable
class _OrderCardData {
  final String status;
  final String code;
  final String customerName;
  final String dateLabel;
  final List<_OrderActionData> actions;

  const _OrderCardData({
    required this.status,
    required this.code,
    required this.customerName,
    required this.dateLabel,
    required this.actions,
  });
}

const List<String> _orderFilters = <String>[
  'All',
  'In Progress',
  'Completed',
  'In Dispute',
  'Cancelled',
  'Refunded',
];

const List<_OrderCardData> _ordersCards = <_OrderCardData>[
  _OrderCardData(
    status: 'Completed',
    code: 'WAIBY-4F7K2',
    customerName: 'Arvkiny',
    dateLabel: '10.Jan.2026, 5:45',
    actions: <_OrderActionData>[
      _OrderActionData(label: 'Refund', style: _OrderActionStyle.solidRed),
      _OrderActionData(label: 'Complete', style: _OrderActionStyle.solidGreen),
    ],
  ),
  _OrderCardData(
    status: 'Completed',
    code: 'WAIBY-4F7K2',
    customerName: 'Josh',
    dateLabel: '10.Jan.2026, 5:45',
    actions: <_OrderActionData>[
      _OrderActionData(label: 'Review', style: _OrderActionStyle.outlinedGreen),
    ],
  ),
];
