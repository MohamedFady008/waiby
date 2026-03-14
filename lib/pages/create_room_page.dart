import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/live_room_media_storage_service.dart';
import '../widgets/common/responsive_layout.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final LiveRoomMediaStorageService _roomMediaStorageService =
      LiveRoomMediaStorageService();
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
  bool _uploadingAtmosphere = false;
  bool _uploadingOverview = false;

  LiveRoomMediaUploadResult? _atmosphereImage;
  LiveRoomMediaUploadResult? _overviewImage;

  String _slugifyRoomId(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (normalized.isEmpty) {
      return 'waiby-live-${DateTime.now().millisecondsSinceEpoch}';
    }
    final truncated = normalized.substring(0, math.min(normalized.length, 40));
    return '$truncated-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _startLive(BuildContext context) {
    final roomName = _roomNameController.text.trim();
    if (roomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room name is required to start live.')),
      );
      return;
    }
    if (_uploadingAtmosphere || _uploadingOverview) {
      _showSnack('Please wait for image uploads to finish.');
      return;
    }

    final queryParameters = <String, String>{
      'role': 'host',
      'roomId': _slugifyRoomId(roomName),
      'roomName': roomName,
      if (_shortTaglineController.text.trim().isNotEmpty)
        'tagline': _shortTaglineController.text.trim(),
      if (_languageController.text.trim().isNotEmpty)
        'language': _languageController.text.trim(),
      if (_tagsController.text.trim().isNotEmpty)
        'tags': _tagsController.text.trim(),
      if (_pinnedMessageController.text.trim().isNotEmpty)
        'pinnedMessage': _pinnedMessageController.text.trim(),
      if (_giftGoalEnabled && _giftGoalController.text.trim().isNotEmpty)
        'giftGoalBuds': _giftGoalController.text.trim(),
      'visibility': _privateRoom ? 'private' : 'public',
      'giftGoalEnabled': _giftGoalEnabled.toString(),
      if (_atmosphereImage?.downloadUrl?.trim().isNotEmpty == true)
        'atmosphereImageUrl': _atmosphereImage!.downloadUrl!,
      if (_overviewImage?.downloadUrl?.trim().isNotEmpty == true)
        'overviewImageUrl': _overviewImage!.downloadUrl!,
    };

    context.go(
      Uri(
        path: '/playground/live-room',
        queryParameters: queryParameters,
      ).toString(),
    );
  }

  Future<void> _pickAndUploadRoomImage({required bool atmosphere}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showSnack('Please sign in before uploading room images.');
      return;
    }

    setState(() {
      if (atmosphere) {
        _uploadingAtmosphere = true;
      } else {
        _uploadingOverview = true;
      }
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showSnack('Could not read the selected image.');
        return;
      }

      final rawExtension = file.extension?.trim().toLowerCase();
      final extFromName = file.name.contains('.')
          ? file.name.split('.').last.trim().toLowerCase()
          : '';
      final extension = rawExtension?.isNotEmpty == true
          ? rawExtension!
          : (extFromName.isNotEmpty ? extFromName : 'jpg');
      final normalizedName = file.name.trim().isNotEmpty
          ? file.name.trim()
          : '${atmosphere ? 'atmosphere' : 'overview'}.$extension';

      final previous = atmosphere ? _atmosphereImage : _overviewImage;
      final upload = await _roomMediaStorageService.uploadRoomImage(
        userId: currentUser.uid,
        kind: atmosphere ? 'atmosphere' : 'overview',
        fileName: normalizedName,
        fileBytes: bytes,
      );
      if (!mounted) return;

      if (!upload.success ||
          upload.downloadUrl == null ||
          upload.storagePath == null) {
        _showSnack(upload.errorMessage ?? 'Could not upload the image.');
        return;
      }

      if (previous?.storagePath?.trim().isNotEmpty == true &&
          previous!.storagePath != upload.storagePath) {
        unawaited(_roomMediaStorageService.deleteImage(previous.storagePath!));
      }

      setState(() {
        if (atmosphere) {
          _atmosphereImage = upload;
        } else {
          _overviewImage = upload;
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showSnack('Upload failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          if (atmosphere) {
            _uploadingAtmosphere = false;
          } else {
            _uploadingOverview = false;
          }
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
        final compact = pageWidth < WaibyBreakpoints.mobile;
        final outerPadding = pageWidth >= 1300
            ? 26.0
            : pageWidth >= 900
            ? 18.0
            : 10.0;
        final contentWidth = math.min(
          1420.0,
          math.max(300.0, pageWidth - (outerPadding * 2)),
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
              Align(
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
                      atmosphereImageUrl: _atmosphereImage?.downloadUrl,
                      atmosphereImageName: _atmosphereImage?.fileName,
                      overviewImageUrl: _overviewImage?.downloadUrl,
                      overviewImageName: _overviewImage?.fileName,
                      privateRoom: _privateRoom,
                      publicRoom: _publicRoom,
                      giftGoalEnabled: _giftGoalEnabled,
                      uploadingAtmosphere: _uploadingAtmosphere,
                      uploadingOverview: _uploadingOverview,
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
                      onPickAtmosphere: () =>
                          _pickAndUploadRoomImage(atmosphere: true),
                      onPickOverview: () =>
                          _pickAndUploadRoomImage(atmosphere: false),
                      onConfirm: () => _startLive(context),
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

class _CreateRoomSurface extends StatelessWidget {
  final TextEditingController roomNameController;
  final TextEditingController shortTaglineController;
  final TextEditingController pinnedMessageController;
  final TextEditingController languageController;
  final TextEditingController tagsController;
  final TextEditingController passwordController;
  final TextEditingController giftGoalController;
  final String? atmosphereImageUrl;
  final String? atmosphereImageName;
  final String? overviewImageUrl;
  final String? overviewImageName;
  final bool privateRoom;
  final bool publicRoom;
  final bool giftGoalEnabled;
  final bool uploadingAtmosphere;
  final bool uploadingOverview;
  final ValueChanged<bool> onPrivateChanged;
  final ValueChanged<bool> onPublicChanged;
  final ValueChanged<bool> onGiftGoalChanged;
  final VoidCallback onPickAtmosphere;
  final VoidCallback onPickOverview;
  final VoidCallback onConfirm;

  const _CreateRoomSurface({
    required this.roomNameController,
    required this.shortTaglineController,
    required this.pinnedMessageController,
    required this.languageController,
    required this.tagsController,
    required this.passwordController,
    required this.giftGoalController,
    required this.atmosphereImageUrl,
    required this.atmosphereImageName,
    required this.overviewImageUrl,
    required this.overviewImageName,
    required this.privateRoom,
    required this.publicRoom,
    required this.giftGoalEnabled,
    required this.uploadingAtmosphere,
    required this.uploadingOverview,
    required this.onPrivateChanged,
    required this.onPublicChanged,
    required this.onGiftGoalChanged,
    required this.onPickAtmosphere,
    required this.onPickOverview,
    required this.onConfirm,
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
                            _AtmosphereSection(
                              imageUrl: atmosphereImageUrl,
                              imageName: atmosphereImageName,
                              uploading: uploadingAtmosphere,
                              onPick: onPickAtmosphere,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _OverviewSection(
                          imageUrl: overviewImageUrl,
                          imageName: overviewImageName,
                          uploading: uploadingOverview,
                          onPick: onPickOverview,
                        ),
                      ),
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
                                _AtmosphereSection(
                                  imageUrl: atmosphereImageUrl,
                                  imageName: atmosphereImageName,
                                  uploading: uploadingAtmosphere,
                                  onPick: onPickAtmosphere,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _OverviewSection(
                        imageUrl: overviewImageUrl,
                        imageName: overviewImageName,
                        uploading: uploadingOverview,
                        onPick: onPickOverview,
                      ),
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
                    _AtmosphereSection(
                      imageUrl: atmosphereImageUrl,
                      imageName: atmosphereImageName,
                      uploading: uploadingAtmosphere,
                      onPick: onPickAtmosphere,
                    ),
                    const SizedBox(height: 16),
                    _OverviewSection(
                      imageUrl: overviewImageUrl,
                      imageName: overviewImageName,
                      uploading: uploadingOverview,
                      onPick: onPickOverview,
                    ),
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
                    onPressed: onConfirm,
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
  final String? imageUrl;
  final String? imageName;
  final bool uploading;
  final VoidCallback onPick;

  const _AtmosphereSection({
    required this.imageUrl,
    required this.imageName,
    required this.uploading,
    required this.onPick,
  });

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
        children: [
          const _FieldLabel('Background Style'),
          const SizedBox(height: 8),
          _UploadDropZone(
            height: 126,
            imageUrl: imageUrl,
            fileName: imageName,
            uploading: uploading,
            onTap: onPick,
            emptyTitle: 'Upload atmosphere',
            emptySubtitle: 'This becomes the live room background.',
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final String? imageUrl;
  final String? imageName;
  final bool uploading;
  final VoidCallback onPick;

  const _OverviewSection({
    required this.imageUrl,
    required this.imageName,
    required this.uploading,
    required this.onPick,
  });

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
        _UploadDropZone(
          height: 188,
          imageUrl: imageUrl,
          fileName: imageName,
          uploading: uploading,
          onTap: onPick,
          emptyTitle: 'Upload overview',
          emptySubtitle: 'This is the preview image shown on Playground.',
        ),
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
  final String? imageUrl;
  final String? fileName;
  final bool uploading;
  final VoidCallback onTap;
  final String emptyTitle;
  final String emptySubtitle;

  const _UploadDropZone({
    this.height = 110,
    required this.imageUrl,
    required this.fileName,
    required this.uploading,
    required this.onTap,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: const Color(0xFF080912),
        child: InkWell(
          onTap: uploading ? null : onTap,
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _emptyBackground(),
                  )
                else
                  _emptyBackground(),
                if (hasImage)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.68),
                        ],
                      ),
                    ),
                  ),
                if (uploading)
                  const Center(child: CircularProgressIndicator())
                else if (hasImage)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.36),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            'Uploaded',
                            style: GoogleFonts.notoSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          fileName?.trim().isNotEmpty == true
                              ? fileName!
                              : 'Image selected',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _actionPill('Replace image'),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_upload_rounded,
                          size: 40,
                          color: Color(0xFF636363),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emptyTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emptySubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSans(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _actionPill('Browse image'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBackground() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1020), Color(0xFF151C38)],
        ),
      ),
    );
  }

  Widget _actionPill(String label) {
    return Container(
      width: 96,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          height: 1,
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
