import 'package:flutter/material.dart';

class WorkoutArmPage extends StatelessWidget {
  const WorkoutArmPage({super.key});

  void _showExerciseDetail(BuildContext context, String exerciseName) {
    String exerciseDescription = '';
    String bodyPartTargeted = '';
    String imagePath = '';

    switch (exerciseName) {
      case 'Bicep Curl 彎舉':
        exerciseDescription = '彎舉是鍛鍊肱二頭肌的經典訓練動作。';
        bodyPartTargeted = '主要訓練部位：肱二頭肌\n輔助訓練部位：前臂肌群';
        imagePath = 'assets/images/BicepCurl.jpg';
        break;
      case 'Tricep Dip 撐體':
        exerciseDescription = '撐體可以有效鍛鍊三頭肌與胸部。';
        bodyPartTargeted = '主要訓練部位：肱三頭肌\n輔助訓練部位：胸大肌、三角肌前束';
        imagePath = 'assets/images/TricepDip.jpg';
        break;
      case 'Hammer Curl 槌式彎舉':
        exerciseDescription = '槌式彎舉能強化肱橈肌和肱二頭肌。';
        bodyPartTargeted = '主要訓練部位：肱橈肌\n輔助訓練部位：肱二頭肌';
        imagePath = 'assets/images/HammerCurl.jpg';
        break;
      case 'Overhead Tricep Extension 上舉伸展':
        exerciseDescription = '此動作主要刺激三頭肌的長頭。';
        bodyPartTargeted = '主要訓練部位：肱三頭肌';
        imagePath = 'assets/images/TricepExtension.jpg';
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
      'Bicep Curl 彎舉',
      'Tricep Dip 撐體',
      'Hammer Curl 槌式彎舉',
      'Overhead Tricep Extension 上舉伸展',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('手臂訓練'),
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
                        Icons.build,
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
