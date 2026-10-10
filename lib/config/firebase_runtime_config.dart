import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

/// Non-secret Firebase app identifiers are supplied at build/run time.
/// Do not put service-account private keys or Apple .p8 keys in this app.
class FirebaseRuntimeConfig {
  FirebaseRuntimeConfig._();

  static const projectId = String.fromEnvironment('FITA_FIREBASE_PROJECT_ID');
  static const messagingSenderId =
      String.fromEnvironment('FITA_FIREBASE_MESSAGING_SENDER_ID');

  static const androidApiKey =
      String.fromEnvironment('FITA_FIREBASE_ANDROID_API_KEY');
  static const androidAppId =
      String.fromEnvironment('FITA_FIREBASE_ANDROID_APP_ID');

  static const iosApiKey = String.fromEnvironment('FITA_FIREBASE_IOS_API_KEY');
  static const iosAppId = String.fromEnvironment('FITA_FIREBASE_IOS_APP_ID');
  static const iosBundleId = String.fromEnvironment('FITA_IOS_BUNDLE_ID');

  static bool get isConfigured {
    final common = projectId.isNotEmpty && messagingSenderId.isNotEmpty;
    if (Platform.isAndroid) {
      return common && androidApiKey.isNotEmpty && androidAppId.isNotEmpty;
    }
    if (Platform.isIOS) {
      return common &&
          iosApiKey.isNotEmpty &&
          iosAppId.isNotEmpty &&
          iosBundleId.isNotEmpty;
    }
    return false;
  }

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError(
        'Firebase runtime values are missing. See FIREBASE_SETUP.md and '
        'provide the FITA_FIREBASE_* dart-defines.',
      );
    }

    if (Platform.isAndroid) {
      return FirebaseOptions(
        apiKey: androidApiKey,
        appId: androidAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      );
    }

    if (Platform.isIOS) {
      return FirebaseOptions(
        apiKey: iosApiKey,
        appId: iosAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        iosBundleId: iosBundleId,
      );
    }

    throw UnsupportedError('FITA Mahjong supports Android and iOS only.');
  }
}
