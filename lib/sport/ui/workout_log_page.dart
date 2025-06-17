// workout_log_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'workout_log.dart'; // 匯入紀錄資料

class WorkoutLogPage extends StatelessWidget {
  const WorkoutLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('運動紀錄')),
      body:
          workoutHistory.isEmpty
              ? const Center(
                child: Text('尚無任何訓練紀錄', style: TextStyle(fontSize: 18)),
              )
              : ListView.builder(
                itemCount: workoutHistory.length,
                itemBuilder: (context, index) {
                  final log =
                      workoutHistory[workoutHistory.length - 1 - index]; // 最新在上
                  final formatter = DateFormat('yyyy/MM/dd HH:mm:ss');
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        log.exerciseName,
                        style: const TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(
                        '開始：${formatter.format(log.startTime)}\n'
                        '結束：${formatter.format(log.endTime)}\n'
                        '總組數：${log.sets}\n'
                        '每組 ${log.workoutSeconds} 秒，休息 ${log.restSeconds} 秒\n'
                        '總耗時：${log.durationText}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
