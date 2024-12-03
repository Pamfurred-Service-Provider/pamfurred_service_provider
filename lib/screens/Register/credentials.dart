import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/header.dart';
import 'package:service_provider/components/password_textfield.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/components/text_field.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/providers/register_provider.dart';
import 'package:service_provider/screens/Register/intro_to_app.dart';
import 'package:service_provider/screens/Register/registration_camera.dart';
import 'package:service_provider/components/custom_appbar.dart';

class CredentialsScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const CredentialsScreen({super.key, required this.controllers});

  @override
  CredentialsScreenState createState() => CredentialsScreenState();
}

class CredentialsScreenState extends ConsumerState<CredentialsScreen> {
  bool isLoading = false;
  String? _errorMessage; // Declare the error message here

  bool _validateFields() {
    final email = widget.controllers['email']?.text.trim() ?? '';
    final password = widget.controllers['password']?.text ?? '';
    ref.read(emailProvider.notifier).state = email;
    ref.read(passwordProvider.notifier).state = password;

    if (email.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email) ||
        password.length < 6) {
      setState(() {
        _errorMessage =
            "Invalid input: Ensure all fields are filled and password must be secure.";
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionHeader("Credentials"),
              const SizedBox(height: secondaryBorderRadius),
              formDescription(context,
                  "Enter your email address and choose a password to create an account. This will allow you to log in securely."),
              const SizedBox(height: tertiarySizedBox),
              CustomTextField(
                  label: "Email address",
                  controllerKey: "email",
                  controllers: widget.controllers,
                  isEmail: true),
              const SizedBox(height: secondarySizedBox),
              PasswordTextField(
                label: "Password",
                controllerKey: "password",
                controllers: widget.controllers,
              ),
              const SizedBox(height: secondarySizedBox),
              if (_errorMessage != null) ...[
                Wrap(
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: secondarySizedBox),
              ],
              CustomWideButton(
                text: "Next",
                onPressed: () {
                  if (_validateFields()) {
                    setState(() => _errorMessage =
                        null); // Clear error message if validation passes
                    Navigator.push(
                      context,
                      rightToLeftRoute(
                        RegistrationCameraScreen(
                          onImageUploaded: (imageUrl) {
                            // Handle the image URL once uploaded
                            print("Image uploaded: $imageUrl");
                          },
                          controllers: {},
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: quaternarySizedBox),
              // Assuming hasAnAccount is a widget that displays account information
              hasAnAccount(context),
            ],
          ),
        ),
      ),
    );
  }
}
