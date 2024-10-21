import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnnualAppointmentsChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;

  const AnnualAppointmentsChart(
      {super.key,
      required this.data,
      required this.labels,
      required List<Map<String, dynamic>> annualAppointmentData});

  @override
  AnnualAppointmentsChartState createState() => AnnualAppointmentsChartState();
}

class AnnualAppointmentsChartState extends State<AnnualAppointmentsChart> {
  final Color normalColor = const Color(0xFFD14C01).withOpacity(0.7);

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

  List<FlSpot> _getLineChartData() {
    return widget.data.asMap().entries.map((entry) {
      int index = entry.key;
      double value = entry.value;
      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.66,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(enabled: true),
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
            lineBarsData: [
              LineChartBarData(
                spots: _getLineChartData(),
                isCurved: false,
                barWidth: 3,
                color: normalColor,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
