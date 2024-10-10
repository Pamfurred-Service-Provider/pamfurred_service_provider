import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointment_details.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  final List<Map<String, dynamic>> todayAppointments = [
    {
      'id': '1445547gg5fg1',
      'date': 'January 2, 2024',
      'name': 'Bob Niño Golosinda',
      'time': '09:00 AM - 11:00 AM',
      'status': 'Pending',
      'phone': '09945876258',
      'category': 'Dog',
      'type': 'Pet Salon',
      'total': '350.00',
      'services': [
        {'service': 'Nail Clipping', 'price': '100.00'},
        {'service': 'Haircut', 'price': '250.00'},
      ],
    },
    {
      'id': '1445547gg5fg1',
      'name': 'Lynie Rose Gaa',
      'date': 'January 2, 2024',
      'time': '11:00 AM - 01:00 PM',
      'status': 'Upcoming',
      'phone': '09945876258',
      'category': 'Dog',
      'type': 'Pet Salon',
      'total': '350.00',
      'services': [
        {'service': 'Nail Clipping', 'price': '100.00'},
        {'service': 'Haircut', 'price': '250.00'},
      ],
    },
    {
      'name': 'Aillen Gonzaga',
      'date': 'January 2, 2024',
      'time': '01:00 PM - 03:00 PM',
      'status': 'Upcoming',
    },
    {
      'name': 'Arny A Ucab',
      'date': 'January 2, 2024',
      'time': '03:00 PM - 05:00 PM',
      'status': 'Upcoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Appointments"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: const TabBar(
            isScrollable: false,
            labelPadding: EdgeInsets.symmetric(horizontal: 5.0),
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Upcoming'),
              Tab(text: 'All'),
              Tab(text: 'Done'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: List.generate(5, (_) => _buildAppointmentsTab()),
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: todayAppointments.length,
      itemBuilder: (context, index) {
        return buildAppointmentCard(todayAppointments[index]);
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(
              appointment: appointment,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(appointment['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    appointment['date'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    appointment['time'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: Text(appointment['status']),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
