// revenue_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;

  const RevenueChart({super.key, required this.data, required this.labels});

  @override
  _RevenueChartState createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  final Color normalColor = Color(0xFFD14C01).withOpacity(0.10);
  final Color toplColor = Color.fromARGB(255, 158, 58, 16);

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
      child: Text('₱${value.toInt()}',
          style: const TextStyle(fontSize: 10)), // Format as Philippine pesos
    );
  }

  List<BarChartGroupData> _getData() {
    double barsWidth = 15.0; // Increase the bar width for thicker bars
    double barsSpace = 5.0;

    return widget.data.asMap().entries.map((entry) {
      int index = entry.key;
      double value = entry.value;

      // Define the height for the different color sections
      double bottomSectionHeight = value * 0.97; // 70% normal color
      double topSectionHeight =
          value - bottomSectionHeight; // Remaining height for top color

      return BarChartGroupData(
        x: index,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: value,
            color: normalColor,
            width: barsWidth,
            rodStackItems: [
              BarChartRodStackItem(
                  0, bottomSectionHeight, normalColor), // Bottom color
              BarChartRodStackItem(
                  bottomSectionHeight, value, toplColor), // Top color
            ],
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
                    getTitlesWidget: _leftTitles),
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
            groupsSpace: 100,
            barGroups: _getData(),
          ),
        ),
      ),
    );
  }
}
