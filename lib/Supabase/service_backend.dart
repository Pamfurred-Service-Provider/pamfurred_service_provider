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
    required List<String> petsToCater, // as List for JSONB
    required String serviceType, // or List/Map if complex JSON
    required bool availability, // Boolean for availability_status
    required File? image,
    required String? serviceCategory,
    required String serviceProviderId, // This should be checked
  }) async {
    print("Adding service with category: $serviceCategory");

    // Validate the size value to match database constraints
    const allowedSizes = ['S', 'M', 'L', 'XL', 'N/A'];
    if (!allowedSizes.contains(size)) {
      throw Exception(
          "Invalid size value: $size. Allowed values are $allowedSizes");
    }
    try {
      final response = await _supabase.from('service').insert({
        'service_name': serviceName,
        'price': price,
        'size': size,
        'min_weight': minWeight,
        'max_weight': maxWeight,
        'pet_type': petsToCater,
        'service_type': [serviceType],
        'availability_status': availability,
        'service_image': image != null
            ? await uploadImage(image)
            : null, // Upload image and get URL if needed
        'service_category': [serviceCategory],
      }).select('service_id'); // Selecting the service ID for retrieval

// Ensure we retrieve the inserted service ID
      final insertedService = response.first;
      final serviceId = insertedService['service_id'];

      if (serviceId == null) {
        throw Exception('Failed to retrieve inserted service ID');
      }
      // Now link the service to the service provider in the bridge table
      await addServiceProviderService(
          serviceProviderId: serviceProviderId, serviceId: serviceId);
      // Return the inserted service ID
      return serviceId; // Adjust based on your response structure
    } catch (e) {
      print('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> addServiceProviderService({
    required String serviceProviderId,
    required String serviceId,
  }) async {
    if (serviceProviderId.isEmpty || serviceId.isEmpty) {
      throw Exception('Service provider ID or service ID is null or empty');
    }

    try {
      final response = await _supabase.from('serviceprovider_service').insert({
        'sp_id': serviceProviderId,
        'service_id': serviceId,
      });

      if (response != null) {
        throw Exception(
            'Failed to add service provider service: ${response!.message}');
      }
    } catch (error) {
      throw Exception('Error adding service provider service: $error');
    }
  }

  Future<String> uploadImage(File image) async {
    try {
      final filePath = 'service_images/${image.uri.pathSegments.last}';
      final response = await _supabase.storage
          .from('service_provider_images')
          .upload(filePath, image);

      // if (response != null) {
      //   throw Exception('Failed to upload image: ${response}');
      // }

      return _supabase.storage
          .from('service_provider_images')
          .getPublicUrl(filePath);
    } catch (e) {
      print('Error uploading image: $e');
      rethrow; // Propagate error
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

      if (response != null) {
        throw Exception(
            'Failed to get service provider services: ${response.message}');
      }

      final serviceIds =
          (response as List).map((e) => e['service_id']).toList();
      final servicesResponse = await _supabase
          .from('service')
          .select('*')
          .in_('service_id', serviceIds);

      return servicesResponse; // Return the list of services
    } catch (error) {
      throw Exception('Error getting service provider services: $error');
    }
  }
}
