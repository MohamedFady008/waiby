import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class TicketsSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const TicketsSettingsBody({super.key, required this.entry});

  static const List<_SidebarTicketCategoryData> _sidebarCategories =
      <_SidebarTicketCategoryData>[
        _SidebarTicketCategoryData(
          label: 'Orders',
          icon: Icons.support_agent_outlined,
        ),
        _SidebarTicketCategoryData(
          label: 'Trust & Safety',
          icon: Icons.shield_outlined,
        ),
        _SidebarTicketCategoryData(
          label: 'Payments',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _SidebarTicketCategoryData(
          label: 'Technical',
          icon: Icons.handyman_outlined,
        ),
        _SidebarTicketCategoryData(
          label: 'Appeals',
          icon: Icons.gavel_outlined,
        ),
      ];

  static const List<String> _ticketFilters = <String>[
    'All',
    'In Progress',
    'Answered',
    'Solved',
  ];

  static const List<_TicketCardData> _tickets = <_TicketCardData>[
    _TicketCardData(
      title: 'Catfish',
      dateLabel: 'April 18, 2025, 8:56 AM',
      statusLabel: 'Closed',
      category: _TicketCategory.trustSafety,
      actionLabel: 'Case reviwed',
      actionStyle: _TicketActionStyle.neutral,
      statusStyle: _TicketStatusStyle.muted,
    ),
    _TicketCardData(
      title: 'Refund Declined',
      dateLabel: 'April 28, 2025, 16.50 PM',
      statusLabel: 'Closed',
      category: _TicketCategory.payments,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.muted,
    ),
    _TicketCardData(
      title: 'Shadow Ban',
      dateLabel: 'April 30, 2025, 6.02 AM',
      statusLabel: 'Closed',
      category: _TicketCategory.appeals,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.muted,
    ),
    _TicketCardData(
      title: 'Issue with score system',
      dateLabel: 'April 30, 2025, 6.02 AM',
      statusLabel: 'Answered',
      category: _TicketCategory.technical,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.defaultStyle,
    ),
    _TicketCardData(
      title: 'Bad Review',
      dateLabel: 'April 30, 2025, 6.02 AM',
      statusLabel: 'Answered',
      category: _TicketCategory.orders,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.defaultStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${entry.title} settings',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackedLayout = constraints.maxWidth < 1180;
              final sidebarWidth = constraints.maxWidth >= 1500 ? 420.0 : 340.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Service',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (stackedLayout) ...[
                    const _TicketsSidebarPanel(
                      categories: _sidebarCategories,
                      compact: true,
                    ),
                    const SizedBox(height: 16),
                    const _TicketsContentArea(
                      filters: _ticketFilters,
                      tickets: _tickets,
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: sidebarWidth,
                          child: const _TicketsSidebarPanel(
                            categories: _sidebarCategories,
                          ),
                        ),
                        const SizedBox(width: 32),
                        const Expanded(
                          child: _TicketsContentArea(
                            filters: _ticketFilters,
                            tickets: _tickets,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TicketsSidebarPanel extends StatelessWidget {
  final List<_SidebarTicketCategoryData> categories;
  final bool compact;

  const _TicketsSidebarPanel({required this.categories, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 360 : 960),
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
      decoration: BoxDecoration(
        color: const Color(0xFF060B1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 0.09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'All',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF2F88FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < categories.length; i++) ...[
            _SidebarCategoryRow(data: categories[i]),
            if (i < categories.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 40),
          Center(
            child: Container(
              height: 48,
              width: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF2F88FF),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                'Submit Report',
                style: GoogleFonts.notoSans(
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
    );
  }
}

class _SidebarCategoryRow extends StatelessWidget {
  final _SidebarTicketCategoryData data;

  const _SidebarCategoryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(data.icon, size: 15, color: Colors.white),
        const SizedBox(width: 10),
        Text(
          data.label,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _TicketsContentArea extends StatelessWidget {
  final List<String> filters;
  final List<_TicketCardData> tickets;

  const _TicketsContentArea({required this.filters, required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TicketFiltersBar(filters: filters),
        const SizedBox(height: 16),
        for (var i = 0; i < tickets.length; i++) ...[
          _TicketCard(ticket: tickets[i]),
          if (i < tickets.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _TicketFiltersBar extends StatelessWidget {
  final List<String> filters;

  const _TicketFiltersBar({required this.filters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF060B1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;
          if (narrow) {
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < filters.length; i++)
                  _FilterItem(label: filters[i], selected: i == 0),
              ],
            );
          }
          return Row(
            children: [
              for (var i = 0; i < filters.length; i++) ...[
                _FilterItem(label: filters[i], selected: i == 0),
                if (i < filters.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterItem({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 126),
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected
            ? const Color.fromRGBO(255, 255, 255, 0.09)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF2F88FF),
            ),
          ],
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final _TicketCardData ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(34, 30, 34, 30),
      decoration: BoxDecoration(
        color: const Color(0xFF060B1D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TicketMainInfo(ticket: ticket),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _TicketStatusPill(
                      label: ticket.statusLabel,
                      styleType: ticket.statusStyle,
                    ),
                    _TicketActionButton(
                      label: ticket.actionLabel,
                      styleType: ticket.actionStyle,
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _TicketMainInfo(ticket: ticket)),
              const SizedBox(width: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TicketStatusPill(
                    label: ticket.statusLabel,
                    styleType: ticket.statusStyle,
                  ),
                  const SizedBox(height: 18),
                  _TicketActionButton(
                    label: ticket.actionLabel,
                    styleType: ticket.actionStyle,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TicketMainInfo extends StatelessWidget {
  final _TicketCardData ticket;

  const _TicketMainInfo({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ticket.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ticket.dateLabel,
          style: GoogleFonts.notoSans(
            color: Colors.white.withValues(alpha: 0.62),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        _TicketCategoryChip(category: ticket.category),
      ],
    );
  }
}

class _TicketCategoryChip extends StatelessWidget {
  final _TicketCategory category;

  const _TicketCategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final style = _TicketCategoryStyle.fromCategory(category);
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: style.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 15, color: style.foreground),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: GoogleFonts.notoSans(
              color: style.foreground,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketStatusPill extends StatelessWidget {
  final String label;
  final _TicketStatusStyle styleType;

  const _TicketStatusPill({required this.label, required this.styleType});

  @override
  Widget build(BuildContext context) {
    final textColor = styleType == _TicketStatusStyle.defaultStyle
        ? Colors.white
        : Colors.white.withValues(alpha: 0.38);
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.19),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}

class _TicketActionButton extends StatelessWidget {
  final String label;
  final _TicketActionStyle styleType;

  const _TicketActionButton({required this.label, required this.styleType});

  @override
  Widget build(BuildContext context) {
    final isPrimary = styleType == _TicketActionStyle.primary;
    return Container(
      height: 50,
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFF2F88FF)
            : Colors.white.withValues(alpha: 0.19),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1,
        ),
      ),
    );
  }
}

@immutable
class _SidebarTicketCategoryData {
  final String label;
  final IconData icon;

  const _SidebarTicketCategoryData({required this.label, required this.icon});
}

@immutable
class _TicketCardData {
  final String title;
  final String dateLabel;
  final String statusLabel;
  final _TicketCategory category;
  final String actionLabel;
  final _TicketActionStyle actionStyle;
  final _TicketStatusStyle statusStyle;

  const _TicketCardData({
    required this.title,
    required this.dateLabel,
    required this.statusLabel,
    required this.category,
    required this.actionLabel,
    required this.actionStyle,
    required this.statusStyle,
  });
}

enum _TicketCategory { orders, trustSafety, payments, technical, appeals }

enum _TicketActionStyle { primary, neutral }

enum _TicketStatusStyle { defaultStyle, muted }

@immutable
class _TicketCategoryStyle {
  final String label;
  final IconData icon;
  final Color background;
  final Color border;
  final Color foreground;

  const _TicketCategoryStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.border,
    required this.foreground,
  });

  static _TicketCategoryStyle fromCategory(_TicketCategory category) {
    switch (category) {
      case _TicketCategory.orders:
        return const _TicketCategoryStyle(
          label: 'Order',
          icon: Icons.support_agent_outlined,
          background: Color(0xFF463E0F),
          border: Color(0xFFFFE552),
          foreground: Color(0xFFEDDB74),
        );
      case _TicketCategory.trustSafety:
        return const _TicketCategoryStyle(
          label: 'Trust and safety',
          icon: Icons.shield_outlined,
          background: Color(0xFF4A3535),
          border: Color(0xFF9E5253),
          foreground: Color(0xFFBE9898),
        );
      case _TicketCategory.payments:
        return const _TicketCategoryStyle(
          label: 'Payments',
          icon: Icons.account_balance_wallet_outlined,
          background: Color(0xFF0E3A2F),
          border: Color(0xFF51D76E),
          foreground: Color(0xFF1C805E),
        );
      case _TicketCategory.technical:
        return const _TicketCategoryStyle(
          label: 'Technical',
          icon: Icons.handyman_outlined,
          background: Color(0xFF0D1220),
          border: Color(0xFF1B234B),
          foreground: Color(0xFF727FA3),
        );
      case _TicketCategory.appeals:
        return const _TicketCategoryStyle(
          label: 'Appeals',
          icon: Icons.gavel_outlined,
          background: Color(0xFFB26A3D),
          border: Color(0xFFFF6200),
          foreground: Color(0xFFFFA369),
        );
    }
  }
}
