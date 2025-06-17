import 'package:flutter/material.dart';
import 'run_page.dart'; // 跳轉頁面

class RunHomePage extends StatefulWidget {
  const RunHomePage({super.key});

  @override
  State<RunHomePage> createState() => _RunHomePageState();
}

class _RunHomePageState extends State<RunHomePage> {
  double lastDistance = 0.8; // 公里
  Duration lastDuration = const Duration(minutes: 30);
  double averageSpeed = 0.0; // km/h
  double runningGoal = 3.0; // 公里
  double progress = 0.9; // 已完成距離
  final TextEditingController goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateAverageSpeed();
  }

  void _calculateAverageSpeed() {
    if (lastDuration.inSeconds > 0) {
      setState(() {
        averageSpeed = lastDistance / (lastDuration.inSeconds / 3600);
      });
    }
  }

  void _navigateToRunPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RunPage()),
    );

    if (result != null && result is Map) {
      setState(() {
        lastDistance = (result['distance'] ?? 0) / 1000;
        lastDuration = result['duration'] ?? lastDuration;
        _calculateAverageSpeed();
        progress = lastDistance;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes 分 ${seconds.toString().padLeft(2, '0')} 秒';
  }

  void _updateRunningGoal() {
    final newGoal = double.tryParse(goalController.text);
    if (newGoal != null && newGoal > 0) {
      setState(() {
        runningGoal = newGoal;
      });
      goalController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入有效的跑步目標數字')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 暖色系主色調（橘紅）
    final warmPrimaryColor = const Color(0xFFFF6F3C);
    final warmShadowColor = warmPrimaryColor.withOpacity(0.3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('跑步統計'),
        centerTitle: true,
        elevation: 6.0,
        backgroundColor: warmPrimaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '上次跑步記錄',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 統計卡片
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: warmShadowColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatText('距離：${lastDistance.toStringAsFixed(2)} 公里'),
                    _buildStatText('時間：${_formatDuration(lastDuration)}'),
                    _buildStatText(
                      '平均速度：${averageSpeed.toStringAsFixed(2)} km/h',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              '跑步目標：${runningGoal.toStringAsFixed(2)} 公里',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // 目標輸入框
            TextField(
              controller: goalController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '輸入新的跑步目標 (公里)',
                labelStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.orange.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                hintText: '例如: 12.5',
                hintStyle: TextStyle(color: Colors.orange.shade200),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 更新目標按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateRunningGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: warmPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: warmPrimaryColor.withOpacity(0.6),
                ),
                child: const Text(
                  '更新目標',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 圓形進度條區塊
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.shade100,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: (progress / runningGoal).clamp(0.0, 1.0),
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        warmPrimaryColor,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Text(
                    '${(progress / runningGoal * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                '目前已完成：${progress.toStringAsFixed(2)} 公里',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // 開始跑步按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToRunPage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warmPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: warmPrimaryColor.withOpacity(0.7),
                ),
                child: const Text(
                  '開始新的跑步',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
