import 'package:flutter/material.dart';

class WorkoutAbsPage extends StatelessWidget {
  const WorkoutAbsPage({super.key});

  void _showExerciseDetail(BuildContext context, String exerciseName) {
    String exerciseDescription = '';
    String bodyPartTargeted = '';
    String imagePath = '';

    switch (exerciseName) {
      case 'Crunch 仰臥起坐':
        exerciseDescription = '仰臥起坐是最基礎的腹部訓練，有助於強化腹直肌。';
        bodyPartTargeted = '主要訓練部位：腹直肌\n輔助訓練部位：腹外斜肌';
        imagePath = 'assets/images/Crunch.jpg';
        break;
      case 'Plank 平板支撐':
        exerciseDescription = '平板支撐是一種等長收縮的核心訓練動作。';
        bodyPartTargeted = '主要訓練部位：核心肌群\n輔助訓練部位：臀部、肩膀';
        imagePath = 'assets/images/Plank.jpg';
        break;
      case 'Leg Raise 抬腿':
        exerciseDescription = '抬腿能有效刺激下腹部與腹直肌下段。';
        bodyPartTargeted = '主要訓練部位：下腹肌\n輔助訓練部位：髂腰肌';
        imagePath = 'assets/images/LegRaise.jpg';
        break;
      case 'Bicycle Crunch 腳踏車式捲腹':
        exerciseDescription = '此動作同時鍛鍊腹部與斜肌，是非常有效的核心運動。';
        bodyPartTargeted = '主要訓練部位：腹直肌、腹外斜肌\n輔助訓練部位：髖屈肌';
        imagePath = 'assets/images/BicycleCrunch.jpg';
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
      'Crunch 仰臥起坐',
      'Plank 平板支撐',
      'Leg Raise 抬腿',
      'Bicycle Crunch 腳踏車式捲腹',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('腹部訓練'),
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
                        Icons.adb,
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
