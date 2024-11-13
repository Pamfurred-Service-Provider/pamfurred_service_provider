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
        // actions: [
        //   TextButton(
        //     onPressed: () async {
        //       final updatedPackage = await Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) =>
        //               AddPackageScreen(packageData: packageData),
        //         ),
        //       );
        //       if (updatedPackage != null) {
        //         setState(() {
        //           packageData = updatedPackage; // Update with edited data
        //         });
        //         Navigator.pop(context, updatedPackage);
        //       }
        //     },
        //     child: const Text("Edit"),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: packageData['image'] != null &&
                      packageData['image'] is String &&
                      packageData['image']!.isNotEmpty &&
                      Uri.tryParse(packageData['image']!)?.hasAbsolutePath ==
                          true
                  ? Image.network(
                      packageData['image'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image,
                      size: 200,
                    ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pet Specific Service:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              (packageData['pets'] ?? 'No Specified Pet Type'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Package Inclusions:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              (packageData['inclusions'] ?? 'No inclusions'),
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
              packageData['sizes'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Weight:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${packageData['minWeight']?.toString() ?? 'N/A'} - ${packageData['maxWeight']?.toString() ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Price:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['price']?.toString() ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              "Service Type:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              packageData['type'] ?? 'No Package Type Info',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
