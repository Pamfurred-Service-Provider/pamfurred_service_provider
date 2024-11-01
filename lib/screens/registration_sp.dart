// import 'package:supabase/supabase.dart';
// import 'package:service_provider/Authentication/config.dart';

// class RegistrationService {
//   Future<void> registerServiceProvider(
//     String firstName,
//     String lastName,
//     String email,
//     String phoneNumber,
//   ) async {
//     final response = await supabase
//       .from('service_providers')
//       .insert([
//         {
//           'first_name': firstName,
//           'last_name': lastName,
//           'email': email,
//           'phone_number': phoneNumber,
//         },
//       ]);

//     if (response.error != null) {
//       // Handle registration error
//     } else {
//       // Registration successful
//     }
//   }

//   Future<void> validateServiceProvider(
//     String email,
//     String password,
//   ) async {
//     // Validation logic
//   }
// }
