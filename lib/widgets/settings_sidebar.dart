import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class SettingsSidebarMenuEntry {
  final String key;
  final String title;
  final IconData icon;
  final bool isDanger;

  const SettingsSidebarMenuEntry({
    required this.key,
    required this.title,
    required this.icon,
    this.isDanger = false,
  });
}

class SettingsSidebarDefaults {
  static const List<SettingsSidebarMenuEntry> topEntries =
      <SettingsSidebarMenuEntry>[
        SettingsSidebarMenuEntry(
          key: 'dashboard',
          title: 'Dashboard',
          icon: Icons.av_timer_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'services',
          title: 'Services',
          icon: Icons.grid_view_rounded,
        ),
        SettingsSidebarMenuEntry(
          key: 'customers',
          title: 'My Customers',
          icon: Icons.favorite_border_rounded,
        ),
        SettingsSidebarMenuEntry(
          key: 'chat',
          title: 'Chat',
          icon: Icons.chat_bubble_outline_rounded,
        ),
        SettingsSidebarMenuEntry(
          key: 'wallet',
          title: 'Wallet',
          icon: Icons.account_balance_wallet_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'vip',
          title: 'Subscriptions and VIP',
          icon: Icons.card_giftcard_rounded,
        ),
      ];

  static const List<SettingsSidebarMenuEntry> pageEntries =
      <SettingsSidebarMenuEntry>[
        SettingsSidebarMenuEntry(
          key: 'score-rate',
          title: 'Score Rate',
          icon: Icons.checklist_rtl_rounded,
        ),
        SettingsSidebarMenuEntry(
          key: 'calendar',
          title: 'Calender',
          icon: Icons.calendar_month_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'orders',
          title: 'Orders',
          icon: Icons.inventory_2_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'rankings',
          title: 'Rankings',
          icon: Icons.groups_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'influencer',
          title: 'Influencer program',
          icon: Icons.redeem_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'store',
          title: 'Store',
          icon: Icons.storefront_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'profile',
          title: 'Profile',
          icon: Icons.person_outline_rounded,
        ),
        SettingsSidebarMenuEntry(
          key: 'tickets',
          title: 'Support Tickets',
          icon: Icons.confirmation_number_outlined,
        ),
      ];

  static const List<SettingsSidebarMenuEntry> bottomEntries =
      <SettingsSidebarMenuEntry>[
        SettingsSidebarMenuEntry(
          key: 'settings',
          title: 'Settings',
          icon: Icons.settings_outlined,
        ),
        SettingsSidebarMenuEntry(
          key: 'logout',
          title: 'Logout',
          icon: Icons.power_settings_new_rounded,
          isDanger: true,
        ),
      ];

  static const List<SettingsSidebarMenuEntry> allEntries =
      <SettingsSidebarMenuEntry>[
        ...topEntries,
        ...pageEntries,
        ...bottomEntries,
      ];
}

class SettingsSidebarPanel extends StatelessWidget {
  static const double _minTargetHeight = 460;
  static const double _maxTargetHeight = 894;

  final String selectedKey;
  final ValueChanged<String> onSelect;
  final bool drawRightBorder;
  final List<SettingsSidebarMenuEntry> topEntries;
  final List<SettingsSidebarMenuEntry> pageEntries;
  final List<SettingsSidebarMenuEntry> bottomEntries;

  const SettingsSidebarPanel({
    super.key,
    required this.selectedKey,
    required this.onSelect,
    required this.drawRightBorder,
    this.topEntries = SettingsSidebarDefaults.topEntries,
    this.pageEntries = SettingsSidebarDefaults.pageEntries,
    this.bottomEntries = SettingsSidebarDefaults.bottomEntries,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : _maxTargetHeight;
        final density =
            ((availableHeight - _minTargetHeight) /
                    (_maxTargetHeight - _minTargetHeight))
                .clamp(0.0, 1.0);
        final baseMetrics = _SettingsSidebarMetrics.fromDensity(density);
        final estimatedHeight = baseMetrics.estimateContentHeight(
          topItemCount: topEntries.length,
          pageItemCount: pageEntries.length,
          bottomItemCount: bottomEntries.length,
        );
        final safeHeight = math.max(availableHeight - 2, 0);
        final fitRatio = estimatedHeight <= safeHeight
            ? 1.0
            : (safeHeight / estimatedHeight).clamp(0.0, 1.0);
        final metrics = baseMetrics.scaled(fitRatio);
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: metrics.afterLogoGap),
            ..._buildMenuItems(topEntries, metrics: metrics),
            SizedBox(height: metrics.sectionGapBeforeDivider),
            const Divider(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: metrics.sectionGapAfterDivider),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.logoHorizontalPadding,
              ),
              child: Text(
                'PAGES',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFFAEB0B8),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  fontSize: metrics.pagesLabelSize,
                ),
              ),
            ),
            SizedBox(height: metrics.afterPagesLabelGap),
            ..._buildMenuItems(pageEntries, metrics: metrics),
            SizedBox(height: metrics.sectionGapBeforeDivider),
            const Divider(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              height: 1,
              thickness: 1,
            ),
            SizedBox(height: metrics.sectionGapAfterDivider),
            ..._buildMenuItems(bottomEntries, metrics: metrics),
          ],
        );

        return Container(
          decoration: BoxDecoration(
            border: drawRightBorder
                ? const Border(
                    right: BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.12),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              metrics.horizontalPadding,
              metrics.topPadding,
              metrics.horizontalPadding,
              metrics.bottomPadding,
            ),
            child:
                constraints.hasBoundedHeight && constraints.maxHeight.isFinite
                ? SingleChildScrollView(primary: false, child: content)
                : content,
          ),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(
    List<SettingsSidebarMenuEntry> entries, {
    required _SettingsSidebarMetrics metrics,
  }) {
    final widgets = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      widgets.add(
        _SettingsSidebarMenuTile(
          entry: entry,
          isActive: selectedKey == entry.key,
          onTap: () => onSelect(entry.key),
          tileHeight: metrics.tileHeight,
          iconSize: metrics.iconSize,
          textSize: metrics.textSize,
          tileRadius: metrics.tileRadius,
          leadingInset: metrics.leadingInset,
          iconLabelGap: metrics.iconLabelGap,
          indicatorWidth: metrics.indicatorWidth,
        ),
      );
      if (i < entries.length - 1) {
        widgets.add(SizedBox(height: metrics.itemGap));
      }
    }
    return widgets;
  }
}

class _SettingsSidebarMenuTile extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;
  final bool isActive;
  final VoidCallback onTap;
  final double tileHeight;
  final double iconSize;
  final double textSize;
  final double tileRadius;
  final double leadingInset;
  final double iconLabelGap;
  final double indicatorWidth;

  const _SettingsSidebarMenuTile({
    required this.entry,
    required this.isActive,
    required this.onTap,
    required this.tileHeight,
    required this.iconSize,
    required this.textSize,
    required this.tileRadius,
    required this.leadingInset,
    required this.iconLabelGap,
    required this.indicatorWidth,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = entry.isDanger
        ? const Color(0x3DFF202A)
        : const Color(0xFF4E7FF0);

    final baseColor = entry.isDanger ? const Color(0xFFFF1D25) : Colors.white;

    final contentColor = isActive ? Colors.white : baseColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tileRadius),
        child: SizedBox(
          height: tileHeight,
          child: Row(
            children: [
              /// ===== Indicator OUTSIDE =====
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: isActive ? indicatorWidth : 0,
                margin: EdgeInsets.only(right: leadingInset),
                decoration: BoxDecoration(
                  color: isActive
                      ? (entry.isDanger
                            ? const Color(0xFFFF3A41)
                            : const Color(0xFF4E7FF0))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              /// ===== TILE BODY =====
              Expanded(
                child: Ink(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isActive ? highlightColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(tileRadius),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: leadingInset),

                      Icon(entry.icon, size: iconSize, color: contentColor),

                      SizedBox(width: iconLabelGap),

                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunitoSans(
                            color: contentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: textSize,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
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

@immutable
class _SettingsSidebarMetrics {
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double logoTopGap;
  final double logoHorizontalPadding;
  final double logoFontSize;
  final double afterLogoGap;
  final double sectionGapBeforeDivider;
  final double sectionGapAfterDivider;
  final double pagesLabelSize;
  final double afterPagesLabelGap;
  final double tileHeight;
  final double itemGap;
  final double iconSize;
  final double textSize;
  final double tileRadius;
  final double leadingInset;
  final double iconLabelGap;
  final double indicatorWidth;

  const _SettingsSidebarMetrics({
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.logoTopGap,
    required this.logoHorizontalPadding,
    required this.logoFontSize,
    required this.afterLogoGap,
    required this.sectionGapBeforeDivider,
    required this.sectionGapAfterDivider,
    required this.pagesLabelSize,
    required this.afterPagesLabelGap,
    required this.tileHeight,
    required this.itemGap,
    required this.iconSize,
    required this.textSize,
    required this.tileRadius,
    required this.leadingInset,
    required this.iconLabelGap,
    required this.indicatorWidth,
  });

  factory _SettingsSidebarMetrics.fromDensity(double density) {
    double mix(double min, double max) => min + ((max - min) * density);

    return _SettingsSidebarMetrics(
      horizontalPadding: mix(10, 18),
      topPadding: mix(4, 14),
      bottomPadding: mix(8, 20),
      logoTopGap: mix(0, 2),
      logoHorizontalPadding: mix(4, 8),
      logoFontSize: mix(24, 48),
      afterLogoGap: mix(6, 24),
      sectionGapBeforeDivider: mix(16, 24),
      sectionGapAfterDivider: mix(14, 20),
      pagesLabelSize: mix(10, 14),
      afterPagesLabelGap: mix(4, 10),
      tileHeight: mix(24, 42),
      itemGap: mix(6, 10),
      iconSize: mix(16, 26),
      textSize: mix(11, 16),
      tileRadius: mix(7, 12),
      leadingInset: mix(8, 12),
      iconLabelGap: mix(10, 18),
      indicatorWidth: mix(2.5, 4),
    );
  }

  _SettingsSidebarMetrics scaled(double ratio) {
    final clamped = ratio.clamp(0.0, 1.0);
    return _SettingsSidebarMetrics(
      horizontalPadding: horizontalPadding * clamped,
      topPadding: topPadding * clamped,
      bottomPadding: bottomPadding * clamped,
      logoTopGap: logoTopGap * clamped,
      logoHorizontalPadding: logoHorizontalPadding * clamped,
      logoFontSize: logoFontSize * clamped,
      afterLogoGap: afterLogoGap * clamped,
      sectionGapBeforeDivider: sectionGapBeforeDivider * clamped,
      sectionGapAfterDivider: sectionGapAfterDivider * clamped,
      pagesLabelSize: pagesLabelSize * clamped,
      afterPagesLabelGap: afterPagesLabelGap * clamped,
      tileHeight: tileHeight * clamped,
      itemGap: itemGap * clamped,
      iconSize: iconSize * clamped,
      textSize: textSize * clamped,
      tileRadius: tileRadius * clamped,
      leadingInset: leadingInset * clamped,
      iconLabelGap: iconLabelGap * clamped,
      indicatorWidth: indicatorWidth * clamped,
    );
  }

  double estimateContentHeight({
    required int topItemCount,
    required int pageItemCount,
    required int bottomItemCount,
  }) {
    final itemCount = topItemCount + pageItemCount + bottomItemCount;
    final itemGapCount =
        math.max(topItemCount - 1, 0) +
        math.max(pageItemCount - 1, 0) +
        math.max(bottomItemCount - 1, 0);
    final staticHeight =
        topPadding +
        bottomPadding +
        logoTopGap +
        logoFontSize +
        afterLogoGap +
        sectionGapBeforeDivider +
        1 +
        sectionGapAfterDivider +
        (pagesLabelSize * 1.2) +
        afterPagesLabelGap +
        sectionGapBeforeDivider +
        1 +
        sectionGapAfterDivider;
    final listHeight = (itemCount * tileHeight) + (itemGapCount * itemGap);
    return staticHeight + listHeight;
  }
}
