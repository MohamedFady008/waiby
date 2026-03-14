import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfluencerGuidelinesPage extends StatelessWidget {
  const InfluencerGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF05070D),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1700),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopGuidelinesCard(),
                SizedBox(height: 20),
                _ProhibitedContentSection(),
                SizedBox(height: 20),
                _BottomGuidelinesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopGuidelinesCard extends StatelessWidget {
  const _TopGuidelinesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuidelinesHeroBanner(),
          SizedBox(height: 26),
          _ResponsiveColumns(
            spacing: 24,
            runSpacing: 24,
            minColumnWidth: 320,
            children: [
              _EligibilitySection(),
              _VideoRequirementsSection(),
              _ContentStandardsSection(),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuidelinesHeroBanner extends StatelessWidget {
  const _GuidelinesHeroBanner();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bannerHeight = width < 620
            ? 198.0
            : (width < 980 ? 188.0 : 176.0);
        final titleSize = width < 620 ? 22.0 : 24.0;
        final bodySize = width < 620 ? 14.0 : 16.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: double.infinity,
            height: bannerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/influencer_program.png', fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Text(
                          'Waiby Official Social Feature\nProgram',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0A0A0E),
                            fontWeight: FontWeight.w700,
                            fontSize: titleSize,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: Text(
                          "These guidelines apply to all creators submitting content to be featured on WAIBY's official social media channels.\nParticipation in this program is voluntary, but compliance is mandatory.",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0F111A),
                            fontWeight: FontWeight.w500,
                            fontSize: bodySize,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EligibilitySection extends StatelessWidget {
  const _EligibilitySection();

  @override
  Widget build(BuildContext context) {
    return _GuidelineSection(
      number: 1,
      title: 'Eligibility',
      children: const [
        _SectionLead(text: 'To participate, you must:'),
        SizedBox(height: 8),
        _SectionBullets(
          items: [
            'Be an approved WAIBY Creator.',
            'Have an active profile in good standing.',
            'Have no ongoing suspensions or major penalties.',
            'Provide accurate profile and referral information.',
          ],
        ),
        SizedBox(height: 10),
        _SectionParagraph(
          text:
              'WAIBY reserves the right to deny participation to accounts under review or risk monitoring.',
        ),
      ],
    );
  }
}

class _VideoRequirementsSection extends StatelessWidget {
  const _VideoRequirementsSection();

  @override
  Widget build(BuildContext context) {
    return _GuidelineSection(
      number: 2,
      title: 'Video Requirements',
      children: const [
        _SectionLead(
          text:
              'All submitted videos must meet the following technical and presentation standards:',
        ),
        SizedBox(height: 10),
        _SectionLead(text: 'Format'),
        _SectionBullets(
          items: [
            '20-30 seconds in length.',
            'Vertical format (9:16).',
            'High resolution (minimum 1080p recommended).',
            'Clear, stable camera (no shaking).',
          ],
        ),
        SizedBox(height: 8),
        _SectionLead(text: 'Identity & Visibility'),
        _SectionBullets(
          items: [
            'Your real face must be clearly visible.',
            'You must be the person shown in the video.',
            'No VTuber avatars.',
            'No animated overlays replacing your face.',
            'No pixelation or blurred identity.',
            'No heavy filters that alter facial features.',
          ],
        ),
        SizedBox(height: 8),
        _SectionParagraph(
          text:
              'This program is built on authenticity and trust. Real presence is required.',
        ),
        SizedBox(height: 8),
        _SectionLead(text: 'Audio & Presentation'),
        _SectionBullets(
          items: [
            'Clear voice.',
            'No distorted microphone.',
            'Professional tone.',
            'Neutral background or clean gaming setup preferred.',
            'No copyrighted music unless fully licensed.',
          ],
        ),
      ],
    );
  }
}

class _ContentStandardsSection extends StatelessWidget {
  const _ContentStandardsSection();

  @override
  Widget build(BuildContext context) {
    return _GuidelineSection(
      number: 3,
      title: 'Content Standards',
      children: const [
        _SectionLead(text: 'Your video must:'),
        SizedBox(height: 8),
        _SectionBullets(
          items: [
            'Clearly introduce yourself.',
            'Briefly explain what you offer on WAIBY.',
            'Include a simple call-to-action (for example: "Book me on WAIBY").',
          ],
        ),
      ],
    );
  }
}

class _ProhibitedContentSection extends StatelessWidget {
  const _ProhibitedContentSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: Color(0xFFFF544A), size: 22),
              const SizedBox(width: 8),
              Text(
                'Prohibited Content',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _SectionLead(text: 'The following is strictly forbidden:'),
          const SizedBox(height: 8),
          const _SectionBullets(
            items: [
              'Sexualized tone or intentionally "sexy" voice delivery.',
              'Revealing or attention-focused clothing intended to attract through sexuality.',
              'Suggestive body language or framing.',
              'Dating positioning or romantic implications.',
              "Misleading statements about WAIBY's purpose.",
              'Mentioning personal Discord, Telegram, Instagram, or external contact.',
              'Encouraging off-platform communication or payment.',
              'Price negotiation outside WAIBY.',
            ],
          ),
          const SizedBox(height: 12),
          const _SectionLead(
            text:
                'Submissions that attempt to use sexual appeal for engagement will be rejected and may negatively impact future promotional eligibility.',
          ),
          const SizedBox(height: 4),
          const _SectionLead(
            text:
                'WAIBY is a sponsor-safe 1:1 gaming & social platform - not a dating platform.',
          ),
        ],
      ),
    );
  }
}

class _BottomGuidelinesCard extends StatelessWidget {
  const _BottomGuidelinesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const _ResponsiveColumns(
        spacing: 24,
        runSpacing: 24,
        minColumnWidth: 320,
        children: [
          _SubmissionProcessSection(),
          _RewardsSpotlightSection(),
          _IntegritySection(),
        ],
      ),
    );
  }
}

class _SubmissionProcessSection extends StatelessWidget {
  const _SubmissionProcessSection();

  @override
  Widget build(BuildContext context) {
    return _GuidelineSection(
      number: 4,
      title: 'Submission Process',
      children: const [
        _SectionLead(
          text:
              'To submit your video, send an email to the official WAIBY submission address and include:',
        ),
        SizedBox(height: 8),
        _SectionBullets(
          items: [
            'The video file attached.',
            'Your WAIBY profile URL.',
            'Your official WAIBY referral link.',
            'The required written consent statement.',
          ],
        ),
        SizedBox(height: 10),
        _SectionLead(text: 'Required Consent Statement'),
        SizedBox(height: 6),
        _SectionParagraph(text: 'Your email must include the following:'),
        SizedBox(height: 6),
        _SectionQuote(
          text:
              '"I confirm that I am the person shown in this video and I grant WAIBY permission to edit, publish, and use this content on its official social media channels and marketing materials."',
        ),
        SizedBox(height: 8),
        _SectionParagraph(
          text: 'Submissions without this statement will not be reviewed.',
        ),
        SizedBox(height: 8),
        _SectionParagraph(text: 'By submitting, you acknowledge that:'),
        SizedBox(height: 4),
        _SectionBullets(
          items: [
            'WAIBY may edit the content for branding purposes.',
            'The video may be used across multiple official platforms.',
            'No additional compensation is owed beyond the program rewards.',
          ],
        ),
      ],
    );
  }
}

class _RewardsSpotlightSection extends StatelessWidget {
  const _RewardsSpotlightSection();

  @override
  Widget build(BuildContext context) {
    return _GuidelineSection(
      number: 5,
      title: 'Rewards & Monthly Spotlight',
      children: const [
        _SectionLead(
          text:
              'Creators whose videos are approved and published will receive:',
        ),
        SizedBox(height: 8),
        _SectionBullets(
          items: [
            '100 Gems/1 Week VIP bonus.',
            'Temporary visibility boost.',
            '"Featured on WAIBY" badge. (For the winner)',
          ],
        ),
        SizedBox(height: 10),
        _SectionLead(text: 'Monthly Spotlight Selection'),
        SizedBox(height: 4),
        _SectionParagraph(
          text:
              'Each month, WAIBY selects the most impactful featured creator based on:',
        ),
        SizedBox(height: 4),
        _SectionBullets(
          items: [
            'Video engagement.',
            'Profile visits generated.',
            'Verified referrals.',
            'Completed orders.',
          ],
        ),
        SizedBox(height: 10),
        _SectionLead(text: 'Grand Winner (Gold+ tier):'),
        SizedBox(height: 4),
        _SectionBullets(
          items: [
            'Homepage banner placement for 7 days.',
            'Major visibility boost.',
            'Exclusive frame.',
            'Special recognition badge.',
          ],
        ),
        SizedBox(height: 10),
        _SectionParagraph(
          text:
              'All eligible participants who meet requirements receive 100 Gems/1 Week VIP bonus participation rewards.',
        ),
        SizedBox(height: 4),
        _SectionParagraph(
          text:
              'Final results are reviewed manually before rewards are issued.',
        ),
      ],
    );
  }
}

class _IntegritySection extends StatelessWidget {
  const _IntegritySection();

  @override
  Widget build(BuildContext context) {
    return _GuidelineSection(
      number: 6,
      title: 'Integrity & Enforcement',
      children: const [
        _SectionLead(text: 'WAIBY maintains strict integrity standards.'),
        SizedBox(height: 4),
        _SectionParagraph(
          text:
              'The following will result in immediate disqualification and possible penalties:',
        ),
        SizedBox(height: 4),
        _SectionBullets(
          items: [
            'Artificial traffic.',
            'Bot engagement.',
            'Purchased views.',
            'Referral abuse or self-referrals.',
            'Manipulation attempts.',
          ],
        ),
        SizedBox(height: 10),
        _SectionLead(text: 'WAIBY reserves the right to:'),
        SizedBox(height: 4),
        _SectionBullets(
          items: [
            'Remove content.',
            'Adjust rankings.',
            'Withhold rewards.',
            'Apply Scoreboard penalties.',
            'Suspend accounts in severe cases.',
          ],
        ),
        SizedBox(height: 10),
        _SectionParagraph(
          text:
              'Protecting brand reputation and platform integrity is a priority.',
        ),
      ],
    );
  }
}

class _GuidelineSection extends StatelessWidget {
  const _GuidelineSection({
    required this.number,
    required this.title,
    required this.children,
  });

  final int number;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              color: Colors.white,
              child: Text(
                '$number',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _SectionLead extends StatelessWidget {
  const _SectionLead({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        height: 1.35,
      ),
    );
  }
}

class _SectionParagraph extends StatelessWidget {
  const _SectionParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w600,
        fontSize: 13,
        height: 1.35,
      ),
    );
  }
}

class _SectionQuote extends StatelessWidget {
  const _SectionQuote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.95),
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        fontSize: 13,
        height: 1.4,
      ),
    );
  }
}

class _SectionBullets extends StatelessWidget {
  const _SectionBullets({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 2),
            child: Text(
              '\u2022 ${items[i]}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}

class _ResponsiveColumns extends StatelessWidget {
  const _ResponsiveColumns({
    required this.children,
    this.spacing = 24,
    this.runSpacing = 24,
    this.minColumnWidth = 300,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double minColumnWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canRenderThreeCols =
            constraints.maxWidth >=
            (minColumnWidth * 3) + (spacing * (children.length - 1));

        if (canRenderThreeCols) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                Expanded(child: children[i]),
                if (i < children.length - 1) SizedBox(width: spacing),
              ],
            ],
          );
        }

        final canRenderTwoCols =
            constraints.maxWidth >= (minColumnWidth * 2) + spacing;
        final targetWidth = canRenderTwoCols
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: targetWidth, child: child),
          ],
        );
      },
    );
  }
}
