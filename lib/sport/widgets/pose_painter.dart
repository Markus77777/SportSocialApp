import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<Offset> poseLandmarks;

  PosePainter({required this.poseLandmarks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke;

    // 畫點
    for (final point in poseLandmarks) {
      canvas.drawCircle(point, 8, paint);
    }

    // 畫線（連接點）
    for (int i = 0; i < poseLandmarks.length - 1; i++) {
      canvas.drawLine(poseLandmarks[i], poseLandmarks[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
