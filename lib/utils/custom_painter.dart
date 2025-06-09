import 'package:flutter/material.dart';

class StrikeThroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw a diagonal line from bottom-left to top-right
    canvas.drawLine(
      const Offset(0, 35), // Bottom-left corner
      const Offset(35, 0), // Top-right corner
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}