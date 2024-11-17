import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;

  void listenToAppointments() {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }

    final loggedInServiceProviderId = currentUser
        .id; // Assumes `currentUser.id` corresponds to the service provider ID

    // Listen to new appointments in the 'appointment' table in real-time
    _client
        .from('appointment')
        .stream(primaryKey: ['appointment_id']) // Specify the primary key
        .eq('sp_id',
            loggedInServiceProviderId) // Filter for the current service provider
        .listen(
          (changes) {
            for (final change in changes) {
              // Extract the details of the new appointment from the change object
              final spId = change['sp_id'];
              final appointmentId = change['appointment_id'];
              final appointmentStatus = change['appointment_status'];

              // Check if it's a new appointment and the service provider matches
              if (spId == null || appointmentId == null) {
                continue; // Skip if no relevant data found
              }

              // Only send notifications for "Upcoming" appointments
              if (appointmentStatus == 'Upcoming') {
                print(
                    'New upcoming appointment detected for service provider: $appointmentId, $appointmentStatus');
                sendNotification(
                    change); // Trigger notification for each new appointment
              }
            }
          },
          onError: (error) {
            // Handle errors during the real-time stream
            print('Real-time stream error: $error');
          },
        );
  }

  void sendNotification(Map<String, dynamic> appointment) async {
    print(
        'Sending notification for appointment: ${appointment['appointment_id']}');

    final userId = appointment[
        'pet_owner_id']; // Foreign key pointing to the pet_owner table

    if (userId != null) {
      try {
        // Fetch the username from the pet_owner table
        final response = await Supabase.instance.client
            .from('pet_owner')
            .select('username') // Fetch username directly from pet_owner
            .eq('pet_owner_id', userId)
            .single(); // Ensures you get only one result

        // Check if the response contains data
        if (response != null && response.isNotEmpty) {
          final username = response['username'] ??
              'Unknown User'; // Access 'username' directly

          // Ensure appointment_id is an integer (if it's a string, convert it to an integer)
          final appointmentId =
              int.tryParse(appointment['appointment_id'].toString()) ??
                  0; // Default to 0 if parsing fails

          // Generate a unique notification ID using the lower 32 bits of the timestamp
          final uniqueNotificationId =
              (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

          // Notification details
          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'appointment_channel',
            'Appointment Notifications',
            channelDescription: 'Notifications for upcoming appointments',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'pamfurred',
          );

          const NotificationDetails details =
              NotificationDetails(android: androidDetails);

          // Send the notification for the new appointment with a unique ID
          await flutterLocalNotificationsPlugin.show(
            uniqueNotificationId, // Unique notification ID within the 32-bit range
            'Upcoming Appointment',
            'You have an upcoming appointment with $username.',
            details,
          );
        } else {
          // Handle case where no data was returned for the pet_owner_id
          print('No data found for pet_owner_id: $userId');
        }
      } catch (e) {
        // Handle any unexpected errors
        print('Error during notification process: $e');
      }
    } else {
      // Handle case where pet_owner_id is missing from the appointment data
      print('Error: No pet_owner_id in appointment data.');
    }
  }
}
