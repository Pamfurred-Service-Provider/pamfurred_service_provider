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

  // UPDATE

  Future<String?> updatePackage({
    required String?
        packageId, // Added packageId parameter for the package to be updated
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
    print('--- Package Data to be Updated ---');
    print('Package ID: $packageId');
    // Logging other inputs omitted for brevity
    print('-----------------------------------');

    // Fetch the service package category ID
    final servicePackageCategory = await _supabase
        .from('service_package_category')
        .select('service_package_category_id')
        .eq('category_name', packageCategory)
        .single();

    if (servicePackageCategory == null) {
      throw Exception(
          "Service package category not found for category: $packageCategory");
    }

    final servicePackageCategoryId =
        servicePackageCategory['service_package_category_id'];

    // Update the package
    await _supabase.from('package').update({
      'package_name': packageName,
      'package_desc': packageDesc,
      'pet_type': petsToCater,
      'package_type': packageType,
      'inclusions': inclusionList,
      'package_image': imageUrl,
      'service_package_category_id': servicePackageCategoryId,
    }).eq('package_id', packageId);

    // Fetch current availability status for sizes
    List<String> allSizes = availability.keys.toList();
    final List<String> availabilityStatus = allSizes.map((size) {
      return availability[size] ?? 'Unavailable';
    }).toList();

    try {
      if (size.length != prices.length ||
          size.length != minWeight.length ||
          size.length != maxWeight.length ||
          size.length != availabilityStatus.length) {
        throw Exception('All input lists must have the same length.');
      }

      // Loop through sizes to perform updates
      for (int i = 0; i < size.length; i++) {
        await _supabase
            .from('serviceprovider_package')
            .update({
              'availability_status': availabilityStatus[i],
              'size': size[i],
              'price': prices[i],
              'min_weight': minWeight[i],
              'max_weight': maxWeight[i],
            })
            .eq('package_id', packageId)
            .eq('sp_id', packageProviderId)
            .eq('size', size[i]); // Ensure the size matches for the update
      }
    } catch (e) {
      print('Error occurred during update: $e');
    }

    return packageId;
  }

  Future<String?> fetchPublicUrlByPackageId(String packageId) async {
    final response = await _supabase
            .from('package')
            .select('package_image')
            .eq('package_id', packageId)
            .single() // Expecting a single record
        ;

    if (response == null) {
      // The package_image in the database is the public URL
      return response['package_image'];
    }
    return null;
  }

  Future<String?> updatePackageImageById(
      String packageId, File newImage) async {
    // Fetch the current public URL using the package ID
    String? existingPublicUrl = await fetchPublicUrlByPackageId(packageId);

    if (existingPublicUrl == null) {
      print('No existing image found for packageId: $packageId');
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
    final newFilePath = 'package_images/${newImage.uri.pathSegments.last}';

    // Upload the new image
    await storageBucket.upload(newFilePath, newImage);

    // Update the package record with the new public URL in the database
    await _supabase.from('package').update({
      'package_image':
          storageBucket.getPublicUrl(newFilePath), // Update with new public URL
    }).eq('package_id', packageId); // Update the specific package record by ID

    // Return the new public URL
    return storageBucket.getPublicUrl(newFilePath);
  }

  Future<String?> UpdateServiceProviderPackage({
    String? packageId, // Optional packageId for updating
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

    if (packageId != null) {
      // Update the existing package in the `package` table
      await _supabase.from('package').update({
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
      }).eq('package_id', packageId);

      // Update the related record in the `serviceprovider_package` table
      await _supabase
          .from('serviceprovider_package')
          .update({
            'availability_status': availability ? 'Available' : 'Unavailable',
            'size': size,
            'min_weight': minWeight,
            'max_weight': maxWeight,
          })
          .eq('package_id', packageId)
          .eq('sp_id', serviceProviderId);

      return packageId; // Return the updated packageId
    } else {
      // If no packageId is provided, throw an error (since no insert is allowed)
      throw Exception('packageId is required for updating.');
    }
  }
}
