import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:service_provider/screens/register.dart';
import '../components/globals.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/pamfurred_logo.png'), context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = deviceWidthDivideOnePointFive(context);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/pamfurred_logo.png',
                            width: deviceWidth / 1.25,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          // Email address field
                          SizedBox(
                            width: deviceWidth,
                            height: 50,
                            child: TextFormField(
                              // validator
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email address';
                                } else if (!EmailValidator.validate(value)) {
                                  return 'Invalid Email Address';
                                }
                                return null;
                              },
                              cursorColor: const Color.fromRGBO(74, 74, 74, 1),
                              focusNode: emailFocusNode,
                              controller: emailController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  size: 19,
                                ),
                                labelText: emailFocusNode.hasFocus
                                    ? ''
                                    : 'Email address',
                                labelStyle:
                                    const TextStyle(fontSize: regularText),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(241, 241, 241, 1.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: regularText,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          // Password field
                          SizedBox(
                            width: deviceWidth,
                            height: 50,
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              cursorColor: const Color.fromRGBO(74, 74, 74, 1),
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              obscureText: _obscureText,
                              // validator
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter password";
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                prefixIcon: Transform.rotate(
                                  angle: 40,
                                  child: const Icon(
                                    Icons.key,
                                    size: 19,
                                  ),
                                ),
                                labelText: passwordFocusNode.hasFocus
                                    ? ''
                                    : 'Password',
                                labelStyle:
                                    const TextStyle(fontSize: regularText),
                                suffix: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: (() {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      }),
                                      child: Icon(
                                          _obscureText
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 19),
                                    )
                                  ],
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(241, 241, 241, 1.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: regularText,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: deviceWidth,
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              // validator
                              onPressed: () {},
                              child: const Text(
                                "Forgot passwordd?",
                                style: TextStyle(
                                  fontSize: regularText,
                                  color: secondaryColor,
                                  decoration: TextDecoration.underline,
                                  decorationColor: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            width: deviceWidth,
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                // validator
                                if (formKey.currentState!.validate()) {
                                  // Save to database
                                  Navigator.push(context,
                                      crossFadeRoute(const MainScreen()));
                                }
                              },
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        secondaryBorderRadius),
                                  ),
                                ),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  primaryColor,
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: regularText,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: deviceWidth,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(fontSize: regularText),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Register",
                                    style: const TextStyle(
                                      color: primaryColor,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            rightToLeftRoute(
                                                const RegisterScreen()));
                                        // rightToLeftRoute(const RegisterTest()));
                                      },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                            color: Colors.black, fontSize: regularText),
                        children: [
                          TextSpan(text: "About Pamfurred"),
                          TextSpan(text: " • "),
                          TextSpan(text: "Privacy Policy"),
                          TextSpan(text: " • "),
                          TextSpan(text: "Terms of use")
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
