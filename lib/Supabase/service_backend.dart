import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceBackend {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Service Provider methods
  Future<void> addServiceProvider({
    required String sp_id,
    required String name,
    // Add other service provider fields
  }) async {
    // ...
  }
  Future<int> addService({
    required String serviceName,
    required double price,
    required String size,
    required String minWeight,
    required String maxWeight,
    required List<String> petsToCater, // as List  for JSONB
    required String serviceType, // or List/Map if complex JSON
    required bool availability, // Boolean for availability_status
    required File? image,
  }) async {
    try {
      final response = await _supabase.from('service').insert({
        'service_name': serviceName,
        'price': price,
        'size': size,
        'min_weight': minWeight,
        'max_weight': maxWeight,
        'pets_to_cater': petsToCater,
        'pet_type': serviceType,
        'availability_status': availability,
        'service_image': image != null
            ? await uploadImage(image)
            : null, // Upload image and get URL if needed
      });
      if (response.error != null) {
        throw Exception('Failed to add service: ${response.error!.message}');
      }

      // Assuming the response contains the inserted service ID
      return response.data[0]
          ['service_id']; // Adjust this based on your response structure
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(File image) async {
    final filePath = 'service_images/${image.uri.pathSegments.last}';
    final response = await _supabase.storage
        .from('service_provider_images')
        .upload(filePath, image);

    final imageUrl = _supabase.storage
        .from('service_provider_images')
        .getPublicUrl(filePath);
    return imageUrl; // Return the public URL of the uploaded image
  }

  // Service Provider Service methods (bridge table)
  Future<void> addServiceProviderService({
    required String serviceProviderId,
    required String serviceId,
  }) async {
    try {
      final response = await _supabase.from('serviceprovider_service').insert({
        'sp_id': serviceProviderId,
        'service_id': serviceId,
      });
      if (response.error != null) {
        throw Exception(
            'Failed to add service provider service: ${response.error?.message}');
      }
    } catch (error) {
      throw Exception('Error adding service provider service');
    }
  }

  Future<List<dynamic>> getServiceProviderServices({
    required String serviceProviderId,
  }) async {
    try {
      final response = await _supabase
          .from('serviceprovider_service')
          .select('service_id')
          .eq('sp_id', serviceProviderId);
      if (response.error != null) {
        throw Exception(
            'Failed to get service provider services: ${response.error?.message}');
      }
      final serviceIds =
          (response.data as List).map((e) => e['service_id']).toList();
      final servicesResponse = await _supabase
          .from('service')
          .select('*')
          .in_('service_id', serviceIds);

      return servicesResponse.data; // Return the list of services
    } catch (error) {
      throw Exception('Error getting service provider services');
    }
  }
}
