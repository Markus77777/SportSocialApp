import 'package:flutter/material.dart';
import 'package:flutter_app1/Fitbit/FitbitAuthWebView.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_auth_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_heart_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_steps_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_sleep_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_calories_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_temperature_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_spo2_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_breathing_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_hrv_service.dart';
import 'package:flutter_app1/Fitbit/Fitbit_service/fitbit_constants.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/HeartRatePage.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/StepsPage.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/CaloriesPage.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/SleepPage.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/TemperaturePage.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/SpO2Page.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/BreathingPage.dart';
import 'package:flutter_app1/Fitbit/Fitbit_data_page/HRVPage.dart';

class FitbitPage extends StatefulWidget {
  const FitbitPage({Key? key}) : super(key: key);

  @override
  State<FitbitPage> createState() => _FitbitPageState();
}

class _FitbitPageState extends State<FitbitPage> {
  final _authService = FitbitAuthService();

  late final FitbitHeartService _heartService;
  late final FitbitStepsService _stepsService;
  late final FitbitSleepService _sleepService;
  late final FitbitCaloriesService _caloriesService;
  late final FitbitSpO2Service _spo2Service;
  late final FitbitBreathingService _breathingService;
  late final FitbitHRVService _hrvService;
  late final FitbitTemperatureService _temperatureService;

  bool _authInitiated = false;

  int? currentHeartRate;
  int? todaySteps;
  Duration? todaySleepDuration;
  int? todayCalories;
  double? todaySpO2;
  double? todayBreathingRate;
  double? todayHRV;
  double? todaySkinTemperature;

  String greetingMessage = '';
  String activitySuggestion = '';
  String sleepSuggestion = '';

  @override
  void initState() {
    super.initState();

    _heartService = FitbitHeartService();
    _stepsService = FitbitStepsService();
    _sleepService = FitbitSleepService();
    _caloriesService = FitbitCaloriesService();
    _spo2Service = FitbitSpO2Service();
    _breathingService = FitbitBreathingService();
    _hrvService = FitbitHRVService();
    _temperatureService = FitbitTemperatureService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authService.accessToken == null && !_authInitiated) {
        _authInitiated = true;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FitbitAuthWebView(
              authUrl: authUrl,
              onCodeReceived: (code) async {
                final success = await _authService.handleCallback(code);
                if (success) {
                  await _fetchData();
                  setState(() {});
                }
              },
            ),
          ),
        );
      } else {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    final heartRate = await _heartService.fetchCurrent();
    final steps = await _stepsService.fetchTodaySteps();
    final sleep = await _sleepService.fetchTodaySleepDuration();
    final calories = await _caloriesService.fetchCaloriesOut();
    final spo2 = await _spo2Service.fetchTodaySpO2();
    final br = await _breathingService.fetchBreathingRate();
    final hrv = await _hrvService.fetchHRV();
    final skinTemp = await _temperatureService.fetchTodaySkinTemperature();

    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = '早安 ☀️，今天是充滿活力的一天！';
    } else if (now.hour < 18) {
      greeting = '午安 🌤，別忘了起身活動一下喔！';
    } else {
      greeting = '晚安 🌙，放鬆身心，好好休息吧～';
    }

    String activity;
    if ((steps ?? 0) >= 10000 || (calories ?? 0) >= 2500) {
      activity = '今日活動量很棒，繼續保持 💪';
    } else if ((steps ?? 0) >= 5000) {
      activity = '今天活動中等，再多走點路會更好 🏃‍♂️';
    } else {
      activity = '今日活動偏少，記得起來動一動！🚶';
    }

    final totalMinutes = sleep?.inMinutes ?? 0;
    String sleepRating;
    if (totalMinutes >= 470) {
      sleepRating = '昨晚睡眠充足，精神滿滿！😴';
    } else if (totalMinutes >= 360) {
      sleepRating = '睡眠略少，今晚記得早點休息 🛏️';
    } else {
      sleepRating = '昨晚睡眠不足，建議儘早補眠 💤';
    }
    if (!mounted) return;
    setState(() {
      currentHeartRate = heartRate;
      todaySteps = steps;
      todaySleepDuration = sleep;
      todayCalories = calories;
      todaySpO2 = spo2;
      todayBreathingRate = br;
      todayHRV = hrv;
      todaySkinTemperature = skinTemp;

      greetingMessage = greeting;
      activitySuggestion = activity;
      sleepSuggestion = sleepRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: const Color(0xFFFFCC80),
        title: const Text(
          '智慧手環功能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFamily: 'Noto Sans',
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: '登出 Fitbit',
            onPressed: () async {
              await FitbitAuthService().disconnect();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已斷開 Fitbit 連結')),
                );
              }
            },
          ),
        ],
      ),
      body: _authService.accessToken == null
          ? const Center(child: Text('連結中，正在跳轉...'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuggestionCard(
                      title: '🧠 日常建議',
                      content: [
                        greetingMessage,
                        activitySuggestion,
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSuggestionCard(
                      title: '😴 睡眠建議',
                      content: [
                        sleepSuggestion,
                        if (todaySpO2 != null && todaySpO2! < 90)
                          '⚠️ 血氧濃度偏低，建議注意呼吸品質',
                        if (todayBreathingRate != null &&
                            (todayBreathingRate! < 12 ||
                                todayBreathingRate! > 20))
                          '⚠️ 呼吸速率異常 (${todayBreathingRate!.toStringAsFixed(1)} 次/分)',
                        if (todayHRV != null && todayHRV! < 30)
                          '📉 HRV 偏低，可能與壓力或睡眠品質有關',
                        if (todaySkinTemperature != null &&
                            todaySkinTemperature!.abs() > 1.5)
                          '🌡️ 皮膚溫度變化顯著 (${todaySkinTemperature!.toStringAsFixed(1)} °C)，可能與環境或生理週期有關',
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '生理即時數據',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _buildCard(
                          title: '心律',
                          value: currentHeartRate != null
                              ? '$currentHeartRate bpm'
                              : '沒有資料',
                          icon: Icons.favorite,
                          color: Colors.redAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HeartRatePage(heartService: _heartService),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '步數',
                          value: todaySteps != null ? '$todaySteps 步' : '沒有資料',
                          icon: Icons.directions_walk,
                          color: Colors.blueAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    StepsPage(stepService: _stepsService),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '卡路里',
                          value: todayCalories != null
                              ? '$todayCalories kcal'
                              : '沒有資料',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CaloriesPage(
                                    caloriesService: _caloriesService),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '睡眠',
                          value: todaySleepDuration != null
                              ? '${todaySleepDuration!.inHours} 小時 ${(todaySleepDuration!.inMinutes % 60)} 分鐘'
                              : '沒有資料',
                          icon: Icons.bedtime,
                          color: Colors.deepPurpleAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SleepPage(sleepService: _sleepService),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '血氧濃度',
                          value: todaySpO2 != null
                              ? '${todaySpO2!.toStringAsFixed(1)}%'
                              : '沒有資料',
                          icon: Icons.bloodtype,
                          color: Colors.pinkAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SpO2Page(spo2Service: _spo2Service),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '呼吸速率',
                          value: todayBreathingRate != null
                              ? '${todayBreathingRate!.toStringAsFixed(1)} 次/分'
                              : '沒有資料',
                          icon: Icons.air,
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BreathingPage(
                                    breathingService: _breathingService),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '心律變異',
                          value: todayHRV != null
                              ? '${todayHRV!.toStringAsFixed(1)} ms'
                              : '沒有資料',
                          icon: Icons.show_chart,
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HRVPage(hrvService: _hrvService),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          title: '睡眠膚溫變化',
                          value: todaySkinTemperature != null
                              ? '${todaySkinTemperature! >= 0 ? '+' : ''}${todaySkinTemperature!.toStringAsFixed(1)} °C'
                              : '沒有資料',
                          icon: Icons.thermostat,
                          color: Colors.brown,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TemperaturePage(
                                    temperatureService: _temperatureService),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 185,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required List<String> content,
  }) {
    final visibleItems = content.where((c) => c.trim().isNotEmpty).toList();

    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...visibleItems.map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    msg,
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
