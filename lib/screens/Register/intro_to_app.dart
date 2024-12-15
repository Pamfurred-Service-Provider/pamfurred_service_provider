import 'package:flutter/material.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/screens/login.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/screens/register/personal_info.dart';

class StartYourJourneyScreen extends StatefulWidget {
  const StartYourJourneyScreen({super.key});

  @override
  StartYourJourneyScreenState createState() => StartYourJourneyScreenState();
}

class StartYourJourneyScreenState extends State<StartYourJourneyScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define the fade animation (fade in from 0 to 1)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Start fading in the image after initialization
    _fadeController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _fadeController.dispose(); // Clean up the fade controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Network with FadeTransition
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 200,
                  child: Image.network(
                    'https://cdn-icons-png.freepik.com/256/6244/6244983.png?semt=ais_hybrid', // Direct link to an image file
                    fit: BoxFit.cover, // Ensure the image is scaled properly
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description text
              const SizedBox(
                width: 315,
                child: Text(
                  'Join Pamfurred today and discover a new world of pampering for your furry friends! Register now to unlock exclusive benefits and stay ahead of the pack.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: regularText),
                ),
              ),
              const SizedBox(height: 30),

              // Register button
              SizedBox(
                width: 315,
                child: CustomWideButton(
                  text: "Register now",
                  onPressed: () {
                    Navigator.push(
                      context,
                      rightToLeftRoute(
                        PersonalInformationScreen(
                          controllers: {
                            'establishmentName': TextEditingController(),
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: quaternarySizedBox),
              // Login button
              SizedBox(width: 315, child: hasAnAccount(context))
            ],
          ),
        ),
      ),
    );
  }
}

Widget hasAnAccount(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, slideUpRoute(const LoginScreen(), reverse: true));
        },
        child: const Text(
          "I already have an account",
          style: TextStyle(
              fontSize: regularText,
              color: primaryColor,
              fontWeight: regularWeight),
        ),
      ),
    ],
  );
}

Widget formDescription(BuildContext context, String text) {
  return Text(
    text,
    textAlign: TextAlign.justify,
    style: const TextStyle(fontSize: smallText, color: Colors.black),
  );
}
