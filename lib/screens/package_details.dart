import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/providers/package_details_provider.dart';
import 'package:service_provider/screens/update_package.dart'; // Make sure to create or update this screen as needed

class PackageDetails extends ConsumerWidget {
  const PackageDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the selected package service ID from the provider
    final packageId = ref.watch(selectedPackageIdProvider);
    print("Package ID: $packageId");

    // Check if packageId is null
    if (packageId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Package Details')),
        body: const Center(child: Text('No package selected')),
      );
    }

    // Fetch package details using the package ID
    final packageDetails = ref.watch(fetchPackageDetailsProvider(packageId));
    print("Package details: $packageDetails");

    return Scaffold(
      appBar: AppBar(
        title: packageDetails.when(
          data: (data) {
            // Check if data is not empty and return the package name
            return data.isNotEmpty
                ? Text(data.first['package_name'] ?? 'Package Details')
                : const Text('Package Details');
          },
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Error'),
        ),
        actions: [
          packageDetails.when(
            data: (data) {
              final firstItem = data.isNotEmpty ? data.first : null;

              if (firstItem == null) {
                return const SizedBox();
              }

              return TextButton(
                onPressed: () async {
                  final String packageCategory =
                      firstItem['category_name'] ?? '';

                  // Navigate to UpdatePackageScreen
                  try {
                    final updatedPackage =
                        await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePackageScreen(
                          packageId: packageId,
                          packageData: firstItem,
                          packageCategory: packageCategory,
                        ),
                      ),
                    );

                    // Refresh data if updates are made
                    if (updatedPackage != null) {
                      ref.invalidate(fetchPackageDetailsProvider(packageId));
                    }
                  } catch (e) {
                    print("Error navigating to UpdatePackageScreen: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to navigate: $e")),
                    );
                  }
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Color.fromARGB(255, 108, 12, 12)),
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (error, stack) => const SizedBox(),
          ),
        ],
      ),
      body: packageDetails.when(
        data: (data) {
          // Ensure data is a list
          if (data.isEmpty) {
            return const Center(
                child: Text('No details available for this package.'));
          }

          // Extract general package information (assuming it's the first item in the list)
          final packageInfo = data.isNotEmpty ? data.first : {};
          final variants = data; // Use the entire list for variants

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: packageInfo['package_image'] != null &&
                        packageInfo['package_image'] is String &&
                        packageInfo['package_image'].isNotEmpty &&
                        Uri.tryParse(packageInfo['package_image']) != null &&
                        Uri.tryParse(packageInfo['package_image'])!
                            .hasAbsolutePath
                    ? Image.network(
                        packageInfo['package_image'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 200),
              ),
              const SizedBox(height: 30),
              _buildTextRow(
                  'Package Description:', packageInfo['package_desc']),
              const SizedBox(height: 20),
              const Text(
                'Package Variants:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...variants.map((variant) {
                {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextRow('Size:', variant['size']),
                          _buildTextRow(
                            'Weight:',
                            '${variant['min_weight'] ?? 'N/A'} - ${variant['max_weight'] ?? 'N/A'} kg',
                          ),
                          _buildTextRow(
                              'Price:', '₱${variant['price'] ?? 'Unknown'}'),
                          _buildTextRow('Pet Types:', variant['pet_type']),
                          _buildTextRow(
                              'Availability:', variant['availability_status']),
                          _buildTextRow(
                            'Package Type:',
                            variant['package_type'] ?? 'N/A',
                          ),
                          _buildTextRow('Inclusions:', variant['inclusions']),
                        ],
                      ),
                    ),
                  );
                }
              }).toList(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // Helper widget for rows
  Widget _buildTextRow(String title, dynamic value) {
    String displayValue;
    if (value is List) {
      displayValue = value.isNotEmpty ? value.join(', ') : 'None';
    } else {
      displayValue = value?.toString() ?? 'Unknown';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          displayValue,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
