import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Start and end date for the report generation
final reportStartDateProvider = StateProvider<String>((ref) {
  // Default to today's date in yyyy-MM-dd format
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
});

final reportEndDateProvider = StateProvider<String>((ref) {
  // Default to one month after today's date in yyyy-MM-dd format
  return DateFormat('yyyy-MM-dd')
      .format(DateTime.now().add(Duration(days: 30)));
});
