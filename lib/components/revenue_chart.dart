import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueChart extends StatefulWidget {
  final int year;

  const RevenueChart(
      {Key? key, required this.year, required List data, required List labels})
      : super(key: key);

  @override
  RevenueChartState createState() => RevenueChartState();
}

class RevenueChartState extends State<RevenueChart> {
  final Color barColor = const Color(0xFFD14C01).withOpacity(0.7);
  bool isLoading = true;
  bool noDataForYear = false;
  List<double> data = List.filled(12, 0.0);
  List<String> labels = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    super.initState();
    _fetchMonthlyRevenueData(widget.year); // Fetch data for the initial year
  }

  @override
  void didUpdateWidget(RevenueChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the year has changed
    if (widget.year != oldWidget.year) {
      // Fetch data for the new year
      _fetchMonthlyRevenueData(widget.year);
    }
  }

  Future<void> _fetchMonthlyRevenueData(int year) async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;
      if (userSession == null) {
        throw Exception("User not logged in");
      }

      final userId = userSession.user.id;
      final response = await Supabase.instance.client.rpc(
        'get_monthly_revenue',
        params: {'user_sp_id': userId},
      );

      if (response == null || response is! List) {
        throw Exception('Invalid response data');
      }

      final revenueData = List<Map<String, dynamic>>.from(response);

      // Preparing data based on the month number
      final chartData = List<double>.filled(12, 0.0);
      // Map month names to indices
      const monthMapping = {
        'January': 0,
        'February': 1,
        'March': 2,
        'April': 3,
        'May': 4,
        'June': 5,
        'July': 6,
        'August': 7,
        'September': 8,
        'October': 9,
        'November': 10,
        'December': 11
      };

      for (var item in revenueData) {
        final monthString = item['revenue_month'] as String;
        final monthNumber = monthMapping[monthString];

        if (monthNumber != null && item['revenue_year'] == year.toString()) {
          final revenue = item['total_revenue'] != null
              ? (item['total_revenue'] as num).toDouble()
              : 0.0; // Handle null by setting default value
          chartData[monthNumber] = revenue;
        }
      }

      setState(() {
        data = chartData;
        noDataForYear =
            chartData.every((value) => value == 0); // Set noDataForYear
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching monthly revenue data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load revenue data')),
        );
      }
      setState(() {
        isLoading = false;
        noDataForYear = true; // Assume no data if there's an error
      });
    }
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    final index = value.toInt();
    String text = index >= 0 && index < labels.length ? labels[index] : '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) return Container();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
    );
  }

  List<BarChartGroupData> _getData() {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: barColor,
            width: 16,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (noDataForYear) {
      return const Center(
        child: Text(
          'No available data for this year',
          style: TextStyle(fontSize: regularText, color: mediumGreyColor),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.66,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.center,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: _bottomTitles,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: _leftTitles,
                  // interval: 1000,
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              // checkToShowHorizontalLine: (value) => value % 10 == 0,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 2,
              ),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            groupsSpace: 15,
            barGroups: _getData(),
          ),
        ),
      ),
    );
  }
}
