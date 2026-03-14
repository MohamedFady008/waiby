import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      _assertRequired(const {
        'FIREBASE_WEB_API_KEY': String.fromEnvironment('FIREBASE_WEB_API_KEY'),
        'FIREBASE_WEB_APP_ID': String.fromEnvironment('FIREBASE_WEB_APP_ID'),
        'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
        'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
        ),
      });
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _assertRequired(const {
          'FIREBASE_ANDROID_API_KEY': String.fromEnvironment(
            'FIREBASE_ANDROID_API_KEY',
          ),
          'FIREBASE_ANDROID_APP_ID': String.fromEnvironment(
            'FIREBASE_ANDROID_APP_ID',
          ),
          'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
          'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
            'FIREBASE_MESSAGING_SENDER_ID',
          ),
        });
        return android;
      case TargetPlatform.iOS:
        _assertRequired(const {
          'FIREBASE_IOS_API_KEY': String.fromEnvironment(
            'FIREBASE_IOS_API_KEY',
          ),
          'FIREBASE_IOS_APP_ID': String.fromEnvironment('FIREBASE_IOS_APP_ID'),
          'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
          'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
            'FIREBASE_MESSAGING_SENDER_ID',
          ),
        });
        return ios;
      case TargetPlatform.macOS:
        _assertRequired(const {
          'FIREBASE_MACOS_API_KEY': String.fromEnvironment(
            'FIREBASE_MACOS_API_KEY',
          ),
          'FIREBASE_MACOS_APP_ID': String.fromEnvironment(
            'FIREBASE_MACOS_APP_ID',
          ),
          'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
          'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
            'FIREBASE_MESSAGING_SENDER_ID',
          ),
        });
        return macos;
      case TargetPlatform.windows:
        _assertRequired(const {
          'FIREBASE_WINDOWS_API_KEY': String.fromEnvironment(
            'FIREBASE_WINDOWS_API_KEY',
          ),
          'FIREBASE_WINDOWS_APP_ID': String.fromEnvironment(
            'FIREBASE_WINDOWS_APP_ID',
          ),
          'FIREBASE_PROJECT_ID': String.fromEnvironment('FIREBASE_PROJECT_ID'),
          'FIREBASE_MESSAGING_SENDER_ID': String.fromEnvironment(
            'FIREBASE_MESSAGING_SENDER_ID',
          ),
        });
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    iosClientId: String.fromEnvironment('FIREBASE_IOS_CLIENT_ID'),
    iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_MACOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    iosClientId: String.fromEnvironment('FIREBASE_MACOS_IOS_CLIENT_ID'),
    iosBundleId: String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID'),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WINDOWS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('FIREBASE_WINDOWS_AUTH_DOMAIN'),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
    measurementId: String.fromEnvironment('FIREBASE_WINDOWS_MEASUREMENT_ID'),
  );

  static void _assertRequired(Map<String, String> requiredDefines) {
    final missingKeys = requiredDefines.entries
        .where((entry) => entry.value.trim().isEmpty)
        .map((entry) => entry.key)
        .toList();

    if (missingKeys.isEmpty) {
      return;
    }

    throw UnsupportedError(
      'Missing Firebase dart-defines: ${missingKeys.join(', ')}. '
      'Copy .env.firebase.example.json to .env.firebase.json and run with '
      '--dart-define-from-file=.env.firebase.json.',
    );
  }
}
