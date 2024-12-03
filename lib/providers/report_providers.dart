import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/providers/global_providers.dart';
import 'package:service_provider/providers/sp_details_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Updated FutureProvider to fetch revenue by date range as a List<Map<String, dynamic>>
final revenueByDateRangeProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
        (ref, params) async {
  final spId = params['spId'] ?? ref.watch(userIdProvider);
  final startDate = params['startDate'] ?? ref.watch(reportStartDateProvider);
  final endDate = params['endDate'] ?? ref.watch(reportEndDateProvider);

  // Call the Supabase RPC function to fetch the revenue data
  final response = await Supabase.instance.client.rpc(
    'fetch_revenue_by_date_range',
    params: {
      'sp_id_param': spId,
      'start_date': startDate,
      'end_date': endDate,
    },
  );

  // Log the response to check the data structure
  print("Supabase response: $response");

  // Assuming that the response data is a list of records
  return List<Map<String, dynamic>>.from(response);
});
