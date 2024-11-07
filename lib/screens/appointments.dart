import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointment_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialTabIndex;
  const AppointmentsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;
  List<Map<String, dynamic>> appointments = [];

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
    fetchAppointments();
  }

  // Fetch all appointments from the "appointments" table
  Future<void> fetchAppointments() async {
    final response = await supabase.from('appointment').select('*').execute();
    if (response.error == null) {
      print("Appointments fetched: ${response.data}");
      setState(() {
        appointments = List<Map<String, dynamic>>.from(response.data);
      });
    } else {
      print("Error fetching appointments: ${response.error?.message}");
    }
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

  // Build the appointments list view for each tab (based on status)
  Widget _buildAppointmentsTab({required String status}) {
    List<Map<String, dynamic>> filteredAppointments;

    if (status == 'All') {
      filteredAppointments = appointments;
    } else {
      filteredAppointments = appointments
          .where((appointment) => appointment['appointment_status'] == status)
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

  // Build the appointment card for each item
  Widget buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () async {
        final updatedStatus = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentDetailScreen(
              appointment: appointment,
              updateStatus: (newStatus) async {
                setState(() {
                  appointment['appointment_status'] = newStatus;
                });
                await supabase
                    .from('appointment')
                    .update({'appointment_status': newStatus})
                    .eq('appointment_id', appointment['appointment_id']);
              },
            ),
          ),
        );
        if (updatedStatus != null) {
          setState(() {
            appointment['appointment_status'] = updatedStatus;
          });
        }
      },
      child: Card(
        color: Colors.white,
        elevation: 10,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            title: Text('Pet Owner: ${appointment['user_id'] ?? 'N/A'}'),  // Fallback if null
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Date: ${appointment['appointment_date'] ?? 'N/A'}',  // Fallback if null
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  'Time: ${appointment['appointment_time'] ?? 'N/A'}',  // Fallback if null
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
                  appointment['appointment_status'] ?? 'Unknown',  // Fallback if null
                  style: TextStyle(
                    color: statusColors[appointment['appointment_status']] ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ]), 
      ),
    );
  }
}

extension on PostgrestResponse {
  get error => null;
}
