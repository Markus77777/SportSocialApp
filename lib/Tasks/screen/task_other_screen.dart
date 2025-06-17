import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app1/Tasks/fitbit_task_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_auth_service.dart';

class TaskOtherScreen extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final FitbitAuthService authService;

  const TaskOtherScreen({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.authService,
  });

  @override
  State<TaskOtherScreen> createState() => _TaskOtherScreenState();
}

class _TaskOtherScreenState extends State<TaskOtherScreen> {
  late final FitbitTaskService service;
  bool loading = true;

  List<FlSpot> heartRateData = [];
  List<String> heartRateTimes = [];
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    service = FitbitTaskService();
    _loadData();
  }

  Future<void> _loadData() async {
    final heartList = await service.fetchHeartRateData(widget.startTime, widget.endTime);

    setState(() {
      heartRateData = heartList.asMap().entries.map(
        (e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble()),
      ).toList();
      heartRateTimes = heartList.map((e) => e['time'] as String).toList();
      loading = false;
    });
  }

  Widget _buildHeartRateChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('心律變化（每5分鐘）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: heartRateData.length.toDouble().clamp(1, double.infinity),
                minY: heartRateData.isEmpty ? 0 : heartRateData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 5,
                maxY: heartRateData.isEmpty ? 100 : heartRateData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: heartRateData,
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: false),
                  )
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      reservedSize: 32,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (heartRateData.length / 6).floorToDouble().clamp(1, 999),
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= heartRateTimes.length) return const SizedBox();
                        return Text(
                          heartRateTimes[index].substring(0, 5),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        final time = index < heartRateTimes.length ? heartRateTimes[index] : '';
                        return LineTooltipItem(
                          '$time\n心律 ${touchedSpot.y.toInt()} bpm',
                          const TextStyle(color: Colors.white, fontSize: 14),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('其他活動分析')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        '分析時間：\n${widget.startTime.toLocal().toString().substring(0, 16)} ~\n${widget.endTime.toLocal().toString().substring(0, 16)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  _buildHeartRateChart(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
