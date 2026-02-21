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
      details: _TicketDetailsData(
        caseId: '56767',
        typeLabel: 'Trust & Safety',
        categoryLabel: 'Catfish',
        createdAt: 'April 16, 2025, 8:52 AM',
        reportSummary:
            'Hello, i saw some gil posting pic but its not her, its take from pinterest, u can see all her album and the pinterest page lol. Her acc is Mia janettv https://waiby.gg/Miajanettv',
        evidenceItems: <String>['Evidence 1', 'Evidence 2'],
        evidenceNote: 'Evidence is reviwed manually and sorted securely.',
        responseTeam: 'Waiby Trust & Safety Team',
        responseDate: 'April 16, 2025, 11:20 AM',
        responseBody:
            'We\'ve reviewwed your report and taken appropriate action where necessary!\nFor privacy and safety reasons, specific actions may not be disclosed.\n\nThank you for helping keep Waiby safe.',
        resolutionLabel: 'Closed',
      ),
    ),
    _TicketCardData(
      title: 'Refund Declined',
      dateLabel: 'April 28, 2025, 16.50 PM',
      statusLabel: 'Closed',
      category: _TicketCategory.payments,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.muted,
      details: _TicketDetailsData(
        caseId: '64801',
        typeLabel: 'Payments',
        categoryLabel: 'Refund Declined',
        createdAt: 'April 28, 2025, 16.50 PM',
        reportSummary:
            'My refund request for order #998812 was declined even though the service was not delivered as described.',
        evidenceItems: <String>['Invoice', 'Chat log'],
        evidenceNote: 'Evidence is reviwed manually and sorted securely.',
        responseTeam: 'Waiby Payments Team',
        responseDate: 'April 29, 2025, 10:15 AM',
        responseBody:
            'Your report has been reviewed. We verified payment activity and provided additional guidance through support.',
        resolutionLabel: 'Closed',
      ),
    ),
    _TicketCardData(
      title: 'Shadow Ban',
      dateLabel: 'April 30, 2025, 6.02 AM',
      statusLabel: 'Closed',
      category: _TicketCategory.appeals,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.muted,
      details: _TicketDetailsData(
        caseId: '65102',
        typeLabel: 'Appeals',
        categoryLabel: 'Shadow Ban',
        createdAt: 'April 30, 2025, 6:02 AM',
        reportSummary:
            'I noticed a sudden drop in profile reach and engagement, and I would like this account review to be rechecked.',
        evidenceItems: <String>['Analytics', 'Reach chart'],
        evidenceNote: 'Evidence is reviwed manually and sorted securely.',
        responseTeam: 'Waiby Trust & Safety Team',
        responseDate: 'April 30, 2025, 2:40 PM',
        responseBody:
            'We completed a manual review and applied policy checks. Your account status is now updated in line with current review results.',
        resolutionLabel: 'Closed',
      ),
    ),
    _TicketCardData(
      title: 'Issue with score system',
      dateLabel: 'April 30, 2025, 6.02 AM',
      statusLabel: 'Answered',
      category: _TicketCategory.technical,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.defaultStyle,
      details: _TicketDetailsData(
        caseId: '65110',
        typeLabel: 'Technical',
        categoryLabel: 'Issue with score system',
        createdAt: 'April 30, 2025, 6:02 AM',
        reportSummary:
            'My score did not update after recent activity. I completed tasks that should have increased my rating.',
        evidenceItems: <String>['Task log'],
        evidenceNote: 'Evidence is reviwed manually and sorted securely.',
        responseTeam: 'Waiby Technical Team',
        responseDate: 'April 30, 2025, 1:05 PM',
        responseBody:
            'Thanks for reporting this. We identified a sync delay and corrected score updates for affected actions.',
        resolutionLabel: 'Answered',
      ),
    ),
    _TicketCardData(
      title: 'Bad Review',
      dateLabel: 'April 30, 2025, 6.02 AM',
      statusLabel: 'Answered',
      category: _TicketCategory.orders,
      actionLabel: 'Rate Support',
      actionStyle: _TicketActionStyle.primary,
      statusStyle: _TicketStatusStyle.defaultStyle,
      details: _TicketDetailsData(
        caseId: '65124',
        typeLabel: 'Orders',
        categoryLabel: 'Bad Review',
        createdAt: 'April 30, 2025, 6:02 AM',
        reportSummary:
            'A customer left a review that does not match the delivered order details and contains inaccurate claims.',
        evidenceItems: <String>['Order proof', 'Delivery receipt'],
        evidenceNote: 'Evidence is reviwed manually and sorted securely.',
        responseTeam: 'Waiby Support Team',
        responseDate: 'April 30, 2025, 3:40 PM',
        responseBody:
            'We reviewed the order timeline and attached evidence. Your ticket remains answered while final moderation checks continue.',
        resolutionLabel: 'Answered',
      ),
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
            child: _SidebarSubmitReportButton(
              onPressed: () => showDialog<void>(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.72),
                builder: (dialogContext) => const _SubmitReportDialog(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSubmitReportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SidebarSubmitReportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF2F88FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Submit Report',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
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
          _TicketCard(
            ticket: tickets[i],
            onTap: () => showDialog<void>(
              context: context,
              barrierColor: Colors.black.withValues(alpha: 0.72),
              builder: (dialogContext) =>
                  _TicketDetailsDialog(ticket: tickets[i]),
            ),
          ),
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
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(34, 30, 34, 30),
          decoration: BoxDecoration(
            color: const Color(0xFF060B1D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
            ),
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
        ),
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
  final _TicketDetailsData details;

  const _TicketCardData({
    required this.title,
    required this.dateLabel,
    required this.statusLabel,
    required this.category,
    required this.actionLabel,
    required this.actionStyle,
    required this.statusStyle,
    required this.details,
  });
}

@immutable
class _TicketDetailsData {
  final String caseId;
  final String typeLabel;
  final String categoryLabel;
  final String createdAt;
  final String reportSummary;
  final List<String> evidenceItems;
  final String evidenceNote;
  final String responseTeam;
  final String responseDate;
  final String responseBody;
  final String resolutionLabel;

  const _TicketDetailsData({
    required this.caseId,
    required this.typeLabel,
    required this.categoryLabel,
    required this.createdAt,
    required this.reportSummary,
    required this.evidenceItems,
    required this.evidenceNote,
    required this.responseTeam,
    required this.responseDate,
    required this.responseBody,
    required this.resolutionLabel,
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

class _TicketDetailsDialog extends StatelessWidget {
  final _TicketCardData ticket;

  const _TicketDetailsDialog({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final details = ticket.details;
    final isMutedStatus = ticket.statusStyle == _TicketStatusStyle.muted;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 678,
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0F16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Case Detail',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 26),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 560;
                    final leftMeta = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case ID: #${details.caseId}',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.notoSans(
                                color: Colors.white.withValues(alpha: 0.38),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _CaseStatusBadge(
                              label: ticket.statusLabel,
                              muted: isMutedStatus,
                            ),
                          ],
                        ),
                      ],
                    );

                    final rightMeta = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TicketDetailsMetaLine(
                          label: 'Type:',
                          value: '${details.typeLabel}>',
                        ),
                        const SizedBox(height: 3),
                        _TicketDetailsMetaLine(
                          label: 'Category:',
                          value: details.categoryLabel,
                          emphasizedValue: true,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Created: ${details.createdAt}',
                          style: GoogleFonts.notoSans(
                            color: Colors.white.withValues(alpha: 0.63),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );

                    if (narrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          leftMeta,
                          const SizedBox(height: 14),
                          rightMeta,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: leftMeta),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: rightMeta),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: const Color(0xFF1C2645).withValues(alpha: 0.9),
                ),
                const SizedBox(height: 22),
                Text(
                  'Report Summary',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151721),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(26, 76, 157, 0.9),
                    ),
                  ),
                  child: Text(
                    'False or misleading reports may result in penalties.',
                    style: GoogleFonts.notoSans(
                      color: Colors.white.withValues(alpha: 0.51),
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151721),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evidence',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        details.reportSummary,
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      if (details.evidenceItems.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (
                              var i = 0;
                              i < details.evidenceItems.length;
                              i++
                            )
                              _EvidencePreviewTile(
                                label: details.evidenceItems[i],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 22,
                      color: Colors.white.withValues(alpha: 0.51),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        details.evidenceNote,
                        style: GoogleFonts.notoSans(
                          color: Colors.white.withValues(alpha: 0.51),
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  height: 1,
                  thickness: 0.6,
                  color: const Color(0xFF1C2645).withValues(alpha: 0.9),
                ),
                const SizedBox(height: 22),
                Text(
                  'Official Response',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151721),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.cruelty_free_rounded,
                            size: 30,
                            color: Color(0xFF9BE35E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              details.responseTeam,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        details.responseDate,
                        style: GoogleFonts.notoSans(
                          color: Colors.white.withValues(alpha: 0.51),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        details.responseBody,
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 42,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF2F88FF),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        details.resolutionLabel,
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketDetailsMetaLine extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasizedValue;

  const _TicketDetailsMetaLine({
    required this.label,
    required this.value,
    this.emphasizedValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = emphasizedValue
        ? Colors.white
        : Colors.white.withValues(alpha: 0.38);
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.38),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.notoSans(
              color: valueColor,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _CaseStatusBadge extends StatelessWidget {
  final String label;
  final bool muted;

  const _CaseStatusBadge({required this.label, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.19),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          color: muted
              ? Colors.white.withValues(alpha: 0.38)
              : Colors.white.withValues(alpha: 0.95),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}

class _EvidencePreviewTile extends StatelessWidget {
  final String label;

  const _EvidencePreviewTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      height: 95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1D2233), Color(0xFF111522)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Icon(
              Icons.image_outlined,
              size: 36,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 6,
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.62),
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitReportDialog extends StatefulWidget {
  const _SubmitReportDialog();

  @override
  State<_SubmitReportDialog> createState() => _SubmitReportDialogState();
}

class _SubmitReportDialogState extends State<_SubmitReportDialog> {
  static const int _detailsMaxLength = 2500;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int _detailsLength = 0;

  @override
  void initState() {
    super.initState();
    _detailsController.addListener(_syncDetailsLength);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subjectController.dispose();
    _detailsController.removeListener(_syncDetailsLength);
    _detailsController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncDetailsLength() {
    final nextLength = _detailsController.text.length.clamp(
      0,
      _detailsMaxLength,
    );
    if (nextLength != _detailsLength) {
      setState(() => _detailsLength = nextLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 678,
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0F16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(46, 42, 46, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Report',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 34),
                const _DialogSectionTitle(label: 'Report Category'),
                const SizedBox(height: 12),
                _DialogInputField(
                  controller: _categoryController,
                  hintText: 'Select the category that best matches your issue',
                  trailing: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF2F88FF),
                  ),
                ),
                const SizedBox(height: 30),
                const _DialogSectionTitle(label: 'Subject'),
                const SizedBox(height: 12),
                _DialogInputField(
                  controller: _subjectController,
                  hintText: 'What went wrong?',
                ),
                const SizedBox(height: 30),
                const _DialogSectionTitle(label: 'Details'),
                const SizedBox(height: 12),
                _DialogDetailsField(
                  controller: _detailsController,
                  maxLength: _detailsMaxLength,
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151721),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: const Color.fromRGBO(26, 76, 157, 0.9),
                    ),
                  ),
                  child: Text(
                    'False or misleading reports may result in penalties.',
                    style: GoogleFonts.notoSans(
                      color: Colors.white.withValues(alpha: 0.51),
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _DialogSectionTitle(label: 'Evidence (Optional)'),
                const SizedBox(height: 6),
                Text(
                  'Screenshots or files help us review your case faster.',
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.51),
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                _UploadDropZone(),
                const SizedBox(height: 30),
                const _DialogSectionTitle(label: 'Contact email'),
                const SizedBox(height: 12),
                _DialogInputField(controller: _emailController, hintText: ''),
                const SizedBox(height: 8),
                Text(
                  'We\'ll reply here. Please keep this email accesible.',
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.51),
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 10,
                    children: [
                      _DialogActionButton(
                        label: 'Submit Report',
                        primary: true,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _DialogActionButton(
                        label: 'Cancel',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'By submitting this report, you confirm the information is accurate and complete.',
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.51),
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogSectionTitle extends StatelessWidget {
  final String label;

  const _DialogSectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.notoSans(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    );
  }
}

class _DialogInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? trailing;

  const _DialogInputField({
    required this.controller,
    required this.hintText,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151721),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.notoSans(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _DialogDetailsField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;

  const _DialogDetailsField({
    required this.controller,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final currentLength = controller.text.length;
    return Container(
      height: 186,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151721),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: maxLength,
              maxLines: null,
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                alignLabelWithHint: true,
                border: InputBorder.none,
                counterText: '',
                hintText:
                    'Please explain what happened.\n\nIf relevant, include their order ID, usernames or link',
                hintStyle: GoogleFonts.notoSans(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$currentLength/$maxLength',
              style: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.12),
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 183,
      decoration: BoxDecoration(
        color: const Color(0xFF080912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            'Drag & Drop files here',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 125,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF636363),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Browse files',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primary
              ? const Color(0xFF2F88FF)
              : Colors.white.withValues(alpha: 0.14),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
