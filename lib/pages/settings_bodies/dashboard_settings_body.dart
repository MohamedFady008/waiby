import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waiby/widgets/settings_sidebar.dart';

const Color _kCardBackground = Color(0xFF0B1739);
const Color _kCardBorder = Color(0xFF343B4F);
const Color _kTextMuted = Color(0xFFAEB9E1);
const Color _kAccentPurple = Color(0xFFCB3CFF);
const Color _kAccentBlue = Color(0xFF00C2FF);
const Color _kSuccessGreen = Color(0xFF14CA74);

class DashboardSettingsBody extends StatelessWidget {
  const DashboardSettingsBody({
    super.key,
    required SettingsSidebarMenuEntry entry,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, LaKimi",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Grow, earn and build",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  _secondaryBtn("Get help"),
                  const SizedBox(width: 8),
                  _primaryBtn("Done"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// ===== TOP STATS =====
          Row(
            children: const [
              Expanded(
                child: _StatCard(
                  title: "Views",
                  value: "5.8K",
                  icon: Icons.visibility_rounded,
                  deltaText: "28.4%",
                  isPositive: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Total customers",
                  value: "680",
                  icon: Icons.person_rounded,
                  deltaText: "12.6%",
                  isPositive: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Chats",
                  value: "756",
                  icon: Icons.add_circle_outline_rounded,
                  deltaText: "3.1%",
                  isPositive: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: "Subscriptions + Gifts",
                  value: "2.3K",
                  icon: Icons.star_rounded,
                  deltaText: "11.3%",
                  isPositive: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// ===== CHART SECTION =====
          const _DashboardOverviewCard(),

          const SizedBox(height: 32),

          /// ===== REPORTS / DEALS =====
          const _ReportsSection(),
        ],
      ),
    );
  }

  Widget _primaryBtn(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _kAccentPurple,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _secondaryBtn(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1330),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _ReportsSection extends StatelessWidget {
  const _ReportsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reports overview",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        const _ReportsYearChip(),
        const SizedBox(height: 16),
        const _DealsDetailsCard(),
      ],
    );
  }
}

class _ReportsYearChip extends StatelessWidget {
  const _ReportsYearChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1330),
        border: Border.all(color: _kCardBorder, width: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: _kTextMuted.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 6),
          Text(
            '2025',
            style: GoogleFonts.poppins(
              color: _kTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: _kTextMuted.withValues(alpha: 0.95),
          ),
        ],
      ),
    );
  }
}

class _DealsDetailsCard extends StatelessWidget {
  const _DealsDetailsCard();

  static const List<_DealRowData> _rows = <_DealRowData>[
    _DealRowData(
      service: 'Service income',
      order: '609665787887',
      dateTime: '12.09.2025 - 12.53 PM',
      user: 'krenny',
      amount: '+\$34.29',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 0.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 36,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DealsHeaderRow(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const minTableWidth = 980.0;
              final tableWidth = constraints.maxWidth < minTableWidth
                  ? minTableWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      const _DealsColumnsHeader(),
                      const SizedBox(height: 8),
                      ...List<Widget>.generate(_rows.length, (index) {
                        final row = _rows[index];
                        return Column(
                          children: [
                            _DealRow(data: row),
                            if (index < _rows.length - 1)
                              Divider(
                                color: Colors.white.withValues(alpha: 0.15),
                                height: 1,
                                thickness: 0.6,
                              )
                            else
                              Divider(
                                color: Colors.white.withValues(alpha: 0.45),
                                height: 1,
                                thickness: 0.8,
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DealsHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;

        const controls = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [_DealsSearchField(), _DealsMonthField()],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deals Details',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              controls,
            ],
          );
        }

        return Row(
          children: [
            Text(
              'Deals Details',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            const Spacer(),
            controls,
          ],
        );
      },
    );
  }
}

class _DealsSearchField extends StatelessWidget {
  const _DealsSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 196,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: const Color(0xFF51D76E), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 17,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 6),
          Text(
            'User, order ID',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DealsMonthField extends StatelessWidget {
  const _DealsMonthField();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: const Color(0xFF51D76E), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            'October',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _DealsColumnsHeader extends StatelessWidget {
  const _DealsColumnsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F7).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _DealsHeaderCell(text: 'Service', flex: 24),
          _DealsHeaderCell(text: 'Order', flex: 20),
          _DealsHeaderCell(text: 'Date - Time', flex: 22),
          _DealsHeaderCell(text: 'User', flex: 15),
          _DealsHeaderCell(text: 'Amount', flex: 14),
          _DealsHeaderCell(text: 'Status', flex: 13),
        ],
      ),
    );
  }
}

class _DealsHeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _DealsHeaderCell({required this.text, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF202224),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DealRow extends StatelessWidget {
  final _DealRowData data;

  const _DealRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final regularStyle = GoogleFonts.nunitoSans(
      color: Colors.white.withValues(alpha: 0.82),
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );

    return SizedBox(
      height: 108,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              flex: 24,
              child: Text(
                data.service,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularStyle,
              ),
            ),
            Expanded(
              flex: 20,
              child: Text(
                data.order,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularStyle.copyWith(color: _kSuccessGreen),
              ),
            ),
            Expanded(
              flex: 22,
              child: Text(
                data.dateTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularStyle,
              ),
            ),
            Expanded(
              flex: 15,
              child: Text(
                data.user,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularStyle.copyWith(color: _kSuccessGreen),
              ),
            ),
            Expanded(
              flex: 14,
              child: Text(
                data.amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularStyle.copyWith(
                  color: data.amountPositive ? _kSuccessGreen : Colors.white,
                ),
              ),
            ),
            Expanded(
              flex: 13,
              child: Text(
                data.status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: regularStyle.copyWith(
                  color: data.statusColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
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

class _DashboardOverviewCard extends StatelessWidget {
  const _DashboardOverviewCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout = constraints.maxWidth < 1120;
        return SizedBox(
          height: compactLayout ? 940 : 560,
          child: _DashboardCard(
            child: compactLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Expanded(flex: 7, child: _MainRevenuePanel()),
                      _DashboardDivider(axis: Axis.horizontal),
                      Expanded(flex: 5, child: _RightSummaryPanel()),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Expanded(flex: 2, child: _MainRevenuePanel()),
                      _DashboardDivider(axis: Axis.vertical),
                      Expanded(child: _RightSummaryPanel()),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _DashboardDivider extends StatelessWidget {
  final Axis axis;

  const _DashboardDivider({required this.axis});

  @override
  Widget build(BuildContext context) {
    return axis == Axis.vertical
        ? Container(width: 0.6, color: _kCardBorder)
        : Container(height: 0.6, color: _kCardBorder);
  }
}

class _MainRevenuePanel extends StatelessWidget {
  const _MainRevenuePanel();

  static const List<String> _months = <String>[
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RevenueHeader(),
          const SizedBox(height: 18),
          const Expanded(child: _RevenueChartArea()),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _months
                  .map(
                    (month) => Text(
                      month,
                      style: GoogleFonts.nunitoSans(
                        color: _kTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueHeader extends StatelessWidget {
  const _RevenueHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        final metrics = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stacked_bar_chart_rounded,
                  size: 14,
                  color: _kTextMuted.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Total revenue',
                  style: GoogleFonts.nunitoSans(
                    color: _kTextMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$40.8K',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                const _GrowthChip(),
              ],
            ),
          ],
        );

        final controls = Wrap(
          spacing: 20,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            _LegendDotLabel(label: 'Revenue', color: _kAccentPurple),
            _LegendDotLabel(label: 'Expenses', color: _kAccentBlue),
            _DateRangeChip(label: 'Jan 2026 - Dec 2026'),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [metrics, const SizedBox(height: 10), controls],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [metrics, const Spacer(), controls],
        );
      },
    );
  }
}

class _LegendDotLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDotLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            color: _kTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  final String label;

  const _DateRangeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _kCardBackground,
        border: Border.all(color: _kCardBorder, width: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: _kTextMuted.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              color: _kTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: _kTextMuted.withValues(alpha: 0.95),
          ),
        ],
      ),
    );
  }
}

class _GrowthChip extends StatelessWidget {
  final bool compact;

  const _GrowthChip({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0x3305C168),
        border: Border.all(color: const Color(0x3305C168), width: 0.6),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Default',
            style: GoogleFonts.nunitoSans(
              color: _kSuccessGreen,
              fontSize: compact ? 10 : 14,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.north_east_rounded,
            size: compact ? 11 : 14,
            color: _kSuccessGreen,
          ),
        ],
      ),
    );
  }
}

class _RevenueChartArea extends StatelessWidget {
  const _RevenueChartArea();

  static const List<String> _yLabels = <String>[
    '50K',
    '25K',
    '15K',
    '10K',
    '5K',
    '1K',
    '0',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 36,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _yLabels
                .map(
                  (label) => Text(
                    label,
                    style: GoogleFonts.nunitoSans(
                      color: _kTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const CustomPaint(
                        painter: _RevenueAreaChartPainter(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.30,
                    top: constraints.maxHeight * 0.16,
                    child: const _RevenueTooltip(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RevenueTooltip extends StatelessWidget {
  const _RevenueTooltip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: _kCardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF102352), width: 0.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99020A22),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$9.7k',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const _GrowthChip(compact: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'June 21, 2026',
            style: GoogleFonts.nunitoSans(
              color: _kTextMuted,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RightSummaryPanel extends StatelessWidget {
  const _RightSummaryPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Expanded(child: _TotalProfitCard()),
        _DashboardDivider(axis: Axis.horizontal),
        Expanded(child: _VisitorsCard()),
      ],
    );
  }
}

class _TotalProfitCard extends StatelessWidget {
  const _TotalProfitCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MetricHeading(
            icon: Icons.query_stats_rounded,
            title: 'Total profit',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$35K',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              const _GrowthChip(),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: const _MiniGuidePainter(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _MiniXAxisLabels(
                    style: GoogleFonts.nunitoSans(
                      color: _kTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorsCard extends StatelessWidget {
  const _VisitorsCard();

  static const List<double> _visitorTrend = <double>[
    0.06,
    0.12,
    0.35,
    0.22,
    0.45,
    0.30,
    0.25,
    0.22,
    0.42,
    0.80,
    0.44,
    0.20,
    0.20,
    0.20,
    0.45,
    0.21,
    0.12,
    0.06,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MetricHeading(
            icon: Icons.timer_outlined,
            title: 'Total Visitors',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '5k',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              const _GrowthChip(),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: CustomPaint(
                painter: const _MiniSparklinePainter(
                  values: _visitorTrend,
                  lineColor: _kAccentPurple,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            child: _MiniXAxisLabels(
              style: GoogleFonts.nunitoSans(
                color: _kTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const _VisitorsBadge(),
              const SizedBox(width: 10),
              Text(
                '10k visitors',
                style: GoogleFonts.nunitoSans(
                  color: _kTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MetricHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kTextMuted),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.nunitoSans(
            color: _kTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MiniXAxisLabels extends StatelessWidget {
  final TextStyle style;
  static const List<String> _labels = <String>[
    '12 AM',
    '8 AM',
    '4 PM',
    '11 PM',
  ];

  const _MiniXAxisLabels({required this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _labels
          .map((label) => Text(label, style: style))
          .toList(growable: false),
    );
  }
}

class _VisitorsBadge extends StatelessWidget {
  const _VisitorsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x3305C168),
        border: Border.all(color: const Color(0x3305C168), width: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF05C168),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Default',
            style: GoogleFonts.nunitoSans(
              color: _kSuccessGreen,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGuidePainter extends CustomPainter {
  const _MiniGuidePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = _kCardBorder.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  const _MiniSparklinePainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = _kCardBorder.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 1; i <= 2; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(
        Offset.zero.translate(0, y),
        Offset(size.width, y),
        guidePaint,
      );
    }

    if (values.length < 2) {
      return;
    }

    final points = <Offset>[];
    final lastIndex = values.length - 1;
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / lastIndex);
      final value = values[i].clamp(0.0, 1.0).toDouble();
      final y = size.height * (1 - value);
      points.add(Offset(x, y));
    }

    final linePath = _buildSmoothPath(points);
    final areaPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.2),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

class _RevenueAreaChartPainter extends CustomPainter {
  const _RevenueAreaChartPainter();

  static const List<double> _revenue = <double>[
    0.08,
    0.12,
    0.24,
    0.47,
    0.54,
    0.53,
    0.54,
    0.62,
    0.74,
    0.85,
    0.92,
    0.96,
  ];

  static const List<double> _expenses = <double>[
    0.26,
    0.31,
    0.17,
    0.22,
    0.45,
    0.46,
    0.42,
    0.72,
    0.7,
    0.46,
    0.41,
    0.48,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _kCardBorder.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final expensePoints = _pointsFromValues(_expenses, size);
    final revenuePoints = _pointsFromValues(_revenue, size);

    final expenseLine = _buildSmoothPath(expensePoints);
    final revenueLine = _buildSmoothPath(revenuePoints);

    final expenseArea = Path.from(expenseLine)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final revenueArea = Path.from(revenueLine)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      expenseArea,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _kAccentBlue.withValues(alpha: 0.22),
            _kAccentBlue.withValues(alpha: 0.01),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      revenueArea,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _kAccentPurple.withValues(alpha: 0.24),
            _kAccentPurple.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      expenseLine,
      Paint()
        ..color = _kAccentBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    canvas.drawPath(
      revenueLine,
      Paint()
        ..color = _kAccentPurple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    final focusPoint = revenuePoints[5];
    canvas.drawCircle(focusPoint, 6.5, Paint()..color = _kCardBackground);
    canvas.drawCircle(
      focusPoint,
      5.8,
      Paint()
        ..color = _kAccentPurple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(revenuePoints.last, 4, Paint()..color = _kAccentPurple);
    canvas.drawCircle(expensePoints.last, 4, Paint()..color = _kAccentBlue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  List<Offset> _pointsFromValues(List<double> values, Size size) {
    final points = <Offset>[];
    final lastIndex = values.length - 1;
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / lastIndex);
      final value = values[i].clamp(0.0, 1.0).toDouble();
      final y = size.height * (1 - value);
      points.add(Offset(x, y));
    }
    return points;
  }
}

Path _buildSmoothPath(List<Offset> points) {
  if (points.isEmpty) {
    return Path();
  }
  if (points.length == 1) {
    return Path()..addOval(Rect.fromCircle(center: points.first, radius: 0.1));
  }

  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 0; i < points.length - 1; i++) {
    final p0 = i == 0 ? points[i] : points[i - 1];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i + 2 < points.length ? points[i + 2] : p2;

    final controlPoint1 = Offset(
      p1.dx + (p2.dx - p0.dx) / 6,
      p1.dy + (p2.dy - p0.dy) / 6,
    );
    final controlPoint2 = Offset(
      p2.dx - (p3.dx - p1.dx) / 6,
      p2.dy - (p3.dy - p1.dy) / 6,
    );

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      p2.dx,
      p2.dy,
    );
  }
  return path;
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String deltaText;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.deltaText,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      radius: 8,
      child: SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: _kTextMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(
                        color: _kTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.more_horiz_rounded,
                    size: 17,
                    color: Color(0xFFD9E1FA),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatDeltaBadge(text: deltaText, isPositive: isPositive),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatDeltaBadge extends StatelessWidget {
  final String text;
  final bool isPositive;

  const _StatDeltaBadge({required this.text, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final badgeColor = isPositive
        ? const Color(0x3305C168)
        : const Color(0x33FF5A65);
    final textColor = isPositive ? _kSuccessGreen : const Color(0xFFFF5A65);
    final icon = isPositive
        ? Icons.north_east_rounded
        : Icons.south_east_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: badgeColor, width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontStyle: FontStyle.italic,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(width: 2),
          Icon(icon, size: 10, color: textColor),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final double radius;

  const _DashboardCard({required this.child, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _kCardBorder, width: 0.6),
      ),
      child: child,
    );
  }
}
