import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> todayAppointments = [
      {
        'date': 'January 2, 2024',
        'name': 'Bob Niño Golosinda',
        'time': '09:00 AM - 11:00 AM'
      },
      {'name': 'Lynie Rose Gaa', 'date': 'January 2, 2024', 'time': '11:00 AM'},
    ];

    final List<Map<String, String>> earlierAppointments = [
      {'name': 'Aillen Gonzaga', 'date': 'January 1, 2024', 'time': '01:00 PM'},
      {'name': 'Arny Ucab', 'date': 'December 31, 2023', 'time': '03:00 PM'},
    ];
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Today",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(160, 62, 6, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...todayAppointments
              .map((appointment) => buildAppointmentCard(appointment))
              .toList(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Earlier",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(160, 62, 6, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...earlierAppointments
              .map((appointment) => buildAppointmentCard(appointment))
        ],
      ),
    );
  }

  Widget buildAppointmentCard(Map<String, String> appointment) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['date']!,
                        // style: const TextStyle(
                        //   color: Colors.black54,
                        //   fontSize: 16,
                        // ),
                      ),
                      Text(
                        appointment['time']!,
                        // style: const TextStyle(
                        //   color: Colors.black54,
                        //   fontSize: 16,
                        // ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        appointment['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          indent: 16.0,
        ),
      ],
    );
  }
}
