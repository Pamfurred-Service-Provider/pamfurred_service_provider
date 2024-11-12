import 'package:flutter/material.dart';
import 'package:service_provider/screens/edit_service.dart';

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
        //   actions: [
        //     TextButton(
        //       onPressed: () async {
        //         final updatedService = await Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) =>
        //                 EditServiceScreen(serviceData: serviceData),
        //           ),
        //         );
        //         if (updatedService != null) {
        //           setState(() {
        //             serviceData = updatedService; // Update with edited data
        //           });
        //           Navigator.pop(context, updatedService);
        //         }
        //       },
        //       child: const Text("Edit"),
        //     ),
        //   ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (serviceData['image'] != null && serviceData['image'] is String)
              Center(
                child: Image.network(
                  serviceData['image'],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Center(
                child: Icon(Icons.image, size: 100),
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
