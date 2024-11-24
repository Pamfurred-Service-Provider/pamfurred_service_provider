import 'package:intl/intl.dart';

String formatTime(String timeString) {
  try {
    // Ensure the timeString is not null or empty
    if (timeString.isEmpty) {
      return "Not available"; // Return a default message if time is empty
    }

    // Split the string by colon (:) to extract hours, minutes, and optionally seconds
    final timeParts = timeString.split(':');

    // Ensure there are either two or three parts: hour, minute, and optional second
    if (timeParts.length != 2 && timeParts.length != 3) {
      return "Invalid time format"; // Handle invalid format
    }

    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Default second to 0 if not present
    final second = timeParts.length == 3 ? int.parse(timeParts[2]) : 0;

    // Ensure the hour, minute, and second are within valid ranges
    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59 ||
        second < 0 ||
        second > 59) {
      return "Invalid time"; // Handle out-of-range values
    }

    // Create a DateTime object (using a default date since we only care about time)
    final dateTime = DateTime(0, 1, 1, hour, minute, second);

    // Format it to a readable string (e.g., "8:30 AM" or "5:45 PM")
    return DateFormat.jm()
        .format(dateTime); // "j" for hour (1-12), "a" for AM/PM
  } catch (e) {
    print("Error formatting time: $e");
    return "Invalid time format"; // Handle any parsing or formatting errors
  }
}

String formatDate(String date) {
  final DateFormat inputFormat = DateFormat('MM/dd/yyyy');
  DateTime parsedDate;
  try {
    parsedDate = inputFormat.parse(date);
  } catch (e) {
    return 'Invalid Date';
  }

  final DateFormat outputFormat = DateFormat('MMMM d, yyyy');
  return outputFormat.format(parsedDate); // Format to "Month Day, Year"
}

String secondaryFormatDate(String date) {
  // Parse the input date string (yyyy-mm-dd) to a DateTime object
  DateTime parsedDate = DateTime.parse(date);

  // Format it to "Month day, year" (e.g., November 2, 2003)
  String formattedDate = DateFormat('MMMM d, yyyy').format(parsedDate);

  return formattedDate;
}

String formatDateToShort(String date) {
  // Parse the input date string (yyyy-mm-dd) to a DateTime object
  DateTime parsedDate = DateTime.parse(date);

  // Format it to "MM/dd/yyyy"
  String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);

  return formattedDate;
}
