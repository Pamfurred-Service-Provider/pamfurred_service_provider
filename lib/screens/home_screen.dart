import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';
import 'package:service_provider/components/most_availed_chart.dart';

final List<int> years = [2023, 2024];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedYear = years.first;

  // Static Data
  final List<String> store = [
    'Paws and Claws Pet Station',
    'Groomers on the Go'
  ];
  final List<Map<String, dynamic>> revenueData = [
    {'month': 'Jan', 'value': 1000.00},
    {'month': 'Feb', 'value': 1500.00},
    {'month': 'Mar', 'value': 1700.00},
    {'month': 'Apr', 'value': 2000.00},
    {'month': 'May', 'value': 3000.00},
    {'month': 'Jun', 'value': 4080.00},
    {'month': 'Jul', 'value': 5480.00},
    {'month': 'Aug', 'value': 1080.00},
    {'month': 'Sep', 'value': 6540.00},
    {'month': 'Oct', 'value': 7000.00},
    {'month': 'Nov', 'value': 8000.00},
    {'month': 'Dec', 'value': 3152.00},
  ];
  final List<List<int>> mostAvailedData = [
    [50, 40, 20, 60, 80, 50, 70, 40, 60, 90, 100, 70], //12 months data
    [30, 30, 50, 30, 40, 60, 20, 70, 30, 20, 50, 90], // Second service
    [10, 20, 30, 40, 20, 10, 30, 50, 60, 70, 80, 90], // Third service
  ];

  @override
  Widget build(BuildContext context) {
    final List<double> data =
        revenueData.map((e) => e['value'] as double).toList();
    final List<String> labels =
        revenueData.map((e) => e['month'] as String).toList();
    return Scaffold(
      appBar: appBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Padding for the entire ListView
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  color: Color(0xFF651616),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                store[0],
                style: const TextStyle(
                  color: Color(0xFF651616),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          // First Revenue Chart
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                // Use a Column to arrange text and chart vertically
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the start
                children: [
                  const Text(
                    ' Monthly Revenue', // Title for the chart
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10), // Space between title and chart
                  RevenueChart(
                    data: data,
                    labels: labels,
                    revenueData: const [],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          // Second Chart
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                // Use a Column to arrange text and chart vertically
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the start
                children: [
                  const Text(
                    ' Most Availed Services', // Title for the chart
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MostAvailedChart(
                    data: mostAvailedData, // Pass the data for stacking
                    labels: labels,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
