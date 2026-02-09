/// ثوابت التطبيق والإعدادات
/// Application constants and configuration

class AppConfig {
  // منع إنشاء نسخة من هذا الصنف
  AppConfig._();

  // ========== Supabase Configuration ==========
  /// رابط مشروع Supabase
  static const String supabaseUrl = 'https://oszuukbnfgcnzmjlzvox.supabase.co';

  /// مفتاح Supabase العام (Anon Key)
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9zenV1a2JuZmdjbnptamx6dm94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1NDA5OTcsImV4cCI6MjA4NjExNjk5N30.CYcH4Wt_nqTv44I2UupWTHJdmyid_bic51t4l675K8A';

  // ========== OAuth Configuration ==========
  /// Redirect URL للتطبيق (يستخدم في Social Auth)
  /// يجب تسجيل هذا الرابط في إعدادات Supabase وكل من Google/Facebook
  static const String redirectUrl = 'io.supabase.waiby://login-callback/';

  /// Redirect URL لإعادة تعيين كلمة المرور
  static const String resetPasswordRedirectUrl =
      'io.supabase.waiby://reset-password/';

  // ========== Google OAuth Configuration ==========
  /// يجب الحصول على هذه القيم من Google Cloud Console
  /// 1. اذهب إلى https://console.cloud.google.com/
  /// 2. أنشئ مشروعًا جديدًا أو استخدم مشروعًا موجودًا
  /// 3. اذهب إلى APIs & Services > Credentials
  /// 4. أنشئ OAuth 2.0 Client IDs لكل منصة (Web, Android, iOS)
  /// 5. أضف Redirect URIs المطلوبة

  /// Web Client ID (للويب)
  static const String googleWebClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  /// Android Client ID
  static const String googleAndroidClientId =
      'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';

  /// iOS Client ID
  static const String googleIosClientId =
      'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

  /// Server Client ID (يستخدم لـ ID Token)
  static const String googleServerClientId =
      'YOUR_SERVER_CLIENT_ID.apps.googleusercontent.com';

  // ========== Facebook OAuth Configuration ==========
  /// يجب الحصول على هذه القيم من Facebook Developer Console
  /// 1. اذهب إلى https://developers.facebook.com/
  /// 2. أنشئ تطبيقًا جديدًا
  /// 3. اذهب إلى Settings > Basic للحصول على App ID و App Secret
  /// 4. أضف Platform configurations لكل منصة

  /// Facebook App ID
  static const String facebookAppId = 'YOUR_FACEBOOK_APP_ID';

  // ========== App Info ==========
  static const String appName = 'Waiby';
  static const String appVersion = '1.0.0';
}

/// إعدادات المصادقة
class AuthConfig {
  AuthConfig._();

  /// الحد الأدنى لطول كلمة المرور
  static const int minPasswordLength = 6;

  /// الحد الأقصى لطول كلمة المرور
  static const int maxPasswordLength = 128;

  /// الحد الأدنى لطول الاسم
  static const int minNameLength = 2;

  /// الحد الأقصى لطول الاسم
  static const int maxNameLength = 50;

  /// مدة صلاحية الجلسة (بالثواني)
  static const int sessionTimeout = 3600 * 24 * 7; // 7 أيام

  /// هل يجب تأكيد البريد الإلكتروني للتسجيل
  static const bool requireEmailConfirmation = true;
}
