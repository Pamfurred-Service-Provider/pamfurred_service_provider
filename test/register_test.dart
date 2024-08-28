import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:service_provider/components/custom_appbar.dart';
//import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/components/globals.dart';

class RegisterTest extends StatefulWidget {
  const RegisterTest({super.key});

  @override
  State<RegisterTest> createState() => _RegisterTestState();
}

class _RegisterTestState extends State<RegisterTest> {
  final formKey = GlobalKey<FormState>();

  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();

    controllers = {
      'firstName': TextEditingController(),
      'lastName': TextEditingController(),
      'phoneNumber': TextEditingController(),
      'doorNo': TextEditingController(),
      'street': TextEditingController(),
      'barangay': TextEditingController(),
      'city': TextEditingController(),
      'username': TextEditingController(),
      'email': TextEditingController(),
      'password': TextEditingController(),
    };
  }

  bool _obscureText = true;

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildTextField(String label, String controllerKey,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: "$label ",
              style:
                  const TextStyle(color: Colors.black, fontSize: regularText),
            ),
            const TextSpan(
              text: "*",
              style: TextStyle(color: primaryColor),
            ),
          ]),
        ),
        const SizedBox(height: primarySizedBox),
        SizedBox(
          height: primaryTextFieldHeight,
          child: TextFormField(
            controller: controllers[controllerKey],
            obscureText: isPassword ? _obscureText : false,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(secondaryBorderRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: secondaryColor),
                borderRadius: BorderRadius.circular(secondaryBorderRadius),
              ),
              suffix: isPassword
                  ? IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return SizedBox(
      height: 65,
      child: IntlPhoneField(
        initialCountryCode: 'PH',
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(secondaryBorderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: secondaryColor),
            borderRadius: BorderRadius.circular(secondaryBorderRadius),
          ),
        ),
        onChanged: (phone) {
          controllers['phoneNumber']?.text = phone.completeNumber;
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: secondarySizedBox),
        Text(
          title,
          style:
              const TextStyle(fontSize: headerText, fontWeight: mediumWeight),
        ),
        const SizedBox(height: secondarySizedBox),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = deviceWidthDivideOnePointFive(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: primaryPadding,
          child: Column(
            children: [
              _buildSectionHeader("Create an account"),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: regularText),
                  children: [
                    TextSpan(
                      text: "Fields marked with (",
                      style: TextStyle(color: greyColor),
                    ),
                    TextSpan(
                      text: "*",
                      style: TextStyle(color: primaryColor),
                    ),
                    TextSpan(
                      text: ") are required.",
                      style: TextStyle(color: greyColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              _buildSectionHeader("Name and Contact"),
              Row(
                children: [
                  Expanded(child: _buildTextField("First name", "firstName")),
                  const SizedBox(width: primarySizedBox),
                  Expanded(child: _buildTextField("Last name", "lastName")),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              const Text("Phone number *"),
              const SizedBox(height: secondarySizedBox),
              _buildPhoneField(),
              const SizedBox(height: secondarySizedBox),
              _buildSectionHeader("Address"),
              Row(
                children: [
                  Expanded(child: _buildTextField("Door no.", "doorNo")),
                  const SizedBox(width: primarySizedBox),
                  Expanded(child: _buildTextField("Street", "street")),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              Row(
                children: [
                  Expanded(child: _buildTextField("Barangay", "barangay")),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              Row(
                children: [
                  Expanded(child: _buildTextField("City", "city")),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              _buildSectionHeader("Credentials"),
              Row(
                children: [
                  Expanded(child: _buildTextField("Username", "username")),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              Row(
                children: [
                  Expanded(child: _buildTextField("Email address", "email")),
                ],
              ),
              const SizedBox(height: secondarySizedBox),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField("Password", "password",
                          isPassword: true)),
                ],
              ),
              const SizedBox(height: tertiarySizedBox),
              Center(
                child: SizedBox(
                  width: deviceWidth,
                  height: primaryTextFieldHeight,
                  child: TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Perform registration logic here
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                        ),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(primaryColor),
                    ),
                    child: const Text(
                      "Register",
                      style:
                          TextStyle(color: Colors.white, fontSize: regularText),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: tertiarySizedBox),
              Center(
                child: SizedBox(
                  width: deviceWidth,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: regularText),
                      children: [
                        const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "Login",
                          style: const TextStyle(color: primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: tertiarySizedBox),
            ],
          ),
        ),
      ),
    );
  }
}
