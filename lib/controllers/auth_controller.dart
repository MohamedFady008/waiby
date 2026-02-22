import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/validators/auth_validators.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final Rxn<User> currentUser = Rxn<User>();
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final RxBool online = true.obs;

  final RxBool _isCreator = false.obs;

  bool get isLoggedIn => currentUser.value != null;
  bool get loggedIn => isLoggedIn;
  bool get isCreator => _isCreator.value;
  String get userName => _authService.getUserDisplayName() ?? 'User';
  String get name => userName;
  String? get userEmail => currentUser.value?.email;
  String? get userPhotoUrl => _authService.getUserAvatarUrl();
  String? get photoUrl => userPhotoUrl;
  String get userId => currentUser.value?.uid ?? 'U-00000';

  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    unawaited(_initAuthListener());
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initAuthListener() async {
    final initialUser = _authService.currentUser;
    if (initialUser != null) {
      await _authService.preloadCurrentUserProfile();
      currentUser.value = initialUser;
      status.value = AuthStatus.authenticated;
    } else {
      status.value = AuthStatus.unauthenticated;
    }

    _authSubscription = _authService.authStateChanges.listen(
      (user) => unawaited(_applyAuthState(user)),
      onError: (error) {
        status.value = AuthStatus.error;
        errorMessage.value = 'Connection error: $error';
      },
    );
  }

  Future<void> _applyAuthState(User? user) async {
    currentUser.value = user;
    if (user != null) {
      await _authService.preloadCurrentUserProfile();
      status.value = AuthStatus.authenticated;
    } else {
      status.value = AuthStatus.unauthenticated;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  void _showError(String message) {
    errorMessage.value = message;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.context == null) return;
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    });
  }

  void _showSuccess(String message) {
    successMessage.value = message;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.context == null) return;
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final emailError = AuthValidators.validateEmailSimple(email);
    if (emailError != null) {
      _showError(emailError);
      return false;
    }

    final passwordError = AuthValidators.validatePasswordSimple(password);
    if (passwordError != null) {
      _showError(passwordError);
      return false;
    }

    if (name != null && name.isNotEmpty) {
      final nameError = AuthValidators.validateNameSimple(name);
      if (nameError != null) {
        _showError(nameError);
        return false;
      }
    }

    try {
      isLoading.value = true;
      status.value = AuthStatus.loading;
      clearMessages();

      final result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (!result.success) {
        _showError(result.message ?? 'Failed to create account');
        status.value = AuthStatus.error;
        return false;
      }

      if (result.requiresEmailVerification) {
        currentUser.value = null;
        status.value = AuthStatus.unauthenticated;
      }

      _showSuccess(result.message ?? 'Account created successfully.');
      return true;
    } catch (e) {
      _showError('Unexpected error: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    final emailError = AuthValidators.validateEmailSimple(email);
    if (emailError != null) {
      _showError(emailError);
      return false;
    }

    if (password.isEmpty) {
      _showError('Password is required');
      return false;
    }

    try {
      isLoading.value = true;
      status.value = AuthStatus.loading;
      clearMessages();

      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!result.success) {
        _showError(result.message ?? 'Failed to sign in');
        status.value = AuthStatus.error;
        return false;
      }

      _showSuccess(result.message ?? 'Logged in successfully.');
      return true;
    } catch (e) {
      _showError('Unexpected error: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      status.value = AuthStatus.loading;
      clearMessages();

      final result = await _authService.signInWithGoogle();
      if (result.success) {
        _showSuccess(result.message ?? 'Signed in with Google successfully.');
        return true;
      }

      if (result.errorCode != 'CANCELLED') {
        _showError(result.message ?? 'Failed to sign in with Google');
      }
      status.value = AuthStatus.unauthenticated;
      return false;
    } catch (e) {
      _showError('Error signing in with Google: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      isLoading.value = true;
      status.value = AuthStatus.loading;
      clearMessages();

      final result = await _authService.signInWithFacebook();
      if (result.success) {
        _showSuccess(result.message ?? 'Signed in with Facebook successfully.');
        return true;
      }

      if (result.errorCode != 'CANCELLED') {
        _showError(result.message ?? 'Failed to sign in with Facebook');
      }
      status.value = AuthStatus.unauthenticated;
      return false;
    } catch (e) {
      _showError('Error signing in with Facebook: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      clearMessages();

      final result = await _authService.signOut();
      if (result.success) {
        currentUser.value = null;
        status.value = AuthStatus.unauthenticated;
        _showSuccess('Signed out successfully');
      } else {
        _showError(result.message ?? 'Failed to sign out');
      }
    } catch (e) {
      _showError('Error signing out: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    final emailError = AuthValidators.validateEmailSimple(email);
    if (emailError != null) {
      _showError(emailError);
      return false;
    }

    try {
      isLoading.value = true;
      clearMessages();

      final result = await _authService.resetPassword(email);
      if (result.success) {
        _showSuccess(result.message ?? 'Password reset link sent');
        return true;
      }

      _showError(result.message ?? 'Failed to send reset link');
      return false;
    } catch (e) {
      _showError('Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    try {
      isLoading.value = true;
      clearMessages();

      final result = await _authService.updateUserProfile(
        name: name,
        avatarUrl: avatarUrl,
      );

      if (result.success) {
        _showSuccess('Profile updated successfully');
        return true;
      }

      _showError(result.message ?? 'Failed to update profile');
      return false;
    } catch (e) {
      _showError('Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void toggleOnline() {
    online.value = !online.value;
    unawaited(_authService.updateOnlineStatus(online.value));
  }

  void login() {
    status.value = AuthStatus.authenticated;
  }

  void logout() {
    unawaited(signOut());
  }

  void setCreatorStatus(bool value) {
    if (_isCreator.value == value) return;
    _isCreator.value = value;
  }

  void toggleCreatorStatus() {
    _isCreator.value = !_isCreator.value;
  }
}
