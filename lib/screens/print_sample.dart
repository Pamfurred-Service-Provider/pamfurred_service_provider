// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_to_pdf/flutter_to_pdf.dart';

// class PrintSampleScreen extends StatefulWidget {
//   const PrintSampleScreen({super.key});

//   @override
//   State<PrintSampleScreen> createState() => _PrintSampleScreenState();
// }

// class _PrintSampleScreenState extends State<PrintSampleScreen> {
//   final ExportDelegate exportDelegate = ExportDelegate(
//     ttfFonts: {
//       'LoveDays': 'assets/fonts/LoveDays-Regular.ttf',
//       'OpenSans': 'assets/fonts/OpenSans-Regular.ttf',
//     },
//   );

//   Future<void> saveFile(document, String name) async {
//     final Directory dir = await getApplicationDocumentsDirectory();
//     final File file = File('${dir.path}/$name.pdf');

//     await file.writeAsBytes(await document.save());
//     debugPrint('Saved exported PDF at: ${file.path}');
//   }

//   String currentFrameId = 'questionaireDemo';

//   @override
//   Widget build(BuildContext context) => MaterialApp(
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//           tabBarTheme: const TabBarTheme(
//             labelColor: Colors.black87,
//           ),
//         ),
//         home: DefaultTabController(
//           length: 2,
//           child: Scaffold(
//             key: GlobalKey<ScaffoldState>(),
//             appBar: AppBar(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               title: const Text('Flutter to PDF - Demo'),
//               bottom: TabBar(
//                 indicator: const UnderlineTabIndicator(),
//                 tabs: const [
//                   Tab(
//                     icon: Icon(Icons.question_answer),
//                     text: 'Questionaire',
//                   ),
//                   Tab(
//                     icon: Icon(Icons.ssid_chart),
//                     text: 'Charts & Custom Paint',
//                   ),
//                 ],
//                 onTap: (int value) {
//                   setState(() {
//                     currentFrameId =
//                         value == 0 ? 'questionaireDemo' : 'captureWrapperDemo';
//                   });
//                 },
//               ),
//             ),
//             bottomSheet: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 TextButton(
//                   onPressed: () async {
//                     final ExportOptions overrideOptions = ExportOptions(
//                       textFieldOptions: TextFieldOptions.uniform(
//                         interactive: false,
//                       ),
//                       checkboxOptions: CheckboxOptions.uniform(
//                         interactive: false,
//                       ),
//                     );
//                     // Use post-frame callback to ensure the widget is built
//                     WidgetsBinding.instance.addPostFrameCallback((_) async {
//                       final pdf = await exportDelegate.exportToPdfDocument(
//                         currentFrameId,
//                         overrideOptions: overrideOptions,
//                       );
//                       saveFile(pdf, 'static-example');
//                     });
//                   },
//                   child: const Row(
//                     children: [
//                       Text('Export as static'),
//                       Icon(Icons.save_alt_outlined),
//                     ],
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     // Use post-frame callback to ensure the widget is built
//                     WidgetsBinding.instance.addPostFrameCallback((_) async {
//                       final pdf = await exportDelegate
//                           .exportToPdfDocument(currentFrameId);
//                       saveFile(pdf, 'interactive-example');
//                     });
//                   },
//                   child: const Row(
//                     children: [
//                       Text('Export as interactive'),
//                       Icon(Icons.save_alt_outlined),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             body: TabBarView(
//               children: [
//                 ExportFrame(
//                   frameId: 'questionaireDemo',
//                   exportDelegate: exportDelegate,
//                   child: const QuestionnaireExample(),
//                 ),
//                 ExportFrame(
//                   frameId: 'captureWrapperDemo',
//                   exportDelegate: exportDelegate,
//                   child: const CaptureWrapper(
//                     child: Column(
//                       children: [Text('Hello')],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
// }

// class QuestionnaireExample extends StatefulWidget {
//   const QuestionnaireExample({super.key});

//   @override
//   State<QuestionnaireExample> createState() => _QuestionnaireExampleState();
// }

// class _QuestionnaireExampleState extends State<QuestionnaireExample> {
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final dateOfBirthController = TextEditingController();
//   final placeOfBirthController = TextEditingController();
//   final countryOfBirthController = TextEditingController();

//   bool acceptLorem = false;
//   bool monday = false;
//   bool tuesday = false;
//   bool wednesday = false;
//   bool thursday = false;
//   bool friday = false;
//   bool saturday = false;
//   bool sunday = false;

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Dunef UG (haftungsbeschränkt)'),
//                       Text(
//                         'Questionnaire',
//                         style: TextStyle(
//                           fontSize: 25,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (MediaQuery.of(context).size.width > 425)
//                     const Row(
//                       children: [
//                         Text(
//                           'Date: ',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         Text('04.04.2023'),
//                       ],
//                     ),
//                   SizedBox(
//                     height: 50,
//                     child: Image.asset('assets/pamfurred_secondarylogo.png'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Container(
//                     height: 100,
//                     width: 100,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         image: NetworkImage('http://i.pravatar.cc/100'),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                       child:
//                           buildNameFields(MediaQuery.of(context).size.width)),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               buildBirthFields(MediaQuery.of(context).size.width),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Divider(),
//               ),
//               const Text(
//                 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
//                 style: TextStyle(fontFamily: 'LoveDays'),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Checkbox(
//                     key: const Key('acceptLorem'),
//                     value: acceptLorem,
//                     onChanged: (newValue) => setState(() {
//                       acceptLorem = newValue ?? false;
//                     }),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'I hereby accept the terms of the Lorem Ipsum.',
//                     style: TextStyle(fontFamily: 'OpenSans'),
//                   ),
//                 ],
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 child: Divider(),
//               ),
//               const Padding(
//                 padding: EdgeInsets.only(bottom: 8.0),
//                 child: Text(
//                   'Please select your availability:',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Table(
//                 children: [
//                   const TableRow(
//                     children: [
//                       Center(child: Text('Monday', maxLines: 1)),
//                       Center(child: Text('Tuesday', maxLines: 1)),
//                       Center(child: Text('Wednesday', maxLines: 1)),
//                       Center(child: Text('Thursday', maxLines: 1)),
//                       Center(child: Text('Friday', maxLines: 1)),
//                       Center(child: Text('Saturday', maxLines: 1)),
//                       Center(child: Text('Sunday', maxLines: 1)),
//                     ],
//                   ),
//                   TableRow(
//                     children: [
//                       Checkbox(
//                         key: const Key('monday'),
//                         value: monday,
//                         onChanged: (newValue) => setState(() {
//                           monday = newValue ?? false;
//                         }),
//                       ),
//                       Checkbox(
//                         key: const Key('tuesday'),
//                         value: tuesday,
//                         onChanged: (newValue) => setState(() {
//                           tuesday = newValue ?? false;
//                         }),
//                       ),
//                       Checkbox(
//                         key: const Key('wednesday'),
//                         value: wednesday,
//                         onChanged: (newValue) => setState(() {
//                           wednesday = newValue ?? false;
//                         }),
//                       ),
//                       Checkbox(
//                         key: const Key('thursday'),
//                         value: thursday,
//                         onChanged: (newValue) => setState(() {
//                           thursday = newValue ?? false;
//                         }),
//                       ),
//                       Checkbox(
//                         key: const Key('friday'),
//                         value: friday,
//                         onChanged: (newValue) => setState(() {
//                           friday = newValue ?? false;
//                         }),
//                       ),
//                       Checkbox(
//                         key: const Key('saturday'),
//                         value: saturday,
//                         onChanged: (newValue) => setState(() {
//                           saturday = newValue ?? false;
//                         }),
//                       ),
//                       Checkbox(
//                         key: const Key('sunday'),
//                         value: sunday,
//                         onChanged: (newValue) => setState(() {
//                           sunday = newValue ?? false;
//                         }),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );

//   Widget buildNameFields(double width) {
//     return Row(
//       children: [
//         Container(
//           width: width * 0.45,
//           child: TextField(
//             controller: firstNameController,
//             decoration: const InputDecoration(
//               labelText: 'First Name',
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Container(
//           width: width - 400,
//           child: TextField(
//             controller: lastNameController,
//             decoration: const InputDecoration(
//               labelText: 'Last Name',
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildBirthFields(double width) {
//     return Row(
//       children: [
//         Container(
//           width: width * 0.45,
//           child: TextField(
//             controller: dateOfBirthController,
//             decoration: const InputDecoration(
//               labelText: 'Date of Birth',
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//       ],
//     );
//   }
// }

// class ExportFrame extends StatelessWidget {
//   final String frameId;
//   final ExportDelegate exportDelegate;
//   final Widget child;

//   const ExportFrame({
//     required this.frameId,
//     required this.exportDelegate,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ExportFrameContext(
//       frameId: frameId,
//       exportDelegate: exportDelegate,
//       child: child,
//     );
//   }
// }

// class ExportFrameContext extends StatelessWidget {
//   final String frameId;
//   final ExportDelegate exportDelegate;
//   final Widget child;

//   const ExportFrameContext({
//     required this.frameId,
//     required this.exportDelegate,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return child;
//   }
// }
