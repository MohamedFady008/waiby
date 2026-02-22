/// Application constants and runtime configuration.
library;

class AppConfig {
  AppConfig._();

  static const String appName = 'Waiby';
  static const String appVersion = '1.0.0';

  /// OAuth and provider ids are intentionally sourced from dart-define.
  /// Example:
  /// --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const String facebookAppId = String.fromEnvironment('FACEBOOK_APP_ID');

  /// Continue URL used by Firebase reset-password emails (web/mobile deep link).
  static const String resetPasswordContinueUrl = String.fromEnvironment(
    'FIREBASE_RESET_PASSWORD_CONTINUE_URL',
    defaultValue: '',
  );
}

class AuthConfig {
  AuthConfig._();

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int sessionTimeout = 3600 * 24 * 7; // 7 days

  /// To preserve previous behavior, email verification remains required.
  static const bool requireEmailConfirmation = true;
}
