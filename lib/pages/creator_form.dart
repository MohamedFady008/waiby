import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waiby/widgets/waiby_footer.dart';

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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1910),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = pageHorizontalPadding(width);
                      final useTwoColumns = width >= 1060;
                      final sectionGap = useTwoColumns ? 28.0 : 18.0;

                      return Column(
                        children: [
                          Padding(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 10,
                                        child: _BasicInformationForm(),
                                      ),
                                      SizedBox(width: sectionGap),
                                      SizedBox(
                                        width: math.min(493, width * 0.31),
                                        child:
                                            const _IdentityVerificationCard(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                          SizedBox(height: 100),
                          const WaibyFooter(),
                        ],
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
          onTap: () => _showCreatorGuidelinesDialog(context),
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

Future<void> _showCreatorGuidelinesDialog(BuildContext context) async {
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _CreatorGuidelinesIntroDialog(),
  );

  if (!context.mounted || accepted != true) return;
  context.go('/become-creator/creator-guidelines');
}

class _CreatorGuidelinesIntroDialog extends StatefulWidget {
  const _CreatorGuidelinesIntroDialog();

  @override
  State<_CreatorGuidelinesIntroDialog> createState() =>
      _CreatorGuidelinesIntroDialogState();
}

class _CreatorGuidelinesIntroDialogState
    extends State<_CreatorGuidelinesIntroDialog> {
  int _stepIndex = 0;
  bool _accepted = false;

  bool get _isLastStep => _stepIndex == _dialogSteps.length - 1;

  void _goNext() {
    if (_isLastStep) return;
    setState(() => _stepIndex += 1);
  }

  void _goBack() {
    if (_stepIndex == 0) return;
    setState(() => _stepIndex -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final step = _dialogSteps[_stepIndex];
    final compact = MediaQuery.sizeOf(context).width < 700;

    return Dialog(
      backgroundColor: const Color(0xFF14151C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, compact ? 18 : 22, 22, 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Creator Onboarding',
                        style: GoogleFonts.notoSans(
                          fontSize: compact ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Step ${_stepIndex + 1} of ${_dialogSteps.length}',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: (_stepIndex + 1) / _dialogSteps.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: const Color(0xFF222329),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFCCF308),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  step.title,
                  style: GoogleFonts.notoSans(
                    fontSize: compact ? 20 : 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  step.body,
                  style: GoogleFonts.notoSans(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.45,
                  ),
                ),
                if (_isLastStep) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C13),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _accepted,
                          activeColor: const Color(0xFFCCF308),
                          checkColor: Colors.black,
                          onChanged: (value) {
                            setState(() => _accepted = value ?? false);
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'I confirm that I have read, understood, and agree to follow these Creator Guidelines and the Creator Agreement.',
                              style: GoogleFonts.notoSans(
                                fontSize: compact ? 13 : 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: _stepIndex == 0 ? null : _goBack,
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    if (!_isLastStep)
                      SizedBox(
                        width: compact ? 120 : 140,
                        height: 44,
                        child: WaibyGradientButton(
                          width: compact ? 120 : 140,
                          height: 44,
                          label: 'Next',
                          onTap: _goNext,
                          textStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _accepted
                              ? () => Navigator.of(context).pop(true)
                              : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xFFCCF308),
                            disabledBackgroundColor: const Color(0xFF5D5D5D),
                            disabledForegroundColor: const Color(0xFFBFBFBF),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Continue'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogStepData {
  const _DialogStepData({required this.title, required this.body});

  final String title;
  final String body;
}

const List<_DialogStepData> _dialogSteps = [
  _DialogStepData(
    title: '1. What WAIBY Is (and Is Not)',
    body:
        'WAIBY is a platform for paid 1:1 gaming and private social sessions.\n'
        'You may:\n'
        '- Play games together\n'
        '- Chat and spend time socially\n'
        '- Teach, coach, or practice skills\n'
        '\n'
        'WAIBY is NOT:\n'
        '- An adult or sexual content platform\n'
        '- A dating or romance platform\n'
        '- A "girlfriend/boyfriend" experience\n'
        '\n'
        'Clear boundaries are mandatory at all times.',
  ),
  _DialogStepData(
    title: '2. Your Relationship With WAIBY',
    body:
        'You are an independent creator, not an employee, partner, agent, or representative of WAIBY.\n'
        '\n'
        'WAIBY:\n'
        '- Does not guarantee income, bookings, or visibility\n'
        '- Does not promise rankings, promotion, or success\n'
        '\n'
        'You are fully responsible for your behavior, content, and communications, both on and off the platform when related to a WAIBY order.',
  ),
  _DialogStepData(
    title: '3. Respect & Professional Conduct',
    body:
        'You must:\n'
        '- Treat customers and other creators with respect\n'
        '- Communicate clearly and honestly\n'
        '- Respect boundaries at all times\n'
        '\n'
        'Not allowed:\n'
        '- Harassment, bullying, threats, or intimidation\n'
        '- Hate speech or slurs\n'
        '- Manipulation, pressure, or coercion',
  ),
  _DialogStepData(
    title: '4. Strict Content Boundaries',
    body:
        'Strictly prohibited:\n'
        '- Sexual or explicit content of any kind\n'
        '- Sexual roleplay or romantic services\n'
        '- Requests for nudity or sexual favors\n'
        '- Any interaction involving minors (zero tolerance)\n'
        '\n'
        'Violations involving minors result in immediate permanent bans and may be reported to authorities.\n'
        '\n'
        'If a customer requests prohibited content:\n'
        '- You must clearly refuse\n'
        '- You must remind them such content is not allowed\n'
        '- If they continue or escalate, you must report the behavior immediately\n'
        '\n'
        'Failure to refuse or report may result in enforcement action against the creator.',
  ),
  _DialogStepData(
    title: '5. Orders & Payments (Strict Rule)',
    body:
        'All orders must be created and paid on WAIBY.\n'
        '\n'
        'Forbidden:\n'
        '- Off-platform payments (PayPal, crypto, bank transfer, gifts, discounts)\n'
        '\n'
        'Once you accept an order, you are expected to deliver the service as described.',
  ),
  _DialogStepData(
    title: '5A. Competitive Games, Coaching & No-Boosting Policy',
    body:
        'WAIBY is not a boosting, account-selling, or rank-manipulation platform.\n'
        '\n'
        'Allowed:\n'
        '- Playing together\n'
        '- Coaching, guidance, teamwork, learning\n'
        '\n'
        'Strictly prohibited:\n'
        '- Playing on behalf of a customer\n'
        '- Logging into a customer\'s account\n'
        '- Rank boosting or win-trading\n'
        '- Selling accounts, ranks, or progression\n'
        '- Circumventing game rules or anti-cheat systems\n'
        '\n'
        'Violations may result in:\n'
        '- Immediate order cancellation\n'
        '- Loss of competitive privileges\n'
        '- Suspension or permanent ban',
  ),
  _DialogStepData(
    title: '5B. Platform Fees & Withdrawals',
    body:
        'WAIBY currently applies a 15% platform fee on creator earnings.\n'
        '\n'
        'Important:\n'
        '- Platform fees are not fixed and may change in the future\n'
        '- The applicable fee is always shown before confirming a withdrawal\n'
        '- By confirming a withdrawal, you accept the displayed fee\n'
        '\n'
        'It is your responsibility to review:\n'
        '- The fee percentage\n'
        '- The final payout amount\n'
        '\n'
        'Claiming you were unaware of the fee is not accepted as an excuse.',
  ),
  _DialogStepData(
    title: '6. On-Platform First Policy',
    body:
        'Sessions must take place inside WAIBY using platform chat and call features.\n'
        'Moving to external platforms (e.g. Discord/Telegram...) is NOT ALLOWED.\n'
        '\n'
        'You acknowledge that off-platform redirection creates financial and compliance risks for the platform.',
  ),
  _DialogStepData(
    title: '7. Inactive Account Policy (Dormancy)',
    body:
        'Accounts with a positive balance and no login activity for 9 consecutive months may be marked inactive.\n'
        '\n'
        'If no action is taken within 30 days of notification:\n'
        'A dormancy maintenance fee of 5 EUR per month may apply until the balance reaches zero or the account is reactivated.\n'
        '\n'
        'Dormancy fees are administrative in nature and not penalties.',
  ),
  _DialogStepData(
    title: '8. Cancellations, No-Shows & Disputes',
    body:
        'Repeated no-shows or unjustified cancellations may result in penalties or suspension.\n'
        'Orders may auto-complete to prevent abuse.\n'
        'Funds may be held during dispute reviews.',
  ),
  _DialogStepData(
    title: '8A. Chargebacks, Refunds & Fund Holds',
    body:
        'Customers may request chargebacks or refunds through their bank or payment provider, even after a session is completed.\n'
        '\n'
        'You acknowledge that:\n'
        '- Completed orders are not immune to chargebacks\n'
        '- Chargebacks may occur days or weeks later\n'
        '- Funds may be held, delayed, or reversed during reviews\n'
        '\n'
        'Attempting to avoid chargebacks (off-platform payments, compensation, or pressure) is strictly prohibited.',
  ),
  _DialogStepData(
    title: '9. Financial Abuse, Scams & Money Laundering',
    body:
        'Funds on WAIBY exist within an internal platform system and are subject to reviews, disputes, chargebacks, and compliance controls.\n'
        '\n'
        'Creators must not:\n'
        '- Use WAIBY to move money off-platform\n'
        '- Request or accept payments outside WAIBY\n'
        '- Use third-party wallets, gift cards, or crypto\n'
        '- Split payments to avoid fees or reviews\n'
        '- Act as a middleman for money transfers\n'
        '- Participate in scams, chargeback schemes, or fraud\n'
        '\n'
        'Suspicious activity may result in:\n'
        '- Frozen balances\n'
        '- Payment reviews\n'
        '- Suspension or permanent bans\n'
        '- Reports to payment providers or authorities\n'
        '\n'
        'WAIBY is not responsible for losses caused by off-platform transactions.',
  ),
  _DialogStepData(
    title: '10. Creator Conflicts, Jealousy & Coordinated Abuse',
    body:
        'Creators must not:\n'
        '- Harass or attack other creators\n'
        '- Encourage fake reviews\n'
        '- Coordinate harassment or report campaigns\n'
        '- Spread false claims or rumors\n'
        '- Weaponize customers or third parties\n'
        '\n'
        'Such behavior is considered a severe violation.',
  ),
  _DialogStepData(
    title: '11. Fake Reports, False Content & Evidence Manipulation',
    body:
        'Strictly prohibited:\n'
        '- Fake or malicious reports\n'
        '- Edited or cropped screenshots\n'
        '- Fabricated timestamps or proofs\n'
        '- Reused evidence from unrelated orders\n'
        '- Encouraging others to submit false reports\n'
        '\n'
        'Evidence manipulation is treated as system abuse and may be treated as fraud.',
  ),
  _DialogStepData(
    title: '12. Moderation, Monitoring & Shadow Bans',
    body:
        'Certain words and behaviors are automatically moderated.\n'
        'WAIBY may apply:\n'
        '- Shadow bans\n'
        '- Ranking suppression\n'
        '- Temporary restrictions\n'
        '\n'
        'Attempting to bypass moderation systems is treated as intentional abuse.',
  ),
  _DialogStepData(
    title: '12A. Risk-Based Enforcement',
    body:
        'WAIBY may restrict, suspend, or terminate accounts to prevent risk or harm, even if a violation cannot yet be fully proven.\n'
        '\n'
        'This includes suspected:\n'
        '- Fraud\n'
        '- Abuse\n'
        '- Manipulation\n'
        '- Coordinated activity\n'
        '\n'
        'Such actions are preventive. Platform access is a privilege, not a right.',
  ),
  _DialogStepData(
    title: '12B. Staff & Fair Treatment',
    body:
        'Creators are independent from WAIBY staff.\n'
        '\n'
        '- Staff members do not operate as creators\n'
        '- No creator receives boosts, protection, or review manipulation\n'
        '- Participation in events is voluntary and grants no advantages\n'
        '\n'
        'Favoritism is not tolerated.',
  ),
  _DialogStepData(
    title: '13. Reviews, Ratings & Visibility',
    body:
        'Reviews are allowed only after completed paid sessions.\n'
        'Manipulating or incentivizing reviews is forbidden.\n'
        'Visibility and ranking are determined by platform metrics.',
  ),
  _DialogStepData(
    title: '14. Enforcement & Consequences',
    body:
        'Enforcement follows a progressive system:\n'
        'Warning -> penalties -> suspension -> permanent ban\n'
        '\n'
        'Severe violations may result in immediate termination without warning.',
  ),
  _DialogStepData(
    title: '15. Platform Changes',
    body:
        'WAIBY may update rules, systems, features, visibility, rewards, or fees over time.\n'
        'It is your responsibility to stay informed.\n'
        'Continued use of WAIBY means acceptance of updated rules.',
  ),
  _DialogStepData(
    title: 'Final Confirmation',
    body:
        'By continuing, you confirm that you have read, understood, and agree to follow these Creator Guidelines and the Creator Agreement, including rules related to fees, payouts, enforcement, platform changes, and risk management.\n'
        '\n'
        'You must score 15/20 correct answers on the knowledge test to proceed.\n'
        'If you fail, your application will be paused and can be retried after 3 days.',
  ),
  _DialogStepData(
    title: '15. Platform Changes',
    body: 'The Creator Agreement is governed by the laws of Estonia.',
  ),
];

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
