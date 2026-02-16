import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class BaseSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;
  final String description;
  final String statusText;
  final Color? statusColor;

  const BaseSettingsBody({
    super.key,
    required this.entry,
    required this.description,
    this.statusText = 'Ready',
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDanger = entry.isDanger;
    final accentColor =
        statusColor ??
        (isDanger ? const Color(0xFFFF2A32) : const Color(0xFF4E7FF0));

    return Container(
      constraints: const BoxConstraints(minHeight: 460),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Main Body',
            style: GoogleFonts.nunitoSans(
              color: const Color(0xFFA8AEC2),
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    const Color.fromRGBO(255, 255, 255, 0.08),
                    accentColor,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(entry.icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  entry.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: GoogleFonts.nunitoSans(
              color: const Color(0xFFD2D6E5),
              fontWeight: FontWeight.w600,
              fontSize: 17,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoCard(
                title: 'Active Tab',
                value: entry.title,
                valueColor: Colors.white,
              ),
              _InfoCard(
                title: 'Status',
                value: statusText,
                valueColor: accentColor,
              ),
              const _InfoCard(
                title: 'Responsive',
                value: 'Enabled',
                valueColor: Color(0xFF8CE99A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              color: const Color(0xFF9CA2B9),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
