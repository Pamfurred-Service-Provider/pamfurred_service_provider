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
    // Validate the size value to match database constraints
    const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
    if (!allowedSizes.contains(size)) {
      throw Exception(
          "Invalid size value: $size. Allowed values are $allowedSizes");
    }

    // Insert the package and retrieve the package ID in a single operation
    final response = await _supabase
        .from('package')
        .insert({
          'package_name': packageName,
          'price': price,
          'size': size,
          'min_weight': minWeight,
          'max_weight': maxWeight,
          'pet_type': petsToCater,
          'package_type': [packageType],
          'availability_status': availability,
          'inclusions': inclusionList,
          'package_image': imageUrl,
          'package_category': [packageCategory],
        })
        .select('package_id')
        .single();

    final packageId = response['package_id'];

    // Link the package to the package provider directly
    await _supabase.from('serviceprovider_package').insert({
      'sp_id': packageProviderId,
      'package_id': packageId,
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
