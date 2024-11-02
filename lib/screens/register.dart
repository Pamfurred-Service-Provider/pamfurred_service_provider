import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
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
    'establishmentName': TextEditingController(),
    'email': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'password': TextEditingController(),
  };

  @override
  void dispose() {
    // Dispose controllers to free resources
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  final bool _obscureText = true;
  bool _isLoading = false;

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    // Retrieve user input from controllers
    final firstName = controllers['firstName']?.text ?? '';
    final lastName = controllers['lastName']?.text ?? '';
    final establishmentName = controllers['establishmentName']?.text ?? '';
    final email = controllers['email']?.text ?? '';
    final phoneNumber = controllers['phoneNumber']?.text ?? '';
    final password = controllers['password']?.text ?? ''; // Retrieve password

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        establishmentName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phoneNumber.isEmpty) {
      _showErrorDialog("All fields are required.");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone_number': phoneNumber,
        },
      );

      if (response.user != null) {
        final userId = response.user!.id;
// Insert into 'user' table
        final userInsertResponse = await supabase.from('user').insert({
          'user_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'user_type': 'service_provider',
          'password': password,
        }).select();

        // final serviceProviderResponse = await supabase.from('user').insert({
        //   'user_id': userId,
        //   'first_name': firstName,
        //   'last_name': lastName,
        //   'phone_number': phoneNumber,
        //   'user_type': 'service_provider',
        //   'password': password,
        // }).select();

        // // Now, insert into the `service_provider` table with the existing `user_id`
        // if (serviceProviderResponse.error == null) {
        //   await supabase
        //       .from('service_provider')
        //       .insert({'name': establishmentName, 'user_id': userId}).select();
        // Navigate to the RegistrationConfirmation screen on successful registration
        if (userInsertResponse.isNotEmpty) {
          final serviceProviderInsertResponse = await supabase
              .from('service_provider')
              .insert({'name': establishmentName, 'user_id': userId}).select();
          if (serviceProviderInsertResponse.isNotEmpty) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegistrationConfirmation()),
              );
            }
          } else {
            // _showErrorDialog(serviceProviderResponse.error!.message);
            _showErrorDialog(
                "Failed to add data to the service_provider table.");
          }
        } else {
          _showErrorDialog("Failed to add data to the user table.");
        }
      } else {
        _showErrorDialog("User sign-up failed.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading spinner
        });
      }
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
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
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
                    text: "Establishment name ",
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
                  controller: controllers['establishmentName'],
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email address';
                    } else if (!EmailValidator.validate(value)) {
                      return 'Invalid Email Address';
                    }
                    return null;
                  },
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
                    text: "Password ",
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
                  controller: controllers['password'],
                  obscureText: true, // Hide the text for password
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
                          BorderRadius.circular(secondaryBorderRadius),
                    ),
                  ),
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
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : customPaddedTextButton(
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

extension on AuthResponse {}
