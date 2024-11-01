import 'package:flutter/material.dart'; // For Flutter UI components like Scaffold, Navigator, MaterialPageRoute, etc.
import 'package:service_provider/screens/login.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:service_provider/screens/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For using Supabase in Flutter

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
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    print('Session: $session'); // Log the session to the terminal

    await Future.delayed(const Duration(seconds: 2)); // Add delay for debugging
    if (session != null) {
      final userId = session.user.id;
      try {
        final response = await Supabase.instance.client
            .from('service_provider')
            .select()
            .eq('sp_id', userId)
            .single();
        if (response.error != null || response.data == null) {
          // User is logged in, navigate to Home Screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          });
        } else {
          // User is not logged in, navigate to Login Screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          });
        }
      } catch (error) {
        print("Error checking service_provider table: $error");
        _showErrorDialog("An error occurred. Please try again.");
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:
          Center(child: CircularProgressIndicator()), // While checking session
    );
  }
}
