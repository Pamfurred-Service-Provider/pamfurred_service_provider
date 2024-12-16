import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';
import 'package:service_provider/components/most_availed_chart.dart';
import 'package:service_provider/components/annual_appointments_chart.dart';
import 'package:service_provider/components/satisfaction_rating_chart.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/screens/appointments.dart';
import 'package:service_provider/screens/feedbacks.dart';
import 'package:service_provider/screens/generate_report/generate_report.dart';
import 'package:service_provider/screens/main_screen.dart';
import 'package:service_provider/components/year_dropdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final List<int> years = [2024, 2025, 2026, 2027, 2028];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required Null Function() onCardTap});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<MostAvailedChartState> mostAvailedChartKey =
      GlobalKey<MostAvailedChartState>();

  String serviceProviderName = '';
  int selectedRevenueYear = DateTime.now().year;
  int selectedMostAvailedServicesYear = DateTime.now().year;
  int selectedAnnualYear = DateTime.now().year;
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

  final List<String> cardTitles = [
    'Pending \nAppointments',
    'Upcoming \nAppointments',
    'Appointments \nToday',
    'Cancelled Appointments',
    'Services/ \nPackages',
    'Feedback'
  ];

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
      print("Error fetching user data");
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
        'year': selectedMostAvailedServicesYear,
      });

      final List<dynamic> services = response ?? [];

      // Convert response to a list of maps
      final List<Map<String, dynamic>> processedServices =
          services.map((service) {
        return {
          'service_name': service['service_name'],
          'month': service['month'],
          'count': service['count'],
        };
      }).toList();
      print("Go: $processedServices");

      return processedServices; // Return the processed services list
    } catch (e) {
      print("Error fetching most availed services");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load most availed services')),
      );
      return []; // Return an empty list in case of error
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
          .eq('sp_id', userId);

      final List<dynamic> feedbacks = response ?? [];
      int satisfiedCount = 0, neutralCount = 0, negativeCount = 0;

      for (var feedback in feedbacks) {
        double compoundScore = feedback['compound_score'] ?? 0.0;
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
      print("Error fetching feedback");
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
              DateTime(selectedAnnualYear, 1, 1).toIso8601String())
          .lt('appointment_date',
              DateTime(selectedAnnualYear + 1, 1, 1).toIso8601String());

      final List<dynamic> appointments = response ?? [];
      final monthlyCounts = List<int>.filled(12, 0);

      for (var appointment in appointments) {
        final date = DateTime.parse(appointment['appointment_date']);
        monthlyCounts[date.month - 1]++;
      }

      setState(() {
        annualAppointmentData = monthlyCounts.map((e) => e.toDouble()).toList();
      });
    } catch (e) {
      print("Error fetching appointment");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load annual appointments data')),
        );
      }
    }
  }

  void updateAnnualDataForYear(int year) {
    setState(() {
      selectedAnnualYear = year;
    });
    _fetchAnnualAppointments(); // Refresh data for the selected year
  }

  void updateMonthlyRevenueForYear(int year) {
    setState(() {
      selectedRevenueYear = year;
    });
  }

  void updateMostAvailedServicesForYear(int year) {
    setState(() {
      selectedMostAvailedServicesYear = year;
    });

    // Call refreshData on the MostAvailedChartState
    mostAvailedChartKey.currentState
        ?.refreshData(); // Use the key to access the state
  }

  void navigateToScreen(String title) {
    if (title == 'Services/ \nPackages') {
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
    int initialTabIndex = title == 'Pending \nAppointments'
        ? 0
        : title == 'Appointments \nToday'
            ? 1
            : title == 'Upcoming \nAppointments'
                ? 2
                : 4;
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
    // revenueData.map((e) => e['value'] as double).toList();
    // revenueData.map((e) => e['month'] as String).toList();

    return Scaffold(
      appBar: HomeAppBar(context),
      body: ListView(
        physics: const BouncingScrollPhysics(),
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, slideUpRoute(const GenerateReportScreen()));
            },
            child: Card(
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
                          initialYear: selectedRevenueYear,
                          onYearChanged: updateMonthlyRevenueForYear,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RevenueChart(
                      data: [],
                      labels: [],
                      // revenueData: const [],
                      year: selectedRevenueYear,
                    ),
                  ],
                ),
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
                        initialYear: selectedMostAvailedServicesYear,
                        onYearChanged: updateMostAvailedServicesForYear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MostAvailedChart(
                    key: mostAvailedChartKey,
                    fetchData: _fetchMostAvailedServices,
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
                        initialYear: selectedAnnualYear,
                        onYearChanged: updateAnnualDataForYear,
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
