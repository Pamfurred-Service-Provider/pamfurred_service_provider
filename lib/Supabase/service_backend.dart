import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceBackend {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> addService({
    required String serviceName,
    required int price,
    required String size,
    required int minWeight,
    required int maxWeight,
    required List<String> petsToCater,
    required String serviceType,
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
          'price': price,
          'size': size,
          'min_weight': minWeight,
          'max_weight': maxWeight,
          'pet_type': petsToCater,
          'service_type': [serviceType],
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
    final response = await _supabase.storage
        .from('service_provider_images')
        .upload(filePath, image);

    // Check if the upload was successful
    if (response == null) {
      print("Image upload error");
      throw Exception('Image upload failed');
    }
// If the upload is successful, get the public URL
    final publicUrl = _supabase.storage
        .from('service_provider_images')
        .getPublicUrl(filePath);
    print("Generated public URL: $publicUrl");
    return publicUrl;
  }

  //   return _supabase.storage
  //       .from('service_provider_images')
  //       .getPublicUrl(filePath);
  // }

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
