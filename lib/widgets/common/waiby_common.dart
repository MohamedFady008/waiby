import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

double pageHorizontalPadding(double width) {
  if (width >= 1440) return 140;
  if (width >= 1100) return 80;
  if (width >= 900) return 40;
  return 16;
}

class SupportChatFab extends StatelessWidget {
  final VoidCallback? onPressed;

  const SupportChatFab({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: FloatingActionButton(
        onPressed: onPressed ?? () {},
        backgroundColor: const Color(0xFF51D76E),
        foregroundColor: Colors.white,
        elevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble_rounded, size: 28),
      ),
    );
  }
}

class WaibyGradientButton extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  const WaibyGradientButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    this.onTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(5);
    final labelStyle =
        textStyle ??
        GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.black,
          height: 21 / 14,
        );

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFCCF308), Color(0xFFEDDB74), Color(0xFFCCF308)],
              stops: [0.1394, 0.5, 0.8846],
            ),
          ),
          child: Center(child: Text(label, style: labelStyle)),
        ),
      ),
    );
  }
}
