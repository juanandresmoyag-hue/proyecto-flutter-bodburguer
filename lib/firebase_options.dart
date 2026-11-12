import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const _macosAppId = String.fromEnvironment('FIREBASE_MACOS_APP_ID');

  static bool get isConfigured {
    if (_apiKey.isEmpty || _projectId.isEmpty || _senderId.isEmpty) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidAppId.isNotEmpty,
      TargetPlatform.iOS => _iosAppId.isNotEmpty,
      TargetPlatform.macOS => _macosAppId.isNotEmpty,
      _ => kIsWeb && _webAppId.isNotEmpty,
    };
  }

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw UnsupportedError(
        'Configura los valores Firebase FIREBASE_* con --dart-define.',
      );
    }

    final appId = switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidAppId,
      TargetPlatform.iOS => _iosAppId,
      TargetPlatform.macOS => _macosAppId,
      _ => _webAppId,
    };

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: appId,
      messagingSenderId: _senderId,
      projectId: _projectId,
      authDomain: _authDomain.isEmpty
          ? '$_projectId.firebaseapp.com'
          : _authDomain,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
    );
  }
}
