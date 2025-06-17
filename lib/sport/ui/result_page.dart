import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('運動結果')),
      body: const Center(child: Text('這是你的運動成果頁面！')),
    );
  }
}
