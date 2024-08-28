import 'package:flutter/material.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/screens/login.dart';
import '../components/globals.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/pamfurred_logo.png',
                width: 325,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: tertiarySizedBox),
              Image.asset(
                'assets/check.png',
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: tertiarySizedBox),
              const Text(
                'Thank you for joining us!',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Your registration has been submitted to the admin.\n Please wait for the admin to contact you shortly.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: regularText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: tertiarySizedBox),
              Center(
                child: SizedBox(
                  width: 150,
                  height: primaryTextFieldHeight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        crossFadeRoute(const LoginScreen()),
                      );
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        primaryColor,
                      ),
                    ),
                    child: const Text(
                      "Got it!",
                      style:
                          TextStyle(color: Colors.white, fontSize: regularText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
