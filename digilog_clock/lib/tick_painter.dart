import 'package:digilog_clock/digilog_clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TickPainter extends CustomPainter {
  final Paint linePainter;
  final double lineHeight = 8;
  final int maxLines;
  final double tick;
  final color;
  final TickType tickType;

  TickPainter({this.maxLines, this.tick, this.color, this.tickType})
      : linePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    double tickLength = radius - 12;
    double tickArcPadding = radius;
    Color arcColor;

    switch (tickType) {
      case TickType.second:
        tickLength = radius - 12;
        arcColor = Colors.deepOrangeAccent.withOpacity(0.6);
        break;
      case TickType.minute:
        tickLength = radius - 12;
        tickArcPadding = radius - 8;
        arcColor = Colors.white.withOpacity(0.6);
        break;
      case TickType.hour:
        tickLength = radius - 20;
        tickArcPadding = radius - 16;
        arcColor = Colors.green.withOpacity(0.6);
        break;
    }

    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();

    List.generate(maxLines, (i) {
      canvas.drawLine(
          Offset(0, radius + 3), Offset(0, tickLength), linePainter);
      canvas.rotate(2 * pi / maxLines);
    });

    canvas.restore();
    Paint complete = new Paint()
      ..color = arcColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    Offset center = new Offset(0, 0);
    double arcAngle = 2 * pi * (tick);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: tickArcPadding),
        -pi / 2, arcAngle, false, complete);

    canvas.translate(radius, radius);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
