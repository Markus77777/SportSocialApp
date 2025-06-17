import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_heart_service.dart';

class HeartRatePage extends StatefulWidget {
  final FitbitHeartService heartService;

  const HeartRatePage({Key? key, required this.heartService}) : super(key: key);

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  Map<String, dynamic>? heartRateData;
  String? errorMessage;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now(); // 新增

  @override
  void initState() {
    super.initState();
    _fetchHeartRate(date: selectedDate);
  }

  Future<void> _fetchHeartRate({required DateTime date}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final data = await widget.heartService.fetchIntraday(date: date);

    setState(() {
      isLoading = false;
      selectedDate = date;
      if (data == null) {
        errorMessage = '無法獲取心率數據，請檢查網路或權限';
      } else if (data['type'] == 'empty') {
        errorMessage = '${_formatDateLabel(date)}沒有心率數據';
        heartRateData = null;
      } else {
        heartRateData = data;
      }
    });
  }

  void _goToPreviousDay() {
    final prevDate = selectedDate.subtract(const Duration(days: 1));
    if (prevDate.isAfter(DateTime.now().subtract(const Duration(days: 8)))) {
      _fetchHeartRate(date: prevDate);
    }
  }

  void _goToNextDay() {
    final nextDate = selectedDate.add(const Duration(days: 1));
    if (!nextDate.isAfter(DateTime.now())) {
      _fetchHeartRate(date: nextDate);
    }
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) {
      return '今天';
    } else if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return '昨天';
    } else {
      return DateFormat('MM/dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心率紀錄'),
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
                onPressed: selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 7)))
                    ? _goToPreviousDay
                    : null,
              ),
              Text(
                _formatDateLabel(selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: selectedDate.isBefore(DateTime.now())
                    ? _goToNextDay
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (heartRateData != null)
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '顯示當日 24 小時的每 5 分鐘心率數據',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          SizedBox(height: 300, child: _buildChart()),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Text(
              '免責聲明：本應用所顯示之健康數據僅供參考，不能作為任何醫療診斷或治療依據。如有健康疑慮，請諮詢專業醫療人員。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (errorMessage != null) {
      return const Center(child: Text('無法顯示圖表，請檢查數據'));
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (heartRateData != null && heartRateData!['type'] == 'intraday') {
      final List<dynamic> dataset = heartRateData!['data'];

      if (dataset.isEmpty) {
        return const Center(child: Text('沒有分鐘級心率數據'));
      }

      List<List<FlSpot>> segments = [];
      List<FlSpot> currentSegment = [];

      DateTime? lastTime;

      for (var point in dataset) {
        final timeParts = (point['time'] as String).split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        final value = (point['value'] as num?)?.toDouble();
        if (value == null) continue;

        final currentTime = DateTime(0, 1, 1, hour, minute);

        if (lastTime != null && currentTime.difference(lastTime).inMinutes > 10) {
          if (currentSegment.isNotEmpty) {
            segments.add(currentSegment);
            currentSegment = [];
          }
        }

        final timeAsDouble = hour + (minute / 60.0);
        currentSegment.add(FlSpot(timeAsDouble, value));
        lastTime = currentTime;
      }

      if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
      }

      if (segments.isEmpty) {
        return const Center(child: Text('資料中沒有有效心率紀錄'));
      }

      final allY = segments.expand((s) => s).map((e) => e.y).toList();
      final maxY = allY.reduce((a, b) => a > b ? a : b) * 1.2;
      final minY = allY.reduce((a, b) => a < b ? a : b) * 0.8;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 24,
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  getTitlesWidget: (value, _) => Text(
                    '${value.toInt()}:00',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  getTitlesWidget: (value, _) => Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: segments
                .map(
                  (segment) => LineChartBarData(
                    isCurved: true,
                    spots: segment,
                    color: Colors.red,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    return const Center(child: Text('請獲取數據以顯示圖表'));
  }
}
