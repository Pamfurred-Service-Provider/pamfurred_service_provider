import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackageBackend {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> addPackage({
    required String packageName,
    required int price,
    required String size,
    required int minWeight,
    required int maxWeight,
    required List<String> petsToCater,
    required List<String> inclusionList,
    required String packageType,
    required bool availability,
    required String? imageUrl,
    required String? packageCategory,
    required String packageProviderId,
  }) async {
    // Log all inputs

    print('--- Package Data to be Inserted ---');
    print('Package Name: $packageName');
    print('Price: $price');
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

    // Validate the size value to match database constraints
    const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
    if (!allowedSizes.contains(size)) {
      throw Exception(
          "Invalid size value: $size. Allowed values are $allowedSizes");
    }
    final servicePackageCategory = await _supabase
        .from('service_package_category')
        .select('service_package_category_id, category_name')
        // .contains('category_name', packageCategory)
        .ilike('category_name', '%${packageCategory}%')

        // .eq('category_name', packageCategory)
        .maybeSingle();

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
          'pet_type': petsToCater,
          'package_type': packageType,
          'inclusion': inclusionList,
          'package_image': imageUrl,
          'service_package_category_id': servicePackageCategoryId,
        })
        .select('package_id')
        .single();

    final packageId = response['package_id'];

    // Link the package to the package provider directly
    await _supabase.from('serviceprovider_package').insert({
      'sp_id': packageProviderId,
      'package_id': packageId,
      // 'serviceprovider_package_id': packageId,
      'availability_status': availability,
      'price': price,
      'size': size,
      'min_weight': minWeight,
      'max_weight': maxWeight,
    });

    return packageId; // Return as a Map
  }

  Future<String> uploadImage(File image) async {
    final filePath = 'package_images/${image.uri.pathSegments.last}';
    final response = await _supabase.storage
        .from('service_provider_images')
        .upload(filePath, image);
// If the upload is successful, get the public URL
    final publicUrl = _supabase.storage
        .from('service_provider_images')
        .getPublicUrl(filePath);
    print("Generated public URL: $publicUrl"); // Add this line
    return publicUrl;
  }

  Future<List<String>> fetchServiceName() async {
    final response = await _supabase.from('service').select('service_name');
    print("Services list: $response");

    // Extract only the 'service_name' values
    final services = (response as List)
        .map((service) => service['service_name'] as String)
        .toList();

    return services;
  }
  //   return _supabase.storage
  //       .from('package_provider_images')
  //       .getPublicUrl(filePath);
  // }

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
