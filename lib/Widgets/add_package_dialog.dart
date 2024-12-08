// import 'package:flutter/material.dart';
// import 'package:service_provider/components/globals.dart';

// class AddNewPackageDialog extends StatelessWidget {
//   final TextEditingController nameController;
//   final List<String> serviceNames;
//   final String? selectedService;
//   final ValueChanged<String> onServiceSelected;
//   final ValueChanged<String> onNewServiceAdded;

//   const AddNewPackageDialog({
//     super.key,
//     required this.nameController,
//     required this.serviceNames,
//     required this.selectedService,
//     required this.onServiceSelected,
//     required this.onNewServiceAdded,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: secondarySizedBox),
//         DropdownButtonFormField<String>(
//           value: selectedService,
//           items: [
//             ...serviceNames.map((service) => DropdownMenuItem<String>(
//                   value: service,
//                   child: Text(service),
//                 )),
//             const DropdownMenuItem<String>(
//               enabled: false,
//               child: Divider(
//                 thickness: 1,
//                 color: Colors.grey,
//               ),
//             ),
//             DropdownMenuItem<String>(
//               value: 'Add New Service',
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(Icons.add, color: Color(0xFFA03E06)),
//                   Text('Add New Service'),
//                 ],
//               ),
//             ),
//           ],
//           onChanged: (value) async {
//             if (value == 'Add New Service') {
//               final newService = await showDialog<String>(
//                 context: context,
//                 builder: (context) {
//                   String? newServiceName = '';
//                   return AlertDialog(
//                     title: const Text('Add New Service'),
//                     content: TextField(
//                       autofocus: true,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(secondaryBorderRadius),
//                           ),
//                         ),
//                       ),
//                       onChanged: (text) => newServiceName = text,
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('Cancel'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           if (newServiceName != null &&
//                               newServiceName!.isNotEmpty) {
//                             if (serviceNames.contains(newServiceName)) {
//                               // Show error dialog if service already exists
//                               showDialog<void>(
//                                 context: context,
//                                 builder: (context) {
//                                   return AlertDialog(
//                                     title: const Text('Error'),
//                                     content: const Text(
//                                         'This service name already exists. Please choose a different name.'),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () => Navigator.pop(context),
//                                         child: const Text('OK'),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             } else {
//                               Navigator.pop(context, newServiceName);
//                             }
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content:
//                                     Text('Please enter a valid service name'),
//                               ),
//                             );
//                           }
//                         },
//                         child: const Text('Add'),
//                       ),
//                     ],
//                   );
//                 },
//               );

//               if (newService != null && newService.isNotEmpty) {
//                 onNewServiceAdded(
//                     newService); // Notify parent about the new service
//               }
//             } else {
//               onServiceSelected(
//                   value!); // Notify parent about the selected service
//             }
//           },
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius:
//                   BorderRadius.all(Radius.circular(secondaryBorderRadius)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class AddNewPackageDialog extends StatefulWidget {
//   final TextEditingController nameController;
//   final List<String> serviceNames;
//   final List<String> selectedServices;
//   final ValueChanged<List<String>> onServicesSelected;
//   final ValueChanged<String> onNewServiceAdded;

//   const AddNewPackageDialog({
//     super.key,
//     required this.nameController,
//     required this.serviceNames,
//     required this.selectedServices,
//     required this.onServicesSelected,
//     required this.onNewServiceAdded,
//   });

//   @override
//   _AddNewPackageDialogState createState() => _AddNewPackageDialogState();
// }

// class _AddNewPackageDialogState extends State<AddNewPackageDialog> {
//   late List<String> filteredServices;
//   late List<String> tempSelectedServices;

//   @override
//   void initState() {
//     super.initState();
//     filteredServices = widget.serviceNames;
//     tempSelectedServices = List.from(widget.selectedServices);
//     widget.nameController.addListener(_filterServices);
//   }

//   @override
//   void dispose() {
//     widget.nameController.removeListener(_filterServices);
//     super.dispose();
//   }

//   void _filterServices() {
//     final query = widget.nameController.text.toLowerCase();
//     setState(() {
//       filteredServices = widget.serviceNames
//           .where((service) => service.toLowerCase().contains(query))
//           .toList();
//       if (query.isNotEmpty && filteredServices.isEmpty) {
//         filteredServices = [
//           'Add New Service'
//         ]; // Only show Add New Service if no matches found
//       }
//     });
//   }

//   void _addNewService() {
//     final newServiceName = widget.nameController.text.trim();
//     if (newServiceName.isNotEmpty &&
//         !widget.serviceNames.any((service) =>
//             service.toLowerCase() == newServiceName.toLowerCase())) {
//       setState(() {
//         widget.serviceNames.add(newServiceName);
//         widget.onNewServiceAdded(newServiceName);
//         widget.nameController.text = newServiceName;
//         filteredServices = []; // Hide the dropdown after adding the new service
//       });
//     } else if (newServiceName.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid service name'),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('This service already exists'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: widget.nameController,
//           decoration: InputDecoration(
//             hintText: 'Search or Add Service',
//             border: const OutlineInputBorder(),
//             suffixIcon: const Icon(Icons.search),
//           ),
//           onChanged: (_) {
//             _filterServices();
//           },
//         ),
//         const SizedBox(height: 8),
//         if (filteredServices.isNotEmpty)
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: Colors.grey,
//                 width: 1,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: SizedBox(
//               height: 200,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: filteredServices.length,
//                 itemBuilder: (context, index) {
//                   final service = filteredServices[index];
//                   return ListTile(
//                     title: Row(
//                       children: [
//                         if (service == 'Add New Service')
//                           const Icon(Icons.add, size: 18),
//                         const SizedBox(
//                             width:
//                                 8), // Add some space between the icon and the text
//                         Expanded(
//                           child: Text(service),
//                         ),
//                         Checkbox(
//                           value: tempSelectedServices.contains(service),
//                           onChanged: (bool? isChecked) {
//                             setState(() {
//                               if (isChecked != null && isChecked) {
//                                 tempSelectedServices.add(service);
//                               } else {
//                                 tempSelectedServices.remove(service);
//                               }
//                               widget.onServicesSelected(tempSelectedServices);
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       if (service == 'Add New Service') {
//                         _addNewService();
//                       } else {
//                         widget.nameController.text = service;
//                         setState(() {
//                           filteredServices = [];
//                         });
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class AddNewPackageDialog extends StatefulWidget {
  final TextEditingController nameController;
  final List<String> serviceNames;
  final List<String> selectedServices;
  final ValueChanged<List<String>> onServicesSelected;
  final ValueChanged<String> onNewServiceAdded;

  const AddNewPackageDialog({
    super.key,
    required this.nameController,
    required this.serviceNames,
    required this.selectedServices,
    required this.onServicesSelected,
    required this.onNewServiceAdded,
  });

  @override
  _AddNewPackageDialogState createState() => _AddNewPackageDialogState();
}

class _AddNewPackageDialogState extends State<AddNewPackageDialog> {
  late List<String> filteredServices;
  late List<String> tempSelectedServices;

  @override
  void initState() {
    super.initState();
    filteredServices = widget.serviceNames;
    tempSelectedServices = List.from(widget.selectedServices);
    widget.nameController.addListener(_filterServices);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_filterServices);
    super.dispose();
  }

  void _filterServices() {
    final query = widget.nameController.text.toLowerCase();
    setState(() {
      filteredServices = widget.serviceNames
          .where((service) => service.toLowerCase().contains(query))
          .toList();
      if (query.isNotEmpty && filteredServices.isEmpty) {
        filteredServices = [
          'Add New Service'
        ]; // Only show Add New Service if no matches found
      }
    });
  }

  void _addNewService() {
    final newServiceName = widget.nameController.text.trim();
    if (newServiceName.isNotEmpty &&
        !widget.serviceNames.any((service) =>
            service.toLowerCase() == newServiceName.toLowerCase())) {
      setState(() {
        widget.serviceNames.add(newServiceName);
        widget.onNewServiceAdded(newServiceName);
        widget.nameController.text = newServiceName;
        filteredServices = []; // Hide the dropdown after adding the new service
      });
    } else if (newServiceName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid service name'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This service already exists'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Hide the dropdown when clicking outside of it
        setState(() {
          filteredServices = [];
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.nameController,
            decoration: InputDecoration(
              hintText: 'Search or Add Service',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) {
              _filterServices();
            },
          ),
          const SizedBox(height: 8),
          if (filteredServices.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    return ListTile(
                      title: Row(
                        children: [
                          if (service == 'Add New Service')
                            const Icon(Icons.add, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(service),
                          ),
                          if (service != 'Add New Service')
                            Checkbox(
                              value: tempSelectedServices.contains(service),
                              onChanged: (bool? isChecked) {
                                setState(() {
                                  if (isChecked != null && isChecked) {
                                    tempSelectedServices.add(service);
                                  } else {
                                    tempSelectedServices.remove(service);
                                  }
                                  widget
                                      .onServicesSelected(tempSelectedServices);
                                });
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        if (service == 'Add New Service') {
                          _addNewService();
                        } else {
                          widget.nameController.text = service;
                          setState(() {
                            filteredServices = [];
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
