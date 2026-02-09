import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/common/waiby_common.dart';

class CreatorFormPage extends StatelessWidget {
  const CreatorFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: const Color(0xFF0C0C13),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1910),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = pageHorizontalPadding(width);
                      final useTwoColumns = width >= 1060;
                      final sectionGap = useTwoColumns ? 28.0 : 18.0;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          40,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Become a Waiby Creator",
                              style: GoogleFonts.notoSans(
                                fontSize: width < 700 ? 28 : 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 49 / 36,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Applying is free and only takes a few minutes. You'll receive an update within 48 hours",
                              style: GoogleFonts.notoSans(
                                fontSize: width < 700 ? 16 : 19,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 27 / 20,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(
                              color: Color(0xFF1B234B),
                              thickness: 0.5,
                              height: 0.5,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Basic Information",
                              style: GoogleFonts.notoSans(
                                fontSize: width < 700 ? 27 : 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 44 / 32,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (useTwoColumns)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 10,
                                    child: _BasicInformationForm(),
                                  ),
                                  SizedBox(width: sectionGap),
                                  SizedBox(
                                    width: math.min(493, width * 0.31),
                                    child: const _IdentityVerificationCard(),
                                  ),
                                ],
                              )
                            else ...[
                              const _BasicInformationForm(),
                              const SizedBox(height: 18),
                              const _IdentityVerificationCard(),
                            ],
                            const SizedBox(height: 24),
                            const Divider(
                              color: Color(0xFF1B234B),
                              thickness: 0.5,
                              height: 0.5,
                            ),
                            const SizedBox(height: 20),
                            if (useTwoColumns)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    flex: 10,
                                    child: _CreatorIntroductionSection(),
                                  ),
                                  SizedBox(width: sectionGap),
                                  const Expanded(
                                    flex: 7,
                                    child: _LegalAcknowledgementSection(),
                                  ),
                                ],
                              )
                            else ...[
                              const _CreatorIntroductionSection(),
                              const SizedBox(height: 18),
                              const _LegalAcknowledgementSection(),
                            ],
                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          right: 24,
          bottom: 24,
          child: SafeArea(child: SupportChatFab()),
        ),
      ],
    );
  }
}

class _BasicInformationForm extends StatelessWidget {
  const _BasicInformationForm();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final twoCols = width >= 600;
        final gap = twoCols ? 20.0 : 0.0;
        final fieldWidth = twoCols ? (width - gap) / 2 : width;

        Widget pairField({
          required String leftLabel,
          required Widget leftField,
          String? leftHint,
          String? leftSubText,
          required String rightLabel,
          required Widget rightField,
          String? rightHint,
        }) {
          if (twoCols) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: _LabeledField(
                    label: leftLabel,
                    hint: leftHint,
                    subText: leftSubText,
                    child: leftField,
                  ),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: fieldWidth,
                  child: _LabeledField(
                    label: rightLabel,
                    hint: rightHint,
                    child: rightField,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _LabeledField(
                label: leftLabel,
                hint: leftHint,
                subText: leftSubText,
                child: leftField,
              ),
              const SizedBox(height: 18),
              _LabeledField(
                label: rightLabel,
                hint: rightHint,
                child: rightField,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledField(
              label: "Full legal name",
              child: const _InputField(height: 52),
            ),
            const SizedBox(height: 16),
            pairField(
              leftLabel: "Date of birth",
              leftSubText: "You must be 18 years or older to apply",
              leftField: const _InputField(
                height: 52,
                trailing: Icon(
                  Icons.calendar_month_rounded,
                  size: 24,
                  color: Color(0x45FFFFFF),
                ),
              ),
              rightLabel: "Country of residence",
              rightField: const _InputField(height: 52),
            ),
            const SizedBox(height: 16),
            pairField(
              leftLabel: "Discord username",
              leftField: const _InputField(height: 52),
              rightLabel: "Primary language/s",
              rightField: const _InputField(height: 52),
            ),
          ],
        );
      },
    );
  }
}

class _CreatorIntroductionSection extends StatelessWidget {
  const _CreatorIntroductionSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Creator Introduction",
          style: GoogleFonts.notoSans(
            fontSize: width < 700 ? 27 : 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 44 / 32,
          ),
        ),
        const SizedBox(height: 18),
        const _LabeledField(
          label: "Tell us about yourself",
          child: _CountedTextArea(maxLength: 500, height: 220),
        ),
        const SizedBox(height: 18),
        const _LabeledField(
          label: "Why do you want to become a Waiby Creator?",
          child: _CountedTextArea(maxLength: 500, height: 220),
        ),
      ],
    );
  }
}

class _LegalAcknowledgementSection extends StatelessWidget {
  const _LegalAcknowledgementSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final medium = width < 1200;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Legal Acknowledgement",
          style: GoogleFonts.notoSans(
            fontSize: compact ? 27 : 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 44 / 32,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "By applying to become a Waiby Creator, you acknowledge and agree that:",
          style: GoogleFonts.notoSans(
            fontSize: compact ? 15 : (medium ? 17 : 19),
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 27 / 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "- The information provided is accurate and truthful\n"
          "- Your identity and country of residence may be verified\n"
          "- Waiby may request additional verification if required\n"
          "- You agree that Waiby may contact you via your account email regarding this application\n"
          "- You'll complete your full creator profile after approval\n"
          "- Acceptance as a creator is not guaranteed",
          style: GoogleFonts.notoSans(
            fontSize: compact ? 14 : (medium ? 16 : 18),
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "You'll be asked to review and accept the Waiby Creator Agreement only if your application is approved",
          style: GoogleFonts.notoSans(
            fontSize: compact ? 15 : (medium ? 17 : 19),
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "All information provided will be stored securely and may be retained regardless of the application outcome, in accordance with legal requirements",
          style: GoogleFonts.notoSans(
            fontSize: compact ? 15 : (medium ? 17 : 19),
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        WaibyGradientButton(
          width: compact ? double.infinity : (medium ? 250 : 270),
          height: 56,
          label: 'Submit application',
          textStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 30 / 20,
          ),
        ),
      ],
    );
  }
}

class _IdentityVerificationCard extends StatelessWidget {
  const _IdentityVerificationCard();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14151C),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Identity Verification",
            style: GoogleFonts.notoSans(
              fontSize: compact ? 17 : 19,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 27 / 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "This information is required for legal compliance and will be handled securely",
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 19 / 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Upload your ID or Passport",
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 19 / 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              color: const Color(0xFF080912),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_upload_rounded,
                    size: 66,
                    color: Color(0xFF636363),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Drag & Drop files here",
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 19 / 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 28,
                    constraints: const BoxConstraints(minWidth: 125),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF636363),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Browse files",
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 19 / 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1B234B), thickness: 0.5, height: 0.5),
          const SizedBox(height: 12),
          Text(
            "Complete face verification",
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 27 / 20,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF636363),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Start face verification",
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 20 / 15,
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.hint,
    this.subText,
  });

  final String label;
  final Widget child;
  final String? hint;
  final String? subText;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 27 / 20,
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (subText != null) ...[
          const SizedBox(height: 4),
          Text(
            subText!,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.51),
              height: 16 / 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.height, this.trailing});

  final double height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF222329),
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          ...[trailing].nonNulls,
        ],
      ),
    );
  }
}

class _CountedTextArea extends StatefulWidget {
  const _CountedTextArea({required this.maxLength, required this.height});

  final int maxLength;
  final double height;

  @override
  State<_CountedTextArea> createState() => _CountedTextAreaState();
}

class _CountedTextAreaState extends State<_CountedTextArea> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF222329),
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Stack(
        children: [
          Positioned.fill(
            child: TextField(
              controller: _controller,
              maxLength: widget.maxLength,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                isCollapsed: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              "Max ${widget.maxLength}",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: Colors.white.withValues(alpha: 0.34),
                height: 15 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
