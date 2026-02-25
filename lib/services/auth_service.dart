import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/config/app_config.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repository.dart';

class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? errorCode;
  final bool requiresEmailVerification;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.errorCode,
    this.requiresEmailVerification = false,
  });

  factory AuthResult.success({
    User? user,
    String? message,
    bool requiresEmailVerification = false,
  }) {
    return AuthResult(
      success: true,
      user: user,
      message: message ?? 'Operation completed successfully.',
      requiresEmailVerification: requiresEmailVerification,
    );
  }

  factory AuthResult.failure({required String message, String? errorCode}) {
    return AuthResult(success: false, message: message, errorCode: errorCode);
  }
}

/// Comprehensive authentication service backed by Firebase Auth + Firestore.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    UserProfileRepository? userProfileRepository,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = !kIsWeb
           ? (googleSignIn ??
                 GoogleSignIn(
                   serverClientId: AppConfig.googleServerClientId.isNotEmpty
                       ? AppConfig.googleServerClientId
                       : null,
                   scopes: const ['email', 'profile'],
                 ))
           : null,
       _userProfileRepository =
           userProfileRepository ?? UserProfileRepository();

  final FirebaseAuth _auth;
  final GoogleSignIn? _googleSignIn;
  final UserProfileRepository _userProfileRepository;

  UserProfile? _cachedProfile;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => currentUser != null;

  /// Kept for API compatibility with previous web flow implementation.
  Future<void> completePendingWebAuthFlow() async {}

  Future<void> preloadCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      _cachedProfile = null;
      return;
    }
    _cachedProfile = await _userProfileRepository.fetchById(user.uid);
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure(
          message: 'Failed to create account. Please try again.',
        );
      }

      final cleanedName = name?.trim();
      if (cleanedName != null && cleanedName.isNotEmpty) {
        await user.updateDisplayName(cleanedName);
      }

      await user.reload();
      final refreshedUser = _auth.currentUser ?? user;

      await _ensureUserProfileDocument(
        user: refreshedUser,
        preferredName: cleanedName,
      );

      if (AuthConfig.requireEmailConfirmation && !refreshedUser.emailVerified) {
        await refreshedUser.sendEmailVerification();
        await _auth.signOut();
        return AuthResult.success(
          user: refreshedUser,
          requiresEmailVerification: true,
          message:
              'Account created successfully. Please verify your email before signing in.',
        );
      }

      return AuthResult.success(
        user: refreshedUser,
        message: 'Account created and signed in successfully.',
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      var user = credential.user;
      if (user == null) {
        return AuthResult.failure(
          message: 'Failed to sign in. Please check your credentials.',
        );
      }

      await user.reload();
      user = _auth.currentUser ?? user;

      if (AuthConfig.requireEmailConfirmation && !user.emailVerified) {
        await user.sendEmailVerification();
        await _auth.signOut();
        return AuthResult.failure(
          message: 'Please verify your email before signing in.',
          errorCode: 'EMAIL_NOT_VERIFIED',
        );
      }

      await _ensureUserProfileDocument(user: user);

      return AuthResult.success(user: user, message: 'Signed in successfully.');
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        credential = await _auth.signInWithPopup(provider);
      } else {
        final googleSignIn = _googleSignIn;
        if (googleSignIn == null) {
          return AuthResult.failure(
            message: 'Google Sign-In is not initialized on this platform.',
          );
        }

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return AuthResult.failure(
            message: 'Google sign-in was cancelled.',
            errorCode: 'CANCELLED',
          );
        }

        final googleAuth = await googleUser.authentication;
        final firebaseCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        credential = await _auth.signInWithCredential(firebaseCredential);
      }

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure(message: 'Failed to sign in with Google.');
      }

      await _ensureUserProfileDocument(user: user);

      return AuthResult.success(
        user: user,
        message: 'Signed in with Google successfully.',
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error signing in with Google: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signInWithFacebook() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        final provider = FacebookAuthProvider()..addScope('email');
        credential = await _auth.signInWithPopup(provider);
      } else {
        final loginResult = await FacebookAuth.instance.login(
          permissions: const ['email', 'public_profile'],
        );

        switch (loginResult.status) {
          case LoginStatus.success:
            final accessToken = loginResult.accessToken;
            if (accessToken == null) {
              return AuthResult.failure(
                message: 'Failed to get Facebook access token.',
              );
            }
            final facebookCredential = FacebookAuthProvider.credential(
              accessToken.tokenString,
            );
            credential = await _auth.signInWithCredential(facebookCredential);
            break;
          case LoginStatus.cancelled:
            return AuthResult.failure(
              message: 'Facebook sign-in was cancelled.',
              errorCode: 'CANCELLED',
            );
          case LoginStatus.failed:
            return AuthResult.failure(
              message:
                  loginResult.message ?? 'Failed to sign in with Facebook.',
            );
          case LoginStatus.operationInProgress:
            return AuthResult.failure(
              message: 'Facebook sign-in is already in progress.',
            );
        }
      }

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure(message: 'Failed to sign in with Facebook.');
      }

      await _ensureUserProfileDocument(user: user);

      return AuthResult.success(
        user: user,
        message: 'Signed in with Facebook successfully.',
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(
        message: 'Error signing in with Facebook: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signOut() async {
    try {
      try {
        final googleSignIn = _googleSignIn;
        if (!kIsWeb &&
            googleSignIn != null &&
            await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (_) {
        // Ignore provider sign-out issues, Firebase signOut is the source of truth.
      }

      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {
        // Ignore provider sign-out issues, Firebase signOut is the source of truth.
      }

      await _auth.signOut();
      _cachedProfile = null;

      return AuthResult.success(message: 'Signed out successfully.');
    } catch (e) {
      return AuthResult.failure(message: 'Error signing out: ${e.toString()}');
    }
  }

  Future<AuthResult> resetPassword(String email) async {
    try {
      final trimmedEmail = email.trim();
      final continueUrl = AppConfig.resetPasswordContinueUrl;

      if (continueUrl.isNotEmpty) {
        await _auth.sendPasswordResetEmail(
          email: trimmedEmail,
          actionCodeSettings: ActionCodeSettings(
            url: continueUrl,
            handleCodeInApp: false,
          ),
        );
      } else {
        await _auth.sendPasswordResetEmail(email: trimmedEmail);
      }

      return AuthResult.success(
        message: 'Password reset link was sent to your email.',
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure(message: 'You must be signed in first.');
      }

      await user.updatePassword(newPassword);
      return AuthResult.success(message: 'Password updated successfully.');
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<AuthResult> updateUserProfile({
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure(message: 'You must be signed in first.');
      }

      final cleanedName = name?.trim();
      final cleanedAvatar = avatarUrl?.trim();

      if (cleanedName != null && cleanedName.isNotEmpty) {
        await user.updateDisplayName(cleanedName);
      }

      if (cleanedAvatar != null && cleanedAvatar.isNotEmpty) {
        await user.updatePhotoURL(cleanedAvatar);
      }

      await user.reload();
      final refreshedUser = _auth.currentUser ?? user;

      final metadata = <String, dynamic>{
        ...(_cachedProfile?.metadata ?? const <String, dynamic>{}),
        if (additionalData != null) ...additionalData,
      };
      if (cleanedName != null && cleanedName.isNotEmpty) {
        metadata['full_name'] = cleanedName;
        metadata['name'] = cleanedName;
      }
      if (cleanedAvatar != null && cleanedAvatar.isNotEmpty) {
        metadata['avatar_url'] = cleanedAvatar;
        metadata['picture'] = cleanedAvatar;
      }

      await _userProfileRepository
          .updateFields(refreshedUser.uid, <String, dynamic>{
            if (cleanedName != null && cleanedName.isNotEmpty)
              'full_name': cleanedName,
            if (cleanedAvatar != null && cleanedAvatar.isNotEmpty)
              'avatar_url': cleanedAvatar,
            'email': refreshedUser.email,
            'email_verified': refreshedUser.emailVerified,
            'providers': _providerIds(refreshedUser),
            'metadata': metadata,
          });

      _cachedProfile = await _userProfileRepository.fetchById(
        refreshedUser.uid,
      );

      return AuthResult.success(
        user: refreshedUser,
        message: 'Profile updated successfully.',
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<AuthResult> resendConfirmationEmail(String email) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure(
          message: 'Please sign in first to resend verification email.',
        );
      }

      final userEmail = user.email?.trim().toLowerCase();
      final requestedEmail = email.trim().toLowerCase();
      if (userEmail != null &&
          requestedEmail.isNotEmpty &&
          userEmail != requestedEmail) {
        return AuthResult.failure(
          message: 'Signed in email does not match the requested email.',
        );
      }

      await user.sendEmailVerification();
      return AuthResult.success(
        message: 'Verification email has been sent again.',
      );
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final user = currentUser;
    if (user == null) {
      return;
    }
    await _userProfileRepository.updateFields(user.uid, <String, dynamic>{
      'is_online': isOnline,
    });
    _cachedProfile = _cachedProfile?.copyWith(isOnline: isOnline);
  }

  Map<String, dynamic>? getUserMetadata() {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    final metadata = <String, dynamic>{
      ...(_cachedProfile?.metadata ?? const <String, dynamic>{}),
    };

    final displayName = _cachedProfile?.fullName ?? user.displayName;
    final avatarUrl = _cachedProfile?.avatarUrl ?? user.photoURL;

    if (displayName != null && displayName.isNotEmpty) {
      metadata['full_name'] = displayName;
      metadata['name'] = displayName;
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      metadata['avatar_url'] = avatarUrl;
      metadata['picture'] = avatarUrl;
    }

    return metadata;
  }

  String? getUserDisplayName() {
    final profileName = _cachedProfile?.fullName;
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }
    final authName = currentUser?.displayName;
    if (authName != null && authName.isNotEmpty) {
      return authName;
    }
    return currentUser?.email?.split('@').first;
  }

  String? getUserAvatarUrl() {
    final profileAvatar = _cachedProfile?.avatarUrl;
    if (profileAvatar != null && profileAvatar.isNotEmpty) {
      return profileAvatar;
    }
    final authAvatar = currentUser?.photoURL;
    if (authAvatar != null && authAvatar.isNotEmpty) {
      return authAvatar;
    }
    return null;
  }

  Future<void> _ensureUserProfileDocument({
    required User user,
    String? preferredName,
  }) async {
    final existing = await _userProfileRepository.fetchById(user.uid);

    final displayName = preferredName?.trim().isNotEmpty == true
        ? preferredName!.trim()
        : (user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : existing?.fullName);

    final avatarUrl = user.photoURL?.trim().isNotEmpty == true
        ? user.photoURL!.trim()
        : existing?.avatarUrl;

    final metadata = <String, dynamic>{
      ...(existing?.metadata ?? const <String, dynamic>{}),
      if (displayName != null && displayName.isNotEmpty)
        'full_name': displayName,
      if (displayName != null && displayName.isNotEmpty) 'name': displayName,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'picture': avatarUrl,
    };

    final profile = UserProfile(
      id: user.uid,
      email: user.email ?? existing?.email,
      fullName: displayName,
      avatarUrl: avatarUrl,
      emailVerified: user.emailVerified,
      providers: _providerIds(user),
      isOnline: existing?.isOnline ?? true,
      metadata: metadata,
      createdAt: existing?.createdAt,
    );

    await _userProfileRepository.upsert(profile);
    _cachedProfile = profile;
  }

  List<String> _providerIds(User user) {
    final providers =
        user.providerData
            .map((provider) => provider.providerId)
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return providers;
  }

  AuthResult _handleAuthException(FirebaseAuthException e) {
    final normalized = e.code.toLowerCase();
    switch (normalized) {
      case 'invalid-login-credentials':
      case 'invalid-credential':
      case 'wrong-password':
        return AuthResult.failure(
          message: 'Invalid email or password.',
          errorCode: normalized,
        );
      case 'user-not-found':
        return AuthResult.failure(
          message: 'No account was found for this email.',
          errorCode: normalized,
        );
      case 'email-already-in-use':
        return AuthResult.failure(
          message: 'This email is already registered.',
          errorCode: normalized,
        );
      case 'weak-password':
        return AuthResult.failure(
          message: 'Password is too weak. Use a stronger password.',
          errorCode: normalized,
        );
      case 'invalid-email':
        return AuthResult.failure(
          message: 'Email format is not valid.',
          errorCode: normalized,
        );
      case 'user-disabled':
        return AuthResult.failure(
          message: 'This user account has been disabled.',
          errorCode: normalized,
        );
      case 'too-many-requests':
        return AuthResult.failure(
          message: 'Too many attempts. Please wait and try again later.',
          errorCode: normalized,
        );
      case 'network-request-failed':
        return AuthResult.failure(
          message: 'Network error. Please check your internet connection.',
          errorCode: normalized,
        );
      case 'operation-not-allowed':
        return AuthResult.failure(
          message: 'This authentication method is not enabled.',
          errorCode: normalized,
        );
      case 'requires-recent-login':
        return AuthResult.failure(
          message: 'Please sign in again and retry this sensitive operation.',
          errorCode: normalized,
        );
      case 'popup-closed-by-user':
      case 'web-context-cancelled':
        return AuthResult.failure(
          message: 'The authentication flow was cancelled.',
          errorCode: 'CANCELLED',
        );
      case 'account-exists-with-different-credential':
        return AuthResult.failure(
          message:
              'An account already exists with a different sign-in provider for this email.',
          errorCode: normalized,
        );
      default:
        return AuthResult.failure(
          message: e.message ?? 'Authentication failed.',
          errorCode: normalized,
        );
    }
  }
}
