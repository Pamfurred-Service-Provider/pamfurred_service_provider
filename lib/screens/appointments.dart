import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/screens/appointment_details.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';

class AppointmentsScreen extends StatefulWidget {
  final int initialTabIndex;
  const AppointmentsScreen({super.key, required this.initialTabIndex});

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
    _tabController = TabController(
        length: 5,
        vsync: this,
        initialIndex: widget.initialTabIndex); // Use the initialTabIndex here
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

  Future<List<Map<String, dynamic>>> fetchAppointmentDetails() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.rpc(
      'get_appointment_details_by_sp_id',
      params: {'sp_id_param': serviceProviderId},
    );

    final dataList = List<Map<String, dynamic>>.from(response);
    // Group the data by appointment ID
    final groupedData = groupAppointmentData(dataList);

    return groupedData;
  }

  List<Map<String, dynamic>> groupAppointmentData(
      List<Map<String, dynamic>> dataList) {
    final groupedData = <String, Map<String, dynamic>>{};

    for (var item in dataList) {
      final appointmentId = item['appointment_id'];
      if (!groupedData.containsKey(appointmentId)) {
        groupedData[appointmentId] = {
          ...item,
          'services': [],
          'packages': [],
        };
      }

      if (item['service_name'] != null) {
        groupedData[appointmentId]!['services'].add({
          'name': item['service_name'],
          'price': item['service_price'],
        });
      }

      if (item['package_name'] != null) {
        groupedData[appointmentId]!['packages'].add({
          'name': item['package_name'],
          'price': item['package_price'],
          'inclusions': item['package_inclusions'],
        });
      }
    }

    return groupedData.values.toList();
  }

  // Function to handle appointment status update
  void _updateAppointmentStatus(String status) async {
    final supabase = Supabase.instance.client;
    String appointmentId =
        "some_appointment_id"; // Get this dynamically as needed

    final response = await supabase.from('appointment').update(
        {'appointment_status': status}).eq('appointment_id', appointmentId);

    if (response == null) {
      print('Appointment status updated to: $status');
    } else {
      print('Error updating appointment status: ${response.message}');
    }
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
          indicatorColor: const Color.fromRGBO(160, 62, 6, 1),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
        ),
      ),
      body: serviceProviderId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAppointmentDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final appointmentList = snapshot.data!;

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

//   Widget _buildAppointmentList(
//       int tabIndex, List<Map<String, dynamic>> appointmentList) {
//     final filteredAppointments = appointmentList.where((appointment) {
//       DateTime appointmentDate;

//       try {
//         appointmentDate =
//             DateTime.parse(appointment['appointment_date']).toLocal();
//       } catch (e) {
//         appointmentDate = DateTime.now();
//       }
//       final now = DateTime.now();
//       final today = DateTime.now();

// // Debug print for today filtering
//       if (tabIndex == 0) {
//         // Only print when filtering for the "Today" tab
//         print('Appointment Date: $appointmentDate, Today: $today');
//         print(
//             'Raw appointment date from DB: ${appointment['appointment_date']}');
//       }
  Widget _buildAppointmentList(
      int tabIndex, List<Map<String, dynamic>> appointmentList) {
    final filteredAppointments = appointmentList.where((appointment) {
      DateTime appointmentDate;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      try {
        // Parse the date string from "yyyy-mm-dd" format
        final dateParts = appointment['appointment_date'].split('-');
        appointmentDate = DateTime(
          int.parse(dateParts[0]), // Year
          int.parse(dateParts[1]), // Month
          int.parse(dateParts[2]), // Day
        );
      } catch (e) {
        print('Error parsing date: ${appointment['appointment_date']}');
        return false; // Skip this appointment if date parsing fails
      }
      switch (tabIndex) {
        case 0: // Today
          final normalizedAppointmentDate = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
          );
          final normalizedToday = DateTime(today.year, today.month, today.day);
          final isToday =
              normalizedAppointmentDate.isAtSameMomentAs(normalizedToday);

          return isToday;
        case 1: // Upcoming
          return appointmentDate.isAfter(today) &&
              appointment['appointment_status'] == 'Upcoming';
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
    // Sort appointments by date, descending (most recent first)
    filteredAppointments.sort((a, b) {
      DateTime dateA = DateTime.parse(a['appointment_date']);
      DateTime dateB = DateTime.parse(b['appointment_date']);
      return dateB.compareTo(dateA); // Sort by descending order
    });

    if (filteredAppointments.isEmpty) {
      return const Center(child: Text('No Appointments Available'));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];

        return Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0), // Padding around each card
          child: Card(
            color: Colors.white,
            elevation: 1.5,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                title: Text(
                    '${appointment['pet_owner_first_name']} ${appointment['pet_owner_last_name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 8.0),
                    Text(
                      secondaryFormatDate(appointment['appointment_date']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      formatTime(appointment['appointment_time']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () async {
                  final updatedStatus = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailScreen(
                        appointment:
                            appointment, // Pass the entire appointment map
                        updateStatus: _updateAppointmentStatus,
                      ),
                    ),
                  );

                  if (updatedStatus != null) {
                    // If status is updated, refresh the data
                    setState(() {
                      appointment['appointment_status'] = updatedStatus;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      appointment['appointment_status'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            statusColors[appointment['appointment_status']] ??
                                Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
