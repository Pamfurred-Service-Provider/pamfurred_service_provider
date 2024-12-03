import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';

class AddNewServiceDialog extends StatelessWidget {
  final TextEditingController nameController;
  final List<String> serviceNames;
  final String? selectedService;
  final ValueChanged<String> onServiceSelected;
  final ValueChanged<String> onNewServiceAdded;

  const AddNewServiceDialog({
    super.key,
    required this.nameController,
    required this.serviceNames,
    required this.selectedService,
    required this.onServiceSelected,
    required this.onNewServiceAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16),
            children: [
              TextSpan(
                text: 'Service name ',
                style: const TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: '*',
                style: const TextStyle(color: primaryColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: secondarySizedBox),
        DropdownButtonFormField<String>(
          value: selectedService,
          items: [
            ...serviceNames.map((service) => DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                )),
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Add New Service',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Color(0xFFA03E06)),
                  Text('Add New Service'),
                ],
              ),
            ),
          ],
          onChanged: (value) async {
            if (value == 'Add New Service') {
              final newService = await showDialog<String>(
                context: context,
                builder: (context) {
                  String? newServiceName = '';
                  return AlertDialog(
                    title: const Text('Add New Service'),
                    content: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(secondaryBorderRadius))),
                      ),
                      onChanged: (text) => newServiceName = text,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (newServiceName != null &&
                              newServiceName!.isNotEmpty) {
                            Navigator.pop(context, newServiceName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please enter a valid service name'),
                              ),
                            );
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );

              if (newService != null && newService.isNotEmpty) {
                onNewServiceAdded(
                    newService); // Notify parent about the new service
              }
            } else {
              onServiceSelected(
                  value!); // Notify parent about the selected service
            }
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(secondaryBorderRadius))),
          ),
        ),
      ],
    );
  }
}
