import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void setupFirebaseMessagingListeners() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Check if the app is running on Android 13 or higher
  if (await FirebaseMessaging.instance.getInitialMessage() == null) {
    // For Android 13 and above, request notification permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission for notifications.");
    } else {
      print("User declined or has not accepted notification permission.");
    }
  }

  // Listen for messages while the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Received a message in the foreground!");
    print("Message data: ${message.data}");

    if (message.notification != null) {
      print(
          "Message notification: ${message.notification!.title}, ${message.notification!.body}");
    }
    // You can display a dialog, update the UI, or show a snackbar here
  });

  // Listen for messages when the app is opened directly from a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Opened the app from a notification!");
    // Handle navigation or other actions here
  });

  // Handle background messages (Android/iOS)
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
}

// Top-level background message handler
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  print("Handling a background message: ${message.messageId}");
  // Perform any necessary background tasks here
}
