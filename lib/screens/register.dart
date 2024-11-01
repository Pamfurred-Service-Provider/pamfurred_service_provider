import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/screens/registration_confirmation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final supabase = Supabase.instance.client;
  // TextEditingControllers
  late Map<String, TextEditingController> controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'phoneNumber': TextEditingController(),
  };

  @override
  void dispose() {
    // Dispose controllers to free resources
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> registerUser() async {
    // Retrieve user input from controllers
    final firstName = controllers['firstName']?.text ?? '';
    final lastName = controllers['lastName']?.text ?? '';
    final email = controllers['email']?.text ?? '';
    final phoneNumber = controllers['phoneNumber']?.text ?? '';
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty) {
      _showErrorDialog("All fields are required.");
      return;
    }
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: 'password',
      );

      if (response.user != null) {
        print("User created with ID: ${response.user!.id}");

        final serviceProviderResponse =
            await supabase.from('service_provider').insert({
          'user_id': response.user!.id, // Link the new user ID
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'user_type': 'service_provider',
          'approval_status': 'pending',
        });
        if (serviceProviderResponse.error != null) {
          // Navigate to the RegistrationConfirmation screen on successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationConfirmation(),
            ),
          );
        } else {
          _showErrorDialog(serviceProviderResponse.error!.message);
        }
      } else {
        _showErrorDialog("User sign-up failed.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    }
  } // Function to show error dialog

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: secondarySizedBox),
              const Text(
                "Become one of our partners!",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: titleFont,
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: regularText),
                  children: [
                    TextSpan(
                      text:
                          "Unlock new growth opportunities and boost your business by partnering with us.\n\n",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: "Fields marked with (*) are required \n",
                      style: TextStyle(
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              RichText(
                text: const TextSpan(children: [
                  TextSpan(
                    text: "Business owner first name ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: regularText,
                    ),
                  ),
                  TextSpan(
                    text: "*",
                    style: TextStyle(color: primaryColor),
                  ),
                ]),
              ),
              const SizedBox(height: primarySizedBox),
              SizedBox(
                height: primaryTextFieldHeight,
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: controllers['firstName'],
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          secondaryBorderRadius,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: secondaryColor),
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius))),
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              RichText(
                text: const TextSpan(children: [
                  TextSpan(
                    text: "Business owner last name ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: regularText,
                    ),
                  ),
                  TextSpan(
                    text: "*",
                    style: TextStyle(color: primaryColor),
                  ),
                ]),
              ),
              const SizedBox(height: primarySizedBox),
              SizedBox(
                height: primaryTextFieldHeight,
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: controllers['lastName'],
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          secondaryBorderRadius,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: secondaryColor),
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius))),
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              RichText(
                text: const TextSpan(children: [
                  TextSpan(
                    text: "Business email ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: regularText,
                    ),
                  ),
                  TextSpan(
                    text: "*",
                    style: TextStyle(color: primaryColor),
                  ),
                ]),
              ),
              const SizedBox(height: primarySizedBox),
              SizedBox(
                height: primaryTextFieldHeight,
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: controllers['email'],
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          secondaryBorderRadius,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: secondaryColor),
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius))),
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              RichText(
                text: const TextSpan(children: [
                  TextSpan(
                    text: "Phone number ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: regularText,
                    ),
                  ),
                  TextSpan(
                    text: "*",
                    style: TextStyle(color: primaryColor),
                  ),
                ]),
              ),
              const SizedBox(height: primarySizedBox),
              SizedBox(
                  height: 65,
                  child: IntlPhoneField(
                    cursorColor: Colors.black,
                    initialCountryCode: 'PH',
                    onChanged: (phone) {
                      controllers['phoneNumber']!.text =
                          phone.completeNumber; // Store the complete number
                    },
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            secondaryBorderRadius,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: secondaryColor),
                            borderRadius:
                                BorderRadius.circular(secondaryBorderRadius))),
                  )),
              const SizedBox(height: secondarySizedBox),
              Center(
                child: customPaddedTextButton(
                  text: "Register",
                  onPressed: () async {
                    await registerUser();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}
