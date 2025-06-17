import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_temperature_service.dart';

class TemperaturePage extends StatefulWidget {
  final FitbitTemperatureService temperatureService;

  const TemperaturePage({Key? key, required this.temperatureService}) : super(key: key);

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  DateTime currentStartDate = _startOfWeek(DateTime.now());
  List<Map<String, dynamic>> temperatureData = [];
  bool isLoading = false;
  String? errorMessage;

  static DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday));
  }

  @override
  void initState() {
    super.initState();
    _fetchTemperature();
  }

  Future<void> _fetchTemperature() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await widget.temperatureService.fetchWeeklySkinTemperature(currentStartDate);

    setState(() {
      isLoading = false;
      if (result == null || result['data'] == null) {
        errorMessage = '找不到膚溫資料，請檢查網路或權限。';
        temperatureData = [];
      } else {
        temperatureData = (result['data'] as List<dynamic>)
            .map((e) => {
                  'date': e['date'],
                  'temperature': e['value'],
                })
            .toList();
      }
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      currentStartDate = currentStartDate.subtract(const Duration(days: 7));
    });
    _fetchTemperature();
  }

  void _goToNextWeek() {
    final now = DateTime.now();
    final nextStartDate = currentStartDate.add(const Duration(days: 7));
    if (nextStartDate.isBefore(_startOfWeek(now).add(const Duration(days: 1)))) {
      setState(() {
        currentStartDate = nextStartDate;
      });
      _fetchTemperature();
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
      title: const Text('每週膚溫變化'),
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
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      children: [
                        SizedBox(height: 300, width: double.infinity, child: _buildLineChart()),
                        const SizedBox(height: 24),
                        const Text(
                          '皮膚溫度變化：',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '皮膚溫度變化是指在你睡眠時，從手腕測量到的溫度起伏情況。'
                          '皮膚溫度並不是核心溫度（體內溫度），體內溫度通常要溫度計才能測量出。'
                          '可能導致皮膚溫度變化的因素包括：室內溫度、寢具、月經週期等等。',
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
      final match = temperatureData.firstWhere(
        (e) => e['date'] == dateStr,
        orElse: () => {'temperature': null},
      );
      final temp = (match['temperature'] as num?)?.toDouble();

      if (temp != null) {
        validSpots.add(FlSpot(i.toDouble(), temp));
        hasAnyData = true;
      }
    }

    if (!hasAnyData) {
      return const Center(child: Text('本週無膚溫變化資料', style: TextStyle(color: Colors.grey)));
    }

    final validYs = validSpots.map((s) => s.y);
    final maxY = validYs.reduce((a, b) => a > b ? a : b) + 1;
    final minY = validYs.reduce((a, b) => a < b ? a : b) - 1;

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
            color: Colors.deepOrange,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => true,
            ),
            belowBarData: BarAreaData(show: false),
          )
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.5,
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
                  '${spot.y.toStringAsFixed(1)}°C',
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
          horizontalInterval: 0.5,
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