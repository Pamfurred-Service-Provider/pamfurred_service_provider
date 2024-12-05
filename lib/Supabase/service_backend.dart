import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceBackend {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> addService({
    required String serviceName,
    required String serviceDesc,
    required List<String> petsToCater,
    required List<String> serviceType, // Change to List<String>
    required Map<String, String> availability,
    required String? imageUrl,
    required String serviceProviderId,
    String? serviceCategory,
    required List<int> prices,
    required List<String?> sizes,
    required List<int> minWeights,
    required List<int> maxWeights,
  }) async {
    // Fetch service package category details that match the serviceCategory
    final servicePackageCategory = await _supabase
        .from('service_package_category')
        .select('service_package_category_id, category_name')
        .eq('category_name',
            serviceCategory) // Ensure we fetch the correct category
        .single();

    print("service package category: $servicePackageCategory");

    // Check if a category was found
    if (servicePackageCategory == null) {
      throw Exception('Service category not found: $serviceCategory');
    }

    // // Extract the fetched category ID
    final toBeInsertedCategoryId =
        servicePackageCategory['service_package_category_id'];

    // Insert the service and include the service_package_category_id
    final response = await _supabase
        .from('service')
        .insert({
          'service_package_category_id':
              toBeInsertedCategoryId, // Include the category ID
          'service_name': serviceName,
          'service_desc': serviceDesc,
          'service_type': serviceType, // Pass list directly
          'pet_type': petsToCater,
          'service_image': imageUrl,
        })
        .select('service_id')
        .single();

    final serviceId = response['service_id'];

    print("availability map: $availability");

    List<String> allSizes = availability.keys.toList();

    final List<String> availabilityStatus = allSizes.map((size) {
      // Get the availability status for each size
      return availability[size] ??
          'Unknown'; // Default to 'Unknown' if the size is not in the map
    }).toList();

    print("Availability Status: $availabilityStatus");

    try {
      // Check if all lists have the same length
      if (sizes.length != prices.length ||
          sizes.length != minWeights.length ||
          sizes.length != maxWeights.length ||
          sizes.length != availabilityStatus.length) {
        throw Exception('All input lists must have the same length.');
      }

      // Prepare a list to hold the data for bulk insertion
      final List<Map<String, dynamic>> insertData = [];

      // Loop through the sizes and create a separate map for each size
      for (int i = 0; i < sizes.length; i++) {
        insertData.add({
          'sp_id': serviceProviderId,
          'service_id': serviceId,
          'availability_status':
              availabilityStatus[i], // This should be a valid string
          'size': sizes[i], // Assume sizes[i] is guaranteed to be non-null
          'price': prices[i], // Corresponding price (int)
          'min_weight': minWeights[i], // Corresponding minimum weight (int)
          'max_weight': maxWeights[i], // Corresponding maximum weight (int)
        });
      }

      // Perform the bulk insert
      final insertResponse =
          await _supabase.from('serviceprovider_service').insert(insertData);

      // Check if the insertResponse is null or has an error
      if (insertResponse == null) {
        throw Exception(
            'Insert response is null. Check your Supabase client initialization.');
      } else if (insertResponse.error != null) {
        throw Exception(
            'Failed to insert service provider services: ${insertResponse.error!.message}');
      }

      print('Insert successful: ${insertResponse.data}'); // Log success
    } catch (e) {
      print('Error occurred: $e'); // Log the error
      // Optionally, show an error dialog or a snackbar to the user
    }

    return serviceId;
  }

  Future<String?> addServiceProviderService({
    required String serviceName,
    required String size,
    required int minWeight,
    required int maxWeight,
    required List<String> petsToCater,
    required String selectedServiceType,
    required bool availability,
    required String? imageUrl,
    required String? serviceCategory,
    required String serviceProviderId,
  }) async {
    // Validate the size value to match database constraints
    const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
    if (!allowedSizes.contains(size)) {
      throw Exception(
          "Invalid size value: $size. Allowed values are $allowedSizes");
    }

    // Insert the service and retrieve the service ID in a single operation
    final response = await _supabase
        .from('service')
        .insert({
          'service_name': serviceName,
          'size': size,
          'min_weight': minWeight,
          'max_weight': maxWeight,
          'pet_type': petsToCater,
          'service_type': [selectedServiceType],
          'availability_status': availability,
          'service_image': imageUrl,
          'service_category': [serviceCategory],
        })
        .select('service_id')
        .single();

    final serviceId = response['service_id'];

    // Link the service to the service provider directly
    await _supabase.from('serviceprovider_service').insert({
      'sp_id': serviceProviderId,
      'service_id': serviceId,
    });

    return serviceId;
  }

  Future<String> uploadImage(File image) async {
    final filePath = 'service_images/${image.uri.pathSegments.last}';
    await _supabase.storage
        .from('service_provider_images')
        .upload(filePath, image);
// If the upload is successful, get the public URL
    final publicUrl = _supabase.storage
        .from('service_provider_images')
        .getPublicUrl(filePath);
    return publicUrl;
  }

  Future<List<String>> fetchServiceName() async {
    final response =
        await _supabase.from('distinct_services').select('service_name');
    print("Services list: $response");

    // Extract only the 'service_name' values
    final services = (response as List)
        .map((service) => service['service_name'] as String)
        .toList();

    return services;
  }

  Future<void> updateService({
    required String serviceId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      // Add size validation if provided in updated data
      if (updatedData.containsKey('size')) {
        const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
        if (!allowedSizes.contains(updatedData['size'])) {
          throw Exception("Invalid size value.");
        }
      }

      await _supabase
          .from('service')
          .update(updatedData)
          .eq('service_id', serviceId);
    } catch (error) {
      throw Exception("Failed to update service: $error");
    }
  }

  Future<void> updateServiceProviderService({
    required String serviceId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      // Add size validation if provided in updated data
      if (updatedData.containsKey('size')) {
        const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
        if (!allowedSizes.contains(updatedData['size'])) {
          throw Exception("Invalid size value.");
        }
      }

      await _supabase
          .from('serviceprovider_service')
          .update(updatedData)
          .eq('service_id', serviceId);
    } catch (error) {
      throw Exception("Failed to update service: $error");
    }
  }

  Future<List<dynamic>> getServiceProviderServices({
    required String serviceProviderId,
  }) async {
    final response = await _supabase
        .from('serviceprovider_service')
        .select('service_id')
        .eq('sp_id', serviceProviderId);

    final serviceIds = (response as List).map((e) => e['service_id']).toList();
    return await _supabase
        .from('service')
        .select()
        .in_('service_id', serviceIds);
  }
}
