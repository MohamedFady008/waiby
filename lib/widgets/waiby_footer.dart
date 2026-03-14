import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'common/responsive_layout.dart';

enum WaibyFooterLink {
  browseBuddies,
  vipProgram,
  gemsRewards,
  store,
  playground,
  faq,
  aboutWaiby,
  careers,
  helpCenter,
  contactSupport,
  reportIssue,
  disputesRefunds,
  platformGuidelines,
  termsOfService,
  privacyPolicy,
  cookiePolicy,
  refundPolicy,
  dmcaCopyright,
}

enum WaibyFooterSocial { discord, facebook, tiktok, instagram, youtube, email }

class WaibyFooter extends StatelessWidget {
  final ValueChanged<WaibyFooterLink>? onLinkTap;
  final ValueChanged<WaibyFooterSocial>? onSocialTap;
  final int year;
  final String companyName;
  final String marketplaceDescription;

  const WaibyFooter({
    super.key,
    this.onLinkTap,
    this.onSocialTap,
    this.year = 2026,
    this.companyName = 'WAIBY Inc.',
    this.marketplaceDescription =
        'WAIBY is a digital services marketplace. Creators act as independent contractors.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: WaibyConstrainedContent(
        maxWidth: WaibyBreakpoints.desktopContentMaxWidth,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final desktop = width >= WaibyBreakpoints.tablet;
            final tablet = width >= WaibyBreakpoints.mobile;
            final sectionSpacing = desktop
                ? WaibySpacing.s24
                : WaibySpacing.s16;
            final sectionRunSpacing = tablet
                ? WaibySpacing.s24
                : WaibySpacing.s16;
            final topBottomPadding = desktop ? 40.0 : 28.0;
            final sectionWidth = desktop
                ? (width - (sectionSpacing * 3)) / 4
                : tablet
                ? (width - sectionSpacing) / 2
                : width;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: topBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: sectionSpacing,
                    runSpacing: sectionRunSpacing,
                    children: [
                      for (final section in _footerColumns)
                        SizedBox(
                          width: sectionWidth,
                          child: _FooterSection(
                            title: section.title,
                            links: section.links,
                            onTap: onLinkTap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: WaibySpacing.s24),
                  if (width < 860) ...[
                    _buildCopyright(),
                    const SizedBox(height: WaibySpacing.s16),
                    _SocialPill(onTap: onSocialTap),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildCopyright()),
                        const SizedBox(width: WaibySpacing.s16),
                        _SocialPill(onTap: onSocialTap),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '(c) $year $companyName. All rights reserved.\n$marketplaceDescription',
      style: GoogleFonts.inter(
        color: const Color(0xFF8F8E8A),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final String title;
  final List<_FooterLinkData> links;
  final ValueChanged<WaibyFooterLink>? onTap;

  const _FooterSection({
    required this.title,
    required this.links,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final headingStyle = GoogleFonts.inter(
      color: const Color(0xFF8F8E8A),
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.6,
    );
    final linkStyle = GoogleFonts.inter(
      color: const Color(0xFFCAC9C4),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.35,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: headingStyle),
        const SizedBox(height: WaibySpacing.s8),
        for (final link in links)
          _FooterTextLink(
            label: link.label,
            style: linkStyle,
            onTap: onTap == null ? null : () => onTap!(link.key),
          ),
      ],
    );
  }
}

class _FooterTextLink extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback? onTap;

  const _FooterTextLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(vertical: 1),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: const Color(0xFFCAC9C4),
        ),
        child: Text(label, style: style),
      ),
    );
  }
}

class _SocialPill extends StatelessWidget {
  final ValueChanged<WaibyFooterSocial>? onTap;

  const _SocialPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: WaibySpacing.s8),
      decoration: BoxDecoration(
        color: const Color(0xFF272725),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SocialIconButton(
            icon: FontAwesomeIcons.discord,
            onTap: onTap == null
                ? null
                : () => onTap!(WaibyFooterSocial.discord),
          ),
          _SocialIconButton(
            icon: FontAwesomeIcons.facebookF,
            onTap: onTap == null
                ? null
                : () => onTap!(WaibyFooterSocial.facebook),
          ),
          _SocialIconButton(
            icon: FontAwesomeIcons.tiktok,
            onTap: onTap == null
                ? null
                : () => onTap!(WaibyFooterSocial.tiktok),
          ),
          _SocialIconButton(
            icon: FontAwesomeIcons.instagram,
            onTap: onTap == null
                ? null
                : () => onTap!(WaibyFooterSocial.instagram),
          ),
          _SocialIconButton(
            icon: FontAwesomeIcons.youtube,
            onTap: onTap == null
                ? null
                : () => onTap!(WaibyFooterSocial.youtube),
          ),
          Container(
            width: 1,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white,
          ),
          _SocialIconButton(
            icon: FontAwesomeIcons.envelope,
            onTap: onTap == null ? null : () => onTap!(WaibyFooterSocial.email),
          ),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SocialIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: FaIcon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}

class _FooterColumnData {
  final String title;
  final List<_FooterLinkData> links;

  const _FooterColumnData({required this.title, required this.links});
}

class _FooterLinkData {
  final String label;
  final WaibyFooterLink key;

  const _FooterLinkData(this.label, this.key);
}

const List<_FooterColumnData> _footerColumns = <_FooterColumnData>[
  _FooterColumnData(
    title: 'PLATFORM',
    links: <_FooterLinkData>[
      _FooterLinkData('Browse Buddies', WaibyFooterLink.browseBuddies),
      _FooterLinkData('VIP Program', WaibyFooterLink.vipProgram),
      _FooterLinkData('Gems & Rewards', WaibyFooterLink.gemsRewards),
      _FooterLinkData('Store', WaibyFooterLink.store),
      _FooterLinkData('Playground', WaibyFooterLink.playground),
      _FooterLinkData('FAQ', WaibyFooterLink.faq),
    ],
  ),
  _FooterColumnData(
    title: 'COMPANY',
    links: <_FooterLinkData>[
      _FooterLinkData('About Waiby', WaibyFooterLink.aboutWaiby),
      _FooterLinkData('Careers', WaibyFooterLink.careers),
    ],
  ),
  _FooterColumnData(
    title: 'SUPPORT',
    links: <_FooterLinkData>[
      _FooterLinkData('Help Center', WaibyFooterLink.helpCenter),
      _FooterLinkData('Contact Support', WaibyFooterLink.contactSupport),
      _FooterLinkData('Report an Issue', WaibyFooterLink.reportIssue),
      _FooterLinkData('Disputes & Refunds', WaibyFooterLink.disputesRefunds),
      _FooterLinkData(
        'Platform Guidelines',
        WaibyFooterLink.platformGuidelines,
      ),
    ],
  ),
  _FooterColumnData(
    title: 'LEGAL',
    links: <_FooterLinkData>[
      _FooterLinkData('Terms of Service', WaibyFooterLink.termsOfService),
      _FooterLinkData('Privacy Policy', WaibyFooterLink.privacyPolicy),
      _FooterLinkData('Cookie Policy', WaibyFooterLink.cookiePolicy),
      _FooterLinkData('Refund Policy', WaibyFooterLink.refundPolicy),
      _FooterLinkData('DMCA / Copyright', WaibyFooterLink.dmcaCopyright),
    ],
  ),
];
