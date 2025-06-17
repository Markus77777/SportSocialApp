import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_sleep_service.dart';

class SleepPage extends StatefulWidget {
  final FitbitSleepService sleepService;
  const SleepPage({Key? key, required this.sleepService}) : super(key: key);

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  DateTime selectedDate = DateTime.now();
  Duration totalSleep = Duration.zero;
  int sleepScore = 0;
  String sleepRange = '';
  List<Map<String, String>> sleepStages = [];
  bool isLoading = true;

  String selectedStage = '';
  String selectedTimeRange = '';

  @override
  void initState() {
    super.initState();
    _fetchSleepData();
  }

  Future<void> _fetchSleepData() async {
    setState(() => isLoading = true);
    final summary = await widget.sleepService.fetchSleepSummary(selectedDate);
    final stages = await widget.sleepService.fetchSleepStages(selectedDate);

    setState(() {
      totalSleep = Duration(minutes: summary?['totalMinutesAsleep'] ?? 0);
      sleepScore = summary?['efficiency'] ?? 0;
      sleepRange = summary?['startTime'] != null && summary?['endTime'] != null
          ? '${DateFormat.Hm().format(DateTime.parse(summary!['startTime']).toLocal())} - ${DateFormat.Hm().format(DateTime.parse(summary['endTime']).toLocal())}'
          : '';
      sleepStages = stages ?? [];
      selectedStage = '';
      selectedTimeRange = '';
      isLoading = false;
    });
  }

  void _changeDate(int offsetDays) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offsetDays));
    });
    _fetchSleepData();
  }

  String _dateLabel() {
    final now = DateTime.now();
    if (DateUtils.isSameDay(selectedDate, now)) return '今天';
    if (DateUtils.isSameDay(
        selectedDate, now.subtract(const Duration(days: 1)))) return '昨天';
    return DateFormat('M月d日').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('睡眠紀錄'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () => _changeDate(-1),
                        icon: const Icon(Icons.arrow_left)),
                    Text(_dateLabel(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        if (!DateUtils.isSameDay(
                            selectedDate, DateTime.now())) {
                          _changeDate(1);
                        }
                      },
                      icon: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '總睡眠時間：${totalSleep.inHours} 小時 ${totalSleep.inMinutes % 60} 分鐘',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('目標：8 小時',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '睡眠時間',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      selectedStage.isNotEmpty && selectedTimeRange.isNotEmpty
                          ? '$selectedStage：$selectedTimeRange'
                          : '',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(sleepRange, style: const TextStyle(fontSize: 25)),
                const SizedBox(height: 16),
                _buildVisualSleepChart(screenWidth),
                const SizedBox(height: 24),
    const Text(
      '一般睡眠週期:',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    const Text(
      '在您入睡後，身體通常會經歷數個睡眠週期，每個週期一般維持90到120分鐘。',
      style: TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 8),
    const Text(
      '手環根據身體信號偵測3種睡眠階段：',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    const Text(
      '• 快速動眼(REM)睡眠：睡覺時會容易做比較清晰的夢，且心律和呼吸速率可能出現變化。',
      style: TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 4),
    const Text(
      '• 淺層睡眠：睡覺時可能會有較多動作，且偶爾醒來幾分鐘。',
      style: TextStyle(fontSize: 14),
    ),
    const SizedBox(height: 4),
    const Text(
      '• 深層睡眠：睡覺時比較不會有動作，且心跳速度較慢也較有規律。',
      style: TextStyle(fontSize: 14),
    ),
              ],
            ),
    );
  }

  Widget _buildVisualSleepChart(double chartWidth) {
    final stageOrder = ['清醒', '快速動眼', '淺層睡眠', '深層睡眠'];
    final stageColors = {
      '清醒': Colors.amber,
      '快速動眼': Colors.purple.shade300,
      '淺層睡眠': Colors.indigo.shade400,
      '深層睡眠': Colors.indigo.shade900,
    };

    final startHour =
        sleepStages.isNotEmpty ? _parseTime(sleepStages.first['start']!) : 0.0;
    final endHour =
        sleepStages.isNotEmpty ? _parseTime(sleepStages.last['end']!) : 8.0;
    final totalHours = endHour - startHour;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stageOrder.map((stageName) {
        final segments =
            sleepStages.where((s) => s['stage'] == stageName);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$stageName：${_formatStageDuration(stageName)}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 14,
                    width: chartWidth,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12, width: 1),
                      color: Colors.grey[200],
                    ),
                  ),
                  SizedBox(
                    height: 14,
                    width: chartWidth,
                    child: Stack(
                      children: segments.map((s) {
                        final start = (_parseTime(s['start']!) - startHour) /
                            totalHours;
                        final end = (_parseTime(s['end']!) - startHour) /
                            totalHours;
                        final left = start * chartWidth;
                        final width = (end - start) * chartWidth;
                        return Positioned(
                          left: left,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStage = stageName;
                                selectedTimeRange =
                                    '${s['start']!} - ${s['end']!}';
                              });
                            },
                            child: Container(
                              width: width,
                              height: 14,
                              color: stageColors[stageName],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              if (stageName == '深層睡眠') ...[
                const SizedBox(height: 6),
                _buildTimeTicks(startHour, endHour, chartWidth),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }

Widget _buildTimeTicks(double startHour, double endHour, double chartWidth) {
  final double interval = (endHour - startHour) / 3;
  final List<double> tickHours = [
    startHour,
    startHour + interval,
    startHour + 2 * interval,
    endHour,
  ];

  return Row(
    children: List.generate(tickHours.length, (i) {
      final hour = tickHours[i];
      final label =
          '${hour.floor().toString().padLeft(2, '0')}:${((hour % 1) * 60).round().toString().padLeft(2, '0')}';

      TextAlign align;
      if (i == 0) {
        align = TextAlign.left;
      } else if (i == tickHours.length - 1) {
        align = TextAlign.right;
      } else {
        align = TextAlign.center;
      }

      return Expanded(
        child: Text(
          label,
          textAlign: align,
          style: const TextStyle(fontSize: 12),
        ),
      );
    }),
  );
}


  String _formatStageDuration(String stageName) {
    final segments = sleepStages.where((s) => s['stage'] == stageName);
    int totalMinutes = 0;
    for (var s in segments) {
      final start = _parseTime(s['start']!);
      final end = _parseTime(s['end']!);
      totalMinutes += ((end - start) * 60).round();
    }
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h > 0 ? '$h小時 ' : ''}$m分鐘';
  }

  double _parseTime(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return parts[0] + parts[1] / 60.0;
  }
}
