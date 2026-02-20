import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class WalletSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const WalletSettingsBody({super.key, required this.entry});

  static const List<_DealRowData> _dealRows = <_DealRowData>[
    _DealRowData(
      service: 'Service income',
      order: '609665787887',
      dateTime: '12.09.2025 - 12.53 PM',
      user: 'krenny',
      amount: '+\$34,29',
      amountPositive: true,
      status: 'Delivered',
      statusColor: Colors.white,
    ),
    _DealRowData(
      service: 'Subscription income',
      order: '609215787001',
      dateTime: '12.09.2025 - 12.53 PM',
      user: 'HeyaW',
      amount: '+\$9.99',
      amountPositive: true,
      status: 'Pending',
      statusColor: Colors.white,
    ),
    _DealRowData(
      service: 'Order Tip Income',
      order: '609210987859',
      dateTime: '12.09.2025 - 12.53 PM',
      user: 'meghatin',
      amount: '-\$4.00',
      amountPositive: false,
      status: 'Refunded',
      statusColor: Color(0xFFFF2B2B),
    ),
    _DealRowData(
      service: 'Gift Income',
      order: '609365711040',
      dateTime: '12.09.2025 - 12.53 PM',
      user: 'Jay',
      amount: '+\$18.00',
      amountPositive: true,
      status: 'Delivered',
      statusColor: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1520),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(34, 30, 34, 34),
          decoration: BoxDecoration(
            color: const Color(0x30000000),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WalletStatsSection(),
              const SizedBox(height: 28),
              _DealsDetailsCard(rows: _dealRows),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletStatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 1180) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WalletStatCard(
                      title: 'Buds Balance',
                      value: '0.56',
                      actionLabel: 'Recharge',
                      onActionTap: () => context.go('/wallet/topup'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: _WalletStatCard(
                      title: 'Buds Income',
                      value: '780.56',
                      actionLabel: 'Withdraw',
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: _WalletStatCard(
                      title: 'Buds on hold',
                      value: '90.76',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(
                    child: _WalletStatCard(
                      title: 'Gems',
                      value: '270≈€0,81',
                      actionLabel: 'Get more',
                      actionDark: true,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(child: SizedBox()),
                  SizedBox(width: 14),
                  Expanded(child: SizedBox()),
                ],
              ),
            ],
          );
        }

        final cards = <Widget>[
          _WalletStatCard(
            title: 'Buds Balance',
            value: '0.56',
            actionLabel: 'Recharge',
            onActionTap: () => context.go('/wallet/topup'),
          ),
          _WalletStatCard(
            title: 'Buds Income',
            value: '780.56',
            actionLabel: 'Withdraw',
          ),
          _WalletStatCard(title: 'Buds on hold', value: '90.76'),
          _WalletStatCard(
            title: 'Gems',
            value: '270≈€0,81',
            actionLabel: 'Get more',
            actionDark: true,
          ),
        ];

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: cards
              .map(
                (card) => SizedBox(
                  width: width >= 760 ? (width - 14) / 2 : width,
                  child: card,
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _WalletStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? actionLabel;
  final bool actionDark;
  final VoidCallback? onActionTap;

  const _WalletStatCard({
    required this.title,
    required this.value,
    this.actionLabel,
    this.actionDark = false,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 24,
              letterSpacing: -0.35,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const _CoinGlyph(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF1E2029),
                    fontWeight: FontWeight.w700,
                    fontSize: 45,
                    letterSpacing: -0.7,
                    height: 1.0,
                  ),
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(width: 10),
                _WalletActionButton(
                  label: actionLabel!,
                  dark: actionDark,
                  onTap: onActionTap,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinGlyph extends StatelessWidget {
  const _CoinGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 21,
      height: 21,
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
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}

class _WalletActionButton extends StatelessWidget {
  final String label;
  final bool dark;
  final VoidCallback? onTap;

  const _WalletActionButton({
    required this.label,
    this.dark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 35,
          constraints: const BoxConstraints(minWidth: 113),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0C2444) : const Color(0xFF2F88FF),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: dark ? 16 : 20,
              letterSpacing: -0.25,
              height: dark ? 1.0 : 1.15,
            ),
          ),
        ),
      ),
    );
  }
}

class _DealsDetailsCard extends StatelessWidget {
  final List<_DealRowData> rows;

  const _DealsDetailsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 54,
            offset: Offset(6, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Deals Details',
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 39,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: const [
                      _FilterChip(
                        label: 'User, order ID',
                        withChevron: false,
                        active: true,
                      ),
                      _FilterChip(
                        label: 'October',
                        withChevron: true,
                        active: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(constraints.maxWidth, 1080),
                  child: Column(
                    children: [
                      const _DealsTableHeader(),
                      ...List<Widget>.generate(rows.length, (index) {
                        final row = rows[index];
                        return Column(
                          children: [
                            _DealsTableRow(data: row),
                            Divider(
                              height: 1,
                              color: index == rows.length - 1
                                  ? Colors.white.withValues(alpha: 0.45)
                                  : Colors.white.withValues(alpha: 0.2),
                              thickness: index == rows.length - 1 ? 1 : 0.8,
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 260),
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

class _DealsTableHeader extends StatelessWidget {
  const _DealsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF202224),
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 1.2,
        ),
        child: const Row(
          children: [
            _TableCell(width: 230, child: Text('Service')),
            _TableCell(width: 190, child: Text('Order')),
            _TableCell(width: 210, child: Text('Date - Time')),
            _TableCell(width: 150, child: Text('User')),
            _TableCell(width: 140, child: Text('Amount')),
            _TableCell(width: 130, child: Text('Status')),
          ],
        ),
      ),
    );
  }
}

class _DealsTableRow extends StatelessWidget {
  final _DealRowData data;

  const _DealsTableRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final valueStyle = GoogleFonts.nunitoSans(
      color: Colors.white.withValues(alpha: 0.85),
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.2,
    );

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          _TableCell(width: 230, child: Text(data.service, style: valueStyle)),
          _TableCell(
            width: 190,
            child: Text(
              data.order,
              style: valueStyle.copyWith(color: const Color(0xFF51D76E)),
            ),
          ),
          _TableCell(width: 210, child: Text(data.dateTime, style: valueStyle)),
          _TableCell(
            width: 150,
            child: Text(
              data.user,
              style: valueStyle.copyWith(color: const Color(0xFF51D76E)),
            ),
          ),
          _TableCell(
            width: 140,
            child: Text(
              data.amount,
              style: valueStyle.copyWith(
                color: data.amountPositive
                    ? const Color(0xFF51D76E)
                    : Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ),
          _TableCell(
            width: 130,
            child: Text(
              data.status,
              style: valueStyle.copyWith(
                color: data.statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final double width;
  final Widget child;

  const _TableCell({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool withChevron;
  final bool active;

  const _FilterChip({
    required this.label,
    required this.withChevron,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? const Color(0xFF51D76E) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1,
            ),
          ),
          if (withChevron) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ],
        ],
      ),
    );
  }
}

@immutable
class _DealRowData {
  final String service;
  final String order;
  final String dateTime;
  final String user;
  final String amount;
  final bool amountPositive;
  final String status;
  final Color statusColor;

  const _DealRowData({
    required this.service,
    required this.order,
    required this.dateTime,
    required this.user,
    required this.amount,
    required this.amountPositive,
    required this.status,
    required this.statusColor,
  });
}
