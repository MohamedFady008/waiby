import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../data/models/profile_tab_models.dart';
import '../../data/repositories/profile_tabs_repository.dart';
import '../../widgets/settings_sidebar.dart';

class ServicesSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const ServicesSettingsBody({super.key, required this.entry});

  @override
  State<ServicesSettingsBody> createState() => _ServicesSettingsBodyState();
}

class _ServicesSettingsBodyState extends State<ServicesSettingsBody> {
  final ProfileTabsRepository _repository = ProfileTabsRepository();
  bool _isSubmitting = false;

  Future<void> _showCreateServiceDialog({
    required BuildContext context,
    required String userId,
    required List<ProfileServiceItem> currentServices,
  }) async {
    final draft = await showDialog<_ServiceDraft>(
      context: context,
      barrierColor: const Color(0xB3000000),
      builder: (context) => _CreateServiceDialog(userId: userId),
    );
    if (draft == null) {
      return;
    }

    await _saveService(
      userId: userId,
      currentServices: currentServices,
      draft: draft,
      existingService: null,
    );
  }

  Future<void> _showEditServiceDialog({
    required BuildContext context,
    required String userId,
    required List<ProfileServiceItem> currentServices,
    required ProfileServiceItem service,
  }) async {
    final draft = await showDialog<_ServiceDraft>(
      context: context,
      barrierColor: const Color(0xB3000000),
      builder: (context) => _CreateServiceDialog(
        userId: userId,
        serviceId: service.id,
        initialSeed: _ServiceEditorSeed.fromService(service),
        submitLabel: 'Save changes',
      ),
    );
    if (draft == null) {
      return;
    }

    await _saveService(
      userId: userId,
      currentServices: currentServices,
      draft: draft,
      existingService: service,
    );
  }

  Future<void> _saveService({
    required String userId,
    required List<ProfileServiceItem> currentServices,
    required _ServiceDraft draft,
    required ProfileServiceItem? existingService,
  }) async {
    if (_isSubmitting) {
      return;
    }

    final iconPreset = _iconPresetForCategory(draft.categoryIndex);
    final validPricingRows = draft.pricingRows
        .where(
          (row) =>
              row.label.trim().isNotEmpty &&
              row.price.trim().isNotEmpty &&
              row.unit.trim().isNotEmpty,
        )
        .toList(growable: false);
    final primaryPricing = validPricingRows.isNotEmpty
        ? validPricingRows.first
        : const _ServicePricingDraftRow(
            label: 'Texting',
            price: '2.99',
            unit: '15min',
          );
    final normalizedPrice = _normalizePrice(primaryPricing.price);
    final normalizedUnit = _normalizeUnit(primaryPricing.unit);
    final shouldSelect =
        existingService?.selected == true || currentServices.isEmpty;
    final nextSortOrder =
        existingService?.sortOrder ?? _nextSortOrder(currentServices);

    final payload = ProfileServiceItem(
      id: existingService?.id ?? '',
      title: draft.subCategory,
      shortIntro: draft.shortIntro,
      price: normalizedPrice,
      unit: normalizedUnit,
      iconKey: iconPreset.key,
      iconBackgroundColor: iconPreset.backgroundColor.toARGB32(),
      iconColor: iconPreset.iconColor.toARGB32(),
      selected: shouldSelect,
      isPaused: existingService?.isPaused ?? false,
      servedCount: existingService?.servedCount ?? 0,
      ratingPercent: existingService?.ratingPercent ?? 0,
      description: draft.serviceIntro,
      bannerImageAsset: existingService?.bannerImageAsset ?? 'assets/pp1.png',
      bannerImageUrl: draft.serviceImageUrl ?? existingService?.bannerImageUrl,
      coverImageUrl: draft.coverImageUrl ?? existingService?.coverImageUrl,
      voiceClipUrl: draft.voiceClipUrl ?? existingService?.voiceClipUrl,
      voiceClipName: draft.voiceClipName ?? existingService?.voiceClipName,
      options: validPricingRows
          .map(
            (row) => ProfileServiceOption(
              label: row.label.trim(),
              price: _normalizePrice(row.price),
              unit: _normalizeUnit(row.unit),
            ),
          )
          .toList(growable: false),
      sortOrder: nextSortOrder,
      createdAt: existingService?.createdAt,
      updatedAt: null,
    );

    setState(() => _isSubmitting = true);
    try {
      await _repository.createOrUpdateService(
        userId,
        payload,
        id: existingService?.id,
      );
      if (!mounted) {
        return;
      }
      _showMessage(
        existingService == null ? 'Service created.' : 'Service updated.',
        isError: false,
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message ?? 'Could not save service right now.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not save service right now.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  ProfileServiceItem? _serviceFromCardId(
    int cardId,
    List<_ServiceCardData> cards,
    List<ProfileServiceItem> liveServices,
  ) {
    final index = cards.indexWhere((entry) => entry.id == cardId);
    if (index < 0 || index >= liveServices.length) {
      return null;
    }
    return liveServices[index];
  }

  Future<void> _togglePauseService({
    required String userId,
    required ProfileServiceItem service,
  }) async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _repository.setServicePaused(
        userId,
        service.id,
        isPaused: !service.isPaused,
      );
      if (!mounted) {
        return;
      }
      _showMessage(
        service.isPaused ? 'Service resumed.' : 'Service paused.',
        isError: false,
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message ?? 'Could not update service status.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not update service status.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteService({
    required BuildContext context,
    required String userId,
    required ProfileServiceItem service,
  }) async {
    if (_isSubmitting) {
      return;
    }
    final shouldDelete = await _confirmDeleteService(
      context: context,
      serviceTitle: service.title,
    );
    if (!shouldDelete) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _repository.deleteService(userId, service.id);
      if (!mounted) {
        return;
      }
      _showMessage('Service deleted.', isError: false);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message ?? 'Could not delete service right now.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not delete service right now.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<bool> _confirmDeleteService({
    required BuildContext context,
    required String serviceTitle,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A1435),
          title: Text(
            'Delete service?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This will permanently delete "$serviceTitle".',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFF7A7A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB43A3A)
            : const Color(0xFF2E7D32),
      ),
    );
  }

  int _nextSortOrder(List<ProfileServiceItem> services) {
    if (services.isEmpty) {
      return 0;
    }
    var maxSort = services.first.sortOrder;
    for (final service in services) {
      if (service.sortOrder > maxSort) {
        maxSort = service.sortOrder;
      }
    }
    return maxSort + 1;
  }

  String _normalizePrice(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) {
      return value.trim();
    }
    return parsed.toStringAsFixed(parsed == parsed.roundToDouble() ? 0 : 2);
  }

  String _normalizeUnit(String value) {
    final normalized = value.trim();
    if (normalized.startsWith('/')) {
      return normalized.substring(1).trim();
    }
    return normalized;
  }

  List<_ServiceCardData> _toServiceCards(List<ProfileServiceItem> services) {
    final cards = <_ServiceCardData>[];
    for (var i = 0; i < services.length; i++) {
      cards.add(_ServiceCardData.fromProfileServiceItem(services[i], i + 1));
    }
    return cards;
  }

  static const List<_ServiceCardData> _defaultServices = <_ServiceCardData>[
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          return _buildLayout(
            services: _defaultServices,
            onCreateTap: null,
            onManageTap: null,
            onPauseTap: null,
            onDeleteTap: null,
            signedIn: false,
          );
        }

        return StreamBuilder<List<ProfileServiceItem>>(
          stream: _repository.watchServices(user.uid),
          builder: (context, servicesSnapshot) {
            final liveServices =
                servicesSnapshot.data ?? const <ProfileServiceItem>[];
            final cards = _toServiceCards(liveServices);
            return _buildLayout(
              services: cards,
              onCreateTap: _isSubmitting
                  ? null
                  : () => unawaited(
                      _showCreateServiceDialog(
                        context: context,
                        userId: user.uid,
                        currentServices: liveServices,
                      ),
                    ),
              onManageTap: _isSubmitting
                  ? null
                  : (serviceId) {
                      final service = _serviceFromCardId(
                        serviceId,
                        cards,
                        liveServices,
                      );
                      if (service == null) {
                        return;
                      }
                      unawaited(
                        _showEditServiceDialog(
                          context: context,
                          userId: user.uid,
                          currentServices: liveServices,
                          service: service,
                        ),
                      );
                    },
              onPauseTap: _isSubmitting
                  ? null
                  : (serviceId) {
                      final service = _serviceFromCardId(
                        serviceId,
                        cards,
                        liveServices,
                      );
                      if (service == null) {
                        return;
                      }
                      unawaited(
                        _togglePauseService(userId: user.uid, service: service),
                      );
                    },
              onDeleteTap: _isSubmitting
                  ? null
                  : (serviceId) {
                      final service = _serviceFromCardId(
                        serviceId,
                        cards,
                        liveServices,
                      );
                      if (service == null) {
                        return;
                      }
                      unawaited(
                        _deleteService(
                          context: context,
                          userId: user.uid,
                          service: service,
                        ),
                      );
                    },
              signedIn: true,
            );
          },
        );
      },
    );
  }

  Widget _buildLayout({
    required List<_ServiceCardData> services,
    required VoidCallback? onCreateTap,
    required ValueChanged<int>? onManageTap,
    required ValueChanged<int>? onPauseTap,
    required ValueChanged<int>? onDeleteTap,
    required bool signedIn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.entry.title,
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
              label: _isSubmitting ? 'Saving...' : 'Create new service',
              width: 270,
              color: const Color(0xFF2F88FF),
              onTap: onCreateTap,
            ),
          ],
        ),
        if (!signedIn) ...[
          const SizedBox(height: 14),
          Text(
            'Sign in to create and edit your own services.',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
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

            if (services.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Text(
                  'No services yet. Create your first service.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return Wrap(
              spacing: spacing,
              runSpacing: 16,
              children: services
                  .map(
                    (service) => SizedBox(
                      width: cardWidth,
                      child: _ServicePreviewCard(
                        data: service,
                        onManageTap: onManageTap == null
                            ? null
                            : () => onManageTap(service.id),
                        onPauseTap: onPauseTap == null
                            ? null
                            : () => onPauseTap(service.id),
                        onDeleteTap: onDeleteTap == null
                            ? null
                            : () => onDeleteTap(service.id),
                      ),
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
  final String userId;
  final String? serviceId;
  final _ServiceEditorSeed? initialSeed;
  final String submitLabel;

  const _CreateServiceDialog({
    required this.userId,
    this.serviceId,
    this.initialSeed,
    this.submitLabel = 'Create service',
  });

  @override
  State<_CreateServiceDialog> createState() => _CreateServiceDialogState();
}

class _CreateServiceDialogState extends State<_CreateServiceDialog> {
  late int _selectedCategoryIndex;
  static const _categories = <String>['Chilling', 'Games', 'Custom'];
  late final AudioRecorder _audioRecorder;
  late final TextEditingController _subCategoryController;
  late final TextEditingController _shortIntroController;
  late final TextEditingController _serviceIntroController;
  late final List<_PricingRowController> _pricingRows;

  String? _serviceImageUrl;
  String? _serviceImageName;
  String? _coverImageUrl;
  String? _coverImageName;
  String? _voiceClipUrl;
  String? _voiceClipName;
  bool _uploadingServiceImage = false;
  bool _uploadingCoverImage = false;
  bool _uploadingVoiceClip = false;
  bool _isRecordingVoice = false;
  int _recordingSeconds = 0;
  Timer? _recordingTicker;

  String? _errorText;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    final seed = widget.initialSeed;
    _selectedCategoryIndex = seed?.categoryIndex ?? 1;
    _subCategoryController = TextEditingController(
      text: seed?.subCategory ?? '',
    );
    _shortIntroController = TextEditingController(text: seed?.shortIntro ?? '');
    _serviceIntroController = TextEditingController(
      text: seed?.serviceIntro ?? '',
    );
    _pricingRows =
        seed?.pricingRows
            .map((entry) => _PricingRowController.fromDraft(entry))
            .toList(growable: true) ??
        <_PricingRowController>[
          _PricingRowController(label: 'Texting', price: '2.99', unit: '15min'),
        ];
    _serviceImageUrl = seed?.serviceImageUrl;
    _serviceImageName = seed?.serviceImageName;
    _coverImageUrl = seed?.coverImageUrl;
    _coverImageName = seed?.coverImageName;
    _voiceClipUrl = seed?.voiceClipUrl;
    _voiceClipName = seed?.voiceClipName;
  }

  @override
  void dispose() {
    _subCategoryController.dispose();
    _shortIntroController.dispose();
    _serviceIntroController.dispose();
    _recordingTicker?.cancel();
    unawaited(_audioRecorder.dispose());
    for (final row in _pricingRows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadVoiceFile() async {
    setState(() => _uploadingVoiceClip = true);
    try {
      final uploaded = await _pickAndUploadFile(
        kind: 'voice',
        type: FileType.audio,
      );
      if (!mounted || uploaded == null) {
        return;
      }
      setState(() {
        _voiceClipUrl = uploaded.url;
        _voiceClipName = uploaded.fileName;
      });
    } finally {
      if (mounted) {
        setState(() => _uploadingVoiceClip = false);
      }
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (_uploadingVoiceClip) {
      return;
    }

    if (_isRecordingVoice) {
      await _stopAndUploadVoiceRecording();
      return;
    }
    await _startVoiceRecording();
  }

  Future<void> _startVoiceRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      setState(() {
        _errorText = 'Microphone permission is required to record voice.';
      });
      return;
    }

    try {
      final path = await _resolveRecordingPath();
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_isRecordingVoice) {
          return;
        }
        setState(() => _recordingSeconds += 1);
      });
      setState(() {
        _isRecordingVoice = true;
        _recordingSeconds = 0;
        _errorText = null;
      });
    } on MissingPluginException {
      setState(() {
        _errorText =
            'Microphone recording is unavailable on this browser. Use upload.';
      });
      await _pickAndUploadVoiceFile();
    } catch (_) {
      setState(() {
        _errorText = 'Could not start voice recording.';
      });
    }
  }

  Future<void> _stopAndUploadVoiceRecording() async {
    _recordingTicker?.cancel();
    setState(() {
      _isRecordingVoice = false;
      _uploadingVoiceClip = true;
    });
    try {
      final source = await _audioRecorder.stop();
      if (source == null || source.trim().isEmpty) {
        setState(() {
          _errorText = 'No voice recording captured.';
        });
        return;
      }
      final bytes = await _readRecordedBytes(source);
      final rawFileName = _voiceFileNameFromSource(source);
      final fallbackExt = rawFileName.contains('.')
          ? rawFileName.split('.').last.trim().toLowerCase()
          : 'm4a';
      final resolvedExt = _detectAudioExtensionFromBytes(
        bytes,
        fallbackExt: fallbackExt,
      );
      final fileName = _replaceFileExtension(rawFileName, resolvedExt);
      final uploaded = await _uploadBytesToStorage(
        kind: 'voice',
        fileName: fileName,
        bytes: bytes,
        extensionHint: resolvedExt,
      );
      if (!mounted || uploaded == null) {
        return;
      }
      setState(() {
        _voiceClipUrl = uploaded.url;
        _voiceClipName = uploaded.fileName;
      });
    } catch (error) {
      setState(() {
        _errorText = 'Could not upload recorded voice: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _uploadingVoiceClip = false);
      }
    }
  }

  Future<String> _resolveRecordingPath() async {
    if (kIsWeb) {
      return '';
    }
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${tempDir.path}/waiby_voice_$timestamp.m4a';
  }

  String _formatRecordingDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _voiceFileNameFromSource(String source) {
    final normalized = source.trim();
    if (normalized.isEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'voice_$timestamp.m4a';
    }

    final parsed = Uri.tryParse(normalized);
    if (parsed != null && parsed.scheme == 'blob') {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'voice_$timestamp.m4a';
    }

    final pathSegments = parsed?.pathSegments;
    if (pathSegments != null && pathSegments.isNotEmpty) {
      final candidate = pathSegments.last;
      if (candidate.contains('.')) {
        return candidate;
      }
    }

    final fallbackName = normalized.split('/').last;
    if (fallbackName.contains('.')) {
      return fallbackName;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'voice_$timestamp.m4a';
  }

  Future<Uint8List> _readRecordedBytes(String source) async {
    try {
      return await XFile(source).readAsBytes();
    } catch (_) {
      final response = await http.get(Uri.parse(source));
      return response.bodyBytes;
    }
  }

  String _detectAudioExtensionFromBytes(
    Uint8List bytes, {
    required String fallbackExt,
  }) {
    final normalizedFallback = fallbackExt.trim().isEmpty
        ? 'm4a'
        : fallbackExt.trim().toLowerCase();
    if (bytes.isEmpty) {
      return normalizedFallback;
    }

    bool startsWith(List<int> signature) {
      if (bytes.length < signature.length) {
        return false;
      }
      for (var i = 0; i < signature.length; i++) {
        if (bytes[i] != signature[i]) {
          return false;
        }
      }
      return true;
    }

    if (startsWith(const [0x52, 0x49, 0x46, 0x46]) &&
        bytes.length >= 12 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45) {
      return 'wav';
    }

    if (startsWith(const [0x1A, 0x45, 0xDF, 0xA3])) {
      return 'webm';
    }

    if (startsWith(const [0x4F, 0x67, 0x67, 0x53])) {
      return 'ogg';
    }

    if (startsWith(const [0x66, 0x4C, 0x61, 0x43])) {
      return 'flac';
    }

    // ISO BMFF/MP4 family: [size][ftyp...]
    if (bytes.length >= 8 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      return 'm4a';
    }

    return normalizedFallback;
  }

  String _replaceFileExtension(String fileName, String extension) {
    final normalizedExt = extension.trim().toLowerCase();
    if (normalizedExt.isEmpty) {
      return fileName;
    }

    final baseName = fileName.trim().isEmpty
        ? 'voice_${DateTime.now().millisecondsSinceEpoch}'
        : fileName.trim();
    final dotIndex = baseName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == baseName.length - 1) {
      if (dotIndex == baseName.length - 1) {
        return '${baseName.substring(0, dotIndex)}.$normalizedExt';
      }
      return '$baseName.$normalizedExt';
    }
    return '${baseName.substring(0, dotIndex)}.$normalizedExt';
  }

  Future<void> _pickAndUploadServiceImage() async {
    setState(() => _uploadingServiceImage = true);
    try {
      final uploaded = await _pickAndUploadFile(
        kind: 'service_image',
        type: FileType.image,
      );
      if (!mounted || uploaded == null) {
        return;
      }
      setState(() {
        _serviceImageUrl = uploaded.url;
        _serviceImageName = uploaded.fileName;
      });
    } finally {
      if (mounted) {
        setState(() => _uploadingServiceImage = false);
      }
    }
  }

  Future<void> _pickAndUploadCoverImage() async {
    setState(() => _uploadingCoverImage = true);
    try {
      final uploaded = await _pickAndUploadFile(
        kind: 'cover_image',
        type: FileType.image,
      );
      if (!mounted || uploaded == null) {
        return;
      }
      setState(() {
        _coverImageUrl = uploaded.url;
        _coverImageName = uploaded.fileName;
      });
    } finally {
      if (mounted) {
        setState(() => _uploadingCoverImage = false);
      }
    }
  }

  Future<_UploadedAsset?> _pickAndUploadFile({
    required String kind,
    required FileType type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: type == FileType.audio
            ? const ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'webm']
            : null,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        setState(() => _errorText = 'Could not read selected file.');
        return null;
      }

      final rawExt = file.extension?.trim().toLowerCase();
      final extFromName = file.name.contains('.')
          ? file.name.split('.').last.trim().toLowerCase()
          : '';
      final ext = rawExt != null && rawExt.isNotEmpty ? rawExt : extFromName;
      final safeExt = ext.isEmpty ? 'bin' : ext;
      return _uploadBytesToStorage(
        kind: kind,
        fileName: file.name.isNotEmpty ? file.name : '$kind.$safeExt',
        bytes: bytes,
        extensionHint: safeExt,
      );
    } on FirebaseException catch (error) {
      setState(() {
        _errorText = error.message?.trim().isNotEmpty == true
            ? error.message!.trim()
            : 'Upload failed (${error.code}).';
      });
    } catch (error) {
      setState(() => _errorText = 'Upload failed: $error');
    }
    return null;
  }

  Future<_UploadedAsset?> _uploadBytesToStorage({
    required String kind,
    required String fileName,
    required Uint8List bytes,
    required String extensionHint,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = extensionHint.trim().isEmpty
        ? 'bin'
        : extensionHint.trim().toLowerCase();
    final safeName = fileName.trim().isEmpty ? '$kind.$ext' : fileName.trim();
    final storagePath =
        'service_media/${widget.userId}/${widget.serviceId ?? 'draft'}/${kind}_$timestamp.$ext';
    final ref = FirebaseStorage.instance.ref(storagePath);

    final metadata = SettableMetadata(
      contentType: _resolveMimeType(ext),
      customMetadata: <String, String>{
        'uploaded_by': widget.userId,
        'original_name': safeName,
        'kind': kind,
        'uploaded_at': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await ref.putData(bytes, metadata);
    final url = await ref.getDownloadURL();
    return _UploadedAsset(url: url, fileName: safeName);
  }

  String? _resolveMimeType(String extension) {
    // FilePicker may not expose MIME type consistently across platforms.
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'webm':
        return 'audio/webm';
      default:
        return null;
    }
  }

  void _addPricingRow() {
    setState(() {
      _pricingRows.add(
        _PricingRowController(label: 'Option', price: '2.99', unit: '15min'),
      );
    });
  }

  void _removePricingRow(int index) {
    if (_pricingRows.length <= 1 || index < 0 || index >= _pricingRows.length) {
      return;
    }
    setState(() {
      final row = _pricingRows.removeAt(index);
      row.dispose();
    });
  }

  void _submit() {
    final subCategory = _subCategoryController.text.trim();
    final shortIntro = _shortIntroController.text.trim();
    final serviceIntro = _serviceIntroController.text.trim();
    final pricingRows = _pricingRows
        .map((row) => row.toDraft())
        .where(
          (entry) =>
              entry.label.trim().isNotEmpty ||
              entry.price.trim().isNotEmpty ||
              entry.unit.trim().isNotEmpty,
        )
        .toList(growable: false);

    if (subCategory.isEmpty) {
      setState(() => _errorText = 'Service sub category is required.');
      return;
    }
    if (pricingRows.isEmpty) {
      setState(() => _errorText = 'Add at least one service pricing row.');
      return;
    }
    for (final row in pricingRows) {
      final price = double.tryParse(row.price.replaceAll(',', '.'));
      if (row.label.trim().isEmpty) {
        setState(() => _errorText = 'Each pricing row must have a name.');
        return;
      }
      if (price == null || price <= 0) {
        setState(
          () => _errorText = 'Each pricing row must have a valid price.',
        );
        return;
      }
      if (row.unit.trim().isEmpty) {
        setState(() => _errorText = 'Each pricing row must have a unit.');
        return;
      }
    }

    setState(() => _errorText = null);
    Navigator.of(context).pop(
      _ServiceDraft(
        categoryIndex: _selectedCategoryIndex,
        subCategory: subCategory,
        shortIntro: shortIntro,
        serviceIntro: serviceIntro,
        pricingRows: pricingRows,
        serviceImageUrl: _serviceImageUrl,
        serviceImageName: _serviceImageName,
        coverImageUrl: _coverImageUrl,
        coverImageName: _coverImageName,
        voiceClipUrl: _voiceClipUrl,
        voiceClipName: _voiceClipName,
      ),
    );
  }

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
                        _DialogInput(
                          height: 44,
                          controller: _subCategoryController,
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Short Intro'),
                        const SizedBox(height: 8),
                        _DialogInput(
                          height: 44,
                          controller: _shortIntroController,
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Voice Recording'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _uploadingVoiceClip
                                    ? null
                                    : _toggleVoiceRecording,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isRecordingVoice
                                        ? const Color(0xFFD74A4A)
                                        : const Color(0xFF2F88FF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _isRecordingVoice
                                            ? Icons.mic_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                      ),
                                      const Spacer(),
                                      Text(
                                        _uploadingVoiceClip
                                            ? 'Uploading...'
                                            : _isRecordingVoice
                                            ? 'Recording ${_formatRecordingDuration(_recordingSeconds)}'
                                            : (_voiceClipName
                                                          ?.trim()
                                                          .isNotEmpty ==
                                                      true
                                                  ? _voiceClipName!
                                                  : 'Tap to record'),
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
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: _uploadingVoiceClip
                                  ? null
                                  : _isRecordingVoice
                                  ? _toggleVoiceRecording
                                  : (_voiceClipUrl == null
                                        ? _pickAndUploadVoiceFile
                                        : () => setState(() {
                                            _voiceClipUrl = null;
                                            _voiceClipName = null;
                                          })),
                              child: Icon(
                                _isRecordingVoice
                                    ? Icons.stop_circle_rounded
                                    : _voiceClipUrl == null
                                    ? Icons.upload_file_rounded
                                    : Icons.delete_rounded,
                                color: _isRecordingVoice
                                    ? const Color(0xFFFF8A8A)
                                    : _voiceClipUrl == null
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : const Color(0xFFE61F1F),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Service Intro'),
                        const SizedBox(height: 8),
                        _DialogInput(
                          height: 130,
                          maxLines: 6,
                          counterText: '500',
                          controller: _serviceIntroController,
                        ),
                        const SizedBox(height: 14),
                        const _DialogSectionLabel('Service Image'),
                        const SizedBox(height: 10),
                        _UploadDropZone(
                          helperText:
                              'This image is featured above your service description',
                          onBrowseTap: _uploadingServiceImage
                              ? null
                              : _pickAndUploadServiceImage,
                          uploading: _uploadingServiceImage,
                          fileLabel: _serviceImageName,
                          previewUrl: _serviceImageUrl,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const _DialogSectionLabel('Service Pricing'),
                            const Spacer(),
                            InkWell(
                              onTap: _addPricingRow,
                              borderRadius: BorderRadius.circular(3),
                              child: Container(
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List<Widget>.generate(_pricingRows.length, (index) {
                          final row = _pricingRows[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _pricingRows.length - 1 ? 0 : 10,
                            ),
                            child: _EditablePricingRow(
                              row: row,
                              onRemove: () => _removePricingRow(index),
                              canRemove: _pricingRows.length > 1,
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        const _DialogSectionLabel('Cover  Image'),
                        const SizedBox(height: 10),
                        _UploadDropZone(
                          helperText:
                              'This is the image users see when they find you in search',
                          onBrowseTap: _uploadingCoverImage
                              ? null
                              : _pickAndUploadCoverImage,
                          uploading: _uploadingCoverImage,
                          fileLabel: _coverImageName,
                          previewUrl: _coverImageUrl,
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorText!,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF7B7B),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2F88FF),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                widget.submitLabel,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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
  final TextEditingController? controller;

  const _DialogInput({
    required this.height,
    this.maxLines = 1,
    this.counterText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: height,
          child: TextField(
            controller: controller,
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
  final VoidCallback? onBrowseTap;
  final bool uploading;
  final String? fileLabel;
  final String? previewUrl;

  const _UploadDropZone({
    required this.helperText,
    this.onBrowseTap,
    this.uploading = false,
    this.fileLabel,
    this.previewUrl,
  });

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
              if (previewUrl != null && previewUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    previewUrl!,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.white.withValues(alpha: 0.08),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white.withValues(alpha: 0.58),
                size: 42,
              ),
              const SizedBox(height: 8),
              Text(
                uploading
                    ? 'Uploading...'
                    : (fileLabel?.trim().isNotEmpty == true
                          ? fileLabel!
                          : 'Drag & Drop files here'),
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBrowseTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      uploading ? 'Uploading...' : 'Browse files',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 1.1,
                      ),
                    ),
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

class _EditablePricingRow extends StatelessWidget {
  final _PricingRowController row;
  final VoidCallback onRemove;
  final bool canRemove;

  const _EditablePricingRow({
    required this.row,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                _PricingField(
                  label: 'Name',
                  value: 'Texting',
                  controller: row.labelController,
                ),
                const SizedBox(height: 8),
                _PricingField(
                  label: 'Price',
                  value: '2.99',
                  controller: row.priceController,
                ),
                const SizedBox(height: 8),
                _PricingUnitField(
                  value: '/15min',
                  controller: row.unitController,
                ),
                const SizedBox(height: 8),
                if (canRemove)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Color(0xFFE61F1F),
                        size: 20,
                      ),
                    ),
                  ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 5,
                child: _PricingField(
                  label: 'Name',
                  value: 'Texting',
                  controller: row.labelController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: _PricingField(
                  label: 'Price',
                  value: '2.99',
                  controller: row.priceController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _PricingUnitField(
                  value: '/15min',
                  controller: row.unitController,
                ),
              ),
              const SizedBox(width: 8),
              if (canRemove)
                InkWell(
                  onTap: onRemove,
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFE61F1F),
                    size: 20,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PricingField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController? controller;

  const _PricingField({
    required this.label,
    required this.value,
    this.controller,
  });

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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: controller == null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.1,
                    ),
                  ),
                )
              : TextField(
                  controller: controller,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
        ),
      ],
    );
  }
}

class _PricingUnitField extends StatelessWidget {
  final String value;
  final TextEditingController? controller;

  const _PricingUnitField({required this.value, this.controller});

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
            child: controller == null
                ? Text(
                    value,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.1,
                    ),
                  )
                : TextField(
                    controller: controller,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.1,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
          ),
          if (controller == null)
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
  final VoidCallback? onManageTap;
  final VoidCallback? onPauseTap;
  final VoidCallback? onDeleteTap;

  const _ServicePreviewCard({
    required this.data,
    this.onManageTap,
    this.onPauseTap,
    this.onDeleteTap,
  });

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
              _TinyTag(
                label: data.isPaused ? 'Resume' : 'Pause',
                background: data.isPaused
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC08F13),
                width: 58,
                height: 22,
                onTap: onPauseTap,
              ),
              const SizedBox(width: 8),
              _TinyTag(
                label: 'Delete',
                background: Color(0xFF4A1414),
                width: 60,
                height: 22,
                onTap: onDeleteTap,
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
              _ManageButton(data: data, onTap: onManageTap),
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
            child: data.avatarUrl != null && data.avatarUrl!.isNotEmpty
                ? Image.network(
                    data.avatarUrl!,
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
                  )
                : Image.asset(
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
  final VoidCallback? onTap;

  const _TinyTag({
    required this.label,
    required this.background,
    required this.width,
    this.height = 22,
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
          height: height,
          decoration: BoxDecoration(
            color: onTap == null
                ? background.withValues(alpha: 0.45)
                : background,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 7,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageButton extends StatelessWidget {
  final _ServiceCardData data;
  final VoidCallback? onTap;

  const _ManageButton({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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

// ignore: unused_element
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
  final String? serviceId;
  final int sortOrder;
  final bool selected;
  final bool isPaused;
  final String iconKey;
  final String title;
  final String subtitle;
  final String description;
  final String pricingName;
  final String price;
  final String unit;
  final String avatarAsset;
  final String? avatarUrl;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const _ServiceCardData({
    required this.id,
    this.serviceId,
    this.sortOrder = 0,
    this.selected = false,
    this.isPaused = false,
    this.iconKey = 'chat',
    required this.title,
    required this.subtitle,
    required this.description,
    this.pricingName = 'Texting',
    required this.price,
    required this.unit,
    required this.avatarAsset,
    this.avatarUrl,
    required this.icon,
    required this.iconBackground,
    this.iconColor = Colors.white,
  });

  factory _ServiceCardData.fromProfileServiceItem(
    ProfileServiceItem item,
    int index,
  ) {
    final primaryOption = item.options.isNotEmpty
        ? item.options.first
        : ProfileServiceOption(
            label: 'Texting',
            price: item.price,
            unit: item.unit,
          );
    final displayUnit = item.unit.trim().startsWith('/')
        ? item.unit.trim()
        : '/${item.unit.trim()}';
    return _ServiceCardData(
      id: index,
      serviceId: item.id,
      sortOrder: item.sortOrder,
      selected: item.selected,
      isPaused: item.isPaused,
      iconKey: item.iconKey,
      title: item.title,
      subtitle: item.shortIntro.trim().isNotEmpty
          ? item.shortIntro.trim()
          : primaryOption.label,
      description: item.description,
      pricingName: primaryOption.label,
      price: item.price,
      unit: displayUnit,
      avatarAsset: item.bannerImageAsset,
      avatarUrl: item.coverImageUrl ?? item.bannerImageUrl,
      icon: _iconFromKey(item.iconKey),
      iconBackground: Color(item.iconBackgroundColor),
      iconColor: Color(item.iconColor),
    );
  }
}

class _ServiceEditorSeed {
  final int categoryIndex;
  final String subCategory;
  final String shortIntro;
  final String serviceIntro;
  final List<_ServicePricingDraftRow> pricingRows;
  final String? serviceImageUrl;
  final String? serviceImageName;
  final String? coverImageUrl;
  final String? coverImageName;
  final String? voiceClipUrl;
  final String? voiceClipName;

  const _ServiceEditorSeed({
    required this.categoryIndex,
    required this.subCategory,
    required this.shortIntro,
    required this.serviceIntro,
    required this.pricingRows,
    this.serviceImageUrl,
    this.serviceImageName,
    this.coverImageUrl,
    this.coverImageName,
    this.voiceClipUrl,
    this.voiceClipName,
  });

  factory _ServiceEditorSeed.fromService(ProfileServiceItem item) {
    final pricingRows = item.options.isNotEmpty
        ? item.options
              .map(
                (entry) => _ServicePricingDraftRow(
                  label: entry.label,
                  price: entry.price,
                  unit: entry.unit,
                ),
              )
              .toList(growable: false)
        : <_ServicePricingDraftRow>[
            _ServicePricingDraftRow(
              label: 'Texting',
              price: item.price,
              unit: item.unit,
            ),
          ];
    return _ServiceEditorSeed(
      categoryIndex: _categoryIndexFromIconKey(item.iconKey),
      subCategory: item.title,
      shortIntro: item.shortIntro,
      serviceIntro: item.description,
      pricingRows: pricingRows,
      serviceImageUrl: item.bannerImageUrl,
      serviceImageName: _fileNameFromUrl(item.bannerImageUrl),
      coverImageUrl: item.coverImageUrl,
      coverImageName: _fileNameFromUrl(item.coverImageUrl),
      voiceClipUrl: item.voiceClipUrl,
      voiceClipName: item.voiceClipName ?? _fileNameFromUrl(item.voiceClipUrl),
    );
  }
}

class _ServiceDraft {
  final int categoryIndex;
  final String subCategory;
  final String shortIntro;
  final String serviceIntro;
  final List<_ServicePricingDraftRow> pricingRows;
  final String? serviceImageUrl;
  final String? serviceImageName;
  final String? coverImageUrl;
  final String? coverImageName;
  final String? voiceClipUrl;
  final String? voiceClipName;

  const _ServiceDraft({
    required this.categoryIndex,
    required this.subCategory,
    required this.shortIntro,
    required this.serviceIntro,
    required this.pricingRows,
    this.serviceImageUrl,
    this.serviceImageName,
    this.coverImageUrl,
    this.coverImageName,
    this.voiceClipUrl,
    this.voiceClipName,
  });
}

class _ServicePricingDraftRow {
  final String label;
  final String price;
  final String unit;

  const _ServicePricingDraftRow({
    required this.label,
    required this.price,
    required this.unit,
  });
}

class _PricingRowController {
  final TextEditingController labelController;
  final TextEditingController priceController;
  final TextEditingController unitController;

  _PricingRowController({
    required String label,
    required String price,
    required String unit,
  }) : labelController = TextEditingController(text: label),
       priceController = TextEditingController(text: price),
       unitController = TextEditingController(text: unit);

  factory _PricingRowController.fromDraft(_ServicePricingDraftRow row) {
    return _PricingRowController(
      label: row.label,
      price: row.price,
      unit: row.unit,
    );
  }

  _ServicePricingDraftRow toDraft() {
    return _ServicePricingDraftRow(
      label: labelController.text.trim(),
      price: priceController.text.trim(),
      unit: unitController.text.trim(),
    );
  }

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    unitController.dispose();
  }
}

class _UploadedAsset {
  final String url;
  final String fileName;

  const _UploadedAsset({required this.url, required this.fileName});
}

class _IconPreset {
  final String key;
  final Color backgroundColor;
  final Color iconColor;

  const _IconPreset({
    required this.key,
    required this.backgroundColor,
    required this.iconColor,
  });
}

const _chillingIconPreset = _IconPreset(
  key: 'chat',
  backgroundColor: Color(0xFF2F88FF),
  iconColor: Colors.white,
);

const _gamesIconPreset = _IconPreset(
  key: 'game',
  backgroundColor: Color(0xFFFF3A41),
  iconColor: Colors.white,
);

const _customIconPreset = _IconPreset(
  key: 'magic',
  backgroundColor: Color(0xFFAF1CF4),
  iconColor: Colors.white,
);

_IconPreset _iconPresetForCategory(int categoryIndex) {
  switch (categoryIndex) {
    case 0:
      return _chillingIconPreset;
    case 1:
      return _gamesIconPreset;
    default:
      return _customIconPreset;
  }
}

int _categoryIndexFromIconKey(String iconKey) {
  switch (iconKey.trim().toLowerCase()) {
    case 'game':
    case 'sports_esports':
      return 1;
    case 'magic':
    case 'sparkles':
    case 'tarot':
    case 'gift':
    case 'redeem':
      return 2;
    default:
      return 0;
  }
}

String? _fileNameFromUrl(String? url) {
  final raw = url?.trim();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  try {
    final parsed = Uri.parse(raw);
    final segments = parsed.pathSegments;
    if (segments.isEmpty) {
      return raw;
    }
    final last = segments.last;
    return last.isEmpty ? raw : last;
  } catch (_) {
    return raw;
  }
}

IconData _iconFromKey(String iconKey) {
  switch (iconKey.trim().toLowerCase()) {
    case 'game':
    case 'sports_esports':
      return Icons.sports_esports_rounded;
    case 'gift':
    case 'redeem':
      return Icons.redeem_rounded;
    case 'magic':
    case 'sparkles':
    case 'tarot':
      return Icons.auto_awesome_rounded;
    case 'shield':
    case 'shield_moon':
      return Icons.shield_moon_rounded;
    default:
      return Icons.chat_rounded;
  }
}
