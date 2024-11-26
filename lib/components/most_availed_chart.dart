import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MostAvailedChart extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() fetchData;

  const MostAvailedChart({
    Key? key,
    required this.fetchData,
    required List<String> labels,
    required List<Map<String, dynamic>> data,
  }) : super(key: key);

  @override
  MostAvailedChartState createState() => MostAvailedChartState();
}

class MostAvailedChartState extends State<MostAvailedChart> {
  final Map<String, Color> serviceColors = {};
  List<Map<String, dynamic>> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    try {
      // Fetch data once
      final data = await widget.fetchData();

      debugPrint('Fetched data: $data'); // Log fetched data for debugging

      // Check if data is valid
      if (data == null || data.isEmpty) {
        debugPrint('No valid data fetched');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Initialize map to store service counts for each month
      Map<String, List<int>> serviceCountsMap = {};

      for (var record in data) {
        // Use correct field names and normalize the service name
        final serviceName = (record['service_name'] as String?)?.trim().toLowerCase();
        final month = record['month'] as int?;
        final count = record['count'] as int?;

        debugPrint('Processing record: service=$serviceName, month=$month, count=$count');

        if (serviceName != null && month != null && count != null) {
          serviceCountsMap.putIfAbsent(
              serviceName, () => List<int>.filled(12, 0));
          if (month >= 1 && month <= 12) {
            serviceCountsMap[serviceName]![month - 1] += count;
          }
        } else {
          debugPrint('Skipping invalid record: $record');
        }
      }

      // Convert the map to a list of services with their monthly counts
      List<Map<String, dynamic>> processedData = serviceCountsMap.entries.map((entry) {
        return {
          'service': entry.key,
          'counts': entry.value,
        };
      }).toList();

      debugPrint('Processed data: $processedData'); // Log the processed data

      // Update state with the processed data
      setState(() {
        chartData = processedData;
        isLoading = false;
        initializeServiceColors();
      });
    } catch (e) {
      debugPrint('Error fetching or processing data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void initializeServiceColors() {
    List<Color> colors = [
      const Color.fromRGBO(255, 87, 51, 1),
      const Color.fromRGBO(255, 215, 0, 1),
      const Color.fromRGBO(76, 175, 80, 1),
      Colors.indigo.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
    ];
    int colorIndex = 0;
    for (var service in chartData) {
      final serviceName = service['service'] as String?;
      // Ensure serviceName is not null and is a valid string
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
    double barsWidth = 17.0;

    return List.generate(12, (monthIndex) {
      List<BarChartRodStackItem> stackItems = [];
      double cumulativeHeight = 0.0;

      // Iterate over each service in the processed chart data
      for (var service in chartData) {
        final serviceName = service['service'] as String?;
        if (serviceName == null) {
          continue; // Skip if serviceName is null
        }

        final counts = service['counts'] as List<dynamic>? ?? [];
        // Ensure counts is not null and check if monthIndex is within bounds
        final count = (counts.isNotEmpty && monthIndex < counts.length)
            ? counts[monthIndex] ?? 0
            : 0;

        // Get the color for the service
        final serviceColor = serviceColors[serviceName] ?? Colors.black.withOpacity(0.7);

        // Add stack item for the current service
        stackItems.add(
          BarChartRodStackItem(
            cumulativeHeight,
            cumulativeHeight + count.toDouble(),
            serviceColor,
          ),
        );

        cumulativeHeight += count.toDouble();
      }

      return BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: cumulativeHeight,
            color: Colors.transparent,
            width: barsWidth,
            rodStackItems: stackItems,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chartData.isEmpty) {
      return const Center(child: Text('No data available'));
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
                      interval: 50,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 2 == 0, // Show horizontal lines at multiples of 5
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),  // Light gray color for horizontal lines
                    strokeWidth: 1,  // Set line thickness
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
