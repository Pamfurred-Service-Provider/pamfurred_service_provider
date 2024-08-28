import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'package:service_provider/components/globals.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  // TextEditingControllers
  late Map<String, TextEditingController> controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'phoneNumber': TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(context),
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
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
