import 'workout_log_page.dart';
import 'package:flutter/material.dart';
import 'workout_chest.dart';
import 'workout_back.dart';
import 'workout_leg.dart';
import 'workout_shoulder.dart';
import 'workout_abs.dart';
import 'workout_arm.dart';

class WorkoutHomePage extends StatelessWidget {
  const WorkoutHomePage({super.key});

  void _navigateToWorkout(BuildContext context, String bodyPart) {
    if (bodyPart == '胸部') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutChestPage()),
      );
    } else if (bodyPart == '背部') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutBackPage()),
      );
    } else if (bodyPart == '腿部') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutLegPage()),
      );
    } else if (bodyPart == '肩部') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutShoulderPage()),
      );
    } else if (bodyPart == '腹部') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutAbsPage()),
      );
    } else if (bodyPart == '手臂') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutArmPage()),
      );
    } else if (bodyPart == '運動紀錄') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutLogPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bodyParts = [
      {'name': '胸部', 'icon': Icons.fitness_center},
      {'name': '背部', 'icon': Icons.accessibility_new},
      {'name': '腿部', 'icon': Icons.directions_walk},
      {'name': '肩部', 'icon': Icons.hardware},
      {'name': '腹部', 'icon': Icons.adb},
      {'name': '手臂', 'icon': Icons.build},
      {'name': '運動紀錄', 'icon': Icons.history}, // ✅ 新增紀錄項目
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('選擇訓練部位'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: bodyParts.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap:
                  () => _navigateToWorkout(context, bodyParts[index]['name']),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        bodyParts[index]['icon'],
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bodyParts[index]['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
