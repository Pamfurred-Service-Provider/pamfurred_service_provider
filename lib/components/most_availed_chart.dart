import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MostAvailedChart extends StatefulWidget {
  final List<List<int>> data;
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
  final Color normalColor = const Color(0xFFD14C01).withOpacity(0.7);
  final Color secondColor =
      const Color.fromARGB(255, 2, 58, 211).withOpacity(0.7);
  final Color thirdColor =
      const Color.fromARGB(255, 115, 127, 148).withOpacity(0.7);
  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildLegendItem(normalColor, "Nail Clip"),
        buildLegendItem(secondColor, "Hair Color"),
        buildLegendItem(thirdColor, "Hair Trim"),
      ],
    );
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
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
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${value.toInt()}', style: style),
    );
  }

  List<BarChartGroupData> _getData() {
    double barsWidth = 17.0;

    return List.generate(widget.labels.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: widget.data[0][index].toDouble() +
                widget.data[1][index].toDouble() +
                widget.data[2][index].toDouble(),
            color: normalColor,
            width: barsWidth,
            borderRadius: BorderRadius.circular(0),
            rodStackItems: [
              BarChartRodStackItem(
                0,
                widget.data[0][index].toDouble(),
                normalColor,
              ),
              BarChartRodStackItem(
                widget.data[0][index].toDouble(),
                widget.data[0][index].toDouble() +
                    widget.data[1][index].toDouble(),
                secondColor,
              ),
              BarChartRodStackItem(
                widget.data[0][index].toDouble() +
                    widget.data[1][index].toDouble(),
                widget.data[0][index].toDouble() +
                    widget.data[1][index].toDouble() +
                    widget.data[2][index].toDouble(),
                thirdColor,
              ),
            ],
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
        buildLegend(), //called widget legend
      ],
    );
  }
}
