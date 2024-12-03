import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';

class MostAvailedChart extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchData;
  const MostAvailedChart({
    Key? key,
    required this.fetchData,
  }) : super(key: key);

  @override
  MostAvailedChartState createState() => MostAvailedChartState();
}

class MostAvailedChartState extends State<MostAvailedChart> {
  final Map<String, Color> serviceColors = {};
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = true;
  bool noDataForYear = false;
  void refreshData() {
    fetchChartData(); // Call to fetch new data
  }

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    try {
      final data = await widget.fetchData();

      Map<String, List<int>> serviceCountsMap = {};
      for (var record in data) {
        final serviceName =
            (record['service_name'] as String?)?.trim().toLowerCase();
        final month = record['month'] as int?;
        final count = record['count'] as int?;

        if (serviceName != null && month != null && count != null) {
          serviceCountsMap.putIfAbsent(
              serviceName, () => List<int>.filled(12, 0));
          if (month >= 1 && month <= 12) {
            serviceCountsMap[serviceName]![month - 1] += count;
          }
        }
      }

      List<Map<String, dynamic>> processedData =
          serviceCountsMap.entries.map((entry) {
        return {
          'service': entry.key,
          'counts': entry.value,
        };
      }).toList();

      setState(() {
        chartData = processedData;
        isLoading = false;
        noDataForYear = processedData.isEmpty;
        initializeServiceColors();
      });
    } catch (e) {
      debugPrint('Error fetching or processing data: $e');
      setState(() {
        isLoading = false;
        noDataForYear = true;
      });
    }
  }

  void initializeServiceColors() {
    List<Color> colors = [
      Color.fromRGBO(255, 87, 51, 1),
      Color.fromRGBO(255, 215, 0, 1),
      Color.fromRGBO(76, 175, 80, 1),
      Colors.indigo.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
      Colors.blue.withOpacity(0.7),
      Colors.grey.withOpacity(0.7),
      Colors.green.withOpacity(0.7),
      Colors.red.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.teal.withOpacity(0.7),
      Colors.pink.withOpacity(0.7),
      Colors.yellow.withOpacity(0.7),
      Colors.indigo.withOpacity(0.7),
      Colors.brown.withOpacity(0.7),
    ];
    int colorIndex = 0;
    for (var service in chartData) {
      final serviceName = service['service'] as String?;
      if (serviceName != null && !serviceColors.containsKey(serviceName)) {
        serviceColors[serviceName] = colors[colorIndex % colors.length];
        colorIndex++;
      }
    }
  }

  Widget buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10.0,
      runSpacing: 10.0,
      children: serviceColors.entries.map((entry) {
        return buildLegendItem(entry.value, entry.key);
      }).toList(),
    );
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    List<String> monthNames = [
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
    ];
    String text = monthNames[value.toInt() % monthNames.length];
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${value.toInt()}', style: style),
    );
  }

  List<BarChartGroupData> _getData() {
    double barsWidth = 17.0; // Fixed bar width

    return List.generate(12, (monthIndex) {
      List<Map<String, dynamic>> serviceCounts = [];

      // Gather counts for the current month
      for (var service in chartData) {
        final serviceName = service['service'] as String?;
        if (serviceName == null) continue;

        final counts = service['counts'] as List<dynamic>? ?? [];
        final count = (counts.isNotEmpty && monthIndex < counts.length)
            ? counts[monthIndex] ?? 0
            : 0;

        serviceCounts.add({
          'name': serviceName,
          'count': count,
          'color': serviceColors[serviceName] ?? Colors.black.withOpacity(0.7),
        });
      }

      // Sort services by count (ascending) to stack bars properly
      serviceCounts
          .sort((a, b) => (a['count'] as int).compareTo(b['count'] as int));

      // Create the bar groups with stacked items
      List<BarChartRodStackItem> stackItems = [];
      double cumulativeHeight = 0.0;

      // Add bars in ascending order of count to create a stacking effect
      for (var service in serviceCounts) {
        final count = service['count'] as int;
        final color = service['color'] as Color;

        stackItems.add(
          BarChartRodStackItem(
            cumulativeHeight,
            cumulativeHeight + count.toDouble(),
            color,
          ),
        );

        cumulativeHeight += count.toDouble();
      }

      return BarChartGroupData(
        x: monthIndex, // Fixed x position for the month
        barRods: [
          BarChartRodData(
            toY: cumulativeHeight, // Total height of the stack
            width: barsWidth,
            rodStackItems: stackItems,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    });
  }

// Adding a method to retrieve the peak service name
  String _getPeakServiceName(int monthIndex) {
    final monthData = chartData[monthIndex];
    final serviceCounts = monthData['counts'] as List<dynamic>;
    String peakService = '';
    int maxCount = 0;

    for (var service in serviceCounts) {
      final count = service['count'] as int;
      if (count > maxCount) {
        maxCount = count;
        peakService = service['service'];
      }
    }
    return peakService; // Return the name of the service with the highest count
      return '';
  }

// Custom method to display peak service name at the top
  Widget _topTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text = _getPeakServiceName(value.toInt());

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
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

    return Column(
      children: [
        AspectRatio(
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
                      interval: 10,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 5 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: 15,
                barGroups: _getData(),
              ),
            ),
          ),
        ),
        buildLegend(),
      ],
    );
  }
}
