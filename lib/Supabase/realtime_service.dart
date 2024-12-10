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

    print("Listen to real-time updates in the 'notification_appointment' view");
    // Listen to real-time updates in the 'notification_appointment' view
    _client
        .from('notification_with_appointment')
        .stream(primaryKey: ['notification_id']).listen(
      (changes) async {
        final filteredChanges = changes.where((change) =>
            change['sp_id'] == loggedInServiceProviderId &&
            change['processed'] == false);
        for (final change in filteredChanges) {
          final notificationId = change['notification_id'];
          final appointmentNotifType = change['appointment_notif_type'];
          final createdAt = DateTime.parse(change['created_at']);
          final appointmentId = change['appointment_id'];

          print('\nNotification ID: $notificationId');
          print('\nNotiftype: $appointmentNotifType');
          print('\ncreatedAt: $createdAt');

          // Process 'Pending' status for new inserts
          if (appointmentNotifType == 'Pending') {
            print("We have pending, start createnotif");
            await _createNotification(notificationId, 'Pending', appointmentId);

            // After sending the notification, mark it as processed
            await _markNotificationAsProcessed(notificationId);
          }
        }
      },
      onError: (error) {
        print('Real-time stream error: $error');
      },
    );
  }

  Future<void> _markNotificationAsProcessed(String notificationId) async {
    try {
      await _client
          .from('notification')
          .update({'processed': true}) // Set processed flag to true
          .eq('notification_id', notificationId);

      print('Notification ID $notificationId marked as processed.');
    } catch (e) {
      print('Error marking notification as processed: $e');
    }
  }

  Future<void> _createNotification(String notificationId,
      String notificationType, String appointmentId) async {
    try {
      print('Creating Notification: Fetching the appointment details first');
      final appointment = await _client
          .from('appointment')
          .select('pet_owner_id')
          .eq('appointment_id', appointmentId)
          .single();

      if (appointment == null) {
        print('Appointment details not found.');
        return;
      }

      final petOwnerDetails = await _client
          .from('pet_owner')
          .select('first_name, last_name')
          .eq('pet_owner_id', appointment['pet_owner_id'])
          .single();

      if (petOwnerDetails == null) {
        print('Pet owner details not found.');
        return;
      }

      final petOwnerFullname =
          '${petOwnerDetails['first_name']} ${petOwnerDetails['last_name']}';

      String title = '';
      String body = '';

      if (notificationType == 'Pending') {
        title = 'Pending Appointment';
        body = 'You have a pending appointment with $petOwnerFullname.';
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Notifications',
        channelDescription: 'Notifications for pending appointments',
        importance: Importance.high,
        priority: Priority.max,
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
        ),
        icon: 'pamfurred',
      );

      final NotificationDetails details =
          NotificationDetails(android: androidDetails);

      final uniqueNotificationId =
          (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();

      await flutterLocalNotificationsPlugin.show(
        uniqueNotificationId,
        title,
        body,
        details,
      );

      print('Notification sent for notification ID $notificationId');
    } catch (e) {
      print('Error creating notification: $e');
    }
  }
}
