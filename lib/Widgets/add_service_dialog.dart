import 'package:flutter/material.dart';

class AddNewServiceDialog extends StatefulWidget {
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
  _AddNewServiceDialogState createState() => _AddNewServiceDialogState();
}

class _AddNewServiceDialogState extends State<AddNewServiceDialog> {
  late List<String> filteredServices;

  @override
  void initState() {
    super.initState();
    filteredServices = widget.serviceNames;
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        const SizedBox(
                            width:
                                8), // Add some space between the icon and the text
                        Text(service),
                      ],
                    ),
                    onTap: () {
                      if (service == 'Add New Service') {
                        // Automatically add the new service
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
    );
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
}
