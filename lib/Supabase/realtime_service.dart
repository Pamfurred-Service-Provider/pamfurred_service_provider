import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;

  void listenToAppointments() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      print('No logged-in user.');
      return;
    }

    final loggedInServiceProviderId = currentUser.id;

    // Listen to real-time updates in the 'appointment' table
    _client
        .from('appointment')
        .stream(primaryKey: ['appointment_id'])
        .eq('sp_id', loggedInServiceProviderId)
        .listen(
          (changes) async {
            for (final change in changes) {
              final appointmentId = change['appointment_id'];
              final appointmentStatus = change['appointment_status'];

              if (appointmentId == null) continue;

              // Process 'Upcoming' status
              if (appointmentStatus == 'Upcoming') {
                await _createNotification(appointmentId, 'Upcoming');
              }
            }
          },
          onError: (error) {
            print('Real-time stream error: $error');
          },
        );
  }

  Future<void> _createNotification(
      String appointmentId, String notificationType) async {
    try {
      // Check if a notification already exists for this appointment and type
      await _client
          .from('notification')
          .select('notification_id')
          .eq('appointment_id', appointmentId)
          .eq('appointment_notif_type',
              notificationType) // Corrected column name
          .maybeSingle();

      // Create a new notification in the 'notification' table
      await _client.from('notification').insert({
        'appointment_id': appointmentId,
        'appointment_notif_type': notificationType, // Corrected column name
        'created_at': DateTime.now().toIso8601String(),
      });

      // Fetch the appointment details first
      final appointment = await _client
          .from('appointment')
          .select('pet_owner_id')
          .eq('appointment_id',
              appointmentId) // Use the correct appointmentId to filter
          .single();

      if (appointment == null) {
        print('Appointment details not found.');
        return;
      }

      // Fetch related pet owner details using pet_owner_id to query the 'user' table
      final petOwnerDetails = await _client
          .from('user') // Assuming the table is called 'user'
          .select('first_name, last_name')
          .eq(
              'user_id',
              appointment[
                  'pet_owner_id']) // Match the pet_owner_id with user_id
          .single(); // Ensures only one row is returned

      if (petOwnerDetails == null) {
        print('Pet owner details not found.');
        return;
      }

      final petOwnerFullname =
          petOwnerDetails['first_name'] + ' ' + petOwnerDetails['last_name'] ??
              'Unknown User';

      // Prepare notification content
      String title = '';
      String body = '';

      if (notificationType == 'Upcoming') {
        title = 'Upcoming Appointment';
        body = 'You have an upcoming appointment with $petOwnerFullname.';
      }

      // Display the notification
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        channelDescription: 'Notifications for upcoming appointments',
        importance: Importance.high,
        priority: Priority.max,
        icon: 'pamfurred',
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      final uniqueNotificationId =
          (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

      await flutterLocalNotificationsPlugin.show(
        uniqueNotificationId,
        title,
        body,
        details,
      );

      print('Notification sent for appointment ID $appointmentId');
    } catch (e) {
      print('Skipped because it exist');
    }
  }
}
