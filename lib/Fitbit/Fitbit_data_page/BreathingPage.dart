import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_breathing_service.dart';

class BreathingPage extends StatefulWidget {
  final FitbitBreathingService breathingService;

  const BreathingPage({Key? key, required this.breathingService})
      : super(key: key);

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  DateTime currentStartDate = _startOfWeek(DateTime.now());
  List<Map<String, dynamic>> breathingData = [];
  bool isLoading = false;
  String? errorMessage;

  static DateTime _startOfWeek(DateTime date) {
    // Changed to make Sunday the start of the week
    return date.subtract(Duration(days: date.weekday));
  }

  @override
  void initState() {
    super.initState();
    _fetchBreathingRate();
  }

  Future<void> _fetchBreathingRate() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await widget.breathingService
        .fetchWeeklyBreathingRate(currentStartDate);

    if (!mounted) return;

    setState(() {
      isLoading = false;
      if (result == null || result['data'] == null) {
        errorMessage = '找不到呼吸速率資料，請檢查網路或權限。';
        breathingData = [];
      } else {
        breathingData = (result['data'] as List<dynamic>)
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
    _fetchBreathingRate();
  }

  void _goToNextWeek() {
    final now = DateTime.now();
    final nextStartDate = currentStartDate.add(const Duration(days: 7));
    if (nextStartDate
        .isBefore(_startOfWeek(now).add(const Duration(days: 1)))) {
      setState(() {
        currentStartDate = nextStartDate;
      });
      _fetchBreathingRate();
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
        title: const Text('每週呼吸速率變化'),
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
                  onPressed: isLoading ? null : _goToPreviousWeek),
              Text(_weekLabel(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: isLoading ? null : _goToNextWeek),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        children: [
                          SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: _buildLineChart()),
                          const SizedBox(height: 24),
                          const Text(
                            '呼吸速率 (BR)：',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '呼吸速率是指你每分鐘的呼吸次數，身體會調整呼吸速率，'
                            '以便從血液中排出二氧化碳並獲取足夠氧氣。'
                            '睡眠期間的呼吸速率通常為 12 至 20 次/分鐘。',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '如何偵測：',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '手環只會在你睡覺時測量呼吸速率資料並估算數值，'
                            '而且只會將超過 3 小時的睡眠納入計算。',
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
      final match = breathingData.firstWhere(
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
      return const Center(
          child: Text('本週無呼吸速率資料', style: TextStyle(color: Colors.grey)));
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
            color: Colors.green,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) =>
                  true, 
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
                        child: Text(weekday[index],
                            style: const TextStyle(fontSize: 12)),
                      )
                    : const Text('');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 0)),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} 次/分',
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
