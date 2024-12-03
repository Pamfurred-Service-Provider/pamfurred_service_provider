import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/Authentication/auth_redirect.dart';
import 'package:service_provider/Supabase/realtime_service.dart';
import 'package:service_provider/components/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('pamfurred');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap here
      print('Notification tapped with payload: ${response.payload}');
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization
  await Supabase.initialize(
    url: 'https://gfrbuvjfnlpfqkylbnxb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmcmJ1dmpmbmxwZnFreWxibnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgwMjM0NDgsImV4cCI6MjA0MzU5OTQ0OH0.JmDB012bA04pPoD64jqTTwZIPYowFl5jzIVql49bwx4',
  );
  await initializeNotifications(); // Initialize local notifications

  final realtimeService = RealtimeService();

  // Start listening to appointments
  realtimeService.listenToAppointments();

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pamfurred',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme:
            Theme.of(context).colorScheme.copyWith(primary: primaryColor),
      ),
      home: const AuthRedirect(),
    );
  }
}
