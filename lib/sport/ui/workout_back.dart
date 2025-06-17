import 'package:flutter/material.dart';

class WorkoutBackPage extends StatelessWidget {
  const WorkoutBackPage({super.key});

  void _showExerciseDetail(BuildContext context, String exerciseName) {
    String exerciseDescription = '';
    String bodyPartTargeted = '';
    String imagePath = '';

    switch (exerciseName) {
      case 'Lat Pulldown 引體下拉':
        exerciseDescription = '引體下拉是訓練背部最經典的動作，能有效針對背闊肌進行強化。';
        bodyPartTargeted = '主要訓練部位：背部（背闊肌）\n輔助訓練部位：二頭肌、肩部';
        imagePath = 'assets/images/LatPulldown.jpg';
        break;
      case 'Seated Row 坐姿划船':
        exerciseDescription = '坐姿划船能夠全面刺激整個背部肌群，強化厚度和力量。';
        bodyPartTargeted = '主要訓練部位：背部（闊背肌、中背）\n輔助訓練部位：二頭肌、肩胛穩定肌群';
        imagePath = 'assets/images/SeatedRow.jpg';
        break;
      case 'Deadlift 硬舉':
        exerciseDescription = '硬舉是複合性動作，能同時訓練背部、臀腿與核心肌群。';
        bodyPartTargeted = '主要訓練部位：下背部、臀腿\n輔助訓練部位：核心、前臂';
        imagePath = 'assets/images/Deadlift.jpg';
        break;
      case 'Bent Over Row 彎舉划船':
        exerciseDescription = '彎舉划船強調中背肌群，對於背部的厚度發展特別有效。';
        bodyPartTargeted = '主要訓練部位：中背、斜方肌\n輔助訓練部位：二頭肌、下背';
        imagePath = 'assets/images/BentOverRow.jpg';
        break;
      case 'Pull-Up 引體向上':
        exerciseDescription = '引體向上是自體重量訓練的經典動作，對於背闊肌與上身力量發展非常有效。';
        bodyPartTargeted = '主要訓練部位：背闊肌、上背\n輔助訓練部位：二頭肌、肩膀';
        imagePath = 'assets/images/PullUp.jpg';
        break;
      default:
        exerciseDescription = '這是$exerciseName的介紹。';
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
      'Lat Pulldown 引體下拉',
      'Seated Row 坐姿划船',
      'Deadlift 硬舉',
      'Bent Over Row 彎舉划船',
      'Pull-Up 引體向上',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('背部訓練'),
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
                        Icons.accessibility_new,
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
