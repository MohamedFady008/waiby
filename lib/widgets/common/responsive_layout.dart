import 'package:flutter/material.dart';

class WaibyBreakpoints {
  static const double mobile = 700;
  static const double tablet = 1024;
  static const double desktopContentMaxWidth = 1200;
}

class WaibySpacing {
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;
}

double waibyHorizontalPaddingForWidth(double width) {
  if (width >= WaibyBreakpoints.tablet) {
    return 24;
  }
  if (width >= WaibyBreakpoints.mobile) {
    return 20;
  }
  return 16;
}

class WaibyConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double? horizontalPadding;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const WaibyConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = WaibyBreakpoints.desktopContentMaxWidth,
    this.horizontalPadding,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedHorizontalPadding =
            horizontalPadding ??
            waibyHorizontalPaddingForWidth(constraints.maxWidth);

        return Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding:
                  padding ??
                  EdgeInsets.symmetric(horizontal: resolvedHorizontalPadding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
