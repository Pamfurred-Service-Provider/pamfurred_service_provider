import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';
import 'package:service_provider/components/most_availed_chart.dart';
import 'package:service_provider/components/annual_appointments_chart.dart';
import 'package:service_provider/components/satisfaction_rating_chart.dart';
import 'package:service_provider/screens/appointments.dart';
import 'package:service_provider/screens/feedbacks.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:service_provider/components/year_dropdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final List<int> years = [2024, 2025];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required Null Function() onCardTap});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String serviceProviderName = '';
  int selectedYear = years.first;
  int selectedIndex = 0;
  List<double> annualAppointmentData =
      List.filled(12, 0.0); // Changed to List<double>

  final List<Map<String, dynamic>> satisfactionData = [
    {
      'label': 'Satisfied',
      'value': 0.0,
      'color': const Color.fromRGBO(251, 188, 4, 1)
    },
    {
      'label': 'Neutral',
      'value': 0.0,
      'color': const Color.fromRGBO(102, 22, 22, 1)
    },
    {
      'label': 'Negative',
      'value': 0.0,
      'color': const Color.fromRGBO(255, 0, 0, 1)
    },
  ];

  void onButtomNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  List<Map<String, dynamic>> mostAvailedData =
      []; // Initialize as an empty list

  final List<Map<String, dynamic>> revenueData = [
    {'month': 'Jan', 'value': 2500.00},
    {'month': 'Feb', 'value': 5000.00},
    {'month': 'Mar', 'value': 1000.00},
    {'month': 'Apr', 'value': 2000.00},
    {'month': 'May', 'value': 3000.00},
    {'month': 'Jun', 'value': 4080.00},
    {'month': 'Jul', 'value': 5480.00},
    {'month': 'Aug', 'value': 5050.00},
    {'month': 'Sep', 'value': 6540.00},
    {'month': 'Oct', 'value': 7000.00},
    {'month': 'Nov', 'value': 8000.00},
    {'month': 'Dec', 'value': 3152.00},
  ];

  final List<String> cardTitles = [
    'Appointments \nToday',
    'Upcoming \nAppointments',
    'Cancelled Appointments',
    'Services',
    'Packages',
    'Feedback'
  ];

  final List<int> notificationCounts = [5, 2, 0, 3, 1, 4];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchFeedbackData(); // Fetch satisfaction ratings from feedback table
    _fetchAnnualAppointments(); // Fetch annual appointments data
    _fetchMostAvailedServices(); // Fetch most availed services
  }

  Future<void> _fetchUserData() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;
      if (userSession == null) throw Exception("User not logged in");

      final userId = userSession.user.id;
      final response = await Supabase.instance.client
          .from('service_provider')
          .select('name')
          .eq('sp_id', userId)
          .single();

      setState(() {
        serviceProviderName = response['name'] ?? '';
      });
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMostAvailedServices() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;
      if (userSession == null) throw Exception("User not logged in");

      final userId = userSession.user.id;

      // Call the `get_monthly_service_counts` RPC
      final response = await Supabase.instance.client
          .rpc('get_monthly_service_counts', params: {
        'provider_id': userId,
        'year': selectedYear,
      }).execute();

      final List<dynamic> services = response.data ?? [];

      // Convert response to a list of maps
      final List<Map<String, dynamic>> processedServices =
          services.map((service) {
        return {
          'service_name': service['service_name'],
          'month': service['month'],
          'count': service['count'],
        };
      }).toList();

      return processedServices;
    } catch (e) {
      print("Error fetching most availed services: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load most availed services')),
      );
      return [];
    }
  }

  Future<void> _fetchFeedbackData() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;
      if (userSession == null) throw Exception("User not logged in");

      final userId = userSession.user.id;
      final response = await Supabase.instance.client
          .from('feedback')
          .select('compound_score')
          .eq('sp_id', userId)
          .execute();

      final List<dynamic> feedbacks = response.data ?? [];
      int satisfiedCount = 0, neutralCount = 0, negativeCount = 0;

      for (var feedback in feedbacks) {
        double compoundScore = feedback['compound_score'] as double;

        // Update thresholds based on compound_score ranges for satisfaction
        if (compoundScore >= 0.05) {
          satisfiedCount++;
        } else if (compoundScore >= -0.05 && compoundScore < 0.05) {
          neutralCount++;
        } else if (compoundScore < -0.05) {
          negativeCount++;
        }
      }

      final totalFeedbacks = satisfiedCount + neutralCount + negativeCount;
      if (totalFeedbacks > 0) {
        satisfactionData[0]['value'] = (satisfiedCount / totalFeedbacks) * 100;
        satisfactionData[1]['value'] = (neutralCount / totalFeedbacks) * 100;
        satisfactionData[2]['value'] = (negativeCount / totalFeedbacks) * 100;
      }

      setState(() {});
    } catch (e) {
      print("Error fetching feedback data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load feedback data')),
      );
    }
  }

  Future<void> _fetchAnnualAppointments() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;
      if (userSession == null) throw Exception("User not logged in");

      final userId = userSession.user.id;

      final response = await Supabase.instance.client
          .from('appointment')
          .select('appointment_date')
          .eq('sp_id', userId)
          .gte('appointment_date',
              DateTime(selectedYear, 1, 1).toIso8601String())
          .lt('appointment_date',
              DateTime(selectedYear + 1, 1, 1).toIso8601String())
          .execute();

      final List<dynamic> appointments = response.data ?? [];
      final monthlyCounts = List<int>.filled(12, 0);

      for (var appointment in appointments) {
        final date = DateTime.parse(appointment['appointment_date']);
        monthlyCounts[date.month - 1]++;
      }

      setState(() {
        annualAppointmentData = monthlyCounts.map((e) => e.toDouble()).toList();
      });
    } catch (e) {
      print("Error fetching appointment data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load annual appointments data')),
        );
      }
    }
  }

  void updateDataForYear(int year) {
    setState(() {
      selectedYear = year;
    });
    _fetchAnnualAppointments(); // Refresh data for the selected year
    _fetchMostAvailedServices();
  }

  void navigateToScreen(String title) {
    if (title == 'Services' || title == 'Packages') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const MainScreen(
                  selectedIndex: 1,
                )),
      );
      return;
    }
    if (title == 'Feedback') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedbacksScreen()),
      );
      return;
    }

    // Set the initial tab index based on the title
    int initialTabIndex = title == 'Appointments \nToday'
        ? 0
        : title == 'Upcoming \nAppointments'
            ? 1
            : 3;
    print('Navigating to screen with title: $title');
    print('Initial tab index set to: $initialTabIndex');

    // Navigate to AppointmentsScreen and pass the initialTabIndex
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentsScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<double> data =
        revenueData.map((e) => e['value'] as double).toList();
    final List<String> labels =
        revenueData.map((e) => e['month'] as String).toList();

    return Scaffold(
      appBar: appBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(
                  color: Color(0xFF651616),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                serviceProviderName,
                style: const TextStyle(
                  color: Color(0xFF651616),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ' Monthly Revenue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RevenueChart(
                    data: [],
                    labels: [],
                    // revenueData: const [],
                    year: selectedYear,
                  ),
                ],
              ),
            ),
          ),
          
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ' Most Availed Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MostAvailedChart(
                    fetchData: _fetchMostAvailedServices,
                    data: mostAvailedData.isEmpty
                        ? [
                            {
                              'service_name': 'No data available',
                              'month': '',
                              'count': 0
                            }
                          ]
                        : mostAvailedData,
                    labels: mostAvailedData.isEmpty ? [''] : labels,
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Annual Appointments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnnualAppointmentsChart(
                    data: annualAppointmentData,
                    labels: const [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Satisfaction Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SatisfactionRatingChart(
                    data: satisfactionData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5,
            ),
            itemCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  navigateToScreen(cardTitles[index]);
                },
                child: Stack(
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  cardTitles[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //for the norification number.
                    if (notificationCounts[index] > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: badges.Badge(
                          badgeContent: Text(
                            notificationCounts[index].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          badgeStyle:
                              const badges.BadgeStyle(badgeColor: Colors.red),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
