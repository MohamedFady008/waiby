import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_sidebar.dart';
import '../widgets/common/responsive_layout.dart';
import '../widgets/waiby_footer.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final Set<String> _expandedEntryIds = <String>{};

  void _toggleEntry(String id) {
    setState(() {
      if (_expandedEntryIds.contains(id)) {
        _expandedEntryIds.remove(id);
      } else {
        _expandedEntryIds.add(id);
      }
    });
  }

  void _handleFooterLinkTap(WaibyFooterLink link) {
    switch (link) {
      case WaibyFooterLink.browseBuddies:
        context.go('/explore');
        break;
      case WaibyFooterLink.playground:
        context.go('/playground');
        break;
      case WaibyFooterLink.faq:
        context.go('/about');
        break;
      case WaibyFooterLink.helpCenter:
      case WaibyFooterLink.contactSupport:
      case WaibyFooterLink.reportIssue:
        context.go('/report');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final showSidebar = pageWidth >= 1200;
        final compact = pageWidth < WaibyBreakpoints.mobile;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0C122D), Color(0xFF050816)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _FaqBackgroundGlow()),
              SingleChildScrollView(
                padding: EdgeInsets.only(top: compact ? 28 : 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    WaibyConstrainedContent(
                      maxWidth: showSidebar ? 1380 : 1200,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FaqMainContent(
                              compact: compact,
                              expandedEntryIds: _expandedEntryIds,
                              onToggleEntry: _toggleEntry,
                            ),
                          ),
                          if (showSidebar) ...[
                            const SizedBox(width: WaibySpacing.s16),
                            const _FaqRail(),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 72 : 96),
                    WaibyFooter(onLinkTap: _handleFooterLinkTap),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FaqMainContent extends StatelessWidget {
  final bool compact;
  final Set<String> expandedEntryIds;
  final ValueChanged<String> onToggleEntry;

  const _FaqMainContent({
    required this.compact,
    required this.expandedEntryIds,
    required this.onToggleEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Frequently Asked Questions',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: compact ? 22 : 26,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Everything you need to know about WAIBY, payments, orders and safety',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
            fontSize: compact ? 14 : 18,
          ),
        ),
        SizedBox(height: compact ? 24 : 34),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF080D21),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C6FFF).withValues(alpha: 0.1),
                blurRadius: 50,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 34,
              compact ? 22 : 34,
              compact ? 16 : 34,
              compact ? 24 : 34,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _faqSections.length; i++) ...[
                    _FaqSectionBlock(
                      section: _faqSections[i],
                      compact: compact,
                      expandedEntryIds: expandedEntryIds,
                      onToggleEntry: onToggleEntry,
                    ),
                    SizedBox(height: compact ? 18 : 26),
                  ],
                  _PlatformRulesBlock(compact: compact),
                  SizedBox(height: compact ? 90 : 130),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 38 : 54),
        _HelpCenterCallout(compact: compact),
      ],
    );
  }
}

class _FaqSectionBlock extends StatelessWidget {
  final _FaqSection section;
  final bool compact;
  final Set<String> expandedEntryIds;
  final ValueChanged<String> onToggleEntry;

  const _FaqSectionBlock({
    required this.section,
    required this.compact,
    required this.expandedEntryIds,
    required this.onToggleEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF6E839F),
            fontWeight: FontWeight.w600,
            fontSize: compact ? 16 : 20,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < section.items.length; i++) ...[
          _FaqQuestionTile(
            entry: section.items[i],
            compact: compact,
            expanded: expandedEntryIds.contains(section.items[i].id),
            onTap: () => onToggleEntry(section.items[i].id),
          ),
          if (i != section.items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _FaqQuestionTile extends StatelessWidget {
  final _FaqEntry entry;
  final bool compact;
  final bool expanded;
  final VoidCallback onTap;

  const _FaqQuestionTile({
    required this.entry,
    required this.compact,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.white.withValues(alpha: 0.1);
    const borderRadius = BorderRadius.all(Radius.circular(5));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121628),
        border: Border.all(color: borderColor),
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 12 : 13,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.question,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: compact ? 15 : 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      expanded ? Icons.remove : Icons.add,
                      key: ValueKey<bool>(expanded),
                      color: Colors.white,
                      size: compact ? 22 : 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: expanded
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1326),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(5),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      compact ? 12 : 16,
                      compact ? 10 : 12,
                      compact ? 12 : 16,
                      compact ? 12 : 14,
                    ),
                    child: Text(
                      entry.answer,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                        fontSize: compact ? 14 : 16,
                        height: 1.5,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PlatformRulesBlock extends StatelessWidget {
  final bool compact;

  const _PlatformRulesBlock({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLATFORM RULES',
          style: GoogleFonts.poppins(
            color: const Color(0xFF6E839F),
            fontWeight: FontWeight.w600,
            fontSize: compact ? 16 : 20,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF121628),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 20,
            vertical: compact ? 12 : 18,
          ),
          child: Text(
            'WAIBY is built around safety, transparency, and secure transactions.\n'
            'The following are strictly prohibited:\n\n'
            '- Off-platform payments\n'
            '- Explicit or sexual services\n'
            '- Fraud or chargeback abuse\n'
            '- Harassment or abusive behavior\n\n'
            'Users are encouraged to report violations immediately.\n'
            'WAIBY may suspend or terminate accounts in cases of rule violations or risk-related concerns.',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: compact ? 14 : 20,
              height: compact ? 1.5 : 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _HelpCenterCallout extends StatelessWidget {
  final bool compact;

  const _HelpCenterCallout({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Still need help?',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: compact ? 22 : 30,
          ),
        ),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF2FAF55), Color(0xCC51D76E), Color(0xFF6BEF8A)],
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF51D76E).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: compact ? 210 : 259,
            height: compact ? 52 : 59,
            child: TextButton(
              onPressed: () => context.go('/report'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                'Contact Support',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 18 : 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaqRail extends StatelessWidget {
  const _FaqRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Container(
        height: 793,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: const ChatSidebar(
          width: 84,
          padding: EdgeInsets.symmetric(vertical: 10),
          backgroundColor: Colors.transparent,
          avatarSize: 48,
          frameSize: 62,
          itemSpacing: 14,
          unreadBadgeSize: 20,
          unreadBadgeFontSize: 11,
        ),
      ),
    );
  }
}

class _FaqBackgroundGlow extends StatelessWidget {
  const _FaqBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    Widget orb({required double size, required Color color}) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      );
    }

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -280,
            top: -260,
            child: orb(size: 860, color: const Color(0x443F8BFF)),
          ),
          Positioned(
            right: -260,
            top: 180,
            child: orb(size: 900, color: const Color(0x332E4FFF)),
          ),
          Positioned(
            left: -380,
            bottom: -360,
            child: orb(size: 1100, color: const Color(0x332A56D8)),
          ),
        ],
      ),
    );
  }
}

class _FaqSection {
  final String title;
  final List<_FaqEntry> items;

  const _FaqSection({required this.title, required this.items});
}

class _FaqEntry {
  final String id;
  final String question;
  final String answer;

  const _FaqEntry({
    required this.id,
    required this.question,
    required this.answer,
  });
}

// Replace each `answer` value below with your final FAQ copy.
const List<_FaqSection> _faqSections = <_FaqSection>[
  _FaqSection(
    title: 'General',
    items: <_FaqEntry>[
      _FaqEntry(
        id: 'what-is-waiby',
        question: 'What is WAIBY?',
        answer:
            'WAIBY is a private 1:1 gaming and virtual interaction marketplace connecting Customers with verified Creators worldwide. '
            'WAIBY is not a dating platform and does not allow adult or explicit services. '
            'Payments are securely held until an order is completed.',
      ),
      _FaqEntry(
        id: 'are-sessions-private',
        question: 'Are sessions private?',
        answer: 'Yes. All sessions on WAIBY are private and one-on-one.',
      ),
      _FaqEntry(
        id: 'age-requirement',
        question: 'Is there an age requirement?',
        answer:
            'Yes. WAIBY is strictly 18+. Accounts belonging to minors will be terminated.',
      ),
    ],
  ),
  _FaqSection(
    title: 'PAYMENTS & WALLET',
    items: <_FaqEntry>[
      _FaqEntry(
        id: 'what-are-buds',
        question: 'What are Buds?',
        answer:
            'Buds are WAIBY’s internal payment units (1 USD = 1 Bud).'
            ' All transactions must be completed inside the platform.',
      ),
      _FaqEntry(
        id: 'withdraw-buds',
        question: 'Can I withdraw Buds?',
        answer:
            'Buds purchased are non-withdrawable and are intended for use within WAIBY services.'
            'However, Buds received as Buff Income (such as event rewards, eligible refunds, gifts, or promotional bonuses) may be eligible for withdrawal, subject to platform conditions and review.'
            'Creators can request withdrawals from their dashboard once earnings become available.'
            'Withdrawals may be temporarily restricted in cases of disputes, policy reviews, or risk-related checks.',
      ),
      _FaqEntry(
        id: 'off-platform-payment-request',
        question: 'Can a Creator ask for payment outside WAIBY?',
        answer:
            'No. Redirecting payments outside the platform is strictly prohibited.'
            'If a Creator encourages off-platform payments, please report it immediately through the support system.'
            'Users who report verified policy violations may receive platform rewards.',
      ),
    ],
  ),
  _FaqSection(
    title: 'SUBSCRIPTIONS',
    items: <_FaqEntry>[
      _FaqEntry(
        id: 'what-are-subscriptions',
        question: 'What are Subscriptions?',
        answer:
            'Subscriptions allow Customers to support a Creator monthly in exchange for exclusive benefits defined by the Creator.',
      ),
      _FaqEntry(
        id: 'subscriptions-refundable',
        question: 'Are Subscriptions refundable?',
        answer: 'No. Subscription payments are non-refundable once processed.',
      ),
    ],
  ),
  _FaqSection(
    title: 'TIPS & GIFTS',
    items: <_FaqEntry>[
      _FaqEntry(
        id: 'tips-refundable',
        question: 'Are Tips refundable?',
        answer: 'No. Tips are final and non-refundable',
      ),
      _FaqEntry(
        id: 'gifts-refundable',
        question: 'Are Gifts refundable?',
        answer:
            'No. All Gift purchases are final and non-refundable.'
            'All digital purchases on WAIBY are considered final unless otherwise stated.',
      ),
    ],
  ),
  _FaqSection(
    title: 'DISPUTES & REVIEWS',
    items: <_FaqEntry>[
      _FaqEntry(
        id: 'open-dispute',
        question: 'When can I open a dispute?',
        answer:
            'You may open a dispute if a service was not delivered as agreed or if a rule violation occurred. '
            'Disputes must be submitted within 48 hours of the order being marked as completed. '
            'After the 48-hour period has passed, disputes can no longer be opened through the order panel. '
            'If you need assistance within the 48-hour window, you may also open a support ticket for review. '
            'If no dispute is submitted within 48 hours, the order will be considered final.',
      ),
      _FaqEntry(
        id: 'review-after-session',
        question: 'Can I leave a review after a session?',
        answer:
            'Yes. Customers may rate and review completed orders before 48h.',
      ),
    ],
  ),
];
