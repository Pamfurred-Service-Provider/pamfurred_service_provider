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
    apiKey: 'AIzaSyAW24ue_QZAWOzasb9cE11kxXZk4gRgwwU',
    appId: '1:180918308528:web:a35656d9649ca55d267575',
    messagingSenderId: '180918308528',
    projectId: 'pamfurred-25368',
    authDomain: 'pamfurred-25368.firebaseapp.com',
    storageBucket: 'pamfurred-25368.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7YRldoNJuOzKM4wg1q4CWbyR7-3e2ZXg',
    appId: '1:180918308528:android:2f4f7a62b11ec452267575',
    messagingSenderId: '180918308528',
    projectId: 'pamfurred-25368',
    storageBucket: 'pamfurred-25368.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDASpGNGI7jKZxdTYSoCG-NWoAbR98DhVQ',
    appId: '1:180918308528:ios:7d353b7d75fa10b0267575',
    messagingSenderId: '180918308528',
    projectId: 'pamfurred-25368',
    storageBucket: 'pamfurred-25368.firebasestorage.app',
    iosBundleId: 'com.example.serviceProvider',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDASpGNGI7jKZxdTYSoCG-NWoAbR98DhVQ',
    appId: '1:180918308528:ios:7d353b7d75fa10b0267575',
    messagingSenderId: '180918308528',
    projectId: 'pamfurred-25368',
    storageBucket: 'pamfurred-25368.firebasestorage.app',
    iosBundleId: 'com.example.serviceProvider',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAW24ue_QZAWOzasb9cE11kxXZk4gRgwwU',
    appId: '1:180918308528:web:c15c4dd0c7988bf7267575',
    messagingSenderId: '180918308528',
    projectId: 'pamfurred-25368',
    authDomain: 'pamfurred-25368.firebaseapp.com',
    storageBucket: 'pamfurred-25368.firebasestorage.app',
  );
}