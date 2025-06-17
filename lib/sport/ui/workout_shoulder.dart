import 'package:flutter/material.dart';

class WorkoutShoulderPage extends StatelessWidget {
  const WorkoutShoulderPage({super.key});

  void _showExerciseDetail(BuildContext context, String exerciseName) {
    String exerciseDescription = '';
    String bodyPartTargeted = '';
    String imagePath = '';

    switch (exerciseName) {
      case 'Shoulder Press 推舉':
        exerciseDescription = '肩部推舉是最經典的肩部訓練動作，有效增強三角肌整體力量。';
        bodyPartTargeted = '主要訓練部位：前三角肌\n輔助訓練部位：中三角肌、肱三頭肌';
        imagePath = 'assets/images/ShoulderPress.jpg';
        break;
      case 'Lateral Raise 側平舉':
        exerciseDescription = '側平舉專注於訓練肩膀側邊，能增加肩膀的寬度與輪廓。';
        bodyPartTargeted = '主要訓練部位：中三角肌\n輔助訓練部位：上斜方肌';
        imagePath = 'assets/images/LateralRaise.jpg';
        break;
      case 'Front Raise 前平舉':
        exerciseDescription = '前平舉針對前三角肌，能改善肩部前側的肌肉發展。';
        bodyPartTargeted = '主要訓練部位：前三角肌\n輔助訓練部位：胸鎖乳突肌';
        imagePath = 'assets/images/FrontRaise.jpg';
        break;
      case 'Rear Delt Fly 反向飛鳥':
        exerciseDescription = '反向飛鳥專注後三角肌，是打造立體肩膀不可或缺的動作。';
        bodyPartTargeted = '主要訓練部位：後三角肌\n輔助訓練部位：上背部';
        imagePath = 'assets/images/RearDeltFly.jpg';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            exerciseName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$exerciseDescription\n\n$bodyPartTargeted',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Image.asset(imagePath, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 10),
              const Text('觀看影片學習動作：', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  print('觀看影片');
                },
                child: const Text('觀看教學影片'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> exercises = [
      'Shoulder Press 推舉',
      'Lateral Raise 側平舉',
      'Front Raise 前平舉',
      'Rear Delt Fly 反向飛鳥',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('肩部訓練'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: exercises.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _showExerciseDetail(context, exercises[index]),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hardware,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          exercises[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 20),
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
