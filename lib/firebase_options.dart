// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
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
    apiKey: 'AIzaSyBlwwXgo4YABSb0l79pA7EWMSdqGrimwEw',
    appId: '1:767101878945:web:7cf108ab98e7af2e81e6e0',
    messagingSenderId: '767101878945',
    projectId: 'home-security-6b106',
    authDomain: 'home-security-6b106.firebaseapp.com',
    storageBucket: 'home-security-6b106.firebasestorage.app',
    measurementId: 'G-0QHXS8R6RB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjBHqFMe_0Z3s5MnPu9Q2lYAHNXxWurro',
    appId: '1:767101878945:android:e194159bc69bbaae81e6e0',
    messagingSenderId: '767101878945',
    projectId: 'home-security-6b106',
    storageBucket: 'home-security-6b106.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6fLiblX-S39__C3pJj529I5Y2rMersoY',
    appId: '1:767101878945:ios:41e83922f8f8c52281e6e0',
    messagingSenderId: '767101878945',
    projectId: 'home-security-6b106',
    storageBucket: 'home-security-6b106.firebasestorage.app',
    iosClientId: '767101878945-c4sucjdi5huqe1ejmd2p89nbfkueo5sh.apps.googleusercontent.com',
    iosBundleId: 'com.example.homeSecurity',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA6fLiblX-S39__C3pJj529I5Y2rMersoY',
    appId: '1:767101878945:ios:41e83922f8f8c52281e6e0',
    messagingSenderId: '767101878945',
    projectId: 'home-security-6b106',
    storageBucket: 'home-security-6b106.firebasestorage.app',
    iosClientId: '767101878945-c4sucjdi5huqe1ejmd2p89nbfkueo5sh.apps.googleusercontent.com',
    iosBundleId: 'com.example.homeSecurity',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBlwwXgo4YABSb0l79pA7EWMSdqGrimwEw',
    appId: '1:767101878945:web:7cf108ab98e7af2e81e6e0',
    messagingSenderId: '767101878945',
    projectId: 'home-security-6b106',
    authDomain: 'home-security-6b106.firebaseapp.com',
    storageBucket: 'home-security-6b106.firebasestorage.app',
    measurementId: 'G-0QHXS8R6RB',
  );

}