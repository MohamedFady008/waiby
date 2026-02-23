import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_sidebar.dart';
import '../widgets/common/responsive_layout.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _shortTaglineController = TextEditingController();
  final TextEditingController _pinnedMessageController =
      TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _giftGoalController = TextEditingController();

  bool _privateRoom = false;
  bool _publicRoom = true;
  bool _giftGoalEnabled = true;

  @override
  void dispose() {
    _roomNameController.dispose();
    _shortTaglineController.dispose();
    _pinnedMessageController.dispose();
    _languageController.dispose();
    _tagsController.dispose();
    _passwordController.dispose();
    _giftGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final showSidebar = pageWidth >= 1180;
        final compact = pageWidth < WaibyBreakpoints.mobile;
        final outerPadding = pageWidth >= 1300
            ? 26.0
            : pageWidth >= 900
            ? 18.0
            : 10.0;
        const sidebarWidth = 84.0;
        const sidebarGap = 14.0;
        final contentWidth = math.min(
          1420.0,
          math.max(
            300.0,
            pageWidth -
                (outerPadding * 2) -
                (showSidebar ? sidebarWidth + sidebarGap : 0),
          ),
        );

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
              const Positioned.fill(child: _CreateRoomBackgroundGlow()),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: contentWidth,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            outerPadding,
                            compact ? 24 : 60,
                            outerPadding,
                            compact ? 24 : 30,
                          ),
                          child: _CreateRoomSurface(
                            roomNameController: _roomNameController,
                            shortTaglineController: _shortTaglineController,
                            pinnedMessageController: _pinnedMessageController,
                            languageController: _languageController,
                            tagsController: _tagsController,
                            passwordController: _passwordController,
                            giftGoalController: _giftGoalController,
                            privateRoom: _privateRoom,
                            publicRoom: _publicRoom,
                            giftGoalEnabled: _giftGoalEnabled,
                            onPrivateChanged: (value) {
                              setState(() {
                                _privateRoom = value;
                                if (value) {
                                  _publicRoom = false;
                                } else if (!_publicRoom) {
                                  _publicRoom = true;
                                }
                              });
                            },
                            onPublicChanged: (value) {
                              setState(() {
                                _publicRoom = value;
                                if (value) {
                                  _privateRoom = false;
                                } else if (!_privateRoom) {
                                  _privateRoom = true;
                                }
                              });
                            },
                            onGiftGoalChanged: (value) {
                              setState(() => _giftGoalEnabled = value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showSidebar)
                    Padding(
                      padding: EdgeInsets.only(right: outerPadding),
                      child: const _CreateRoomSidebarRail(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CreateRoomSurface extends StatelessWidget {
  final TextEditingController roomNameController;
  final TextEditingController shortTaglineController;
  final TextEditingController pinnedMessageController;
  final TextEditingController languageController;
  final TextEditingController tagsController;
  final TextEditingController passwordController;
  final TextEditingController giftGoalController;
  final bool privateRoom;
  final bool publicRoom;
  final bool giftGoalEnabled;
  final ValueChanged<bool> onPrivateChanged;
  final ValueChanged<bool> onPublicChanged;
  final ValueChanged<bool> onGiftGoalChanged;

  const _CreateRoomSurface({
    required this.roomNameController,
    required this.shortTaglineController,
    required this.pinnedMessageController,
    required this.languageController,
    required this.tagsController,
    required this.passwordController,
    required this.giftGoalController,
    required this.privateRoom,
    required this.publicRoom,
    required this.giftGoalEnabled,
    required this.onPrivateChanged,
    required this.onPublicChanged,
    required this.onGiftGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B1D),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _SurfaceHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1240;
                final medium = constraints.maxWidth >= 860 && !wide;

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 394,
                        child: _RoomIdentitySection(
                          roomNameController: roomNameController,
                          shortTaglineController: shortTaglineController,
                          pinnedMessageController: pinnedMessageController,
                          languageController: languageController,
                          tagsController: tagsController,
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 394,
                        child: Column(
                          children: [
                            _AccessMonetizationSection(
                              passwordController: passwordController,
                              giftGoalController: giftGoalController,
                              privateRoom: privateRoom,
                              publicRoom: publicRoom,
                              giftGoalEnabled: giftGoalEnabled,
                              onPrivateChanged: onPrivateChanged,
                              onPublicChanged: onPublicChanged,
                              onGiftGoalChanged: onGiftGoalChanged,
                            ),
                            const SizedBox(height: 22),
                            const _AtmosphereSection(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Expanded(child: _OverviewSection()),
                    ],
                  );
                }

                if (medium) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _RoomIdentitySection(
                              roomNameController: roomNameController,
                              shortTaglineController: shortTaglineController,
                              pinnedMessageController: pinnedMessageController,
                              languageController: languageController,
                              tagsController: tagsController,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                _AccessMonetizationSection(
                                  passwordController: passwordController,
                                  giftGoalController: giftGoalController,
                                  privateRoom: privateRoom,
                                  publicRoom: publicRoom,
                                  giftGoalEnabled: giftGoalEnabled,
                                  onPrivateChanged: onPrivateChanged,
                                  onPublicChanged: onPublicChanged,
                                  onGiftGoalChanged: onGiftGoalChanged,
                                ),
                                const SizedBox(height: 20),
                                const _AtmosphereSection(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const _OverviewSection(),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RoomIdentitySection(
                      roomNameController: roomNameController,
                      shortTaglineController: shortTaglineController,
                      pinnedMessageController: pinnedMessageController,
                      languageController: languageController,
                      tagsController: tagsController,
                    ),
                    const SizedBox(height: 16),
                    _AccessMonetizationSection(
                      passwordController: passwordController,
                      giftGoalController: giftGoalController,
                      privateRoom: privateRoom,
                      publicRoom: publicRoom,
                      giftGoalEnabled: giftGoalEnabled,
                      onPrivateChanged: onPrivateChanged,
                      onPublicChanged: onPublicChanged,
                      onGiftGoalChanged: onGiftGoalChanged,
                    ),
                    const SizedBox(height: 16),
                    const _AtmosphereSection(),
                    const SizedBox(height: 16),
                    const _OverviewSection(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 112,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.go('/playground/live-room?role=host'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F88FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceHeader extends StatelessWidget {
  const _SurfaceHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 720;
        return Container(
          height: narrow ? 112 : 75,
          decoration: BoxDecoration(
            color: const Color(0xFF191D30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Customize Live room',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF51D76E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Guidelines',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Text(
                      'Customize Live room',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF51D76E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Guidelines',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _RoomIdentitySection extends StatelessWidget {
  final TextEditingController roomNameController;
  final TextEditingController shortTaglineController;
  final TextEditingController pinnedMessageController;
  final TextEditingController languageController;
  final TextEditingController tagsController;

  const _RoomIdentitySection({
    required this.roomNameController,
    required this.shortTaglineController,
    required this.pinnedMessageController,
    required this.languageController,
    required this.tagsController,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Room Identity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Room name'),
          _DarkInputField(controller: roomNameController),
          const SizedBox(height: 12),
          const _FieldLabel('Short Tagline'),
          _DarkInputField(controller: shortTaglineController),
          const SizedBox(height: 12),
          const _FieldLabel('Room pinned message (Optional)'),
          _DarkInputField(controller: pinnedMessageController),
          const SizedBox(height: 12),
          const _FieldLabel('Language'),
          _DarkInputField(controller: languageController),
          const SizedBox(height: 12),
          const _FieldLabel('Tags'),
          _DarkInputField(controller: tagsController),
        ],
      ),
    );
  }
}

class _AccessMonetizationSection extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController giftGoalController;
  final bool privateRoom;
  final bool publicRoom;
  final bool giftGoalEnabled;
  final ValueChanged<bool> onPrivateChanged;
  final ValueChanged<bool> onPublicChanged;
  final ValueChanged<bool> onGiftGoalChanged;

  const _AccessMonetizationSection({
    required this.passwordController,
    required this.giftGoalController,
    required this.privateRoom,
    required this.publicRoom,
    required this.giftGoalEnabled,
    required this.onPrivateChanged,
    required this.onPublicChanged,
    required this.onGiftGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Accces & Monetization',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            label: 'Private',
            value: privateRoom,
            onChanged: onPrivateChanged,
          ),
          const SizedBox(height: 8),
          _DarkInputField(
            controller: passwordController,
            hintText: 'Set up password',
            enabled: privateRoom,
            suffixIcon: Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            label: 'Public',
            value: publicRoom,
            onChanged: onPublicChanged,
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            label: 'Enable Gift Goal',
            value: giftGoalEnabled,
            onChanged: onGiftGoalChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Gift Goal',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.toll_rounded,
                size: 13,
                color: Color(0xFF8FBFFA),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 52,
                height: 17,
                child: TextField(
                  controller: giftGoalController,
                  enabled: giftGoalEnabled,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    filled: true,
                    fillColor: const Color(0xFF151721),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtmosphereSection extends StatelessWidget {
  const _AtmosphereSection();

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Atmosphere',
      accentBorder: true,
      trailing: const Icon(
        Icons.eco_rounded,
        color: Color(0xFF51D76E),
        size: 13,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _FieldLabel('Background Style'),
          SizedBox(height: 8),
          _UploadDropZone(),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const _UploadDropZone(height: 132),
      ],
    );
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final Widget child;
  final bool accentBorder;
  final Widget? trailing;

  const _SectionShell({
    required this.title,
    required this.child,
    this.accentBorder = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = accentBorder
        ? const Color(0xFF51D76E)
        : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0F16),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 39,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3C4C),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
              border: accentBorder
                  ? const Border(bottom: BorderSide(color: Color(0xFF51D76E)))
                  : null,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 6), trailing!],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        _TinyToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _TinyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TinyToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 24,
        height: 10,
        padding: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF51D76E) : const Color(0xFF303030),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFFECECEC),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}

class _DarkInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool enabled;
  final Widget? suffixIcon;

  const _DarkInputField({
    required this.controller,
    this.hintText,
    this.enabled = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.38),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: suffixIcon,
                ),
          suffixIconConstraints: const BoxConstraints(
            minHeight: 20,
            minWidth: 24,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          filled: true,
          fillColor: const Color(0xFF151721),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Color(0xFF2F88FF)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
          ),
        ),
      ),
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  final double height;

  const _UploadDropZone({this.height = 110});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF080912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_rounded,
              size: 40,
              color: Color(0xFF636363),
            ),
            const SizedBox(height: 2),
            Text(
              'Drag & Drop files here',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 77,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF636363),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                'Browse files',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRoomSidebarRail extends StatelessWidget {
  const _CreateRoomSidebarRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          border: Border(
            left: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            right: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
          ),
        ),
        child: const ChatSidebar(
          width: 84,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.only(top: 8, bottom: 12),
          avatarSize: 48,
          frameSize: 62,
          itemSpacing: 12,
          unreadBadgeSize: 20,
          unreadBadgeFontSize: 11,
        ),
      ),
    );
  }
}

class _CreateRoomBackgroundGlow extends StatelessWidget {
  const _CreateRoomBackgroundGlow();

  @override
  Widget build(BuildContext context) {
    Widget orb({
      required double size,
      required Color color,
      required double left,
      required double top,
    }) {
      return Positioned(
        left: left,
        top: top,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0)],
                stops: const [0, 1],
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        orb(size: 960, color: const Color(0x552638B9), left: -300, top: -260),
        orb(size: 900, color: const Color(0x332F88FF), left: 340, top: -220),
        orb(size: 960, color: const Color(0x4420298F), left: -260, top: 380),
      ],
    );
  }
}
