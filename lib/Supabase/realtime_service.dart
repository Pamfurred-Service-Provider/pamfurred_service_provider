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
              final spId = change['sp_id'];
              final appointmentId = change['appointment_id'];
              final appointmentStatus = change['appointment_status'];

              if (spId != loggedInServiceProviderId || appointmentId == null) {
                continue;
              }

              // Process only 'Upcoming' status
              if (appointmentStatus == 'Upcoming') {
                sendNotification(change);
              }
            }
          },
          onError: (error) {
            print('Real-time stream error: $error');
          },
        );
  }

  void sendNotification(Map<String, dynamic> appointment) async {
    final appointmentId = appointment['appointment_id'];
    final userId = appointment['pet_owner_id'];

    if (userId != null && appointmentId != null) {
      // Check if a notification already exists for this appointment
      final existingNotification = await _client
          .from('notification')
          .select('notification_id')
          .eq('appointment_id', appointmentId)
          .maybeSingle();

      if (existingNotification != null) {
        print('Notification already exists for appointment ID $appointmentId');
        return;
      }

      try {
        final response = await Supabase.instance.client
            .from('pet_owner')
            .select('username')
            .eq('pet_owner_id', userId)
            .single();

        if (response != null && response.isNotEmpty) {
          final username = response['username'] ?? 'Unknown User';

          // Create the notification in the 'notification' table
          await _client.from('notification').insert({
            'appointment_id': appointmentId,
            'appointment_notif_type': 'Upcoming', // Assuming notification type
            'created_at': DateTime.now().toIso8601String(),
          });

          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'appointment_channel',
            'Appointment Notifications',
            channelDescription: 'Notifications for upcoming appointments',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'pamfurred',
          );

          final uniqueNotificationId =
              (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

          const NotificationDetails details =
              NotificationDetails(android: androidDetails);

          await flutterLocalNotificationsPlugin.show(
            uniqueNotificationId,
            'Upcoming Appointment',
            'You have an upcoming appointment with $username.',
            details,
          );

          print('Notification sent for appointment ID $appointmentId');
        }
      } catch (e) {
        print('Error sending notification: $e');
      }
    }
  }
}
