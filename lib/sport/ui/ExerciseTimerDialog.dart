import 'package:flutter/material.dart';
import 'dart:async';

class ExerciseTimerDialog extends StatefulWidget {
  final int workoutSeconds;
  final int restSeconds;
  final VoidCallback onFinish;

  const ExerciseTimerDialog({
    super.key,
    required this.workoutSeconds,
    required this.restSeconds,
    required this.onFinish,
  });

  @override
  State<ExerciseTimerDialog> createState() => _ExerciseTimerDialogState();
}

class _ExerciseTimerDialogState extends State<ExerciseTimerDialog> {
  late int secondsLeft;
  bool isResting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.workoutSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsLeft--;
        if (secondsLeft <= 0) {
          if (!isResting) {
            isResting = true;
            secondsLeft = widget.restSeconds;
          } else {
            _timer?.cancel();
            widget.onFinish();
            Navigator.of(context).pop();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isResting ? '休息中' : '訓練中'),
      content: Text(
        '剩餘時間：$secondsLeft 秒',
        style: const TextStyle(fontSize: 28),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('結束'),
        ),
      ],
    );
  }
}
