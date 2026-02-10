import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// نتيجة عملية المصادقة
/// Result class for authentication operations
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? errorCode;

  AuthResult({required this.success, this.message, this.user, this.errorCode});

  factory AuthResult.success({User? user, String? message}) {
    return AuthResult(
      success: true,
      user: user,
      message: message ?? 'تمت العملية بنجاح',
    );
  }

  factory AuthResult.failure({required String message, String? errorCode}) {
    return AuthResult(success: false, message: message, errorCode: errorCode);
  }
}

/// خدمة المصادقة المتكاملة مع Supabase
/// Comprehensive authentication service using Supabase
class AuthService {
  // الحصول على نسخة Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  // إعداد Google Sign-In مع Web Client ID الخاص بـ Supabase
  // يجب استبدال هذا بالـ Client ID الخاص بمشروعك
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      // Web Client ID من Google Cloud Console
      // يجب الحصول عليه من إعدادات OAuth في Supabase Dashboard
      clientId: kIsWeb
          ? '782633293030-ei377tcui7t15nmcvivpnvss9r65f655.apps.googleusercontent.com'
          : null,
      // serverClientId غير مدعوم على الويب
      serverClientId: kIsWeb
          ? null
          : '782633293030-ei377tcui7t15nmcvivpnvss9r65f655.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    );
  }

  // الحصول على المستخدم الحالي
  User? get currentUser => _supabase.auth.currentUser;

  // الاستماع لتغييرات حالة المصادقة
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // التحقق من حالة تسجيل الدخول
  bool get isLoggedIn => currentUser != null;

  /// تسجيل مستخدم جديد بالبريد الإلكتروني وكلمة المرور
  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: name != null ? {'full_name': name.trim()} : null,
      );

      if (response.user != null) {
        // تحقق إذا كان المستخدم بحاجة لتأكيد البريد الإلكتروني
        if (response.user!.emailConfirmedAt == null) {
          return AuthResult.success(
            user: response.user,
            message:
                'تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني لتأكيد الحساب.',
          );
        }
        return AuthResult.success(
          user: response.user,
          message: 'تم إنشاء الحساب وتسجيل الدخول بنجاح!',
        );
      }

      return AuthResult.failure(
        message: 'فشل في إنشاء الحساب. يرجى المحاولة مرة أخرى.',
      );
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(
          user: response.user,
          message: 'تم تسجيل الدخول بنجاح!',
        );
      }

      return AuthResult.failure(
        message: 'فشل في تسجيل الدخول. يرجى التحقق من بياناتك.',
      );
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// تسجيل الدخول عبر حساب Google
  /// Sign in with Google account
  Future<AuthResult> signInWithGoogle() async {
    try {
      // على الويب، نستخدم Supabase OAuth بدلاً من google_sign_in
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:${Uri.base.port}/',
        );
        // سيتم التعامل مع الرد عبر authStateChanges
        return AuthResult.success(
          message: 'جارٍ التوجيه لتسجيل الدخول عبر Google...',
        );
      }

      // على الموبايل، نستخدم google_sign_in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure(
          message: 'تم إلغاء تسجيل الدخول عبر Google',
          errorCode: 'CANCELLED',
        );
      }

      // الحصول على بيانات المصادقة
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        return AuthResult.failure(
          message: 'فشل في الحصول على رمز المصادقة من Google',
        );
      }

      // تسجيل الدخول في Supabase باستخدام رمز Google
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        return AuthResult.success(
          user: response.user,
          message: 'تم تسجيل الدخول عبر Google بنجاح!',
        );
      }

      return AuthResult.failure(message: 'فشل في تسجيل الدخول عبر Google');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(
        message: 'حدث خطأ أثناء تسجيل الدخول عبر Google: ${e.toString()}',
      );
    }
  }

  /// تسجيل الدخول عبر حساب Facebook
  /// Sign in with Facebook account
  Future<AuthResult> signInWithFacebook() async {
    try {
      // على الويب، نستخدم Supabase OAuth بدلاً من flutter_facebook_auth
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.facebook,
          redirectTo: 'http://localhost:${Uri.base.port}/',
        );
        // سيتم التعامل مع الرد عبر authStateChanges
        return AuthResult.success(
          message: 'جارٍ التوجيه لتسجيل الدخول عبر Facebook...',
        );
      }

      // على الموبايل، نستخدم flutter_facebook_auth
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      switch (result.status) {
        case LoginStatus.success:
          final AccessToken accessToken = result.accessToken!;

          // تسجيل الدخول في Supabase باستخدام رمز Facebook
          final AuthResponse response = await _supabase.auth.signInWithIdToken(
            provider: OAuthProvider.facebook,
            idToken: accessToken.tokenString,
          );

          if (response.user != null) {
            return AuthResult.success(
              user: response.user,
              message: 'تم تسجيل الدخول عبر Facebook بنجاح!',
            );
          }

          return AuthResult.failure(
            message: 'فشل في تسجيل الدخول عبر Facebook',
          );

        case LoginStatus.cancelled:
          return AuthResult.failure(
            message: 'تم إلغاء تسجيل الدخول عبر Facebook',
            errorCode: 'CANCELLED',
          );

        case LoginStatus.failed:
          return AuthResult.failure(
            message: result.message ?? 'فشل في تسجيل الدخول عبر Facebook',
          );

        case LoginStatus.operationInProgress:
          return AuthResult.failure(
            message: 'عملية تسجيل الدخول قيد التنفيذ بالفعل',
          );
      }
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(
        message: 'حدث خطأ أثناء تسجيل الدخول عبر Facebook: ${e.toString()}',
      );
    }
  }

  /// تسجيل الخروج
  /// Sign out from all providers
  Future<AuthResult> signOut() async {
    try {
      // تسجيل الخروج من Google إذا كان مسجل الدخول
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // تسجيل الخروج من Facebook
      await FacebookAuth.instance.logOut();

      // تسجيل الخروج من Supabase
      await _supabase.auth.signOut();

      return AuthResult.success(message: 'تم تسجيل الخروج بنجاح');
    } catch (e) {
      return AuthResult.failure(
        message: 'حدث خطأ أثناء تسجيل الخروج: ${e.toString()}',
      );
    }
  }

  /// إعادة تعيين كلمة المرور
  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.waiby://reset-password/',
      );

      return AuthResult.success(
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'حدث خطأ: ${e.toString()}');
    }
  }

  /// تحديث كلمة المرور
  /// Update user password
  Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      return AuthResult.success(message: 'تم تحديث كلمة المرور بنجاح');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'حدث خطأ: ${e.toString()}');
    }
  }

  /// تحديث بيانات المستخدم
  /// Update user profile data
  Future<AuthResult> updateUserProfile({
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (name != null) data['full_name'] = name;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (additionalData != null) data.addAll(additionalData);

      await _supabase.auth.updateUser(UserAttributes(data: data));

      return AuthResult.success(
        user: currentUser,
        message: 'تم تحديث البيانات بنجاح',
      );
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'حدث خطأ: ${e.toString()}');
    }
  }

  /// إعادة إرسال رسالة التأكيد
  /// Resend confirmation email
  Future<AuthResult> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email.trim());

      return AuthResult.success(message: 'تم إرسال رسالة التأكيد مرة أخرى');
    } on AuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return AuthResult.failure(message: 'حدث خطأ: ${e.toString()}');
    }
  }

  /// معالجة أخطاء المصادقة
  /// Handle authentication exceptions with user-friendly messages
  AuthResult _handleAuthException(AuthException e) {
    String message;
    String errorCode = e.statusCode ?? 'UNKNOWN';

    // ترجمة رسائل الخطأ الشائعة
    switch (e.message.toLowerCase()) {
      case 'invalid login credentials':
        message =
            'بيانات الدخول غير صحيحة. تحقق من البريد الإلكتروني وكلمة المرور.';
        break;
      case 'user already registered':
        message = 'هذا البريد الإلكتروني مسجل مسبقاً. يرجى تسجيل الدخول.';
        break;
      case 'email not confirmed':
        message = 'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.';
        break;
      case 'invalid email':
        message = 'البريد الإلكتروني غير صالح.';
        break;
      case 'weak password':
        message = 'كلمة المرور ضعيفة جداً. استخدم كلمة مرور أقوى.';
        break;
      case 'too many requests':
        message = 'محاولات كثيرة جداً. يرجى الانتظار قليلاً.';
        break;
      case 'user not found':
        message = 'لا يوجد حساب بهذا البريد الإلكتروني.';
        break;
      default:
        message = e.message;
    }

    return AuthResult.failure(message: message, errorCode: errorCode);
  }

  /// الحصول على بيانات المستخدم الإضافية
  /// Get user metadata
  Map<String, dynamic>? getUserMetadata() {
    return currentUser?.userMetadata;
  }

  /// الحصول على اسم المستخدم
  /// Get user display name
  String? getUserDisplayName() {
    final metadata = getUserMetadata();
    return metadata?['full_name'] ??
        metadata?['name'] ??
        currentUser?.email?.split('@').first;
  }

  /// الحصول على صورة المستخدم
  /// Get user avatar URL
  String? getUserAvatarUrl() {
    final metadata = getUserMetadata();
    return metadata?['avatar_url'] ?? metadata?['picture'];
  }
}
