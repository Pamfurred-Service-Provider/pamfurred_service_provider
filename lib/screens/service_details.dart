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
            if (serviceData['image'] != null)
              Center(
                child: Image.file(
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
            const SizedBox(height: 20),
            const Text(
              'Pet Specific Service:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text((serviceData['petsList'] as List<String>?)?.join(',') ??
                'No Specified Pet Type'),
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
              '${serviceData['minWeight']} - ${serviceData['maxWeight']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Price:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['price'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Service Type:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              serviceData['serviceType'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
