import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/settings_sidebar.dart';

class ServicesSettingsBody extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const ServicesSettingsBody({super.key, required this.entry});

  Future<void> _showCreateServiceDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0xB3000000),
      builder: (context) => const _CreateServiceDialog(),
    );
  }

  static const List<_ServiceCardData> _services = <_ServiceCardData>[
    _ServiceCardData(
      id: 1,
      title: 'E-chat',
      subtitle: 'Call me maybe',
      description:
          'Hello, my name is Kimi. I enjoy meeting new people. I can carry you in e-chat if you are shy. We can text, share stories and have deep talks.',
      price: '2.99',
      unit: '/15min',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.chat_rounded,
      iconBackground: Color(0xFF2F88FF),
    ),
    _ServiceCardData(
      id: 2,
      title: 'Valorant',
      subtitle: 'Get carried by a girl',
      description:
          'Wanna duo and climb in Valorant. I play on EU and also have a NA account. Good vibes, solid comms and focused ranked sessions.',
      price: '5.99',
      unit: '/Game',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.sports_esports_rounded,
      iconBackground: Color(0xFFFF3A41),
    ),
    _ServiceCardData(
      id: 3,
      title: 'Watch Together',
      subtitle: 'Netflix and chill',
      description:
          'I love movies and anime. Horror, action or adventure. Grab snacks, grab blankets and we can binge watch together.',
      price: '22.22',
      unit: '/Hour',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.redeem_rounded,
      iconBackground: Color(0xFFE3484D),
    ),
    _ServiceCardData(
      id: 4,
      title: 'Supportive Chat',
      subtitle: 'Let me hear you out',
      description:
          'It is okay to feel down sometimes. I will be here when you need, you do not have to be alone. Reach out for a friendly hand.',
      price: '12.99',
      unit: '/20min',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.favorite_rounded,
      iconBackground: Color(0xFF4BE58A),
      iconColor: Color(0xFF082218),
    ),
    _ServiceCardData(
      id: 5,
      title: 'League Of Legends',
      subtitle: 'Your chill duo',
      description:
          'I just got back into League and I am still warming up. If you want a cozy duo with good vibes and fun games, lets queue.',
      price: '5.99',
      unit: '/Game',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.sports_esports_rounded,
      iconBackground: Color(0xFFD9A43A),
      iconColor: Color(0xFF3A2A07),
    ),
    _ServiceCardData(
      id: 6,
      title: 'Photo drop',
      subtitle: 'Call me maybe',
      description:
          'I love taking selfies and I would love to share some of them with you. Cute shots, quick delivery, and lots of personality.',
      price: '6.66',
      unit: '/Game',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.chat_rounded,
      iconBackground: Color(0xFF2F88FF),
    ),
    _ServiceCardData(
      id: 7,
      title: 'Tarot Session',
      subtitle: 'Tarot reading',
      description:
          'I am an experienced tarot reader since 2021. I can help with advice and guidance for your life questions when you feel uncertain.',
      price: '6.66',
      unit: '/Game',
      avatarAsset: 'assets/pp1.png',
      icon: Icons.chat_rounded,
      iconBackground: Color(0xFF2F88FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            const _HeaderButton(
              label: 'Short',
              width: 104,
              color: Color(0xFF282828),
            ),
            _HeaderButton(
              label: 'Create new service',
              width: 270,
              color: const Color(0xFF2F88FF),
              onTap: () => _showCreateServiceDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 16.0;
            final width = constraints.maxWidth;

            int columns;
            if (width >= 1460) {
              columns = 4;
            } else if (width >= 1080) {
              columns = 3;
            } else if (width >= 700) {
              columns = 2;
            } else {
              columns = 1;
            }

            final cardWidth = (width - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: 16,
              children: _services
                  .map(
                    (service) => SizedBox(
                      width: cardWidth,
                      child: _ServicePreviewCard(data: service),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final double width;
  final Color color;
  final VoidCallback? onTap;

  const _HeaderButton({
    required this.label,
    required this.width,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateServiceDialog extends StatefulWidget {
  const _CreateServiceDialog();

  @override
  State<_CreateServiceDialog> createState() => _CreateServiceDialogState();
}

class _CreateServiceDialogState extends State<_CreateServiceDialog> {
  int _selectedCategoryIndex = 1;
  static const _categories = <String>['Chilling', 'Games', 'Custom'];

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.94;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 860, maxHeight: maxDialogHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF020A30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Service Info',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0x440A1330),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                      width: 0.8,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _DialogSectionLabel('Service Category'),
                        const SizedBox(height: 10),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172042),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: List<Widget>.generate(
                              _categories.length,
                              (index) {
                                final isSelected =
                                    index == _selectedCategoryIndex;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                      () => _selectedCategoryIndex = index,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      curve: Curves.easeOut,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF2A375F)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _categories[index],
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withValues(
                                            alpha: isSelected ? 0.95 : 0.82,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _DialogSectionLabel('Service Sub category'),
                        const SizedBox(height: 8),
                        const _DialogInput(height: 44),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Short Intro'),
                        const SizedBox(height: 8),
                        const _DialogInput(height: 44),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Voice Recording'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F88FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '12s',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.delete_rounded,
                              color: Color(0xFFE61F1F),
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Service Intro'),
                        const SizedBox(height: 8),
                        const _DialogInput(
                          height: 130,
                          maxLines: 6,
                          counterText: '500',
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Service Image'),
                        const SizedBox(height: 10),
                        const _UploadDropZone(
                          helperText:
                              'This image is featured above your service description',
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const _DialogSectionLabel('Service Pricing'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '+ Add',
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFF1A1B20),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 560;
                              if (narrow) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _PricingInputsStacked(),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.delete_rounded,
                                        color: const Color(0xFFE61F1F),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return const Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _PricingField(
                                      label: 'Name',
                                      value: 'Texting',
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    flex: 5,
                                    child: _PricingField(
                                      label: 'Price',
                                      value: '2.99',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    flex: 3,
                                    child: _PricingUnitField(value: '/15min'),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.delete_rounded,
                                    color: Color(0xFFE61F1F),
                                    size: 20,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _DialogSectionLabel('Cover  Image'),
                        const SizedBox(height: 10),
                        const _UploadDropZone(
                          helperText:
                              'This is the image users see when they find you in search',
                        ),
                      ],
                    ),
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

class _DialogSectionLabel extends StatelessWidget {
  final String label;

  const _DialogSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );
  }
}

class _DialogInput extends StatelessWidget {
  final double height;
  final int maxLines;
  final String? counterText;

  const _DialogInput({
    required this.height,
    this.maxLines = 1,
    this.counterText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          child: TextField(
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0x220A1330),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF2F88FF), width: 1),
              ),
            ),
          ),
        ),
        if (counterText != null)
          Positioned(
            right: 8,
            bottom: 4,
            child: Text(
              counterText!,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.22),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  final String helperText;

  const _UploadDropZone({required this.helperText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xAA00051A),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white.withValues(alpha: 0.58),
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                'Drag & Drop files here',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Browse files',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                helperText,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PricingInputsStacked extends StatelessWidget {
  const _PricingInputsStacked();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _PricingField(label: 'Name', value: 'Texting'),
        SizedBox(height: 8),
        _PricingField(label: 'Price', value: '2.99'),
        SizedBox(height: 8),
        _PricingUnitField(value: '/15min'),
      ],
    );
  }
}

class _PricingField extends StatelessWidget {
  final String label;
  final String value;

  const _PricingField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _PricingUnitField extends StatelessWidget {
  final String value;

  const _PricingUnitField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.1,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }
}

class _ServicePreviewCard extends StatelessWidget {
  final _ServiceCardData data;

  const _ServicePreviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x55243266), Color(0x66121C48)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 0.6,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceAvatar(data: data),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w500,
                        fontSize: 8,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w400,
                        fontSize: 7,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const _TinyTag(
                label: 'Chilling',
                background: Color(0x33609D7E),
                width: 72,
              ),
              const SizedBox(width: 6),
              _TinyTag(
                label: 'Id #${data.id}',
                background: const Color(0x33293B5F),
                width: 48,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const _TinyTag(
                label: 'Pause',
                background: Color(0xFFC08F13),
                width: 58,
                height: 22,
              ),
              const SizedBox(width: 8),
              const _TinyTag(
                label: 'Delete',
                background: Color(0xFF4A1414),
                width: 60,
                height: 22,
              ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'from ',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 8,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: data.price,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 8,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: data.unit,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                        fontSize: 8,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ManageButton(data: data),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceAvatar extends StatelessWidget {
  final _ServiceCardData data;

  const _ServiceAvatar({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              data.avatarAsset,
              width: 80,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 72,
                  color: const Color(0xFF2F88FF).withValues(alpha: 0.25),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white70,
                    size: 28,
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: 0,
            bottom: -6,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: data.iconBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF0A1330), width: 1),
              ),
              child: Icon(data.icon, size: 16, color: data.iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  final String label;
  final Color background;
  final double width;
  final double height;

  const _TinyTag({
    required this.label,
    required this.background,
    required this.width,
    this.height = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 7,
          height: 1,
        ),
      ),
    );
  }
}

class _ManageButton extends StatelessWidget {
  final _ServiceCardData data;

  const _ManageButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog<void>(
            context: context,
            barrierColor: const Color(0xB3000000),
            builder: (context) => _ManageServiceDialog(data: data),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          width: 76,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF2F88FF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Text(
                'Manage',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 7,
                  height: 1,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 8,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageServiceDialog extends StatelessWidget {
  final _ServiceCardData data;

  const _ManageServiceDialog({required this.data});

  static const List<_ManagePricingRowData> _pricingRows =
      <_ManagePricingRowData>[
        _ManagePricingRowData(name: 'Texting', price: '2.99', unit: '/15min'),
        _ManagePricingRowData(name: 'E-chat', price: '2.99', unit: '/15min'),
        _ManagePricingRowData(
          name: 'Video Call',
          price: '2.99',
          unit: '/15min',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final maxDialogHeight = MediaQuery.of(context).size.height * 0.94;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 860, maxHeight: maxDialogHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF020A30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Service Info',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0x440A1330),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                      width: 0.8,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _DialogSectionLabel('Short Intro'),
                        const SizedBox(height: 8),
                        _ReadOnlyDialogField(
                          text: '${data.subtitle}${data.id == 1 ? ' 😘' : ''}',
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Voice Recording'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F88FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '12s',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withValues(
                                          alpha: 0.92,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.delete_rounded,
                              color: Color(0xFFE61F1F),
                              size: 22,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Service Intro'),
                        const SizedBox(height: 8),
                        _ReadOnlyDialogTextArea(text: data.description),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Service Image'),
                        const SizedBox(height: 10),
                        const _UploadDropZone(
                          helperText:
                              'This image is featured above your service description',
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const _DialogSectionLabel('Service Pricing'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                '+ Add',
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFF1A1B20),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ..._pricingRows.map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ManagePricingRow(data: row),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const _DialogSectionLabel('Cover  Image'),
                        const SizedBox(height: 10),
                        _CoverImagePreview(
                          imageAsset: data.avatarAsset,
                          helperText:
                              'This is the image users see when they find you in search',
                        ),
                      ],
                    ),
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

class _ReadOnlyDialogField extends StatelessWidget {
  final String text;

  const _ReadOnlyDialogField({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0x220A1330),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.94),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}

class _ReadOnlyDialogTextArea extends StatelessWidget {
  final String text;

  const _ReadOnlyDialogTextArea({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 130),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          decoration: BoxDecoration(
            color: const Color(0x220A1330),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 4,
          child: Text(
            '500',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.22),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ManagePricingRow extends StatelessWidget {
  final _ManagePricingRowData data;

  const _ManagePricingRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
          width: 0.8,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PricingField(label: 'Name', value: data.name),
                const SizedBox(height: 8),
                _PricingField(label: 'Price', value: data.price),
                const SizedBox(height: 8),
                _PricingUnitField(value: data.unit),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFE61F1F),
                    size: 20,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 5,
                child: _PricingField(label: 'Name', value: data.name),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _PricingField(label: 'Price', value: data.price),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _PricingUnitField(value: data.unit)),
              const SizedBox(width: 10),
              const Icon(
                Icons.delete_rounded,
                color: Color(0xFFE61F1F),
                size: 20,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoverImagePreview extends StatelessWidget {
  final String imageAsset;
  final String helperText;

  const _CoverImagePreview({
    required this.imageAsset,
    required this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageAsset,
              width: 520,
              height: 380,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 520,
                  height: 380,
                  color: const Color(0x331E88E5),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_rounded,
                    size: 46,
                    color: Colors.white60,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                helperText,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.28),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

@immutable
class _ManagePricingRowData {
  final String name;
  final String price;
  final String unit;

  const _ManagePricingRowData({
    required this.name,
    required this.price,
    required this.unit,
  });
}

@immutable
class _ServiceCardData {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final String unit;
  final String avatarAsset;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const _ServiceCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.unit,
    required this.avatarAsset,
    required this.icon,
    required this.iconBackground,
    this.iconColor = Colors.white,
  });
}
