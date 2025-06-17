import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_steps_service.dart';

class StepsPage extends StatefulWidget {
  final FitbitStepsService stepService;

  const StepsPage({Key? key, required this.stepService}) : super(key: key);

  @override
  State<StepsPage> createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  DateTime currentStartDate = _startOfWeek(DateTime.now());
  List<Map<String, dynamic>> stepsData = [];
  bool isLoading = false;
  String? errorMessage;

  static DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7)); 
  }

  @override
  void initState() {
    super.initState();
    _fetchSteps();
  }

  Future<void> _fetchSteps() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await widget.stepService.fetchWeeklySteps(currentStartDate);

    setState(() {
      isLoading = false;

      if (result == null || result['data'] == null) {
        errorMessage = '找不到步數資料，請檢查網路或權限。';
        stepsData = [];
      } else {
        stepsData = (result['data'] as List<dynamic>)
            .map((e) => {
                  'date': e['date'],
                  'steps': e['value'] ?? 0,
                })
            .toList();
      }
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      currentStartDate = currentStartDate.subtract(const Duration(days: 7));
    });
    _fetchSteps();
  }

  void _goToNextWeek() {
    final now = DateTime.now();
    final nextStartDate = currentStartDate.add(const Duration(days: 7));
    if (nextStartDate.isBefore(_startOfWeek(now).add(const Duration(days: 1)))) {
      setState(() {
        currentStartDate = nextStartDate;
      });
      _fetchSteps();
    }
  }

  String _weekLabel() {
    final formatter = DateFormat('M月d日');
    final endDate = currentStartDate.add(const Duration(days: 6));
    final isThisWeek =
        _startOfWeek(DateTime.now()).difference(currentStartDate).inDays == 0;
    return isThisWeek
        ? '本週'
        : '${formatter.format(currentStartDate)} 至 ${formatter.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每週步數'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: _goToPreviousWeek),
              Text(_weekLabel(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: _goToNextWeek),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const CircularProgressIndicator()
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            )
          else
            Column(
              children: [
                SizedBox(height: 300, child: _buildBarChart()),
                _buildSuggestion(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final days = ['日', '一', '二', '三', '四', '五', '六'];

    final barGroups = stepsData.asMap().entries.map((entry) {
      final index = entry.key;
      final steps = (entry.value['steps'] as num?)?.toDouble() ?? 0;
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(toY: steps, color: Colors.blue, width: 16)
      ]);
    }).toList();

    final maxY = stepsData.isEmpty
        ? 10000
        : stepsData
                .map((e) => (e['steps'] as num?)?.toDouble() ?? 0)
                .reduce((a, b) => a > b ? a : b) *
            1.2;

    final adjustedInterval = maxY <= 10000
        ? 2500
        : maxY <= 20000
            ? 5000
            : 10000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          maxY: maxY.toDouble(),
          minY: 0,
          barGroups: barGroups,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: adjustedInterval.toDouble(),
                getTitlesWidget: (value, _) {
                  final kValue = value >= 1000
                      ? '${(value / 1000).toStringAsFixed(1)}K'
                      : value.toInt().toString();
                  return Text(kValue, style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text(days[value.toInt()],
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

Widget _buildSuggestion() {
  final totalSteps = stepsData.fold<int>(
    0,
    (sum, item) => sum + (item['steps'] as int? ?? 0),
  );

  final List<int> dailySteps = stepsData
      .map((item) => (item['steps'] as int?) ?? 0)
      .toList();

  final int goalPerWeek = 10000 * 7;

  String message;
  Color color;

  bool hasVeryLowDays =
      dailySteps.where((steps) => steps < 3000).length >= 3;

  bool hasHighVariance =
      dailySteps.any((steps) => steps >= 10000) &&
      dailySteps.any((steps) => steps < 3000);

  bool isDeclining = dailySteps.length >= 3 &&
      dailySteps[dailySteps.length - 3] > dailySteps[dailySteps.length - 2] &&
      dailySteps[dailySteps.length - 2] > dailySteps[dailySteps.length - 1];

  if (totalSteps >= goalPerWeek) {
    message = '🎉 恭喜！你本週已達到目標步數，保持運動習慣對健康很有幫助。';
    color = Colors.green;
  } else if (hasVeryLowDays) {
    message = '🔴 本週有多天步數少於 3000 步，建議避免久坐，保持基本活動量。';
    color = Colors.red;
  } else if (isDeclining) {
    message = '💤 你這幾天的步數有明顯下降，可能是疲勞累積，建議注意休息與恢復。';
    color = Colors.orange;
  } else if (hasHighVariance) {
    message = '📉 你的步數變化很大，建議平日也能穩定維持基本活動。';
    color = Colors.orange;
  } else if (totalSteps >= 50000) {
    message = '⚠️ 這週表現不錯，但距離理想步數還有一點距離，加油！';
    color = Colors.orange;
  } else {
    message = '📉 本週步數偏少，試著安排散步或日常走動時間來維持健康。';
    color = Colors.red;
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
    ),
  );
}

}
