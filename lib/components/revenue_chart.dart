import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueChart extends StatefulWidget {
  final int year;

  const RevenueChart({Key? key, required this.year, required List data, required List labels}) : super(key: key);

  @override
  RevenueChartState createState() => RevenueChartState();
}

class RevenueChartState extends State<RevenueChart> {
  final Color barColor = const Color(0xFFD14C01).withOpacity(0.7);
  bool isLoading = true;
  List<double> data = List.filled(12, 0.0);
  List<String> labels = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

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
      final response = await Supabase.instance.client.rpc(
        'get_monthly_revenue1',
        params: {'user_sp_id': userId},
      );

      if (response == null || response is! List) {
        throw Exception('Invalid response data');
      }

      final revenueData = List<Map<String, dynamic>>.from(response);

      // Preparing data based on the month number
      final chartData = List<double>.filled(12, 0.0);
      for (var item in revenueData) {
        final monthNumber = (item['month_number'] as int) - 1;
        if (item['revenue_year'] == year.toString() && monthNumber >= 0 && monthNumber < 12) {
          chartData[monthNumber] = (item['total_revenue'] as num).toDouble();
        }
      }

      setState(() {
        data = chartData;
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
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : AspectRatio(
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
