import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to store the selected service ID
final selectedServiceServiceIdProvider = StateProvider<String?>((ref) => null);

// Function to fetch service details
Future<List<Map<String, dynamic>>> fetchServiceDetails(String serviceId) async {
  final response = await Supabase.instance.client.rpc(
    'fetch_service_details', // The name of your RPC function
    params: {'service_id_param': serviceId}, // Parameter as a named argument
  );

  // Return the response as a List of Maps
  return (response as List)
      .map((item) => item as Map<String, dynamic>)
      .toList();
}

// Provider to fetch service details based on service ID
final fetchServiceDetailsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, serviceId) async {
  return await fetchServiceDetails(serviceId);
});
