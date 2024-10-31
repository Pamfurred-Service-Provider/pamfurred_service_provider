// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class RegisterTest extends StatelessWidget {
//   Future<void> checkConnection() async {
//     try {
//       // Directly attempt to fetch data from the 'test_table'
//       final response =
//           await Supabase.instance.client.from('test_table').select();

//       // Check if the response is a list, meaning it returned data
//       if (response.isNotEmpty) {
//         print('Connection successful: ${response}');
//       } else {
//         print('Connection failed: No data returned from the table.');
//       }
//     } catch (error) {
//       print('Connection error: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Supabase Connection Test')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: checkConnection,
//           child: Text('Check Connection'),
//         ),
//       ),
//     );
//   }
// }
