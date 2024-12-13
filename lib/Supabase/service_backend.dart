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
    required List<String?> size,
    required List<int> minWeight,
    required List<int> maxWeight,
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
      if (size.length != prices.length ||
          size.length != minWeight.length ||
          size.length != maxWeight.length ||
          size.length != availabilityStatus.length) {
        throw Exception('All input lists must have the same length.');
      }

      // Prepare a list to hold the data for bulk insertion
      final List<Map<String, dynamic>> insertData = [];

      // Loop through the sizes and create a separate map for each size
      for (int i = 0; i < size.length; i++) {
        insertData.add({
          'sp_id': serviceProviderId,
          'service_id': serviceId,
          'availability_status':
              availabilityStatus[i], // This should be a valid string
          'size': size[i], // Assume sizes[i] is guaranteed to be non-null
          'price': prices[i], // Corresponding price (int)
          'min_weight': minWeight[i], // Corresponding minimum weight (int)
          'max_weight': maxWeight[i], // Corresponding maximum weight (int)
        });
      }

      // Perform the bulk insert
      await _supabase.from('serviceprovider_service').insert(insertData);
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

  Future<List<Map<String, String>>> fetchServiceNamesWithCategories() async {
    final response = await _supabase
        .from('distinct_services')
        .select('service_name, category_name');
    print("Services list: $response");

    // Extract both 'service_name' and 'category_name'
    final services = (response as List)
        .map((service) => {
              'service_name': service['service_name'] as String,
              'category_name': service['category_name'] as String,
            })
        .toList();

    return services;
  }

  // UPDATE

  Future<String?> fetchPublicUrlByServiceId(String serviceId) async {
    final response = await _supabase
            .from('service')
            .select('service_image')
            .eq('service_id', serviceId)
            .single() // Expecting a single record
        ;

    if (response == null) {
      // The service_image in the database is the public URL
      return response['service_image'];
    }
    return null;
  }

  Future<String?> updateServiceImageById(
      String serviceId, File newImage) async {
    // Fetch the current public URL using the service ID
    String? existingPublicUrl = await fetchPublicUrlByServiceId(serviceId);

    if (existingPublicUrl == null) {
      print('No existing image found for serviceId: $serviceId');
      return null; // Handle case where no existing image is found
    }

    // Construct the file path from the public URL
    final uri = Uri.parse(existingPublicUrl);
    final pathSegments = uri.pathSegments;

    // Extract the file path
    final filePath =
        '${pathSegments[pathSegments.length - 2]}/${pathSegments.last}'; // e.g., service_images/filename

    final storageBucket = _supabase.storage.from('service_provider_images');

    // Delete the existing image using the extracted file path
    await storageBucket.remove([filePath]);

    // Create a new file path for the new image
    final newFilePath = 'service_images/${newImage.uri.pathSegments.last}';

    // Upload the new image
    await storageBucket.upload(newFilePath, newImage);

    // Update the service record with the new public URL in the database
    await _supabase.from('service').update({
      'service_image':
          storageBucket.getPublicUrl(newFilePath), // Update with new public URL
    }).eq('service_id', serviceId); // Update the specific service record by ID

    // Return the new public URL
    return storageBucket.getPublicUrl(newFilePath);
  }

  Future<void> updateService({
    required String serviceProviderId,
    required String? serviceId,
    required String serviceName,
    required String serviceDesc,
    required List<String> petsToCater,
    required List<String> serviceType,
    required Map<String, String> availability,
    required String? imageUrl,
    String? serviceCategory,
    required List<int> prices,
    required List<String?> size,
    required List<int> minWeight,
    required List<int> maxWeight,
  }) async {
    // Fetch service package category details that match the serviceCategory
    final servicePackageCategory = serviceCategory != null
        ? await _supabase
            .from('service_package_category')
            .select('service_package_category_id, category_name')
            .eq('category_name',
                serviceCategory) // Ensure we fetch the correct category
            .single()
        : null;

    // Check if a category was found if serviceCategory is provided
    if (serviceCategory != null && servicePackageCategory == null) {
      throw Exception('Service category not found: $serviceCategory');
    }

    // Extract the fetched category ID if available
    final toBeUpdatedCategoryId = servicePackageCategory != null
        ? servicePackageCategory['service_package_category_id']
        : null;

    print("to be updated category id: $toBeUpdatedCategoryId");

    // Update the service details in the 'service' table
    await _supabase.from('service').update({
      if (toBeUpdatedCategoryId != null)
        'service_package_category_id':
            toBeUpdatedCategoryId, // Include the category ID
      'service_name': serviceName,
      'service_desc': serviceDesc,
      'service_type': serviceType, // Pass list directly
      'pet_type': petsToCater,
      'service_image': imageUrl,
    }).eq('service_id', serviceId);

    // Update availability and size-related data in the 'serviceprovider_service' table
    List<String> allSizes = availability.keys.toList();

    final List<String> availabilityStatus = allSizes.map((size) {
      // Get the availability status for each size
      return availability[size] ??
          'Unknown'; // Default to 'Unknown' if the size is not in the map
    }).toList();

    // Check if all lists have the same length
    if (size.length != prices.length ||
        size.length != minWeight.length ||
        size.length != maxWeight.length ||
        size.length != availabilityStatus.length) {
      throw Exception('All input lists must have the same length.');
    }

    // Prepare a list to hold the data for bulk update
    final List<Map<String, dynamic>> updateData = [];

    // Loop through the sizes and create a separate map for each size
    for (int i = 0; i < size.length; i++) {
      updateData.add({
        'availability_status': availabilityStatus[i],
        'size': size[i],
        'price': prices[i],
        'min_weight': minWeight[i],
        'max_weight': maxWeight[i],
      });
    }

    // Update the data in the 'serviceprovider_service' table
    for (int i = 0; i < updateData.length; i++) {
      await _supabase
          .from('serviceprovider_service')
          .update(updateData[i])
          .eq('service_id', serviceId)
          .eq('size', size[i]);
    }
  }

  Future<void> updateServiceProviderService({
    required String serviceId,
    required String serviceName,
    required String size,
    required int minWeight,
    required int maxWeight,
    required List<String> petsToCater,
    required String selectedServiceType,
    required bool availability,
    required String? imageUrl,
    String? serviceCategory,
  }) async {
    // Validate the size value to match database constraints
    const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
    if (!allowedSizes.contains(size)) {
      throw Exception(
          "Invalid size value: $size. Allowed values are $allowedSizes");
    }

    // Fetch the category ID if a category is provided
    String? categoryId;
    if (serviceCategory != null) {
      final categoryResponse = await _supabase
          .from('service_package_category')
          .select('service_package_category_id')
          .eq('category_name', serviceCategory)
          .single();

      categoryId = categoryResponse['service_package_category_id'];
    }

    // Update the service details in the 'service' table
    await _supabase.from('service').update({
      'service_name': serviceName,
      'size': size,
      'min_weight': minWeight,
      'max_weight': maxWeight,
      'pet_type': petsToCater,
      'service_type': [selectedServiceType],
      'availability_status': availability,
      'service_image': imageUrl,
      if (categoryId != null) 'service_package_category_id': categoryId,
    }).eq('service_id', serviceId);
  }
}
