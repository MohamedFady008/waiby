import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> _openCreateDialog(
    BuildContext context,
    User user,
    List<ProfileServiceItem> currentServices,
  ) async {
    final draft = await showDialog<_ServiceDraft>(
      context: context,
      barrierColor: const Color(0xB3000000),
      builder: (context) => _ServiceEditorDialog(
        title: 'Create Service',
        confirmLabel: 'Create',
        isFirstService: currentServices.isEmpty,
      ),
    );
    if (draft == null) {
      return;
    }

    await _saveService(
      user: user,
      currentServices: currentServices,
      draft: draft,
      existingService: null,
    );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    User user,
    List<ProfileServiceItem> currentServices,
    ProfileServiceItem service,
  ) async {
    final draft = await showDialog<_ServiceDraft>(
      context: context,
      barrierColor: const Color(0xB3000000),
      builder: (context) => _ServiceEditorDialog(
        title: 'Edit Service',
        confirmLabel: 'Save',
        initialService: service,
        isFirstService: false,
      ),
    );
    if (draft == null) {
      return;
    }

    await _saveService(
      user: user,
      currentServices: currentServices,
      draft: draft,
      existingService: service,
    );
  }

  Future<void> _saveService({
    required User user,
    required List<ProfileServiceItem> currentServices,
    required _ServiceDraft draft,
    required ProfileServiceItem? existingService,
  }) async {
    if (_isSubmitting) {
      return;
    }

    final isCreating = existingService == null;
    final hasOtherSelected = currentServices.any(
      (service) => service.id != existingService?.id && service.selected,
    );
    final mustRemainSelected =
        existingService != null &&
        existingService.selected &&
        !hasOtherSelected;
    final shouldSelect =
        (isCreating && currentServices.isEmpty) ||
        mustRemainSelected ||
        draft.selected;

    final normalizedPrice = _normalizePrice(draft.price);
    final sortOrder =
        existingService?.sortOrder ?? _nextSortOrder(currentServices);

    final service = ProfileServiceItem(
      id: existingService?.id ?? '',
      title: draft.title,
      price: normalizedPrice,
      unit: draft.unit,
      iconKey: draft.iconPreset.key,
      iconBackgroundColor: draft.iconPreset.backgroundColor.toARGB32(),
      iconColor: draft.iconPreset.iconColor.toARGB32(),
      selected: shouldSelect,
      servedCount: existingService?.servedCount ?? 0,
      ratingPercent: existingService?.ratingPercent ?? 0,
      description: draft.description,
      bannerImageAsset: existingService?.bannerImageAsset ?? 'assets/login.png',
      bannerImageUrl: draft.bannerImageUrl,
      options: <ProfileServiceOption>[
        ProfileServiceOption(
          label: draft.optionLabel,
          price: normalizedPrice,
          unit: draft.unit,
        ),
      ],
      sortOrder: sortOrder,
      createdAt: existingService?.createdAt,
      updatedAt: null,
    );

    setState(() => _isSubmitting = true);
    try {
      await _repository.createOrUpdateService(
        user.uid,
        service,
        id: existingService?.id,
      );
      if (!mounted) {
        return;
      }
      _showMessage(
        isCreating ? 'Service created.' : 'Service updated.',
        isError: false,
      );
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message ?? 'Could not save service.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not save service.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _setFeatured(User user, ProfileServiceItem service) async {
    if (_isSubmitting || service.selected) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _repository.setSelectedService(user.uid, service.id);
      if (!mounted) {
        return;
      }
      _showMessage('Featured service updated.', isError: false);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message ?? 'Could not update featured service.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not update featured service.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteService(
    BuildContext context,
    User user,
    ProfileServiceItem service,
  ) async {
    if (_isSubmitting) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF081433),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            title: Text(
              'Delete Service',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Delete "${service.title}"?',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD74A4A),
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _repository.deleteService(user.uid, service.id);
      if (!mounted) {
        return;
      }
      _showMessage('Service deleted.', isError: false);
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(error.message ?? 'Could not delete service.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not delete service.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int _nextSortOrder(List<ProfileServiceItem> items) {
    if (items.isEmpty) {
      return 0;
    }
    var maxOrder = items.first.sortOrder;
    for (final item in items) {
      if (item.sortOrder > maxOrder) {
        maxOrder = item.sortOrder;
      }
    }
    return maxOrder + 1;
  }

  String _normalizePrice(String raw) {
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) {
      return raw.trim();
    }
    return parsed.toStringAsFixed(parsed == parsed.roundToDouble() ? 0 : 2);
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          return _SignedOutServicesHint(entry: widget.entry);
        }

        return StreamBuilder<List<ProfileServiceItem>>(
          stream: _repository.watchServices(user.uid),
          builder: (context, servicesSnapshot) {
            final services =
                servicesSnapshot.data ?? const <ProfileServiceItem>[];
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
                const SizedBox(height: 10),
                Text(
                  'Create and manage the services shown on your profile.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => unawaited(
                              _openCreateDialog(context, user, services),
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2F88FF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(190, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(
                        'Create new service',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    if (_isSubmitting)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                if (servicesSnapshot.hasError)
                  const _MessageCard(
                    title: 'Could not load services',
                    body:
                        'Please check your internet connection and Firestore rules.',
                    color: Color(0xFF7B1F1F),
                  )
                else if (services.isEmpty)
                  const _MessageCard(
                    title: 'No services yet',
                    body:
                        'Create your first service. It will appear in your Profile > Services tab.',
                    color: Color(0xFF0C274E),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final columns = maxWidth >= 1300
                          ? 3
                          : maxWidth >= 840
                          ? 2
                          : 1;
                      const spacing = 14.0;
                      final cardWidth =
                          (maxWidth - spacing * (columns - 1)) / columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: services
                            .map(
                              (service) => SizedBox(
                                width: cardWidth,
                                child: _ServiceCard(
                                  service: service,
                                  disabled: _isSubmitting,
                                  onSetFeatured: () =>
                                      unawaited(_setFeatured(user, service)),
                                  onEdit: () => unawaited(
                                    _openEditDialog(
                                      context,
                                      user,
                                      services,
                                      service,
                                    ),
                                  ),
                                  onDelete: () => unawaited(
                                    _deleteService(context, user, service),
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SignedOutServicesHint extends StatelessWidget {
  final SettingsSidebarMenuEntry entry;

  const _SignedOutServicesHint({required this.entry});

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      title: entry.title,
      body: 'Sign in to create and edit your profile services.',
      color: const Color(0xFF0C274E),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String title;
  final String body;
  final Color color;

  const _MessageCard({
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ProfileServiceItem service;
  final bool disabled;
  final VoidCallback onSetFeatured;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.disabled,
    required this.onSetFeatured,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconFromKey(service.iconKey);
    final description = service.description.trim();
    final option = service.options.isNotEmpty
        ? service.options.first
        : ProfileServiceOption(
            label: 'Standard',
            price: service.price,
            unit: service.unit,
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070F2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Color(service.iconBackgroundColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Color(service.iconColor), size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: service.selected
                      ? const Color(0x3358D56E)
                      : const Color(0x223B4A73),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: service.selected
                        ? const Color(0xFF58D56E)
                        : Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  service.selected ? 'Featured' : 'Normal',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${service.price} / ${service.unit}',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? 'No description yet.' : description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Text(
                  '${option.price}/${option.unit}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: disabled || service.selected ? null : onSetFeatured,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  service.selected ? 'Featured' : 'Set featured',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
              FilledButton(
                onPressed: disabled ? null : onEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F88FF),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton(
                onPressed: disabled ? null : onDelete,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD74A4A),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceEditorDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final bool isFirstService;
  final ProfileServiceItem? initialService;

  const _ServiceEditorDialog({
    required this.title,
    required this.confirmLabel,
    required this.isFirstService,
    this.initialService,
  });

  @override
  State<_ServiceEditorDialog> createState() => _ServiceEditorDialogState();
}

class _ServiceEditorDialogState extends State<_ServiceEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _unitController;
  late final TextEditingController _optionLabelController;
  late final TextEditingController _bannerUrlController;

  late _ServiceIconPreset _selectedIconPreset;
  late bool _selected;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialService;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _priceController = TextEditingController(text: initial?.price ?? '');
    _unitController = TextEditingController(text: initial?.unit ?? '15 Min');
    _optionLabelController = TextEditingController(
      text: initial?.options.isNotEmpty == true
          ? initial!.options.first.label
          : 'Standard',
    );
    _bannerUrlController = TextEditingController(
      text: initial?.bannerImageUrl ?? '',
    );
    _selectedIconPreset = _presetFromKey(initial?.iconKey ?? 'chat');
    _selected = widget.isFirstService || (initial?.selected ?? false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _optionLabelController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final unit = _unitController.text.trim();
    final optionLabel = _optionLabelController.text.trim();
    final priceRaw = _priceController.text.trim().replaceAll(',', '.');
    final bannerUrlRaw = _bannerUrlController.text.trim();
    final parsedPrice = double.tryParse(priceRaw);

    if (title.isEmpty) {
      setState(() => _error = 'Service title is required.');
      return;
    }
    if (parsedPrice == null || parsedPrice <= 0) {
      setState(() => _error = 'Enter a valid price greater than 0.');
      return;
    }
    if (unit.isEmpty) {
      setState(() => _error = 'Service unit is required.');
      return;
    }

    Navigator.of(context).pop(
      _ServiceDraft(
        title: title,
        description: description,
        price: priceRaw,
        unit: unit,
        optionLabel: optionLabel.isEmpty ? 'Standard' : optionLabel,
        bannerImageUrl: bannerUrlRaw.isEmpty ? null : bannerUrlRaw,
        iconPreset: _selectedIconPreset,
        selected: _selected || widget.isFirstService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.92;
    return Dialog(
      backgroundColor: const Color(0xFF071230),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const _FieldLabel('Service title'),
                _DialogInput(
                  controller: _titleController,
                  hintText: 'Example: E-Chat',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Description'),
                _DialogInput(
                  controller: _descriptionController,
                  hintText: 'Describe what users get from this service.',
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Price'),
                          _DialogInput(
                            controller: _priceController,
                            hintText: '7.99',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Unit'),
                          _DialogInput(
                            controller: _unitController,
                            hintText: '15 Min / Game / Hour',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Default option label'),
                _DialogInput(
                  controller: _optionLabelController,
                  hintText: 'Standard',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Banner image URL (optional)'),
                _DialogInput(
                  controller: _bannerUrlController,
                  hintText: 'https://...',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Service icon'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _serviceIconPresets
                      .map((preset) {
                        final isSelected =
                            preset.key == _selectedIconPreset.key;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedIconPreset = preset),
                          borderRadius: BorderRadius.circular(8),
                          child: Ink(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF244A9A)
                                  : const Color(0x1FFFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4A8DFF)
                                    : Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: preset.backgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    preset.icon,
                                    color: preset.iconColor,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  preset.label,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  value: _selected || widget.isFirstService,
                  onChanged: widget.isFirstService
                      ? null
                      : (value) => setState(() => _selected = value),
                  title: Text(
                    'Set as featured service',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    widget.isFirstService
                        ? 'Your first service is featured automatically.'
                        : 'Featured service appears selected in your profile.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontSize: 12.5,
                    ),
                  ),
                  activeThumbColor: const Color(0xFF58D56E),
                  activeTrackColor: const Color(0x8858D56E),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _error!,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF7575),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
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
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2F88FF),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        widget.confirmLabel,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _DialogInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DialogInput({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.4),
          fontWeight: FontWeight.w500,
          fontSize: 12.5,
        ),
        filled: true,
        fillColor: const Color(0x220A1330),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: maxLines > 1 ? 11 : 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF4A8DFF)),
        ),
      ),
    );
  }
}

class _ServiceDraft {
  final String title;
  final String description;
  final String price;
  final String unit;
  final String optionLabel;
  final String? bannerImageUrl;
  final _ServiceIconPreset iconPreset;
  final bool selected;

  const _ServiceDraft({
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.optionLabel,
    required this.bannerImageUrl,
    required this.iconPreset,
    required this.selected,
  });
}

class _ServiceIconPreset {
  final String key;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _ServiceIconPreset({
    required this.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

const _serviceIconPresets = <_ServiceIconPreset>[
  _ServiceIconPreset(
    key: 'chat',
    label: 'Chat',
    icon: Icons.chat_rounded,
    backgroundColor: Color(0xFF5A90F8),
    iconColor: Color(0xFF06163A),
  ),
  _ServiceIconPreset(
    key: 'game',
    label: 'Game',
    icon: Icons.sports_esports_rounded,
    backgroundColor: Color(0xFFD6A748),
    iconColor: Color(0xFF1A152C),
  ),
  _ServiceIconPreset(
    key: 'gift',
    label: 'Gift',
    icon: Icons.redeem_rounded,
    backgroundColor: Color(0xFFE74949),
    iconColor: Colors.white,
  ),
  _ServiceIconPreset(
    key: 'shield',
    label: 'Pro',
    icon: Icons.shield_moon_rounded,
    backgroundColor: Color(0xFF7A62FF),
    iconColor: Colors.white,
  ),
  _ServiceIconPreset(
    key: 'magic',
    label: 'Magic',
    icon: Icons.auto_awesome_rounded,
    backgroundColor: Color(0xFFAF1CF4),
    iconColor: Color(0xFF190433),
  ),
];

_ServiceIconPreset _presetFromKey(String key) {
  final normalized = key.trim().toLowerCase();
  return _serviceIconPresets.firstWhere(
    (preset) => preset.key == normalized,
    orElse: () => _serviceIconPresets.first,
  );
}

IconData _iconFromKey(String key) {
  switch (key.trim().toLowerCase()) {
    case 'chat':
    case 'chat_rounded':
      return Icons.chat_rounded;
    case 'shield':
    case 'shield_moon':
      return Icons.shield_moon_rounded;
    case 'gift':
    case 'redeem':
      return Icons.redeem_rounded;
    case 'triangle':
    case 'change_history':
      return Icons.change_history_rounded;
    case 'game':
    case 'sports_esports':
      return Icons.sports_esports_rounded;
    case 'magic':
    case 'sparkles':
    case 'tarot':
      return Icons.auto_awesome_rounded;
    default:
      return Icons.miscellaneous_services_rounded;
  }
}
