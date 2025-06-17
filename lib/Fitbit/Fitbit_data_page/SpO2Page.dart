import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_spo2_service.dart';

class SpO2Page extends StatefulWidget {
  final FitbitSpO2Service spo2Service;

  const SpO2Page({Key? key, required this.spo2Service}) : super(key: key);

  @override
  State<SpO2Page> createState() => _SpO2PageState();
}

class _SpO2PageState extends State<SpO2Page> {
  DateTime currentStartDate = _startOfWeek(DateTime.now());
  List<Map<String, dynamic>> spo2Data = [];
  bool isLoading = false;
  String? errorMessage;

  static DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday));
  }

  @override
  void initState() {
    super.initState();
    _fetchSpO2();
  }

  Future<void> _fetchSpO2() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await widget.spo2Service.fetchWeeklySpO2(currentStartDate);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (result == null || result['data'] == null) {
        errorMessage = '找不到 SpO2 資料，請檢查網路或權限。';
        spo2Data = [];
      } else {
        spo2Data = (result['data'] as List<dynamic>)
            .map((e) => {
                  'date': e['date'],
                  'value': e['value'],
                })
            .toList();
      }
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      currentStartDate = currentStartDate.subtract(const Duration(days: 7));
    });
    _fetchSpO2();
  }

  void _goToNextWeek() {
    final now = DateTime.now();
    final nextStartDate = currentStartDate.add(const Duration(days: 7));
    if (nextStartDate.isBefore(_startOfWeek(now).add(const Duration(days: 1)))) {
      setState(() {
        currentStartDate = nextStartDate;
      });
      _fetchSpO2();
    }
  }

  String _weekLabel() {
    final formatter = DateFormat('M月d日');
    final endDate = currentStartDate.add(const Duration(days: 6));
    final isThisWeek = _startOfWeek(DateTime.now()).difference(currentStartDate).inDays == 0;
    return isThisWeek ? '本週' : '${formatter.format(currentStartDate)} 至 ${formatter.format(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每週 SpO2 變化'),
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
              IconButton(icon: const Icon(Icons.arrow_left), onPressed: isLoading ? null : _goToPreviousWeek),
              Text(_weekLabel(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_right), onPressed: isLoading ? null : _goToNextWeek),
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
  Expanded(
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        SizedBox(height: 300, child: _buildLineChart()),
        const SizedBox(height: 24),
        const Text(
          '血氧濃度：',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '通常是指血液中氧氣的飽和程度，最常見的測量指標是血氧飽和度（SpO₂）。'
          '簡單來說，就是你血液裡的血紅蛋白中有多少百分比正在運送氧氣。',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        const Text(
          '如何偵測：',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '手環只會在你睡覺時收集血氧濃度資料並估算數值，'
          '而且只會將超過 3 小時的睡眠納入計算。'
          '一般來說，睡眠期間的血氧濃度會比清醒時低，'
          '這是因為睡眠時的呼吸速率通常比較慢。'
          '睡眠期間的血氧濃度通常會高於 90%。',
          style: TextStyle(fontSize: 14),
        ),
      ],
    ),
  ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final validSpots = <FlSpot>[];
    bool hasAnyData = false;

   
    for (int i = 0; i < 7; i++) {
      final date = currentStartDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final match = spo2Data.firstWhere(
        (e) => e['date'] == dateStr,
        orElse: () => {'value': null},
      );
      final value = (match['value'] as num?)?.toDouble();

      if (value != null) {
        validSpots.add(FlSpot(i.toDouble(), value));
        hasAnyData = true;
      }
    }

    if (!hasAnyData) {
      return const Center(child: Text('本週無 SpO2 資料', style: TextStyle(color: Colors.grey)));
    }

    final validYs = validSpots.map((s) => s.y);
    double maxY = validYs.reduce((a, b) => a > b ? a : b) + 1;
    double minY = validYs.reduce((a, b) => a < b ? a : b) - 1;
    if ((maxY - minY).abs() < 1e-6) {
      maxY += 1;
      minY -= 1;
    }

    return LineChart(
      LineChartData(
        minX: 0, 
        maxX: 6, 
        minY: minY,
        maxY: maxY,
        clipData: FlClipData(
          top: true,
          bottom: true,
          left: true,
          right: true,
        ),
        extraLinesData: ExtraLinesData(),
        lineBarsData: [
          LineChartBarData(
            spots: validSpots,
            isCurved: true,
            isStrokeCapRound: true,
            barWidth: 3,
            color: Colors.blue,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => true,
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const weekday = ['日', '一', '二', '三', '四', '五', '六'];
                final index = value.toInt();
                return index >= 0 && index < 7
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(weekday[index], style: const TextStyle(fontSize: 12)),
                      )
                    : const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}%',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 1, 
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black26, width: 1),
        ),
      ),
    );
  }
}