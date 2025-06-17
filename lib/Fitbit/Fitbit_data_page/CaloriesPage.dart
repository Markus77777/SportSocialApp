import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_calories_service.dart'; 

class CaloriesPage extends StatefulWidget {
  final FitbitCaloriesService caloriesService;

  const CaloriesPage({Key? key, required this.caloriesService}) : super(key: key);

  @override
  State<CaloriesPage> createState() => _CaloriesPageState();
}

class _CaloriesPageState extends State<CaloriesPage> {
  DateTime currentStartDate = _startOfWeek(DateTime.now());
  List<Map<String, dynamic>> caloriesData = [];
  bool isLoading = false;
  String? errorMessage;

  static DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7)); // 週日開始
  }
int _calculateAverageCalories() {
  if (caloriesData.isEmpty) return 0;
  final total = caloriesData.fold<int>(
    0,
    (sum, item) => sum + (item['calories'] as int? ?? 0),
  );
  return (total / caloriesData.length).round();
}


  @override
  void initState() {
    super.initState();
    _fetchCalories();
  }

  Future<void> _fetchCalories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await widget.caloriesService.fetchWeeklyCalories(currentStartDate);

    setState(() {
      isLoading = false;

      if (result == null || result['data'] == null) {
        errorMessage = '找不到熱量資料，請檢查網路或權限。';
        caloriesData = [];
      } else {
        caloriesData = (result['data'] as List<dynamic>)
            .map((e) => {
                  'date': e['date'],
                  'calories': e['value'] ?? 0,
                })
            .toList();
      }
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      currentStartDate = currentStartDate.subtract(const Duration(days: 7));
    });
    _fetchCalories();
  }

  void _goToNextWeek() {
    final now = DateTime.now();
    final nextStartDate = currentStartDate.add(const Duration(days: 7));
    if (nextStartDate.isBefore(_startOfWeek(now).add(const Duration(days: 1)))) {
      setState(() {
        currentStartDate = nextStartDate;
      });
      _fetchCalories();
    }
  }

  String _weekLabel() {
    final formatter = DateFormat('M月d日');
    final endDate = currentStartDate.add(const Duration(days: 6));
    final isThisWeek = _startOfWeek(DateTime.now()).difference(currentStartDate).inDays == 0;
    return isThisWeek
        ? '本週'
        : '${formatter.format(currentStartDate)} 至 ${formatter.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每週熱量消耗'),
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
              IconButton(icon: const Icon(Icons.arrow_left), onPressed: _goToPreviousWeek),
              Text(_weekLabel(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_right), onPressed: _goToNextWeek),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const CircularProgressIndicator()
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            )
          else
            Column(
    children: [
      Text(
        '本週平均熱量消耗：${_calculateAverageCalories()} kcal',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
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

    final barGroups = caloriesData.asMap().entries.map((entry) {
      final index = entry.key;
      final calories = (entry.value['calories'] as num?)?.toDouble() ?? 0;
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(toY: calories, color: Colors.orange, width: 16),
      ]);
    }).toList();

    final maxCalories = caloriesData.isEmpty
        ? 2000
        : caloriesData.map((e) => (e['calories'] as num?)?.toDouble() ?? 0).reduce((a, b) => a > b ? a : b) * 1.2;

    final adjustedInterval = maxCalories <= 2000
        ? 500
        : maxCalories <= 4000
            ? 1000
            : 2000;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BarChart(
        BarChartData(
          maxY: maxCalories.toDouble(),
          minY: 0,
          barGroups: barGroups,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: adjustedInterval.toDouble(),
                getTitlesWidget: (value, _) {
                  final formatted = value >= 1000
                      ? '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K'
                      : value.toInt().toString();
                  return Text(
                    formatted,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
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
  final totalCalories = caloriesData.fold<int>(
    0,
    (sum, item) => sum + (item['calories'] as int? ?? 0),
  );

  final dailyCalories = caloriesData
      .map((e) => (e['calories'] as int?) ?? 0)
      .toList();

  bool hasLowDays = dailyCalories.where((c) => c < 1500).length >= 3;

  bool isDeclining = dailyCalories.length >= 3 &&
      dailyCalories[dailyCalories.length - 3] > dailyCalories[dailyCalories.length - 2] &&
      dailyCalories[dailyCalories.length - 2] > dailyCalories[dailyCalories.length - 1];

  String message;
  Color color;

  if (totalCalories >= 17500) {
    message = '🎉 活動量充足，本週熱量消耗表現優異，保持下去！';
    color = Colors.green;
  } else if (hasLowDays) {
    message = '⚠️ 本週有多天熱量消耗低於 1500 卡，建議增加活動時間。';
    color = Colors.orange;
  } else if (isDeclining) {
    message = '💤 最近熱量消耗連續下降，可能是活動減少或疲勞，建議注意恢復。';
    color = Colors.red;
  } else if (totalCalories >= 12500) {
    message = '👍 熱量消耗尚可，持續維持運動與活動習慣。';
    color = Colors.blue;
  } else {
    message = '📉 熱量消耗略低於建議，可考慮安排更多日常活動。';
    color = Colors.orange;
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
