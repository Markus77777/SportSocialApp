import 'package:flutter/material.dart';

class WorkoutLegPage extends StatelessWidget {
  const WorkoutLegPage({super.key});

  void _showExerciseDetail(BuildContext context, String exerciseName) {
    String exerciseDescription = '';
    String bodyPartTargeted = '';
    String imagePath = '';

    switch (exerciseName) {
      case 'Squat 深蹲':
        exerciseDescription = '深蹲是鍛鍊下半身力量的經典動作，能全面訓練腿部與臀部肌群。';
        bodyPartTargeted = '主要訓練部位：股四頭肌、臀大肌\n輔助訓練部位：腿後肌群、核心';
        imagePath = 'assets/images/Squat.jpg';
        break;
      case 'Lunge 弓箭步':
        exerciseDescription = '弓箭步可加強單腿穩定性與腿部力量，對提升運動表現極有幫助。';
        bodyPartTargeted = '主要訓練部位：股四頭肌、臀大肌\n輔助訓練部位：腿後側、核心';
        imagePath = 'assets/images/Lunge.jpg';
        break;
      case 'Leg Press 腿舉':
        exerciseDescription = '腿舉機可安全地增加下半身肌肉強度，適合初學者與進階者。';
        bodyPartTargeted = '主要訓練部位：股四頭肌、臀大肌\n輔助訓練部位：小腿肌群';
        imagePath = 'assets/images/LegPress.jpg';
        break;
      case 'Romanian Deadlift 羅馬尼亞硬舉':
        exerciseDescription = '這個動作針對腿後側與臀部，強化髖關節的伸展力量。';
        bodyPartTargeted = '主要訓練部位：腿後肌群、臀大肌\n輔助訓練部位：下背部、核心';
        imagePath = 'assets/images/RomanianDeadlift.jpg';
        break;
      default:
        exerciseDescription = '這是 $exerciseName 的介紹。';
        bodyPartTargeted = '主要訓練部位：未知';
        imagePath = 'assets/images/DefaultImage.jpg';
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
      'Squat 深蹲',
      'Lunge 弓箭步',
      'Leg Press 腿舉',
      'Romanian Deadlift 羅馬尼亞硬舉',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('腿部訓練'),
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
                        Icons.directions_walk,
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
