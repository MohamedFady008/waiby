import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_profile.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../services/frame_store_service.dart';
import '../../widgets/user_avatar_with_frame.dart';
import '../../widgets/settings_sidebar.dart';

const List<String> _tabs = <String>[
  'My Profile',
  'Edit Profile',
  'Notifications',
  'Privacy',
  'Language',
  'Referrals',
  'IM Settings',
];

const Map<String, bool> _defaultNotificationSettings = <String, bool>{
  'push_enabled': false,
  'email_enabled': false,
  'buddy_recommendations': false,
  'sound_new_message': true,
  'sound_order': true,
  'sound_incoming_call': false,
};

const Map<String, bool> _defaultPrivacySettings = <String, bool>{
  'incognito_browsing': false,
  'hide_activity_interactions': false,
  'hide_leaderboard_identity': true,
  'disable_profile_suggestions': true,
  'direct_message_restricted': false,
};

class ProfileSettingsBody extends StatefulWidget {
  final SettingsSidebarMenuEntry entry;

  const ProfileSettingsBody({super.key, required this.entry});

  @override
  State<ProfileSettingsBody> createState() => _ProfileSettingsBodyState();
}

class _ProfileSettingsBodyState extends State<ProfileSettingsBody> {
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  int _selected = 0;
  String? _languageOverride;
  String? _lastUserId;

  final Map<String, bool> _notificationOverrides = <String, bool>{};
  final Map<String, bool> _privacyOverrides = <String, bool>{};

  bool _isSavingProfile = false;
  bool _isSendingPasswordReset = false;
  bool _isDeletingAccount = false;

  Widget _currentView({
    required User user,
    required UserProfile? profile,
    required _ProfileSettingsData settings,
  }) {
    final notifications = Map<String, bool>.from(settings.notifications)
      ..addAll(_notificationOverrides);
    final privacy = Map<String, bool>.from(settings.privacy)
      ..addAll(_privacyOverrides);
    final selectedLanguage = _languageOverride ?? settings.preferredLanguage;

    switch (_selected) {
      case 0:
        return _MyProfileTab(
          settings: settings,
          sendingResetPassword: _isSendingPasswordReset,
          deletingAccount: _isDeletingAccount,
          onEditProfile: () => setState(() => _selected = 1),
          onResetPassword: () => unawaited(_sendPasswordResetEmail(user)),
          onDeleteAccount: () => unawaited(_deleteAccount(user)),
        );
      case 1:
        return _EditProfileTab(
          settings: settings,
          saving: _isSavingProfile,
          onSave: (update) =>
              _saveProfileEdits(user: user, profile: profile, update: update),
        );
      case 2:
        return _NotificationsTab(
          values: notifications,
          onToggle: (key, value) => unawaited(
            _updateNotificationSetting(
              user: user,
              profile: profile,
              key: key,
              value: value,
            ),
          ),
        );
      case 3:
        return _PrivacyTab(
          values: privacy,
          onToggle: (key, value) => unawaited(
            _updatePrivacySetting(
              user: user,
              profile: profile,
              key: key,
              value: value,
            ),
          ),
        );
      case 4:
        return _LanguageTab(
          selectedLanguage: selectedLanguage,
          onSelectLanguage: (language) {
            final previousLanguage = selectedLanguage;
            setState(() => _languageOverride = language);
            unawaited(
              _updatePreferredLanguage(
                user: user,
                profile: profile,
                language: language,
                previousLanguage: previousLanguage,
              ),
            );
          },
        );
      case 5:
        return _ReferralsTab(
          referralLink: settings.referralLink,
          onCopyReferralLink: () => _copyReferralLink(settings.referralLink),
        );
      default:
        return _PlaceholderTab(title: _tabs[_selected]);
    }
  }

  Future<void> _saveProfileEdits({
    required User user,
    required UserProfile? profile,
    required _EditProfileUpdate update,
  }) async {
    if (_isSavingProfile) {
      return;
    }
    if (update.displayName.trim().isEmpty) {
      _showProfileSettingsSnackBar(context, 'Display name is required.');
      return;
    }

    setState(() => _isSavingProfile = true);
    try {
      final metadata = _buildMergedMetadata(
        profile,
        profileUrlSlug: update.profileUrlSlug,
        gender: update.gender,
        languages: update.languages,
        preferredLanguage: update.preferredLanguage,
      );

      await _userProfileRepository.updateFields(user.uid, <String, dynamic>{
        'full_name': update.displayName.trim(),
        'metadata': metadata,
      });

      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(
        context,
        'Profile settings saved.',
        isError: false,
      );
      setState(() {
        _languageOverride = update.preferredLanguage;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(
        context,
        'Could not save profile settings right now.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingProfile = false);
      }
    }
  }

  Future<void> _updateNotificationSetting({
    required User user,
    required UserProfile? profile,
    required String key,
    required bool value,
  }) async {
    final previous = _notificationOverrides[key];
    setState(() => _notificationOverrides[key] = value);

    try {
      final settings = _ProfileSettingsData.fromSources(
        user: user,
        profile: profile,
      );
      final merged = Map<String, bool>.from(settings.notifications)
        ..addAll(_notificationOverrides)
        ..[key] = value;
      final metadata = _buildMergedMetadata(profile, notifications: merged);
      await _userProfileRepository.updateFields(user.uid, <String, dynamic>{
        'metadata': metadata,
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (previous == null) {
          _notificationOverrides.remove(key);
        } else {
          _notificationOverrides[key] = previous;
        }
      });
      _showProfileSettingsSnackBar(
        context,
        'Could not update notification setting.',
      );
    }
  }

  Future<void> _updatePrivacySetting({
    required User user,
    required UserProfile? profile,
    required String key,
    required bool value,
  }) async {
    final previous = _privacyOverrides[key];
    setState(() => _privacyOverrides[key] = value);

    try {
      final settings = _ProfileSettingsData.fromSources(
        user: user,
        profile: profile,
      );
      final merged = Map<String, bool>.from(settings.privacy)
        ..addAll(_privacyOverrides)
        ..[key] = value;
      final metadata = _buildMergedMetadata(profile, privacy: merged);
      await _userProfileRepository.updateFields(user.uid, <String, dynamic>{
        'metadata': metadata,
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (previous == null) {
          _privacyOverrides.remove(key);
        } else {
          _privacyOverrides[key] = previous;
        }
      });
      _showProfileSettingsSnackBar(
        context,
        'Could not update privacy setting.',
      );
    }
  }

  Future<void> _updatePreferredLanguage({
    required User user,
    required UserProfile? profile,
    required String language,
    required String previousLanguage,
  }) async {
    try {
      final metadata = _buildMergedMetadata(
        profile,
        preferredLanguage: language,
      );
      await _userProfileRepository.updateFields(user.uid, <String, dynamic>{
        'metadata': metadata,
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _languageOverride = previousLanguage);
      _showProfileSettingsSnackBar(context, 'Could not update language.');
    }
  }

  Future<void> _copyReferralLink(String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(
        context,
        'Referral link copied.',
        isError: false,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(context, 'Could not copy referral link.');
    }
  }

  Future<void> _sendPasswordResetEmail(User user) async {
    if (_isSendingPasswordReset) {
      return;
    }
    final email = user.email?.trim();
    if (email == null || email.isEmpty) {
      _showProfileSettingsSnackBar(
        context,
        'No email is linked to this account.',
      );
      return;
    }

    setState(() => _isSendingPasswordReset = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(
        context,
        'Password reset email sent to $email.',
        isError: false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(
        context,
        error.message ?? 'Could not send password reset email.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(
        context,
        'Could not send password reset email right now.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingPasswordReset = false);
      }
    }
  }

  Future<void> _deleteAccount(User user) async {
    if (_isDeletingAccount) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: Text(
          'Delete account?',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone.',
          style: GoogleFonts.notoSans(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.notoSans(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    setState(() => _isDeletingAccount = true);
    try {
      await _userProfileRepository.deleteById(user.uid);
      await user.delete();

      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(context, 'Account deleted.', isError: false);
      context.go('/signup');
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.code == 'requires-recent-login'
          ? 'Re-authenticate, then try deleting your account again.'
          : (error.message ?? 'Could not delete account right now.');
      _showProfileSettingsSnackBar(context, message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showProfileSettingsSnackBar(context, 'Could not delete account.');
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  Map<String, dynamic> _buildMergedMetadata(
    UserProfile? profile, {
    String? profileUrlSlug,
    String? gender,
    List<String>? languages,
    String? preferredLanguage,
    Map<String, bool>? notifications,
    Map<String, bool>? privacy,
  }) {
    final metadata = Map<String, dynamic>.from(
      profile?.metadata ?? const <String, dynamic>{},
    );

    if (profileUrlSlug != null) {
      metadata['profile_url_slug'] = _sanitizeProfileSlug(profileUrlSlug);
    }
    if (gender != null) {
      metadata['gender'] = gender.trim();
    }
    if (languages != null) {
      metadata['languages'] = languages;
    }
    if (preferredLanguage != null) {
      metadata['preferred_language'] = preferredLanguage.trim();
    }
    if (notifications != null) {
      metadata['notifications'] = notifications;
    }
    if (privacy != null) {
      metadata['privacy'] = privacy;
    }

    return metadata;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;
        if (user == null) {
          _lastUserId = null;
          _notificationOverrides.clear();
          _privacyOverrides.clear();
          _languageOverride = null;
          return const _SignedOutProfileSettingsHint();
        }

        if (_lastUserId != user.uid) {
          _lastUserId = user.uid;
          _notificationOverrides.clear();
          _privacyOverrides.clear();
          _languageOverride = null;
        }

        return StreamBuilder<UserProfile?>(
          stream: _userProfileRepository.watchById(user.uid),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;
            final settings = _ProfileSettingsData.fromSources(
              user: user,
              profile: profile,
            );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1650),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 1220;
                    final left = Column(
                      children: [
                        _SidebarCard(
                          tabs: _tabs,
                          selected: _selected,
                          onTap: (i) => setState(() => _selected = i),
                        ),
                        if (_selected == 1) ...[
                          const SizedBox(height: 26),
                          const _PromoCard(),
                        ],
                      ],
                    );

                    final view = _currentView(
                      user: user,
                      profile: profile,
                      settings: settings,
                    );

                    if (stacked) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [left, const SizedBox(height: 20), view],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 420, child: left),
                        const SizedBox(width: 44),
                        Expanded(child: view),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onTap;

  const _SidebarCard({
    required this.tabs,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 286),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(30, 31, 34, 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            _SidebarTile(
              label: tabs[i],
              selected: i == selected,
              onTap: () => onTap(i),
            ),
            if (i < tabs.length - 1) const SizedBox(height: 3),
          ],
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromRGBO(255, 255, 255, 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: Color(0xFF2F88FF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: child,
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final Widget trailing;
  final Widget body;

  const _HeroCard({
    required this.title,
    required this.trailing,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 188,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/influencer_program.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ColoredBox(
                    color: Color(0xFF081133),
                    child: SizedBox(height: 72),
                  ),
                ),
                const Positioned(left: 22, top: 82, child: _Avatar()),
                Positioned(
                  left: 154,
                  top: 138,
                  child: Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: const Color(0xFFF2F3F5),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(right: 16, bottom: 16, child: trailing),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D31),
              borderRadius: BorderRadius.circular(8),
            ),
            child: body,
          ),
        ],
      ),
    );
  }
}

class _MyProfileTab extends StatelessWidget {
  final _ProfileSettingsData settings;
  final VoidCallback onEditProfile;
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteAccount;
  final bool sendingResetPassword;
  final bool deletingAccount;

  const _MyProfileTab({
    required this.settings,
    required this.onEditProfile,
    required this.onResetPassword,
    required this.onDeleteAccount,
    required this.sendingResetPassword,
    required this.deletingAccount,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Account',
            style: GoogleFonts.notoSans(
              color: const Color(0xFFF2F3F5),
              fontWeight: FontWeight.w700,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 20),
          _HeroCard(
            title: settings.displayName,
            trailing: _Btn.blue('Edit Profile', onPressed: onEditProfile),
            body: Column(
              children: [
                _Line('NAME', settings.displayName),
                const SizedBox(height: 14),
                _Line('EMAIL', settings.maskedEmail, reveal: true),
                const SizedBox(height: 14),
                _Line(
                  'PHONE NUMBER',
                  settings.maskedPhoneNumber,
                  reveal: true,
                  delete: settings.phoneNumber.trim().isNotEmpty,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _section(
            'Password and Authentication',
            sendingResetPassword ? 'Sending...' : 'Change Password',
            onPressed: sendingResetPassword ? null : onResetPassword,
          ),
          const SizedBox(height: 18),
          _section(
            'Account Removal',
            deletingAccount ? 'Deleting...' : 'Delete Account',
            red: true,
            onPressed: deletingAccount ? null : onDeleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    String action, {
    bool red = false,
    VoidCallback? onPressed,
  }) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          red
              ? _Btn.red(action, onPressed: onPressed)
              : _Btn.blue(action, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _EditProfileTab extends StatefulWidget {
  final _ProfileSettingsData settings;
  final bool saving;
  final Future<void> Function(_EditProfileUpdate update) onSave;

  const _EditProfileTab({
    required this.settings,
    required this.saving,
    required this.onSave,
  });

  @override
  State<_EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<_EditProfileTab> {
  final FrameStoreService _frameStoreService = FrameStoreService();
  late final TextEditingController _displayNameController;
  late final TextEditingController _profileUrlController;
  late final TextEditingController _genderController;
  late final TextEditingController _languagesController;

  bool _removingFrame = false;
  bool _didEdit = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.settings.displayName,
    );
    _profileUrlController = TextEditingController(
      text: widget.settings.profileUrlSlug,
    );
    _genderController = TextEditingController(text: widget.settings.gender);
    _languagesController = TextEditingController(
      text: widget.settings.languages.join(', '),
    );
    _displayNameController.addListener(_markEdited);
    _profileUrlController.addListener(_markEdited);
    _genderController.addListener(_markEdited);
    _languagesController.addListener(_markEdited);
  }

  @override
  void didUpdateWidget(covariant _EditProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_didEdit) {
      return;
    }

    if (oldWidget.settings.displayName != widget.settings.displayName) {
      _displayNameController.text = widget.settings.displayName;
    }
    if (oldWidget.settings.profileUrlSlug != widget.settings.profileUrlSlug) {
      _profileUrlController.text = widget.settings.profileUrlSlug;
    }
    if (oldWidget.settings.gender != widget.settings.gender) {
      _genderController.text = widget.settings.gender;
    }
    final oldLanguages = oldWidget.settings.languages.join(', ');
    final newLanguages = widget.settings.languages.join(', ');
    if (oldLanguages != newLanguages) {
      _languagesController.text = newLanguages;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _profileUrlController.dispose();
    _genderController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _markEdited() {
    if (_didEdit) {
      return;
    }
    setState(() => _didEdit = true);
  }

  Future<void> _removeFrame() async {
    if (_removingFrame) {
      return;
    }

    setState(() => _removingFrame = true);
    try {
      await _frameStoreService.setActiveFrame(null);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile frame removed.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } on FrameStoreException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: const Color(0xFFB43A3A),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove frame right now.'),
          backgroundColor: Color(0xFFB43A3A),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _removingFrame = false);
      }
    }
  }

  Future<void> _handleSave() async {
    final displayName = _displayNameController.text.trim();
    final slug = _sanitizeProfileSlug(_profileUrlController.text);
    final gender = _genderController.text.trim();
    final languages = _languagesController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (displayName.isEmpty) {
      _showProfileSettingsSnackBar(context, 'Display name is required.');
      return;
    }

    await widget.onSave(
      _EditProfileUpdate(
        displayName: displayName,
        profileUrlSlug: slug,
        gender: gender,
        languages: languages,
        preferredLanguage: widget.settings.preferredLanguage,
      ),
    );
    if (mounted) {
      setState(() => _didEdit = false);
    }
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 11,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.42),
                fontSize: 10,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.11),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.21),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.21),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFF2F88FF)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: _HeroCard(
        title: widget.settings.displayName,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn.blue(
              'Change Frame',
              onPressed: () => context.go('/settings?tab=store'),
            ),
            const SizedBox(width: 6),
            _Btn.gray(
              _removingFrame ? 'Removing...' : 'Remove Frame',
              onPressed: _removingFrame ? null : _removeFrame,
            ),
          ],
        ),
        body: Column(
          children: [
            _editableField(
              label: 'Display Name',
              controller: _displayNameController,
            ),
            const SizedBox(height: 10),
            _editableField(
              label: 'Profile URL',
              controller: _profileUrlController,
              hint: 'waiby.gg/your-handle',
            ),
            const SizedBox(height: 10),
            _editableField(
              label: 'Gender',
              controller: _genderController,
              hint: 'Choose your gender',
            ),
            const SizedBox(height: 10),
            _editableField(
              label: 'Languages',
              controller: _languagesController,
              hint: 'English, Spanish',
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: _Btn.blue(
                widget.saving ? 'Saving...' : 'Save',
                onPressed: widget.saving ? null : _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  final Map<String, bool> values;
  final void Function(String key, bool value) onToggle;

  const _NotificationsTab({required this.values, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Banner(
            title: 'Enable push notifications',
            subtitle: 'Never miss an update with real-time alerts',
            action: 'Enable',
            onAction: () => onToggle('push_enabled', true),
          ),
          const SizedBox(height: 20),
          _RowItem(
            title: 'Enable email notifications',
            subtitle:
                'Get notified about orders, platform news, major updates, and special promotions.',
            on: values['email_enabled'] ?? false,
            onChanged: (value) => onToggle('email_enabled', value),
          ),
          const SizedBox(height: 14),
          _RowItem(
            title: 'Buddy Recommendations',
            subtitle:
                'Receive creator recommendations selected by the platform.',
            on: values['buddy_recommendations'] ?? false,
            onChanged: (value) => onToggle('buddy_recommendations', value),
          ),
          const SizedBox(height: 18),
          const _Divider(),
          const SizedBox(height: 18),
          const _RowItem(title: 'Sounds', subtitle: '', header: true),
          const SizedBox(height: 10),
          _RowItem(
            title: 'New Message',
            subtitle: '',
            on: values['sound_new_message'] ?? true,
            onChanged: (value) => onToggle('sound_new_message', value),
          ),
          const SizedBox(height: 10),
          _RowItem(
            title: 'Order',
            subtitle: '',
            on: values['sound_order'] ?? true,
            onChanged: (value) => onToggle('sound_order', value),
          ),
          const SizedBox(height: 10),
          _RowItem(
            title: 'Incoming Call ring',
            subtitle: '',
            on: values['sound_incoming_call'] ?? false,
            onChanged: (value) => onToggle('sound_incoming_call', value),
          ),
        ],
      ),
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  final Map<String, bool> values;
  final void Function(String key, bool value) onToggle;

  const _PrivacyTab({required this.values, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowItem(
            title: 'Incognito Browsing',
            subtitle: 'View profiles anonymously without notifying users',
            on: values['incognito_browsing'] ?? false,
            premium: true,
            onChanged: (value) => onToggle('incognito_browsing', value),
          ),
          const SizedBox(height: 14),
          _RowItem(
            title: 'Hide activity interactions',
            subtitle:
                'Hide your Following, likes, and pet activity from other users.',
            on: values['hide_activity_interactions'] ?? false,
            premium: true,
            onChanged: (value) => onToggle('hide_activity_interactions', value),
          ),
          const SizedBox(height: 14),
          _RowItem(
            title: 'Hide identity on leaderboard',
            subtitle: 'Hide your avatar and nickname on leaderboards.',
            on: values['hide_leaderboard_identity'] ?? true,
            onChanged: (value) => onToggle('hide_leaderboard_identity', value),
          ),
          const SizedBox(height: 14),
          _RowItem(
            title: 'Disable profile suggestions',
            subtitle: 'Hide your profile from recommendations.',
            on: values['disable_profile_suggestions'] ?? true,
            onChanged: (value) =>
                onToggle('disable_profile_suggestions', value),
          ),
          const SizedBox(height: 18),
          const _Divider(),
          const SizedBox(height: 18),
          const _BlockedRow(),
          const SizedBox(height: 18),
          const _Divider(),
          const SizedBox(height: 18),
          const _RowItem(
            title: 'Social Permissions',
            subtitle: '',
            header: true,
          ),
          const SizedBox(height: 14),
          _RowItem(
            title: 'Direct Message',
            subtitle:
                'Only allow messages after an order is placed or when you start the conversation',
            on: values['direct_message_restricted'] ?? false,
            premium: true,
            onChanged: (value) => onToggle('direct_message_restricted', value),
          ),
        ],
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;

  const _LanguageTab({
    required this.selectedLanguage,
    required this.onSelectLanguage,
  });

  static const List<String> _leftColumnLanguages = <String>[
    'English',
    'Deutsch',
    '中文',
    '日本語',
    'العربية',
    'Hrvatski',
  ];

  static const List<String> _rightColumnLanguages = <String>[
    'Español',
    'Français',
    'русский',
    'Português',
    'Türkçe',
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Language',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20 * 2.0,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set your preferred display language.',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.46),
              fontWeight: FontWeight.w500,
              fontSize: 10,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(43, 45, 49, 0.52),
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 560;

                if (stacked) {
                  return Column(
                    children: [
                      for (final language in _leftColumnLanguages) ...[
                        _LanguageChip(
                          label: language,
                          selected: language == selectedLanguage,
                          onTap: () => onSelectLanguage(language),
                        ),
                        const SizedBox(height: 12),
                      ],
                      for (
                        var i = 0;
                        i < _rightColumnLanguages.length;
                        i++
                      ) ...[
                        _LanguageChip(
                          label: _rightColumnLanguages[i],
                          selected:
                              _rightColumnLanguages[i] == selectedLanguage,
                          onTap: () =>
                              onSelectLanguage(_rightColumnLanguages[i]),
                        ),
                        if (i < _rightColumnLanguages.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < _leftColumnLanguages.length;
                            i++
                          ) ...[
                            _LanguageChip(
                              label: _leftColumnLanguages[i],
                              selected:
                                  _leftColumnLanguages[i] == selectedLanguage,
                              onTap: () =>
                                  onSelectLanguage(_leftColumnLanguages[i]),
                            ),
                            if (i < _leftColumnLanguages.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 38),
                    Expanded(
                      child: Column(
                        children: [
                          for (
                            var i = 0;
                            i < _rightColumnLanguages.length;
                            i++
                          ) ...[
                            _LanguageChip(
                              label: _rightColumnLanguages[i],
                              selected:
                                  _rightColumnLanguages[i] == selectedLanguage,
                              onTap: () =>
                                  onSelectLanguage(_rightColumnLanguages[i]),
                            ),
                            if (i < _rightColumnLanguages.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_outline_rounded
                      : Icons.circle_outlined,
                  size: 32,
                  color: selected ? const Color(0xFF51D76E) : Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * 2.1,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferralsTab extends StatelessWidget {
  final String referralLink;
  final VoidCallback onCopyReferralLink;

  const _ReferralsTab({
    required this.referralLink,
    required this.onCopyReferralLink,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 28, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Waiby Referral Program',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: Text(
              'Earn cashback when your friends pay on Waiby!\n'
              'Invite friends to Waiby and earn cashback every time they place an order.\n'
              'The more they stay, the more you earn.',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 34 / 2.1,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1050;
              if (!wide) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferralProgramDetails(),
                    SizedBox(height: 18),
                    _ImportantRulesCard(),
                  ],
                );
              }
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _ReferralProgramDetails()),
                  SizedBox(width: 26),
                  SizedBox(width: 440, child: _ImportantRulesCard()),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          const _ReferralMetricsGrid(),
          const SizedBox(height: 24),
          Text(
            'Invite & Earn',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 46 / 1.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your referral link and unlock rewards.',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 30 / 2.1,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 500;
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReferralLinkField(link: referralLink),
                    const SizedBox(height: 10),
                    _CopyLinkButton(onPressed: onCopyReferralLink),
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(
                    width: 360,
                    child: _ReferralLinkField(link: referralLink),
                  ),
                  const SizedBox(width: 10),
                  _CopyLinkButton(onPressed: onCopyReferralLink),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReferralProgramDetails extends StatelessWidget {
  const _ReferralProgramDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenTag(label: 'Cashback rates'),
        const SizedBox(height: 10),
        Text(
          '-Non-Verified users: earn 0.5% cashback\n'
          '-Verified users: earn 1.5% cashback',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cashback is calculated on every completed order made by your invited customer.',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 31 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        const _GreenTag(label: 'How it works'),
        const SizedBox(height: 10),
        Text(
          '1. Share your personal referral link\n'
          '2. Your friend signs up and completes their first order\n'
          '3. From their second order onward, you earn cashback automatically',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'That\'s it. No limits, no tricks.',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const _GreenTag(label: 'Bonus for your friend'),
        const SizedBox(height: 10),
        Text(
          'Your invited friend gets:\n   -5% fee on their first order',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Applied automatically at checkout.',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 40 / 2.2,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _GreenTag extends StatelessWidget {
  final String label;

  const _GreenTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF308211),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _ImportantRulesCard extends StatelessWidget {
  const _ImportantRulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        border: Border.all(color: const Color(0xFFFF0000), width: 0.8),
      ),
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important rules',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
              fontSize: 20 * 1.6,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '\u2022 Cashback starts from the 2nd order\n'
            '\u2022 Only completed orders count\n'
            '\u2022 Refunds or charge backs are excluded\n'
            '\u2022 Abuse, self-buying, or off-platform activity will cancel the\n'
            '  referral and both account banned, creator & customer.',
            style: GoogleFonts.notoSans(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralMetricsGrid extends StatelessWidget {
  const _ReferralMetricsGrid();

  static const List<_ReferralMetricData> _metrics = <_ReferralMetricData>[
    _ReferralMetricData(
      title: 'Earnings',
      value: '72,20 EUR',
      accent: Color(0xFF1FC27B),
      glow: Color.fromRGBO(27, 199, 166, 0.42),
      bars: <int>[3, 5, 4, 3, 4, 5, 7, 6, 8, 11, 10, 14],
    ),
    _ReferralMetricData(
      title: 'Link Opens',
      value: '100',
      accent: Color(0xFF5E95F6),
      glow: Color.fromRGBO(59, 130, 255, 0.42),
      bars: <int>[6, 9, 7, 10, 5, 6, 8, 7, 9, 10, 13, 16],
    ),
    _ReferralMetricData(
      title: 'Registrations',
      value: '29',
      accent: Color(0xFFD94BEB),
      glow: Color.fromRGBO(251, 222, 255, 0.42),
      bars: <int>[8, 6, 4, 7, 5, 5, 6, 8, 4, 6, 10, 16],
    ),
    _ReferralMetricData(
      title: 'Completed Orders',
      value: '29',
      accent: Color(0xFFEEB24C),
      glow: Color.fromRGBO(235, 186, 104, 0.42),
      bars: <int>[4, 8, 10, 12, 5, 8, 6, 7, 8, 6, 7, 9],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final width = constraints.maxWidth;

        int columns;
        if (width >= 1200) {
          columns = 4;
        } else if (width >= 680) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = (width - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in _metrics)
              SizedBox(
                width: cardWidth,
                child: _ReferralMetricCard(data: metric),
              ),
          ],
        );
      },
    );
  }
}

class _ReferralMetricCard extends StatelessWidget {
  final _ReferralMetricData data;

  const _ReferralMetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: data.glow.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: data.glow, blurRadius: 18, spreadRadius: 2),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: data.accent.withValues(alpha: 0.65),
            width: 0.7,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: GoogleFonts.notoSans(
                      color: data.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * 1.3,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.value,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * 1.3,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 112,
              child: Align(
                alignment: Alignment.bottomRight,
                child: _SparkBars(accent: data.accent, values: data.bars),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkBars extends StatelessWidget {
  final Color accent;
  final List<int> values;

  const _SparkBars({required this.accent, required this.values});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          Container(
            width: 6,
            height: (values[i].toDouble().clamp(3, 18) * 2.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent, const Color(0xFFC4E0DC)],
              ),
            ),
          ),
          if (i < values.length - 1) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

class _ReferralLinkField extends StatelessWidget {
  final String link;

  const _ReferralLinkField({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1220),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        link,
        style: GoogleFonts.notoSans(
          color: Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
          fontSize: 12 * 1.2,
        ),
      ),
    );
  }
}

class _CopyLinkButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CopyLinkButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.copy_rounded, size: 14),
        label: Text(
          'Copy link',
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 10 * 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF2F88FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}

@immutable
class _ReferralMetricData {
  final String title;
  final String value;
  final Color accent;
  final Color glow;
  final List<int> bars;

  const _ReferralMetricData({
    required this.title,
    required this.value,
    required this.accent,
    required this.glow,
    required this.bars,
  });
}

class _Banner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback? onAction;

  const _Banner({
    required this.title,
    required this.subtitle,
    required this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D31),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.46),
                    fontWeight: FontWeight.w500,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),
          _Btn.blue(action, onPressed: onAction),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool header;
  final bool premium;
  final bool? on;
  final ValueChanged<bool>? onChanged;

  const _RowItem({
    required this.title,
    required this.subtitle,
    this.header = false,
    this.premium = false,
    this.on,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: header ? 15 : 12,
          ),
        ),
        if (premium) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.workspace_premium_rounded,
            size: 11,
            color: Color(0xFF51D76E),
          ),
        ],
      ],
    );

    if (on == null) {
      return titleWidget;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    color: Colors.white.withValues(alpha: 0.46),
                    fontWeight: FontWeight.w500,
                    fontSize: 7,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _Toggle(on: on!, onChanged: onChanged),
      ],
    );
  }
}

class _BlockedRow extends StatelessWidget {
  const _BlockedRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RowItem(
            title: 'Blocked users',
            subtitle: 'View and manage users you\'ve blocked.',
          ),
        ),
        _Btn.blue('View'),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool reveal;
  final bool delete;

  const _Line(
    this.label,
    this.value, {
    this.reveal = false,
    this.delete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  color: const Color(0xFFB5BAC1),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  if (reveal)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Reveal',
                        style: GoogleFonts.notoSans(
                          color: const Color(0xFF00A8FC),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (delete)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              'Delete',
              style: GoogleFonts.notoSans(
                color: const Color(0xFFFF0000),
                fontSize: 13,
              ),
            ),
          ),
        _Btn.gray('Edit'),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool on;
  final ValueChanged<bool>? onChanged;

  const _Toggle({required this.on, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged!.call(!on),
        borderRadius: BorderRadius.circular(212),
        child: Container(
          width: 33,
          height: 13,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: on ? const Color(0xFF51D76E) : const Color(0xFF303030),
            borderRadius: BorderRadius.circular(212),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          child: Align(
            alignment: on ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFFECECEC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 0.5,
      color: Colors.white.withValues(alpha: 0.14),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final EdgeInsets padding;
  final VoidCallback? onPressed;

  const _Btn._(this.label, this.color, this.padding, this.onPressed);

  const _Btn.blue(String label, {VoidCallback? onPressed})
    : this._(
        label,
        const Color(0xFF2F88FF),
        const EdgeInsets.symmetric(horizontal: 18),
        onPressed,
      );
  const _Btn.gray(String label, {VoidCallback? onPressed})
    : this._(
        label,
        const Color(0xFF2B2D31),
        const EdgeInsets.symmetric(horizontal: 16),
        onPressed,
      );
  const _Btn.red(String label, {VoidCallback? onPressed})
    : this._(
        label,
        const Color(0xFFFF0000),
        const EdgeInsets.symmetric(horizontal: 16),
        onPressed,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const UserAvatarWithFrame(
          size: 80,
          frameScale: 1.30,
          borderWidth: 2,
          borderColor: Color(0xFF8EFA4E),
          fallbackAsset: 'assets/pp4.png',
        ),
        Positioned(
          left: 2,
          top: -8,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2F88FF),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.star, size: 11, color: Color(0xFFF6E27A)),
          ),
        ),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        height: 86,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/leaderboard_wallpaper.png', fit: BoxFit.cover),
            Positioned(
              left: 112,
              top: 12,
              child: Text(
                'Style your profile',
                style: GoogleFonts.notoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              left: 112,
              top: 34,
              child: Text(
                'Unlock exclusive avatar decorations and more',
                style: GoogleFonts.notoSans(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 7,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -16,
              child: SizedBox(
                width: 120,
                child: Image.asset('assets/bunny1.png'),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 8,
              child: _Btn.blue(
                'Open shop',
                onPressed: () => context.go('/settings?tab=store'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _EditProfileUpdate {
  final String displayName;
  final String profileUrlSlug;
  final String gender;
  final List<String> languages;
  final String preferredLanguage;

  const _EditProfileUpdate({
    required this.displayName,
    required this.profileUrlSlug,
    required this.gender,
    required this.languages,
    required this.preferredLanguage,
  });
}

@immutable
class _ProfileSettingsData {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String profileUrlSlug;
  final String gender;
  final List<String> languages;
  final String preferredLanguage;
  final Map<String, bool> notifications;
  final Map<String, bool> privacy;
  final String referralCode;
  final String referralLink;

  const _ProfileSettingsData({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    required this.profileUrlSlug,
    required this.gender,
    required this.languages,
    required this.preferredLanguage,
    required this.notifications,
    required this.privacy,
    required this.referralCode,
    required this.referralLink,
  });

  factory _ProfileSettingsData.fromSources({
    required User user,
    required UserProfile? profile,
  }) {
    final metadata = Map<String, dynamic>.from(
      profile?.metadata ?? const <String, dynamic>{},
    );

    final displayName = _firstNonEmpty(<String?>[
      profile?.fullName,
      user.displayName,
      user.email?.split('@').first,
    ], fallback: 'User');
    final email = _firstNonEmpty(<String?>[profile?.email, user.email]);
    final phoneNumber = _firstNonEmpty(<String?>[
      metadata['phone_number']?.toString(),
      metadata['phone']?.toString(),
      user.phoneNumber,
    ]);
    final profileSlug = _sanitizeProfileSlug(
      _firstNonEmpty(<String?>[
        metadata['profile_url_slug']?.toString(),
        metadata['profile_slug']?.toString(),
        displayName,
      ], fallback: user.uid),
    );
    final gender = _firstNonEmpty(<String?>[
      metadata['gender']?.toString(),
    ], fallback: 'Choose your gender');

    final rawLanguages = metadata['languages'];
    final parsedLanguages = rawLanguages is Iterable
        ? rawLanguages
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final languages = parsedLanguages.isEmpty
        ? const <String>['English']
        : parsedLanguages;

    final preferredLanguage = _firstNonEmpty(<String?>[
      metadata['preferred_language']?.toString(),
      if (languages.isNotEmpty) languages.first,
    ], fallback: 'English');

    final notifications = _extractBoolMap(
      metadata['notifications'],
      _defaultNotificationSettings,
    );
    final privacy = _extractBoolMap(
      metadata['privacy'],
      _defaultPrivacySettings,
    );
    final referralCode = _firstNonEmpty(
      <String?>[metadata['referral_code']?.toString()],
      fallback: user.uid.length > 8
          ? user.uid.substring(0, 8).toLowerCase()
          : user.uid.toLowerCase(),
    );
    final referralLink = 'https://waiby.gg/?ref=$referralCode';

    return _ProfileSettingsData(
      displayName: displayName,
      email: email,
      phoneNumber: phoneNumber,
      profileUrlSlug: profileSlug,
      gender: gender,
      languages: languages,
      preferredLanguage: preferredLanguage,
      notifications: notifications,
      privacy: privacy,
      referralCode: referralCode,
      referralLink: referralLink,
    );
  }

  String get maskedEmail => _maskEmail(email);

  String get maskedPhoneNumber =>
      phoneNumber.trim().isEmpty ? 'Not added' : _maskPhone(phoneNumber);
}

class _SignedOutProfileSettingsHint extends StatelessWidget {
  const _SignedOutProfileSettingsHint();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in to manage your profile settings',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profile, privacy, language and notification preferences are account-based and synced from backend.',
              style: GoogleFonts.notoSans(
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            _Btn.blue('Go to login', onPressed: () => context.go('/login')),
          ],
        ),
      ),
    );
  }
}

Map<String, bool> _extractBoolMap(dynamic raw, Map<String, bool> defaults) {
  final result = Map<String, bool>.from(defaults);
  if (raw is! Map) {
    return result;
  }

  for (final entry in raw.entries) {
    final key = entry.key.toString();
    if (!result.containsKey(key)) {
      continue;
    }
    result[key] = _toBool(entry.value, fallback: result[key] ?? false);
  }
  return result;
}

bool _toBool(dynamic value, {required bool fallback}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

String _firstNonEmpty(Iterable<String?> values, {String fallback = ''}) {
  for (final candidate in values) {
    final normalized = candidate?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
  }
  return fallback;
}

String _sanitizeProfileSlug(String input) {
  final trimmed = input.trim().toLowerCase();
  final withoutProtocol = trimmed
      .replaceFirst('https://', '')
      .replaceFirst('http://', '')
      .replaceFirst('waiby.gg/', '');
  final afterSlash = withoutProtocol.contains('/')
      ? withoutProtocol.split('/').last
      : withoutProtocol;
  final cleaned = afterSlash
      .replaceAll(RegExp(r'[^a-z0-9\-_ ]'), '')
      .replaceAll(RegExp(r'[\s_]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (cleaned.isEmpty) {
    return 'user';
  }
  return cleaned;
}

String _maskEmail(String email) {
  final normalized = email.trim();
  final atIndex = normalized.indexOf('@');
  if (atIndex <= 0) {
    return normalized.isEmpty ? 'Not added' : normalized;
  }

  final local = normalized.substring(0, atIndex);
  final domain = normalized.substring(atIndex);
  final visible = local.length <= 2 ? 1 : 2;
  final hiddenCount = (local.length - visible).clamp(1, 20);
  return '${local.substring(0, visible)}${'*' * hiddenCount}$domain';
}

String _maskPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 4) {
    return phone;
  }
  return '${'*' * (digits.length - 4)}${digits.substring(digits.length - 4)}';
}

void _showProfileSettingsSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? const Color(0xFFB43A3A)
          : const Color(0xFF2E7D32),
    ),
  );
}

class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0x12000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
        ),
        child: Text(
          '$title view is ready for the next mock.',
          style: GoogleFonts.notoSans(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
