import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../core/validators/auth_validators.dart';

/// حالات المصادقة
/// Authentication states enum
enum AuthStatus {
  initial, // الحالة الأولية
  loading, // جاري التحميل
  authenticated, // تم المصادقة
  unauthenticated, // غير مصادق
  error, // حدث خطأ
}

/// وحدة تحكم المصادقة باستخدام GetX
/// Authentication controller using GetX for state management
class AuthController extends GetxController {
  // ========== Dependencies ==========
  final AuthService _authService = AuthService();

  // ========== Observable States ==========
  /// حالة المصادقة الحالية
  final Rx<AuthStatus> status = AuthStatus.initial.obs;

  /// المستخدم الحالي
  final Rxn<User> currentUser = Rxn<User>();

  /// رسالة الخطأ
  final RxString errorMessage = ''.obs;

  /// رسالة النجاح
  final RxString successMessage = ''.obs;

  /// حالة التحميل
  final RxBool isLoading = false.obs;

  /// حالة تذكرني
  final RxBool rememberMe = false.obs;

  /// حالة الاتصال (للتوافق مع الكود القديم)
  final RxBool online = true.obs;

  // ========== Getters ==========
  /// هل المستخدم مسجل الدخول
  bool get isLoggedIn => currentUser.value != null;

  /// للتوافق مع الكود القديم - loggedIn getter
  bool get loggedIn => isLoggedIn;

  /// اسم المستخدم
  String get userName => _authService.getUserDisplayName() ?? 'User';

  /// للتوافق مع الكود القديم - name getter
  String get name => userName;

  /// البريد الإلكتروني للمستخدم
  String? get userEmail => currentUser.value?.email;

  /// صورة المستخدم
  String? get userPhotoUrl => _authService.getUserAvatarUrl();

  /// للتوافق مع الكود القديم - photoUrl getter
  String? get photoUrl => userPhotoUrl;

  /// معرف المستخدم
  String get userId => currentUser.value?.id ?? 'U-00000';

  // ========== Subscriptions ==========
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initAuthListener();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  /// تهيئة مستمع حالة المصادقة
  /// Initialize auth state listener
  void _initAuthListener() {
    // التحقق من الحالة الأولية
    final initialUser = _authService.currentUser;
    if (initialUser != null) {
      currentUser.value = initialUser;
      status.value = AuthStatus.authenticated;
    } else {
      status.value = AuthStatus.unauthenticated;
    }

    // الاستماع لتغييرات المصادقة
    _authSubscription = _authService.authStateChanges.listen(
      (AuthState authState) {
        final user = authState.session?.user;
        currentUser.value = user;

        if (user != null) {
          status.value = AuthStatus.authenticated;
        } else {
          status.value = AuthStatus.unauthenticated;
        }
      },
      onError: (error) {
        status.value = AuthStatus.error;
        errorMessage.value = 'خطأ في الاتصال: $error';
      },
    );
  }

  /// مسح الرسائل
  /// Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// عرض رسالة خطأ
  /// Show error snackbar
  void _showError(String message) {
    errorMessage.value = message;
    // تأخير بسيط لضمان وجود Overlay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.context != null) {
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
      }
    });
  }

  /// عرض رسالة نجاح
  /// Show success snackbar
  void _showSuccess(String message) {
    successMessage.value = message;
    // تأخير بسيط لضمان وجود Overlay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.context != null) {
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
      }
    });
  }

  // ========== Authentication Methods ==========

  /// تسجيل مستخدم جديد
  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    // التحقق من صحة البيانات
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

      if (result.success) {
        _showSuccess(result.message ?? 'Account created successfully!');
        return true;
      } else {
        _showError(result.message ?? 'Failed to create account');
        status.value = AuthStatus.error;
        return false;
      }
    } catch (e) {
      _showError('Unexpected error: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني
  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    // التحقق من صحة البيانات
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

      if (result.success) {
        _showSuccess(result.message ?? 'Logged in successfully!');
        return true;
      } else {
        _showError(result.message ?? 'Failed to sign in');
        status.value = AuthStatus.error;
        return false;
      }
    } catch (e) {
      _showError('Unexpected error: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الدخول عبر Google
  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      status.value = AuthStatus.loading;
      clearMessages();

      final result = await _authService.signInWithGoogle();

      if (result.success) {
        _showSuccess(result.message ?? 'Signed in with Google successfully!');
        return true;
      } else {
        // لا تظهر خطأ إذا تم الإلغاء
        if (result.errorCode != 'CANCELLED') {
          _showError(result.message ?? 'Failed to sign in with Google');
        }
        status.value = AuthStatus.unauthenticated;
        return false;
      }
    } catch (e) {
      _showError('Error signing in with Google: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الدخول عبر Facebook
  /// Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      isLoading.value = true;
      status.value = AuthStatus.loading;
      clearMessages();

      final result = await _authService.signInWithFacebook();

      if (result.success) {
        _showSuccess(result.message ?? 'Signed in with Facebook successfully!');
        return true;
      } else {
        // لا تظهر خطأ إذا تم الإلغاء
        if (result.errorCode != 'CANCELLED') {
          _showError(result.message ?? 'Failed to sign in with Facebook');
        }
        status.value = AuthStatus.unauthenticated;
        return false;
      }
    } catch (e) {
      _showError('Error signing in with Facebook: $e');
      status.value = AuthStatus.error;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل الخروج
  /// Sign out
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

  /// إعادة تعيين كلمة المرور
  /// Reset password
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
      } else {
        _showError(result.message ?? 'Failed to send reset link');
        return false;
      }
    } catch (e) {
      _showError('Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث بيانات المستخدم
  /// Update user profile
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
      } else {
        _showError(result.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _showError('Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تبديل حالة تذكرني
  /// Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// تبديل حالة الاتصال (للتوافق مع الكود القديم)
  /// Toggle online status (for backward compatibility)
  void toggleOnline() {
    online.value = !online.value;
  }

  // =========== Backward Compatibility Methods ===========

  /// للتوافق مع الكود القديم - login method
  void login() {
    // هذه الطريقة للتوافق مع الكود القديم فقط
    // يجب استخدام signIn بدلاً منها
    status.value = AuthStatus.authenticated;
  }

  /// للتوافق مع الكود القديم - logout method
  void logout() {
    signOut();
  }
}
