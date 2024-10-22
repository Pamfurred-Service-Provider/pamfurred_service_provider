import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointment_details.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialTabIndex;
  const AppointmentsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> todayAppointments = [
    {
      'id': '1445547gg5fg1',
      'date': 'January 2, 2024',
      'status': 'Upcoming',
      'name': 'Bob Niño Golosinda',
      'time': '09:00 AM - 11:00 AM',
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
      'status': 'Done',
      'time': '11:00 AM - 01:00 PM',
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
      'status': 'Cancelled',
    },
  ];
  final Map<String, Color> statusColors = {
    'Upcoming': const Color.fromRGBO(255, 143, 0, 1),
    'Done': Colors.green,
    'Cancelled': const Color.fromRGBO(160, 62, 6, 1),
  };
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 5, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'All'),
            Tab(text: 'Done'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsTab(status: 'Today'),
          _buildAppointmentsTab(status: 'Upcoming'),
          _buildAppointmentsTab(status: 'All'),
          _buildAppointmentsTab(status: 'Done'),
          _buildAppointmentsTab(status: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab({required String status}) {
    List<Map<String, dynamic>> filteredAppointments;

    if (status == 'All') {
      filteredAppointments = todayAppointments;
    } else {
      filteredAppointments = todayAppointments
          .where((appointment) => appointment['status'] == status)
          .toList();
    }
    if (filteredAppointments.isEmpty) {
      return Center(
        child: Text('No appointments for $status'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        return buildAppointmentCard(filteredAppointments[index]);
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  Widget buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () async {
        final updatedStatus = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(
                appointment: appointment,
                updateStatus: (newStatus) {
                  setState(() {
                    appointment['status'] = newStatus;
                  });
                }),
          ),
        );
        if (updatedStatus != null) {
          setState(() {
            appointment['status'] = updatedStatus;
          });
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 10,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  appointment['status'],
                  style: TextStyle(
                      color: statusColors[appointment['status']] ??
                          Colors.black87),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
