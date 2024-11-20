import 'package:flutter/material.dart';
import 'package:service_provider/Supabase/realtime_service.dart';
import 'package:service_provider/screens/login.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRedirect extends StatefulWidget {
  const AuthRedirect({super.key});

  @override
  AuthRedirectState createState() => AuthRedirectState();
}

class AuthRedirectState extends State<AuthRedirect> {
  @override
  void initState() {
    super.initState();
    _checkSession();
    initializeAndListenToAppointments();
  }

  void initializeAndListenToAppointments() async {
    final realtimeService = RealtimeService();

    // Load processed appointment IDs
    await realtimeService.loadProcessedAppointmentIds();

    // Start listening to appointments
    realtimeService.listenToAppointments();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    // Add a delay for debugging if necessary
    await Future.delayed(const Duration(seconds: 2));

    if (session != null) {
      // If there is an active session, navigate to MainScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      });
    } else {
      // If there is no session, navigate to LoginScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Show loading indicator while checking session
      ),
    );
  }
}
