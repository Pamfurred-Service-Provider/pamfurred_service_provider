import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;

  // A Set to track the processed appointment IDs
  final Set<String> processedAppointmentIds = {};

  // // Constructor to call the necessary functions when the service is initialized
  // RealtimeService() {
  //   loadProcessedAppointmentIds(); // Load processed appointment IDs on initialization
  // }

  // Function to load processed appointment IDs from the 'user' table
  Future<void> loadProcessedAppointmentIds() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }
    final loggedInUserId = currentUser.id;

    final response = await _client
        .from('user') // Use the 'users' table
        .select(
            'processed_appointment_ids') // Column storing processed appointment IDs
        .eq('user_id', loggedInUserId) // Fetch for the current user
        .single();
    print(response);

    if (response != null) {
      final ids = response['processed_appointment_ids'] as List<dynamic>;
      processedAppointmentIds.addAll(ids.cast<String>());
      print('Loaded processed appointment IDs: $processedAppointmentIds');
    }
  }

  // Function to save processed appointment IDs to the 'user' table
  Future<void> saveProcessedAppointmentIds() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }
    final loggedInUserId = currentUser.id;

    final response = await _client
        .from('user') // Use the 'users' table
        .update({
      'processed_appointment_ids': processedAppointmentIds.toList(),
    }).eq('user_id', loggedInUserId); // Use user_id for the specific user

    if (response != null) {
      print('Processed appointment IDs: ${response}');
    }
  }

  // Listen to new appointments in the 'appointment' table in real-time
  void listenToAppointments() {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }

    final loggedInServiceProviderId = currentUser
        .id; // Assumes `currentUser.id` corresponds to the service provider ID

    _client
        .from('appointment')
        .stream(primaryKey: ['appointment_id']) // Specify the primary key
        .eq('sp_id',
            loggedInServiceProviderId) // Filter for the current service provider
        .listen(
          (changes) async {
            for (final change in changes) {
              // Extract the details of the new appointment from the change object
              final spId = change['sp_id'];
              final appointmentId = change['appointment_id'];
              final appointmentStatus = change['appointment_status'];

              // Check if it's a valid appointment for the logged-in service provider
              if (spId != loggedInServiceProviderId || appointmentId == null) {
                continue; // Skip if the service provider doesn't match or appointment ID is invalid
              }

              // Check if it's an insert (appointment_id is new)
              if (!processedAppointmentIds.contains(appointmentId)) {
                // Only send notifications for "Upcoming" appointments
                if (appointmentStatus == 'Upcoming') {
                  print(
                      'New upcoming appointment detected for service provider: $appointmentId, $appointmentStatus');
                  processedAppointmentIds
                      .add(appointmentId); // Mark this appointment as processed
                  await saveProcessedAppointmentIds(); // Save the updated set to the database
                  sendNotification(
                      change); // Send notification for the new appointment
                }
              } else {
                // Handle updates here
                print(
                    'Appointment update detected for appointment: $appointmentId, $appointmentStatus');
              }
            }
          },
          onError: (error) {
            print('Real-time stream error: $error');
          },
        );
  }

  // Create a set to track sent notification IDs
  final Set<String> sentNotificationIds = {};

  Future<void> sendNotification(Map<String, dynamic> appointment) async {
    print(
        'Preparing to send notification for appointment: ${appointment['appointment_id']}');

    final userId = appointment[
        'pet_owner_id']; // Foreign key pointing to the pet_owner table
    final appointmentId = appointment['appointment_id'];

    if (userId != null && appointmentId != null) {
      try {
        // Check if the notification for this appointment ID has already been sent
        if (sentNotificationIds.contains(appointmentId)) {
          print(
              'Notification for appointment ID $appointmentId already sent. Skipping...');
          return; // Skip sending the notification if it's already been sent
        }

        // Fetch the username from the pet_owner table
        final response = await Supabase.instance.client
            .from('pet_owner')
            .select('username') // Fetch username directly from pet_owner
            .eq('pet_owner_id', userId)
            .single(); // Ensures you get only one result

        if (response != null) {
          final username = response['username'] ??
              'Unknown User'; // Access 'username' directly

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

          // Generate a unique notification ID using the lower 32 bits of the timestamp
          final uniqueNotificationId =
              (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

          const NotificationDetails details =
              NotificationDetails(android: androidDetails);

          // Send the notification for the new appointment with a unique ID
          await flutterLocalNotificationsPlugin.show(
            uniqueNotificationId, // Unique notification ID within the 32-bit range
            'Upcoming Appointment',
            'You have an upcoming appointment with $username.',
            details,
          );

          // After sending the notification, mark it as sent by adding the appointment ID to the set
          sentNotificationIds.add(appointmentId);

          // Save sent notification IDs to the 'user' table
          await saveSentNotificationIds();

          print('Notification sent for appointment ID $appointmentId');
        } else {
          print('No data found for pet_owner_id: $userId');
        }
      } catch (e) {
        print('Error during notification process: $e');
      }
    } else {
      print(
          'Error: Missing pet_owner_id or appointment_id in appointment data.');
    }
  }

  // Function to save sent notification IDs to the 'user' table
  Future<void> saveSentNotificationIds() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }
    final loggedInUserId = currentUser.id;

    final response = await _client
        .from('user') // Use the 'users' table
        .update({
      'sent_notification_ids': sentNotificationIds.toList(),
    }).eq('user_id', loggedInUserId); // Use user_id for the specific user

    if (response.error != null) {
      print('Sent notification IDs saved successfully: ${response}');
    } else {
      print('Sent notification IDs saved successfully.');
    }
  }
}
