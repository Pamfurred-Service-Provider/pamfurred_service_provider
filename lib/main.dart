import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/screens/main_screen.dart';
// import 'package:service_provider/screens/notification_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
