import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MostAvailedChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String> labels;

  const MostAvailedChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  MostAvailedChartState createState() => MostAvailedChartState();
}

class MostAvailedChartState extends State<MostAvailedChart> {
  final Map<String, Color> serviceColors = {};

  @override
  void initState() {
    super.initState();
    initializeServiceColors();
  }

  void initializeServiceColors() {
    // Assign a unique color to each service
    List<Color> colors = [
      const Color.fromRGBO(255, 87, 51, 1),
      const Color.fromRGBO(255, 215, 0, 1),
      const Color.fromRGBO(76, 175, 80, 1),
      Colors.indigo.withOpacity(0.7),
      Colors.purple.withOpacity(0.7),
      Colors.redAccent.withOpacity(0.7),
      Colors.orange.withOpacity(0.7),
      Colors.blue.withOpacity(0.9),
      Colors.teal.withOpacity(0.7),
      Colors.pink.withOpacity(0.7),
      Colors.yellow.withOpacity(0.7),
      Colors.brown.withOpacity(0.7),
    ];
    int colorIndex = 0;
    for (var service in widget.data) {
      final serviceName = service['service'];
      if (!serviceColors.containsKey(serviceName)) {
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
    double barsWidth = 17.0;

    return List.generate(12, (monthIndex) {
      List<BarChartRodStackItem> stackItems = [];
      double cumulativeHeight = 0.0;

      for (var service in widget.data) {
        final serviceName = service['service'];
        final count = monthIndex < service['counts'].length
            ? service['counts'][monthIndex]
            : 0;
        final serviceColor =
            serviceColors[serviceName] ?? Colors.black.withOpacity(0.7);

        stackItems.add(
          BarChartRodStackItem(
            cumulativeHeight,
            cumulativeHeight + count.toDouble(),
            serviceColor,
          ),
        );

        // Update cumulative height for stacking
        cumulativeHeight += count.toDouble();
      }

      return BarChartGroupData(
        x: monthIndex,
        barRods: [
          BarChartRodData(
            toY: cumulativeHeight,
            color: Colors.transparent, // Use transparent color for the main rod
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
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1), strokeWidth: 2),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: 15,
                barGroups: _getData(),
              ),
            ),
          ),
        ),
        buildLegend(), // Called widget legend
      ],
    );
  }
}
