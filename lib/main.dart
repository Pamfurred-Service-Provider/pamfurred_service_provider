import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/Authentication/auth_redirect.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MainScreen(),
    );
  }
}
