import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:service_provider/screens/register.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/globals.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;
  String loginErrorMessage = ''; // Store error message for validation

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

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      loginErrorMessage = ''; // Clear any previous errors
    });

    try {
      // Supabase login process
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (response.user != null) {
        // Login successful, navigate to MainScreen
        Navigator.push(context, crossFadeRoute(const MainScreen()));
      } else {
        // Display error if login fails
        setState(() {
          loginErrorMessage = 'Invalid email or password';
        });
        formKey.currentState!.validate();
      }
    } catch (error) {
      // Log the error for debugging purposes with detailed info
      print('Login error: $error');

      // Update the UI with a detailed error message
      setState(() {
        loginErrorMessage =
            'An unexpected error occurred. Please try again. Details: $error';
      });
      formKey.currentState!.validate();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                          const SizedBox(height: 24),
                          // Email address field
                          SizedBox(
                            width: deviceWidth,
                            height: 50,
                            child: TextFormField(
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
                                prefixIcon: const Icon(Icons.person, size: 19),
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
                              style: const TextStyle(fontSize: regularText),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          SizedBox(
                            width: deviceWidth,
                            height: 50,
                            child: TextFormField(
                              cursorColor: const Color.fromRGBO(74, 74, 74, 1),
                              focusNode: passwordFocusNode,
                              controller: passwordController,
                              obscureText: _obscureText,
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
                                  child: const Icon(Icons.key, size: 19),
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
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 19,
                                      ),
                                    ),
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
                              style: const TextStyle(fontSize: regularText),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Display error message
                          if (loginErrorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                loginErrorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: regularText,
                                ),
                              ),
                            ),
                          // Login Button
                          SizedBox(
                            width: deviceWidth,
                            height: 50,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isLoading
                                    ? Container(
                                        key: const ValueKey('loading'),
                                        width: double.infinity,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(
                                              secondaryBorderRadius),
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                              strokeWidth: 2.0,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        key: const ValueKey('loginButton'),
                                        width: double.infinity,
                                        height: 50,
                                        child: Material(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(
                                              secondaryBorderRadius),
                                          child: InkWell(
                                            onTap: () async {
                                              if (!isLoading) {
                                                await handleLogin();
                                              }
                                            },
                                            borderRadius: BorderRadius.circular(
                                                secondaryBorderRadius),
                                            child: const Center(
                                              child: Text(
                                                "Login",
                                                style: TextStyle(
                                                  fontSize: regularText,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Register prompt
                          SizedBox(
                            width: deviceWidth,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(fontSize: regularText),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: "Register",
                                    style: const TextStyle(color: primaryColor),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          rightToLeftRoute(
                                              const RegisterScreen()),
                                        );
                                      },
                                  ),
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
                          TextSpan(text: "Terms of use"),
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
