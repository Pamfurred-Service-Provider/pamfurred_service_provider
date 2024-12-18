// import 'package:email_validator/email_validator.dart';
// import 'package:fancy_password_field/fancy_password_field.dart';
// import 'package:flutter/material.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:service_provider/components/globals.dart';
// import 'package:service_provider/components/screen_transitions.dart';
// import 'package:service_provider/screens/otp_input.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   RegisterScreenState createState() => RegisterScreenState();
// }

// class RegisterScreenState extends State<RegisterScreen> {
//   final supabase = Supabase.instance.client;
//   File? imageFile;

//   // TextEditingControllers
//   late Map<String, TextEditingController> controllers = {
//     'firstName': TextEditingController(),
//     'lastName': TextEditingController(),
//     'establishmentName': TextEditingController(),
//     'email': TextEditingController(),
//     'phoneNumber': TextEditingController(),
//     'password': TextEditingController(),
//   };

//   @override
//   void dispose() {
//     // Dispose controllers to free resources
//     controllers.forEach((_, controller) => controller.dispose());
//     super.dispose();
//   }

//   bool obscureText = true;
//   bool _isLoading = false;

//   Future<void> registerUser() async {
//     setState(() {
//       _isLoading = true; // Start loading
//     });
//     // Retrieve user input from controllers
//     final firstName = controllers['firstName']?.text ?? '';
//     final lastName = controllers['lastName']?.text ?? '';
//     final establishmentName = controllers['establishmentName']?.text ?? '';
//     final email = controllers['email']?.text ?? '';
//     final phoneNumber = controllers['phoneNumber']?.text ?? '';
//     final password = controllers['password']?.text ?? ''; // Retrieve password

//     if (firstName.isEmpty ||
//         lastName.isEmpty ||
//         establishmentName.isEmpty ||
//         email.isEmpty ||
//         password.isEmpty ||
//         imageFile == null ||
//         phoneNumber.isEmpty) {
//       _showErrorDialog("All fields are required.");
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }
//     try {
//       final filePath =
//           'business_permit/${DateTime.now().millisecondsSinceEpoch}.jpg'; // Generate a unique file name
//       final storageResponse = await supabase.storage
//           .from('service_provider_images')
//           .upload(filePath, imageFile!);

//       if (storageResponse.isEmpty) {
//         throw Exception("Failed to upload image:");
//       }

//       // Step 2: Get the public URL of the uploaded image
//       final imageUrl = supabase.storage
//           .from('service_provider_images')
//           .getPublicUrl(filePath);

//       final response = await supabase.auth.signUp(
//         email: email,
//         password: password,
//         data: {
//           'firstName': firstName,
//           'lastName': lastName,
//           'phone_number': phoneNumber,
//         },
//       );

//       if (response.user != null) {
//         final userId = response.user!.id;
// // Insert into 'user' table
//         final userInsertResponse = await supabase.from('user').insert({
//           'user_id': userId,
//           'first_name': firstName,
//           'last_name': lastName,
//           'phone_number': phoneNumber,
//           'user_type': 'service_provider',
//           'password': password,
//           'created_at': DateTime.now().toUtc().toIso8601String(),
//         }).select();

//         if (userInsertResponse.isNotEmpty) {
//           final serviceProviderInsertResponse =
//               await supabase.from('service_provider').insert({
//             'name': establishmentName,
//             'email': email,
//             'sp_id': userId,
//             'sp_business_permit': imageUrl,
//           }).select();
//           if (serviceProviderInsertResponse.isNotEmpty) {
//             if (mounted) {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => OtpVerificationScreen(email: email)),
//               );
//             }
//           } else {
//             _showErrorDialog("Failed create account. Please try again");
//           }
//         } else {
//           _showErrorDialog("Failed create account.");
//         }
//       } else {
//         _showErrorDialog("User sign-up failed.");
//       }
//     } catch (e) {
//       _showErrorDialog("Account already exists. Please try another email");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to open the camera
//   Future<void> captureImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       setState(() {
//         imageFile = File(pickedFile.path);
//       });
//     } else {
//       // Handle the case where no image was captured
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No image captured!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: secondarySizedBox),
//               const Text(
//                 "Become one of our partners!",
//                 style: TextStyle(
//                   color: primaryColor,
//                   fontWeight: FontWeight.w900,
//                   fontSize: titleFont,
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(
//                   style: TextStyle(fontSize: regularText),
//                   children: [
//                     TextSpan(
//                       text:
//                           "Unlock new growth opportunities and boost your business by partnering with us.\n\n",
//                       style: TextStyle(
//                         color: Colors.black,
//                       ),
//                     ),
//                     TextSpan(
//                       text: "Fields marked with (*) are required \n",
//                       style: TextStyle(
//                         color: greyColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Business owner first name ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['firstName'],
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Business owner last name ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['lastName'],
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Establishment name ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   cursorColor: Colors.black,
//                   controller: controllers['establishmentName'],
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Business email ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                 height: primaryTextFieldHeight,
//                 child: TextFormField(
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter email address';
//                     } else if (!EmailValidator.validate(value)) {
//                       return 'Invalid Email Address';
//                     }
//                     return null;
//                   },
//                   cursorColor: Colors.black,
//                   controller: controllers['email'],
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                       contentPadding: const EdgeInsets.all(10.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                           secondaryBorderRadius,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                           borderSide: const BorderSide(color: secondaryColor),
//                           borderRadius:
//                               BorderRadius.circular(secondaryBorderRadius))),
//                 ),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Password ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               FancyPasswordField(
//                 controller: controllers['password'],
//                 validationRules: {
//                   DigitValidationRule(),
//                   UppercaseValidationRule(),
//                   LowercaseValidationRule(),
//                   SpecialCharacterValidationRule(),
//                   MinCharactersValidationRule(6),
//                 },
//                 validationRuleBuilder: (rules, value) {
//                   if (value.isEmpty) {
//                     return const SizedBox.shrink();
//                   }
//                   return Column(
//                     children: rules.map((rule) {
//                       final isValid = rule.validate(value);
//                       return Row(
//                         children: [
//                           Icon(
//                             isValid ? Icons.check : Icons.close,
//                             color: isValid ? Colors.green : Colors.red,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             rule.name,
//                             style: TextStyle(
//                               color: isValid ? Colors.green : Colors.red,
//                             ),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   );
//                 },
//                 decoration: InputDecoration(
//                     contentPadding: const EdgeInsets.all(10.0),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(
//                         secondaryBorderRadius,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                         borderSide: const BorderSide(color: secondaryColor),
//                         borderRadius:
//                             BorderRadius.circular(secondaryBorderRadius))),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Phone number ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: primarySizedBox),
//               SizedBox(
//                   height: 65,
//                   child: IntlPhoneField(
//                     cursorColor: Colors.black,
//                     initialCountryCode: 'PH',
//                     onChanged: (phone) {
//                       controllers['phoneNumber']!.text =
//                           phone.completeNumber; // Store the complete number
//                     },
//                     decoration: InputDecoration(
//                         contentPadding: const EdgeInsets.all(10.0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             secondaryBorderRadius,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                             borderSide: const BorderSide(color: secondaryColor),
//                             borderRadius:
//                                 BorderRadius.circular(secondaryBorderRadius))),
//                   )),
//               const SizedBox(height: primarySizedBox),
//               RichText(
//                 text: const TextSpan(children: [
//                   TextSpan(
//                     text: "Business Permit ",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: regularText,
//                     ),
//                   ),
//                   TextSpan(
//                     text: "*",
//                     style: TextStyle(color: primaryColor),
//                   ),
//                 ]),
//               ),
//               const SizedBox(height: secondarySizedBox),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: captureImage,
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Please attach your business permit'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: secondarySizedBox),
//               if (imageFile != null)
//                 Image.file(
//                   imageFile!,
//                   width: double.infinity,
//                   // height: 200,
//                   fit: BoxFit.cover,
//                 ),
//                 const SizedBox(height: secondarySizedBox),
//                 Center(
//                   child: ElevatedButton(
//                   Navigator.push(context, rightToLeftRoute(RegistrationCameraScreen())),
//                 ), ),
//               const SizedBox(height: secondarySizedBox),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     await registerUser();
//                   },
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.white),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(
//                           color: Colors.white,
//                         )
//                       : const Text('Register',
//                           style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// extension on AuthResponse {}
