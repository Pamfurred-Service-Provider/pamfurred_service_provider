import 'package:flutter/material.dart';
import 'package:service_provider/screens/add_package.dart';

class PackageDetails extends StatefulWidget {
  final Map<String, dynamic> packageData;

  const PackageDetails({super.key, required this.packageData});

  @override
  PackageDetailsState createState() => PackageDetailsState();
}

class PackageDetailsState extends State<PackageDetails> {
  late Map<String, dynamic> packageData;

  @override
  void initState() {
    super.initState();
    packageData = widget.packageData; // Initialize with the provided data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(packageData['name']),
        actions: [
          TextButton(
            onPressed: () async {
              final updatedPackage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddPackageScreen(packageData: packageData),
                ),
              );
              if (updatedPackage != null) {
                setState(() {
                  packageData = updatedPackage; // Update with edited data
                });
                Navigator.pop(context, updatedPackage);
              }
            },
            child: const Text("Edit"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (packageData['image'] != null)
              Center(
                child: Image.file(
                  packageData['image'],
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
              "Description:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Package Inclusions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              (packageData['inclusionList'] as List<String>?)?.join(', ') ??
                  'No inclusions',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Availability:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['availability'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Size:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['size'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Weight:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${packageData['minWeight']} - ${packageData['maxWeight']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Price:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['price'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Service Type:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['packageType'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
