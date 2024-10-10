// import 'package:flutter/material.dart';

// class NotificationDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> appointment;

//   const NotificationDetailsScreen({Key? key, required this.appointment})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Appointment Details"),
//       ),
//       body: ListView(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: Center(
//               child: Text(
//                 "Appointment ID:",
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(18.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Date:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['date']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Time:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['time']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Status:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['status']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Name:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['name']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Phone Number:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['phone']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Pet Category:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['category']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Service Type:',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${appointment['type']}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Service Availed:',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '${appointment['availed']}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     Text(
//                       'Prices:',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       '${appointment['price']}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 10),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Total:',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromRGBO(160, 62, 6, 1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
