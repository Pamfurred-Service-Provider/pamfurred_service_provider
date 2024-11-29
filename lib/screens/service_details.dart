import 'package:flutter/material.dart';
import 'package:service_provider/screens/update_service.dart';

class ServiceDetails extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final String serviceProviderId; // Added required serviceProviderId

  const ServiceDetails({
    super.key,
    required this.serviceData,
    required this.serviceProviderId,
  });

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
        title: Text(serviceData['name'] ?? 'Service Details'),
        actions: [
          TextButton(
            onPressed: () async {
              print("Navigating to UpdateServiceScreen with serviceData: ${widget.serviceData}");
              print("Navigating to UpdateServiceScreen with serviceProviderId: ${widget.serviceProviderId}");

              // Extract required parameters from widget and serviceData
              final String serviceProviderId = widget.serviceProviderId; // Directly from widget
              final String serviceId = serviceData['id'] ?? '';
              final String serviceCategory = serviceData['category'] ?? '';

              // Validate serviceProviderId and serviceId before navigating
              if (serviceProviderId.isEmpty) {
                print("Error: Service Provider ID is null or empty");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Service Provider ID is missing. Unable to proceed.")),
                );
                return;
              }
              if (serviceId.isEmpty) {
                print("Error: Service ID is null or empty");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Service ID is missing. Unable to proceed.")),
                );
                return;
              }

              try {
                // Navigate to UpdateServiceScreen with required parameters
                final updatedService = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateServiceScreen(
                      serviceProviderId: serviceProviderId, // Pass serviceProviderId
                      serviceId: serviceId, // Pass serviceId
                      serviceCategory: serviceCategory, // Pass serviceCategory
                      serviceData: widget.serviceData, // Pass serviceData
                    ),
                  ),
                );

                // Check if updatedService is not null and update serviceData
                if (updatedService != null) {
                  print("Updated Service: $updatedService");
                  setState(() {
                    serviceData = updatedService; // Update the service data with the new values
                  });
                } else {
                  print("No updates made to the service.");
                }
              } catch (e) {
                print("Error navigating to UpdateServiceScreen: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to navigate: $e")),
                );
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
                      Uri.tryParse(serviceData['image'])!.hasAbsolutePath
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
              serviceData['pets'] ?? 'No Specified Pet Type',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Availability:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['availability'] ?? 'Unknown',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Size:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['size'] ?? 'Unknown',
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
              serviceData['price']?.toString() ?? 'Unknown',
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