import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to store the selected service ID
final selectedPackageIdProvider = StateProvider<String?>((ref) => null);

// Function to fetch service details
Future<List<Map<String, dynamic>>> fetchPackageDetails(String packageId) async {
  final response = await Supabase.instance.client.rpc(
    'fetch_package_details', // The name of your RPC function
    params: {'package_id_param': packageId}, // Parameter as a named argument
  );

  // Return the response as a List of Maps
  return (response as List)
      .map((item) => item as Map<String, dynamic>)
      .toList();
}

// Provider to fetch service details based on service ID
final fetchPackageDetailsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, packageId) async {
  return await fetchPackageDetails(packageId);
});
