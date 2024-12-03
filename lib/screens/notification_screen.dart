import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  String? serviceProviderId;
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true; // Loading state for data fetching

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final supabase = Supabase.instance.client;
    final serviceSession = supabase.auth.currentSession;

    if (serviceSession == null) {
      throw Exception("User not logged in");
    }
    final userId = serviceSession.user.id;
    print('User ID: $userId');

    // Fetch the service provider ID (sp_id) using user_id
    final spResponse = await supabase
        .from('service_provider')
        .select('sp_id')
        .eq('sp_id', userId)
        .single();

    if (spResponse == null || spResponse['sp_id'] == null) return;

    setState(() {
      serviceProviderId = spResponse['sp_id'];
    });

    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.rpc(
        'fetch_notification_details_by_sp_id',
        params: {'sp_id_param': serviceProviderId},
      );

      final fetchedNotifications = List<Map<String, dynamic>>.from(response);

      setState(() {
        notifications = fetchedNotifications;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to check if the date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Function to check if the date is yesterday
  bool isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Function to compute time elapsed since the notification was created
  String timeElapsed(DateTime notificationArrival) {
    final now = DateTime.now();
    final notificationTime = notificationArrival.toLocal(); // Ensure it's local
    final difference = now.difference(notificationTime);

    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;
    final weeks = (days / 7).floor();
    final months = (days / 30).floor();
    final years = (days / 365).floor();

    if (minutes < 1) return "Just now";
    if (minutes < 60) return "$minutes minute${minutes == 1 ? '' : 's'} ago";
    if (hours < 24) return "$hours hour${hours == 1 ? '' : 's'} ago";
    if (days < 7) return "$days day${days == 1 ? '' : 's'} ago";
    if (days < 30) return "$weeks week${weeks == 1 ? '' : 's'} ago";
    if (days < 365) return "$months month${months == 1 ? '' : 's'} ago";
    return "$years year${years == 1 ? '' : 's'} ago";
  }

  @override
  Widget build(BuildContext context) {
    // Sort the notifications by notification arrival in descending order
    notifications.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    // Separate notifications into "Today," "Yesterday," and "Older"
    List todayNotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isToday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();
    print("Rendering Today Section: ${todayNotifications.length}");
    for (var notif in todayNotifications) {
      print("Rendering Today's Notification: ${notif['notification_id']}");
    }

    List yesterdayNotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return isYesterday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();
    print("Rendering Yesterday Section: ${yesterdayNotifications.length}");
    List olderNotifications = notifications.where((notification) {
      final createdAt = notification['created_at'];
      if (createdAt != null) {
        final parsedDate = DateTime.parse(createdAt);
        return !isToday(parsedDate) && !isYesterday(parsedDate);
      }
      return false; // Return false if created_at is null
    }).toList();
    print("Rendering Older Section: ${olderNotifications.length}");
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? const Center(
                    child: Text(
                      "No notifications",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      // "Today" notifications
                      if (todayNotifications.isNotEmpty) ...[
                        _buildSectionHeader("Today"),
                        ...todayNotifications.map((notification) {
                          final index = notifications.indexOf(notification);
                          return _buildNotificationCard(index, notification);
                        }),
                      ],
                      const SizedBox(height: 16),
                      // "Yesterday" notifications
                      if (yesterdayNotifications.isNotEmpty) ...[
                        _buildSectionHeader("Yesterday"),
                        ...yesterdayNotifications.map((notification) {
                          final index = notifications.indexOf(notification);
                          return _buildNotificationCard(index, notification);
                        }),
                      ],
                      const SizedBox(height: 16),
                      // "Earlier" notifications
                      if (olderNotifications.isNotEmpty) ...[
                        _buildSectionHeader("Earlier"),
                        ...olderNotifications.map((notification) {
                          final index = notifications.indexOf(notification);
                          return _buildNotificationCard(index, notification);
                        }),
                      ],
                    ],
                  ),
      ),
    );
  }

  // Section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(160, 62, 6, 1),
        ),
      ),
    );
  }

  // Notification card widget
  Widget _buildNotificationCard(int index, Map<String, dynamic> notification) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Title
            Row(
              children: [
                if (notification['appointment_notif_type'] == 'Upcoming') ...[
                  Text(
                    notification['name'] ?? 'Appointment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (notification['appointment_notif_type'] != 'Upcoming') ...[
                  Text(
                    notification['Appointment'] ?? 'Appointment',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                Text(
                  notification['appointment_notif_type'] == "Done"
                      ? " completed"
                      : " ${notification['appointment_notif_type']}",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: primarySizedBox),
            // Notification Body
            RichText(
              text: TextSpan(
                children: [
                  // Determine the initial message based on appointment status
                  TextSpan(
                    text: (() {
                      if (notification['appointment_notif_type'] ==
                          'Upcoming') {
                        return 'You have an';
                      } else {
                        return 'Your appointment with';
                      }
                    })(),
                    style: const TextStyle(
                        fontSize: regularText, color: Colors.black),
                  ),
                  if (notification['appointment_notif_type'] == 'Upcoming') ...[
                    const TextSpan(
                      text: ' upcoming ', // Null check for 'establishment_name'
                      style:
                          TextStyle(fontSize: regularText, color: primaryColor),
                    ),
                    const TextSpan(
                      text: 'appointment with',
                      style: TextStyle(
                        fontSize: regularText,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' ${notification['pet_owner_name'] ?? "unknown"}',
                      style: const TextStyle(
                        fontSize: regularText,
                        color: primaryColor,
                      ),
                    ),
                  ],
                  if (notification['appointment_notif_type'] != 'Upcoming') ...[
                    TextSpan(
                      text: ' ${notification['pet_owner_name'] ?? "unknown"}',
                      style: const TextStyle(
                        fontSize: regularText,
                        color: primaryColor,
                      ),
                    ),
                    const TextSpan(
                      text: ' has been ',
                      style: TextStyle(
                        fontSize: regularText,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: notification['appointment_notif_type'] == 'Done'
                          ? 'completed'
                          : (notification['appointment_notif_type'] ?? ''),
                      style: const TextStyle(
                        fontSize: regularText,
                        color: primaryColor,
                      ),
                    ),
                  ],
                  const TextSpan(
                    text: ".",
                    style: TextStyle(
                      fontSize: regularText,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: primarySizedBox),

            // Time Elapsed
            Text(
              timeElapsed(
                DateTime.parse(
                  notification['created_at'] ?? DateTime.now().toString(),
                ),
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
