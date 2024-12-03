// StateProvider to hold the current user ID
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Access user session from Supabase instance
final userSession = Supabase.instance.client.auth.currentSession;

// Get the user ID from the user session
final userId = userSession!.user.id;

// StateProvider to hold the user ID
final userIdProvider = StateProvider<String>((ref) => userId);

// FutureProvider to fetch service provider details
final serviceProviderProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = ref.watch(userIdProvider);

  // Pass the user ID as a named parameter in a map
  final response = await Supabase.instance.client
      .rpc('fetch_service_provider_details', params: {
    'sp_id_param': userId
  } // Pass the user ID in a map with the correct key
          );

  // Return the result as a map
  return response[0];
});
