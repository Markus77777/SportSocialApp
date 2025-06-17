import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(
  const MaterialApp(
    home: WorkoutChestPage(),
    debugShowCheckedModeBanner: false,
  ),
);

class WorkoutChestPage extends StatefulWidget {
  const WorkoutChestPage({super.key});

  @override
  State<WorkoutChestPage> createState() => _WorkoutChestPageState();
}

class _WorkoutChestPageState extends State<WorkoutChestPage> {
  int workoutSeconds = 30;
  int restSeconds = 20;
  int sets = 3;

  void _showExerciseDetail(String exerciseName) {
    String description = '';
    String bodyPart = '';
    String imagePath = '';

    switch (exerciseName) {
      case 'Chest press 胸推':
        description = '胸推是最常見的胸部訓練動作，主要針對胸大肌，並且還會訓練到肩部與三頭肌。';
        bodyPart = '主要訓練部位：胸部（胸大肌）\n輔助訓練部位：肩部、三頭肌';
        imagePath = 'assets/images/ChestPress.jpg';
        break;
      case 'Chest Fly 胸飛鳥':
        description = '胸飛鳥是一個擴展胸部的動作，著重於胸部內側的拉伸，對胸肌發展很有幫助。';
        bodyPart = '主要訓練部位：胸部（胸大肌內側）\n輔助訓練部位：肩部、三頭肌';
        imagePath = 'assets/images/ChestFly.jpg';
        break;
      case 'Incline Chest press 上斜胸推':
        description = '上斜胸推針對上胸的訓練，有助於胸部上方的肌肉發展。';
        bodyPart = '主要訓練部位：上胸部（上胸肌）\n輔助訓練部位：肩部、三頭肌';
        imagePath = 'assets/images/incline_chest_press.jpeg';
        break;
      case 'Incline Chest Fly 上斜飛鳥':
        description = '上斜飛鳥能有效鍛鍊上胸部，並增加胸肌拉伸與厚度。';
        bodyPart = '主要訓練部位：上胸部（上胸肌）\n輔助訓練部位：肩部、三頭肌';
        imagePath = 'assets/images/InclineChestFly.jpg';
        break;
      case 'Decline Chest press 下斜胸推':
        description = '下斜胸推針對胸部下方，能改善胸型完整性。';
        bodyPart = '主要訓練部位：下胸部（下胸肌）\n輔助訓練部位：肩部、三頭肌';
        imagePath = 'assets/images/DeclineChestPress.jpg';
        break;
      case 'Decline Chest Fly 下斜飛鳥':
        description = '下斜飛鳥是針對下胸的優化動作，幫助雕塑胸部下緣。';
        bodyPart = '主要訓練部位：下胸部（下胸肌）\n輔助訓練部位：肩部、三頭肌';
        imagePath = 'assets/images/DeclineChestFly.jpg';
        break;
      default:
        description = '這是$exerciseName的介紹。';
        bodyPart = '主要訓練部位：未知';
        imagePath = 'assets/images/DefaultImage.jpg';
    }

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              exerciseName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$description\n\n$bodyPart',
                    style: const TextStyle(fontSize: 17, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      imagePath,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('關閉', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startWorkout();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('開始訓練', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
    );
  }

  void _startWorkout() {
    int currentSet = 0;
    int secondsLeft = workoutSeconds;
    bool isRest = false;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            void startTimer() {
              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                setState(() {
                  secondsLeft--;
                });

                if (secondsLeft <= 0) {
                  if (!isRest) {
                    setState(() {
                      isRest = true;
                      secondsLeft = restSeconds;
                    });
                  } else {
                    currentSet++;
                    if (currentSet >= sets) {
                      t.cancel();
                      Navigator.pop(context);
                      return;
                    }
                    setState(() {
                      isRest = false;
                      secondsLeft = workoutSeconds;
                    });
                  }
                }
              });
            }

            if (timer == null) {
              startTimer();
            }

            final int totalSeconds = isRest ? restSeconds : workoutSeconds;
            final double progress = secondsLeft / totalSeconds;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isRest ? '休息中' : '訓練中',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '第 ${currentSet + 1} 組 / 共 $sets 組',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isRest ? Colors.blueAccent : Colors.redAccent,
                          ),
                        ),
                      ),
                      Text(
                        '$secondsLeft 秒',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('結束', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) {
        double workoutValue = workoutSeconds.toDouble();
        double restValue = restSeconds.toDouble();
        double setsValue = sets.toDouble();

        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  '設定訓練參數',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('訓練時間（秒）'),
                      Slider(
                        value: workoutValue,
                        min: 10,
                        max: 120,
                        divisions: 11,
                        label: workoutValue.round().toString(),
                        activeColor: Colors.redAccent,
                        onChanged: (value) {
                          setState(() {
                            workoutValue = value;
                          });
                        },
                      ),
                      Text('${workoutValue.round()} 秒'),
                      const SizedBox(height: 20),
                      const Text('休息時間（秒）'),
                      Slider(
                        value: restValue,
                        min: 10,
                        max: 120,
                        divisions: 11,
                        label: restValue.round().toString(),
                        activeColor: Colors.blueAccent,
                        onChanged: (value) {
                          setState(() {
                            restValue = value;
                          });
                        },
                      ),
                      Text('${restValue.round()} 秒'),
                      const SizedBox(height: 20),
                      const Text('組數'),
                      Slider(
                        value: setsValue,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: setsValue.round().toString(),
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() {
                            setsValue = value;
                          });
                        },
                      ),
                      Text('${setsValue.round()} 組'),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        workoutSeconds = workoutValue.round();
                        restSeconds = restValue.round();
                        sets = setsValue.round();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('儲存'),
                  ),
                ],
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = [
      'Chest press 胸推',
      'Chest Fly 胸飛鳥',
      'Incline Chest press 上斜胸推',
      'Incline Chest Fly 上斜飛鳥',
      'Decline Chest press 下斜胸推',
      'Decline Chest Fly 下斜飛鳥',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '胸部訓練',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定訓練參數',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.redAccent.withOpacity(0.4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                title: Text(
                  exercises[index],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.redAccent),
                  onPressed: () => _showExerciseDetail(exercises[index]),
                  tooltip: '查看詳情',
                ),
                onTap: () => _showExerciseDetail(exercises[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
