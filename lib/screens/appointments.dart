import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/providers/global_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/screens/appointment_details.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const AppointmentsScreen({super.key, required this.initialTabIndex});

  @override
  AppointmentsScreenState createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? serviceProviderId; // Nullable service provider ID

  final Map<String, Color> statusColors = {
    'Upcoming': secondaryColor,
    'Done': Colors.green,
    'Cancelled': primaryColor,
    'Pending': greyColor,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 6,
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
      ref.read(appointmentIdProvider.notifier).state = appointmentId;
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
    final appointmentId = ref.watch(appointmentIdProvider);

    final response = await supabase.from('appointment').update(
        {'appointment_status': status}).eq('appointment_id', appointmentId);

    if (response == null) {
      print('Appointment status updated to: $status');
    } else {
      print('Error updating appointment status');
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    tabs: [
                      _buildTab('Pending'),
                      _buildTab('Today'),
                      _buildTab('Upcoming'),
                      _buildTab('Done'),
                      _buildTab('Cancelled'),
                      _buildTab('All'),
                    ],
                    indicatorColor: const Color.fromRGBO(160, 62, 6, 1),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                ),
              ],
            ),
          ),
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
                    children: List.generate(6, (index) {
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
      final normalizedAppointmentDate = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      switch (tabIndex) {
        case 0: // Pending
          return appointment['appointment_status'] == 'Pending';
        case 1: // Today
          return normalizedAppointmentDate.isAtSameMomentAs(today) &&
              appointment['appointment_status'] == 'Approved';
        case 2: // Upcoming
          return appointment['appointment_status'] == 'Upcoming';
        case 3: // Done
          return appointment['appointment_status'] == 'Done';
        case 4: // Cancelled
          return appointment['appointment_status'] == 'Cancelled';
        case 5: // All
          return true;
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
                      appointment['appointment_status'] ?? '',
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
