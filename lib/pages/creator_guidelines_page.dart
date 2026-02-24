import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waiby/widgets/waiby_footer.dart';

import '../widgets/common/waiby_common.dart';

class CreatorGuidelinesPage extends StatefulWidget {
  const CreatorGuidelinesPage({super.key});

  @override
  State<CreatorGuidelinesPage> createState() => _CreatorGuidelinesPageState();
}

class _CreatorGuidelinesPageState extends State<CreatorGuidelinesPage> {
  static const int _requiredCorrectAnswers = 15;

  bool _rulesAccepted = false;
  late final List<int?> _answers = List<int?>.filled(
    _knowledgeQuestions.length,
    null,
  );

  int get _answeredCount => _answers.where((value) => value != null).length;

  int get _correctAnswers {
    var correct = 0;
    for (var i = 0; i < _knowledgeQuestions.length; i++) {
      if (_answers[i] == _knowledgeQuestions[i].correctOptionIndex) {
        correct += 1;
      }
    }
    return correct;
  }

  int get _scorePercentage {
    return ((_correctAnswers / _knowledgeQuestions.length) * 100).round();
  }

  void _onSubmit() {
    if (!_rulesAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the test rules before submitting.'),
        ),
      );
      return;
    }

    if (_answeredCount != _knowledgeQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all questions before submitting ($_answeredCount/${_knowledgeQuestions.length}).',
          ),
        ),
      );
      return;
    }

    final passed = _correctAnswers >= _requiredCorrectAnswers;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14151C),
          title: Text(
            passed ? 'Test Passed' : 'Test Not Passed',
            style: GoogleFonts.notoSans(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          content: Text(
            'You answered $_correctAnswers/${_knowledgeQuestions.length} correctly ($_scorePercentage%). ${passed ? "You passed the required score." : "Required score is $_requiredCorrectAnswers/${_knowledgeQuestions.length}. Please review the rules and try again."}',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
                      final horizontalPadding = pageHorizontalPadding(
                        constraints.maxWidth,
                      );
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              40,
                              horizontalPadding,
                              0,
                            ),
                            child: _KnowledgeTestContent(
                              rulesAccepted: _rulesAccepted,
                              answeredCount: _answeredCount,
                              answers: _answers,
                              onRulesAcceptedChanged: (value) {
                                setState(() => _rulesAccepted = value);
                              },
                              onAnswerSelected: (questionIndex, optionIndex) {
                                if (!_rulesAccepted) return;
                                setState(
                                  () => _answers[questionIndex] = optionIndex,
                                );
                              },
                              onSubmit: _onSubmit,
                            ),
                          ),
                          const SizedBox(height: 90),
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

class _KnowledgeTestContent extends StatelessWidget {
  const _KnowledgeTestContent({
    required this.rulesAccepted,
    required this.answeredCount,
    required this.answers,
    required this.onRulesAcceptedChanged,
    required this.onAnswerSelected,
    required this.onSubmit,
  });

  final bool rulesAccepted;
  final int answeredCount;
  final List<int?> answers;
  final ValueChanged<bool> onRulesAcceptedChanged;
  final void Function(int questionIndex, int optionIndex) onAnswerSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final titleSize = width < 760 ? 33.0 : 41.0;
    final questionSize = width < 760 ? 17.0 : 20.0;
    final optionSize = width < 760 ? 13.0 : 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creator Knowledge Test',
          style: GoogleFonts.notoSans(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This test checks your understanding of WAIBY creator rules before final review.',
          style: GoogleFonts.notoSans(
            fontSize: compact ? 14 : 17,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.86),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF2C94C)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You must get at least 15/20 correct answers to pass this test.',
                style: GoogleFonts.notoSans(
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF2C94C),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF1B234B), thickness: 0.5, height: 0.5),
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111A3A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF2A3B86), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Test Rules',
                style: GoogleFonts.notoSans(
                  fontSize: compact ? 15 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              for (final rule in _testRules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '- $rule',
                    style: GoogleFonts.notoSans(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.35,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => onRulesAcceptedChanged(!rulesAccepted),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      rulesAccepted
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: const Color(0xFF52E37B),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I read, accept, and understand these test rules.',
                        style: GoogleFonts.notoSans(
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Answered: $answeredCount/${_knowledgeQuestions.length}',
          style: GoogleFonts.notoSans(
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < _knowledgeQuestions.length; i++) ...[
          _QuestionBlock(
            questionNumber: i + 1,
            question: _knowledgeQuestions[i],
            selectedOptionIndex: answers[i],
            enabled: rulesAccepted,
            questionSize: questionSize,
            optionSize: optionSize,
            onSelect: (optionIndex) => onAnswerSelected(i, optionIndex),
          ),
          const SizedBox(height: 24),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF51D76E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Submit Test'),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.questionNumber,
    required this.question,
    required this.selectedOptionIndex,
    required this.enabled,
    required this.questionSize,
    required this.optionSize,
    required this.onSelect,
  });

  final int questionNumber;
  final _KnowledgeQuestion question;
  final int? selectedOptionIndex;
  final bool enabled;
  final double questionSize;
  final double optionSize;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$questionNumber. ${question.prompt}',
          style: GoogleFonts.notoSans(
            fontSize: questionSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < question.options.length; i++)
          InkWell(
            onTap: enabled ? () => onSelect(i) : null,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selectedOptionIndex == i
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: enabled
                        ? const Color(0xFF52E37B)
                        : Colors.white.withValues(alpha: 0.35),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.options[i],
                      style: GoogleFonts.notoSans(
                        fontSize: optionSize,
                        fontWeight: FontWeight.w500,
                        color: enabled
                            ? Colors.white.withValues(alpha: 0.92)
                            : Colors.white.withValues(alpha: 0.42),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _KnowledgeQuestion {
  const _KnowledgeQuestion({
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
}

const List<String> _testRules = [
  'You have 3 attempts to complete this test.',
  'You must score at least 15/20 to pass.',
  'You can review the rules before submitting your answers.',
  'If you fail, your application may be paused and can be retried after 3 days.',
  'Reading the full guideline page is strongly recommended.',
];

const List<_KnowledgeQuestion> _knowledgeQuestions = [
  _KnowledgeQuestion(
    prompt: 'What type of platform is WAIBY?',
    options: [
      'Adult and explicit roleplay platform',
      'A profile gaming and private social sessions platform',
      'A freelancing marketplace',
      'A streaming and influencer platform',
    ],
    correctOptionIndex: 1,
  ),
  _KnowledgeQuestion(
    prompt: 'Your relationship with WAIBY is best described as:',
    options: [
      'Employee',
      'Partner',
      'Independent creator',
      'Contractor with guaranteed income',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'Does WAIBY guarantee bookings, income, or visibility?',
    options: [
      'Yes, if your profile is complete',
      'Yes, for top creators only',
      'No',
      'Only during promotions',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'Which content is strictly prohibited on WAIBY?',
    options: [
      'Coaching and tutoring',
      'Friendly chatting',
      'Scam, explicit, or sexual content',
      'Playing games together',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt:
        'What must you do if a customer requests sexual or prohibited content?',
    options: [
      'Ignore and proceed',
      'Comply if the customer insists',
      'Clearly refuse and report if it continues',
      'Move the discussion off platform',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'Where must all orders be created and paid?',
    options: [
      'Any platform accepted by the creator',
      'PayPal or crypto transfer',
      'WAIBY only',
      'In person',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'Which of the following is allowed in competitive games?',
    options: [
      'Losing matches intentionally',
      'Fixing win/loss with customers',
      'Coaching and playing together',
      'Boosting with cheats',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'Can platform fees change over time?',
    options: [
      'No, the fee is permanent',
      'Yes, but only after email notice',
      'Yes, with terms updates',
      'Only once per year',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'When do you accept the platform fee?',
    options: [
      'When signing up',
      'When your account is banned',
      'When you confirm a withdrawal',
      'At the end of each month',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'What is the current platform fee?',
    options: ['10%', '15%', '20%', 'No fixed platform fee'],
    correctOptionIndex: 1,
  ),
  _KnowledgeQuestion(
    prompt: 'Are completed orders immune to chargebacks?',
    options: ['Yes', 'Only for top creators', 'No', 'Only after 24 hours'],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'How long after completion can a chargeback occur?',
    options: [
      'Within the same day',
      'Up to 72 hours',
      'Days or weeks later',
      'Never after completion',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'What may happen to funds during disputes or chargeback reviews?',
    options: [
      'They are never delayed',
      'They may be held or delayed',
      'They are automatically refunded',
      'WAIBY never touches balances',
    ],
    correctOptionIndex: 1,
  ),
  _KnowledgeQuestion(
    prompt:
        'Can WAIBY suspend an account without a fully proven final violation?',
    options: [
      'No, proof is always required',
      'Yes, to prevent risk or harm',
      'Only with court order',
      'Only after repeated warnings',
    ],
    correctOptionIndex: 1,
  ),
  _KnowledgeQuestion(
    prompt: 'Platform access on WAIBY is considered:',
    options: [
      'A guaranteed right',
      'A paid entitlement',
      'A privilege',
      'A no-risk service',
    ],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt:
        'Are WAIBY staff members allowed to operate as creators with special advantages?',
    options: ['Yes, during events', 'Yes, if disclosed', 'No', 'Only support'],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt:
        'Does participating in events give creators ranking or moderation advantages?',
    options: ['Yes', 'Sometimes', 'No', 'Only if paid'],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt: 'Are balances on WAIBY considered a personal bank account?',
    options: ['Yes', 'Sometimes', 'No', 'Only before withdrawal'],
    correctOptionIndex: 2,
  ),
  _KnowledgeQuestion(
    prompt:
        'What happens if a creator manipulates additional accounts for fake reports?',
    options: [
      'Warning from staff before decision',
      'Account can be suspended and penalties may apply',
      'Limited suspension only in special cases',
      'The report is ignored',
    ],
    correctOptionIndex: 1,
  ),
  _KnowledgeQuestion(
    prompt: 'What law governs the WAIBY Creator Agreement?',
    options: [
      'All international laws',
      'United Kingdom',
      'Serbia',
      "The creator's local country",
    ],
    correctOptionIndex: 2,
  ),
];
