import 'package:flutter/material.dart';
import 'package:service_provider/screens/update_service.dart';

class ServiceDetails extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetails({super.key, required this.serviceData});

  @override
  ServiceDetailsState createState() => ServiceDetailsState();
}

class ServiceDetailsState extends State<ServiceDetails> {
  late Map<String, dynamic> serviceData;

  @override
  void initState() {
    super.initState();
    serviceData = widget.serviceData; // Initialize with the provided data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceData['name']),
        actions: [
          TextButton(
            onPressed: () async {
              // Navigate to UpdateServiceScreen for editing
              final updatedService = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateServiceScreen(
                    serviceData: serviceData,
                    serviceProviderId: widget.serviceData['serviceProviderId'],
                  ),
                ),
              );
              print("Updated Service: $updatedService"); // Debug print
              // Update the UI with the edited data
              if (updatedService != null) {
                setState(() {
                  serviceData = {
                    'name': updatedService['name'] ?? serviceData['name'] ?? '',
                    'image':
                        updatedService['image'] ?? serviceData['image'] ?? '',
                    'pets': updatedService['pets'] ?? serviceData['pets'] ?? '',
                    'availability': updatedService['availability'] ??
                        serviceData['availability'] ??
                        '',
                    'size': updatedService['size'] ?? serviceData['size'] ?? '',
                    'minWeight': updatedService['minWeight']?.toString() ??
                        serviceData['minWeight']?.toString() ??
                        'N/A',
                    'maxWeight': updatedService['maxWeight']?.toString() ??
                        serviceData['maxWeight']?.toString() ??
                        'N/A',
                    'price': updatedService['price']?.toString() ??
                        serviceData['price']?.toString() ??
                        'N/A',
                    'type': updatedService['type'] ??
                        serviceData['type'] ??
                        'No Service Type Info',
                    // Add any other fields that are part of your service data
                  };
                });
                print("Updated Service Data: $serviceData"); // Debug print
              }
            },
            child: const Text(
              "Edit",
              style: TextStyle(color: Color.fromARGB(255, 108, 12, 12)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: serviceData['image'] != null &&
                      serviceData['image'] is String &&
                      serviceData['image'] != '' &&
                      Uri.tryParse(serviceData['image']) != null &&
                      Uri.tryParse(serviceData['image']) != null &&
                      Uri.tryParse(serviceData['image'])?.hasAbsolutePath ==
                          true
                  ? Image.network(
                      serviceData['image'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 200),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pet Specific Service:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              (serviceData['pets'] ?? 'No Specified Pet Type'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Availability:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['availability'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Size:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['size'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Weight:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${serviceData['minWeight']?.toString() ?? 'N/A'} - ${serviceData['maxWeight']?.toString() ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Price:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['price']?.toString() ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Service Type:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['type'] ?? 'No Service Type Info',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
