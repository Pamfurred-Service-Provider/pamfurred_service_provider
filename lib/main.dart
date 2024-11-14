import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/Authentication/auth_redirect.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/firebase_options.dart';
import 'package:service_provider/firebase_services.dart/messaging_listener.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; // Add Firebase Core package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions
            .currentPlatform); // Assuming you have DefaultFirebaseOptions configured
    print("Firebase init was successful");
    setupFirebaseMessagingListeners();
    print("set up worked");
  } catch (e) {
    print("Firebase initialization failed: $e");
    // Optionally, handle the failure
    return; // Exit early if Firebase initialization fails
  }

  // Supabase initialization
  await Supabase.initialize(
    url: 'https://gfrbuvjfnlpfqkylbnxb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdmcmJ1dmpmbmxwZnFreWxibnhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgwMjM0NDgsImV4cCI6MjA0MzU5OTQ0OH0.JmDB012bA04pPoD64jqTTwZIPYowFl5jzIVql49bwx4',
  );

  runApp(const MyApp());
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
