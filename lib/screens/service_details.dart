import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/providers/service_details_provider.dart';
import 'package:service_provider/screens/update_service.dart';

class ServiceDetails extends ConsumerWidget {
  const ServiceDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the selected service ID from the provider
    final serviceId = ref.watch(selectedServiceIdProvider);
    print("Service ID: $serviceId");

    // Check if serviceId is null
    if (serviceId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Details')),
        body: const Center(child: Text('No service selected')),
      );
    }

    // Fetch service details using the service ID
    final serviceDetails = ref.watch(fetchServiceDetailsProvider(serviceId));
    print("service details: $serviceDetails");

    return Scaffold(
      appBar: AppBar(
        title: serviceDetails.when(
          data: (data) {
            // Check if data is not empty and return the service name
            return data.isNotEmpty
                ? Text(data.first['service_name'] ?? 'Service Details')
                : const Text('Service Details');
          },
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Error'),
        ),
        actions: [
          serviceDetails.when(
            data: (data) {
              final firstItem = data.isNotEmpty ? data.first : null;

              if (firstItem == null) {
                return const SizedBox();
              }

              return TextButton(
                onPressed: () async {
                  final String serviceCategory =
                      firstItem['category_name'] ?? '';

                  // Navigate to UpdateServiceScreen
                  try {
                    final updatedService =
                        await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateServiceScreen(
                          serviceProviderId: '', // Update this field if needed
                          serviceId: serviceId,
                          serviceCategory: serviceCategory,
                          serviceData: firstItem,
                        ),
                      ),
                    );

                    // Refresh data if updates are made
                    if (updatedService != null) {
                      ref.invalidate(fetchServiceDetailsProvider(serviceId));
                    }
                  } catch (e) {
                    print("Error navigating to UpdateServiceScreen: $e");
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
      body: serviceDetails.when(
        data: (data) {
          // Ensure data is a list
          if (data.isEmpty) {
            return const Center(
                child: Text('No details available for this service.'));
          }

          // Extract general service information (assuming it's the first item in the list)
          final serviceInfo = data.isNotEmpty ? data.first : {};
          final variants = data; // Use the entire list for variants

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: serviceInfo['service_image'] != null &&
                        serviceInfo['service_image'] is String &&
                        serviceInfo['service_image'].isNotEmpty &&
                        Uri.tryParse(serviceInfo['service_image']) != null &&
                        Uri.tryParse(serviceInfo['service_image'])!
                            .hasAbsolutePath
                    ? Image.network(
                        serviceInfo['service_image'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 200),
              ),
              const SizedBox(height: 30),
              _buildTextRow(
                  'Service Description:', serviceInfo['service_desc']),
              const SizedBox(height: 20),
              const Text(
                'Service Variants:',
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
                          _buildTextRow(
                            'Pet Types:',
                            (variant['pet_type'] as List<dynamic>?)?.join(', '),
                          ),
                          _buildTextRow(
                              'Availability:', variant['availability_status']),
                          _buildTextRow(
                            'Service Type:',
                            (variant['service_type'] as List<dynamic>?)
                                ?.join(', '),
                          ),
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
  Widget _buildTextRow(String title, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value ?? 'Unknown',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
