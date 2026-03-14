import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

const _firebaseProjectId = 'waiby-89732';
const _firebaseDatabaseUrl = 'https://waiby-89732-default-rtdb.firebaseio.com';
const _firebaseStorageBucket = 'waiby-89732.firebasestorage.app';
const _firebaseMessagingSenderId = '686865131708';

const _firebaseWebApiKey = 'AIzaSyB4NHP7bOIXh_QvS84JZRwtqBIde_A_WsI';
const _firebaseWebAppId = '1:686865131708:web:f121c754016723d44848b9';
const _firebaseWebAuthDomain = 'waiby-89732.firebaseapp.com';
const _firebaseWebMeasurementId = 'G-V195160D2X';

const _firebaseAndroidApiKey = 'AIzaSyA73uqaCR_yD_pzMP04FjAaJm1WCK4H89k';
const _firebaseAndroidAppId = '1:686865131708:android:14187e1eb86903614848b9';

const _firebaseIosApiKey = 'AIzaSyCY5jM4n-PUulpedBoMC7Q4qJlFAtq0mzk';
const _firebaseIosAppId = '1:686865131708:ios:8d23694559efd3754848b9';
const _firebaseIosClientId =
    '686865131708-d59q0kirn2ss47d38e4ofqk2m7sb3jd3.apps.googleusercontent.com';
const _firebaseIosBundleId = 'com.example.waiby';

const _firebaseWindowsAppId = '1:686865131708:web:467c8fa9638e4ea34848b9';
const _firebaseWindowsAuthDomain = 'waiby-89732.firebaseapp.com';
const _firebaseWindowsMeasurementId = 'G-0W636N58LV';

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
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: _firebaseWebApiKey,
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: _firebaseWebAppId,
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: _firebaseMessagingSenderId,
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: _firebaseProjectId,
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_WEB_AUTH_DOMAIN',
      defaultValue: _firebaseWebAuthDomain,
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: _firebaseDatabaseUrl,
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: _firebaseStorageBucket,
    ),
    measurementId: String.fromEnvironment(
      'FIREBASE_WEB_MEASUREMENT_ID',
      defaultValue: _firebaseWebMeasurementId,
    ),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: _firebaseAndroidApiKey,
    ),
    appId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: _firebaseAndroidAppId,
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: _firebaseMessagingSenderId,
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: _firebaseProjectId,
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: _firebaseDatabaseUrl,
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: _firebaseStorageBucket,
    ),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: _firebaseIosApiKey,
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: _firebaseIosAppId,
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: _firebaseMessagingSenderId,
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: _firebaseProjectId,
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: _firebaseDatabaseUrl,
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: _firebaseStorageBucket,
    ),
    iosClientId: String.fromEnvironment(
      'FIREBASE_IOS_CLIENT_ID',
      defaultValue: _firebaseIosClientId,
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: _firebaseIosBundleId,
    ),
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_MACOS_API_KEY',
      defaultValue: _firebaseIosApiKey,
    ),
    appId: String.fromEnvironment(
      'FIREBASE_MACOS_APP_ID',
      defaultValue: _firebaseIosAppId,
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: _firebaseMessagingSenderId,
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: _firebaseProjectId,
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: _firebaseDatabaseUrl,
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: _firebaseStorageBucket,
    ),
    iosClientId: String.fromEnvironment(
      'FIREBASE_MACOS_IOS_CLIENT_ID',
      defaultValue: _firebaseIosClientId,
    ),
    iosBundleId: String.fromEnvironment(
      'FIREBASE_MACOS_BUNDLE_ID',
      defaultValue: _firebaseIosBundleId,
    ),
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WINDOWS_API_KEY',
      defaultValue: _firebaseWebApiKey,
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WINDOWS_APP_ID',
      defaultValue: _firebaseWindowsAppId,
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: _firebaseMessagingSenderId,
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: _firebaseProjectId,
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_WINDOWS_AUTH_DOMAIN',
      defaultValue: _firebaseWindowsAuthDomain,
    ),
    databaseURL: String.fromEnvironment(
      'FIREBASE_DATABASE_URL',
      defaultValue: _firebaseDatabaseUrl,
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: _firebaseStorageBucket,
    ),
    measurementId: String.fromEnvironment(
      'FIREBASE_WINDOWS_MEASUREMENT_ID',
      defaultValue: _firebaseWindowsMeasurementId,
    ),
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
