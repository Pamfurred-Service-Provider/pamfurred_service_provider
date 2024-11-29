import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SatisfactionRatingChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const SatisfactionRatingChart({
    super.key,
    required this.data,
  });

  @override
  SatisfactionRatingChartState createState() => SatisfactionRatingChartState();
}

class SatisfactionRatingChartState extends State<SatisfactionRatingChart> {
  List<PieChartSectionData> _getData() {
    // double total = widget.data.fold(0, (sum, value) => sum + value['value']);

    return List.generate(widget.data.length, (index) {
      final value = widget.data[index]['value'];
      final color = widget.data[index]['color'];

      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        radius: 50,
        title: '',
        titleStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  Widget buildLegend() {
    double total = widget.data.fold(0, (sum, value) => sum + value['value']);
    if (total == 0) {
      // Avoid division by zero and show 0% if total is 0
      total = 1; // This ensures no division by zero
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10.0,
      runSpacing: 10.0,
      children: List.generate(widget.data.length, (index) {
        final color = widget.data[index]['color'];
        final label = widget.data[index]['label'];
        final value = widget.data[index]['value'];
        final percentage = (value / total) * 100; // Calculate percentage

        return buildLegendItem(color, label, percentage);
      }),
    );
  }

  Widget buildLegendItem(Color color, String text, double percentage) {
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
        Text('$text (${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: _getData(),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        buildLegend(), // Display the legend
      ],
    );
  }
}
