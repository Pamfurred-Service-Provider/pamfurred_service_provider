import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/screens/appointment_details.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  AppointmentsScreenState createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? serviceProviderId; // Nullable service provider ID

  final Map<String, Color> statusColors = {
    'Upcoming': const Color.fromRGBO(255, 143, 0, 1),
    'Done': Colors.green,
    'Cancelled': const Color.fromRGBO(160, 62, 6, 1),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchAppointmentDetails() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.rpc(
      'get_appointment_details_by_sp_id',
      params: {'sp_id_param': serviceProviderId},
    );

    final dataList = List<Map<String, dynamic>>.from(response);
    return {'appointments': dataList};
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
          tabs: [
            _buildTab('Today'),
            _buildTab('Upcoming'),
            _buildTab('All'),
            _buildTab('Done'),
            _buildTab('Cancelled'),
          ],
          // labelColor: Colors.orange, // Replace with `tangerine` if defined
          indicatorColor: const Color.fromRGBO(160, 62, 6, 1),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        ),
      ),
      body: serviceProviderId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: fetchAppointmentDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final appointmentList = snapshot.data!['appointments']
                      as List<Map<String, dynamic>>;

                  return TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: List.generate(5, (index) {
                      return _buildAppointmentList(index, appointmentList);
                    }),
                  );
                } else {
                  return const Center(child: Text('No appointments found.'));
                }
              },
            ),
    );
  }

  Widget _buildTab(String text) {
    return Tab(
      child: Text(text),
    );
  }

  Widget _buildAppointmentList(
      int tabIndex, List<Map<String, dynamic>> appointmentList) {
    final filteredAppointments = appointmentList.where((appointment) {
      final dateFormat = DateFormat('MM/dd/yyyy');
      DateTime appointmentDate;

      try {
        appointmentDate = dateFormat.parse(appointment['appointment_date']);
      } catch (e) {
        appointmentDate = DateTime.now();
      }

      switch (tabIndex) {
        case 0: // Today
          final today = DateTime.now();
          return appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day;
        case 1: // Upcoming
          return appointment['appointment_status'] == 'Upcoming';
        case 2: // All
          return true;
        case 3: // Done
          return appointment['appointment_status'] == 'Done';
        case 4: // Cancelled
          return appointment['appointment_status'] == 'Cancelled';
        default:
          return false;
      }
    }).toList();

    if (filteredAppointments.isEmpty) {
      return const Center(child: Text('No Appointments Available'));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];

        return Card(
          color: Colors.white,
          elevation: 1.5,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            ListTile(
              title: Text(appointment['pet_owner_first_name'] ?? 'N/A'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 8.0),
                  Text(
                    appointment['appointment_date'] ?? 'N/A',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    appointment['appointment_time'] ?? 'N/A',
                    style: const TextStyle(color: Colors.grey),
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
                    appointment['appointment_status'] ?? 'Unknown',
                    style: TextStyle(
                      color: statusColors[appointment['appointment_status']] ??
                          Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
