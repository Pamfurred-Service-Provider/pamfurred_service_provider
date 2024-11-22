import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;
  final int year;

  const RevenueChart(
      {super.key,
      required this.data,
      required this.labels,
      required this.year});

  @override
  RevenueChartState createState() => RevenueChartState();
}

class RevenueChartState extends State<RevenueChart> {
  final Color normalColor = const Color(0xFFD14C01).withOpacity(0.7);
  bool isLoading = true;
  List<double> data = [];
  List<String> labels = [];
  @override
  void initState() {
    super.initState();
    _fetchMonthlyRevenueData(widget.year);
  }

  Future<void> _fetchMonthlyRevenueData(int year) async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;
      if (userSession == null) {
        throw Exception("User not logged in");
      }

      final userId = userSession.user.id;
      print('Fetching revenue data for user: $userId');

      // Fetch the monthly revenue data for the logged-in user and selected year
      final response = await Supabase.instance.client
          .rpc('get_monthly_revenue', params: {'user_sp_id': userId});
      print('Raw response from get_monthly_revenue: $response');

      // if (response != null) {
      //   throw Exception('Error fetching revenue data: ');
      // }
      // if (response == null || !(response is List)) {
      //   throw Exception('Invalid response data');
      // }
      // final revenueData = List<Map<String, dynamic>>.from(response);
      if (response == null) {
        throw Exception('No response from get_monthly_revenue RPC');
      }

      final revenueData = List<Map<String, dynamic>>.from(response);

      print('Revenue data: $revenueData');
      // Filter the data by the selected year and prepare it for display
      final filteredData = revenueData
          .where((data) => data['revenue_year'] == year.toString())
          .toList();
      print('Filtered data for year $year: $filteredData'); // Log filtered data

      // final revenueList = filteredData.map((data) {
      //   return {
      //     'month': data['revenue_month'] as String,
      //     'value': data['total_revenue'] as double
      //   };
      // }).toList();
      if (filteredData.isEmpty) {
        setState(() {
          data = [];
          labels = [];
          isLoading = false;
        });
        return;
      }

      // Prepare data for the chart
      final chartData = filteredData
          .map((e) => (e['total_revenue'] as num).toDouble())
          .toList();
      final chartLabels =
          filteredData.map((e) => e['revenue_month'] as String).toList();

      setState(() {
        data = chartData;
        labels = chartLabels;
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
        data = [];
        labels = [];
      });
    }
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text = widget.labels[value.toInt() % widget.labels.length];
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
    double barsWidth = 17.0;
    double barsSpace = 5.0;

    return widget.data.asMap().entries.map((entry) {
      int index = entry.key;
      double value = entry.value;

      return BarChartGroupData(
        x: index,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: value,
            color: normalColor,
            width: barsWidth,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                    getTitlesWidget: _bottomTitles),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: _leftTitles,
                  interval: 1000,
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              checkToShowHorizontalLine: (value) => value % 10 == 0,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 2),
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
