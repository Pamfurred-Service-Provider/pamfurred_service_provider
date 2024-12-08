import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackageBackend {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> addPackage({
    required String packageName,
    required String packageDesc,
    required List<int> prices,
    required List<String?> size,
    required List<int> minWeight,
    required List<int> maxWeight,
    required List<String> petsToCater,
    required List<String> inclusionList,
    required List<String> packageType,
    required Map<String, String> availability,
    required String? imageUrl,
    required String? packageCategory,
    required String packageProviderId,
  }) async {
    // Log all inputs

    print('--- Package Data to be Inserted ---');
    print('Package Name: $packageName');
    print('Price: $prices');
    print('Size: $size');
    print('Min Weight: $minWeight');
    print('Max Weight: $maxWeight');
    print('Pets to Cater: $petsToCater');
    print('Inclusions: $inclusionList');
    print('Package Type: $packageType');
    print('Availability: $availability');
    print('Image URL: $imageUrl');
    print('Package Category: $packageCategory');
    print('Package Provider ID: $packageProviderId');
    print('-----------------------------------');

    print('Inserting package: $packageName');

    final servicePackageCategory = await _supabase
        .from('service_package_category')
        .select('service_package_category_id, category_name')
        .eq('category_name', packageCategory)
        .single();

    if (servicePackageCategory == null) {
      throw Exception(
          "Service package category not found for category: $packageCategory");
    }

    final servicePackageCategoryId =
        servicePackageCategory['service_package_category_id'];
    // Insert the package and retrieve the package ID in a single operation
    final response = await _supabase
        .from('package')
        .insert({
          'package_name': packageName,
          'package_desc': packageDesc,
          'pet_type': petsToCater,
          'package_type': packageType,
          'inclusions': inclusionList,
          'package_image': imageUrl,
          'service_package_category_id': servicePackageCategoryId,
        })
        .select('package_id')
        .single();

    final packageId = response['package_id'];
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
      // Loop through the size and create a separate map for each size
      for (int i = 0; i < size.length; i++) {
        insertData.add({
          'sp_id': packageProviderId,
          'package_id': packageId,
          'availability_status':
              availabilityStatus[i], // This should be a valid string
          'size': size[i], // Assume size[i] is guaranteed to be non-null
          'price': prices[i], // Corresponding price (int)
          'min_weight': minWeight[i], // Corresponding minimum weight (int)
          'max_weight': maxWeight[i], // Corresponding maximum weight (int)
        });
      }

      await _supabase.from('serviceprovider_package').insert(insertData);
    } catch (e) {
      print('Error occurred: $e'); // Log the error
      // Optionally, show an error dialog or a snackbar to the user
    }

    return packageId;
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

  Future<String?> addServiceProviderPackage({
    required List<String> packageName,
    required String size,
    required int minWeight,
    required int maxWeight,
    required List<String> petsToCater,
    required List<String> inclusionList,
    required String selectedPackageType,
    required bool availability,
    required String? imageUrl,
    required String? packageCategory,
    required String serviceProviderId,
  }) async {
// Validate the size value to match database constraints
    const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
    if (!allowedSizes.contains(size)) {
      throw Exception(
          "Invalid size value: $size. Allowed values are $allowedSizes");
    }
    final response = await _supabase
        .from('package')
        .insert({
          'package_name': packageName,
          'size': size,
          'min_weight': minWeight,
          'max_weight': maxWeight,
          'pet_type': petsToCater,
          'package_type': [selectedPackageType],
          'availability_status': availability,
          'package_image': imageUrl,
          'inclusions': inclusionList,
          'package_category': [packageCategory],
        })
        .select('package_id')
        .single();

    final packageId = response['package_id'];
    // Link the package to the package provider directly
    await _supabase.from('serviceprovider_package').insert({
      'sp_id': serviceProviderId,
      'package_id': packageId,
    });

    return packageId; // Return as a Map
  }

  Future<String> uploadImage(File image) async {
    final filePath = 'package_images/${image.uri.pathSegments.last}';
    await _supabase.storage
        .from('service_provider_images')
        .upload(filePath, image);
// If the upload is successful, get the public URL
    final publicUrl = _supabase.storage
        .from('service_provider_images')
        .getPublicUrl(filePath);
    return publicUrl;
  }

  Future<List<dynamic>> getpackageProviderpackages({
    required String packageProviderId,
  }) async {
    final response = await _supabase
        .from('serviceprovider_package')
        .select('package_id')
        .eq('sp_id', packageProviderId);

    final packageIds = (response as List).map((e) => e['package_id']).toList();
    return await _supabase
        .from('package')
        .select()
        .in_('package_id', packageIds);
  }
}
