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

class AuthRedirectState extends State<AuthRedirect>
    with WidgetsBindingObserver {
  late RealtimeService realtimeService;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    realtimeService = RealtimeService();
    _checkSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this); // Remove observer when disposing
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart listener on resume
      print("App resumed, restarting real-time listener...");
      realtimeService.listenToAppointments();
    }
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    // Add a delay for debugging if necessary
    await Future.delayed(const Duration(seconds: 2));

    if (session != null) {
      // If there is an active session, start listening to appointments
      final realtimeService = RealtimeService();
      realtimeService
          .listenToAppointments(); // Start listening to notifications
      print("LISTEN TO APPOINTMENTS LET'S GO!");

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
