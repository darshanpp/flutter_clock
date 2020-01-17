import 'dart:math';

import 'package:flutter/material.dart';

class RainWidget extends StatefulWidget {
  final int totalSnow;
  final double speed;
  final bool isRunning;

  RainWidget({Key key, this.totalSnow, this.speed, this.isRunning})
      : super(key: key);

  _RainWidgetState createState() => _RainWidgetState();
}

class _RainWidgetState extends State<RainWidget>
    with SingleTickerProviderStateMixin {
  Random _rnd;
  AnimationController controller;
  Animation animation;
  List<Water> _snows;
  double angle = 0;
  double W = 0;
  double H = 0;
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    _rnd = new Random();
    if (controller == null) {
      controller = new AnimationController(
          lowerBound: 0,
          upperBound: 1,
          vsync: this,
          duration: const Duration(milliseconds: 20000));
      controller.addListener(() {
        if (mounted) {
          setState(() {
            update();
          });
        }
      });
    }
    if (!widget.isRunning) {
      controller.stop();
    } else {
      controller.repeat();
    }
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  _createSnow() {
    _snows = new List();
    for (var i = 0; i < widget.totalSnow; i++) {
      _snows.add(new Water(
          x: _rnd.nextDouble() * W,
          y: _rnd.nextDouble() * H,
          r: _rnd.nextDouble() * 4 + 1,
          d: _rnd.nextDouble() * widget.speed));
    }
  }

  update() {
    angle += 0.01;
    if (_snows == null || widget.totalSnow != _snows.length) {
      _createSnow();
    }
    for (var i = 0; i < widget.totalSnow; i++) {
      var snow = _snows[i];

      snow.y += (cos(angle + snow.d) + 1 + snow.r / 2) * widget.speed;
      snow.x += sin(angle) * 2 * widget.speed;
      if (snow.x > W + 5 || snow.x < -5 || snow.y > H) {
        if (i % 3 > 0) {
          _snows[i] =
              new Water(x: _rnd.nextDouble() * W, y: -10, r: snow.r, d: snow.d);
        } else {
          if (sin(angle) > 0) {
            _snows[i] = new Water(
                x: -5, y: _rnd.nextDouble() * H, r: snow.r, d: snow.d);
          } else {
            _snows[i] = new Water(
                x: W + 5, y: _rnd.nextDouble() * H, r: snow.r, d: snow.d);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRunning && !controller.isAnimating) {
      controller.repeat();
    } else if (!widget.isRunning && controller.isAnimating) {
      controller.stop();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_snows == null) {
          W = constraints.maxWidth;
          H = constraints.maxHeight;
        }
        return CustomPaint(
          willChange: widget.isRunning,
          painter: SnowPainter(
              // progress: controller.value,
              isRunning: widget.isRunning,
              snows: _snows),
          size: Size.infinite,
        );
      },
    );
  }
}

class Water {
  double x;
  double y;
  double r; //radius
  double d; //density
  Water({this.x, this.y, this.r, this.d});
}

class SnowPainter extends CustomPainter {
  List<Water> snows;
  bool isRunning;

  SnowPainter({this.isRunning, this.snows});

  @override
  void paint(Canvas canvas, Size size) {
    if (snows == null || !isRunning) return;
    //draw circle
    final Paint paint = new Paint()
      ..color = Colors.blue[300]
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;
    for (var i = 0; i < snows.length; i++) {
      var snow = snows[i];
      canvas.drawLine(
          Offset(snow.x, snow.y), Offset(snow.x - 8, snow.y - 8), paint);
      if (snow != null) {
//        canvas.drawCircle(Offset(snow.x, snow.y), snow.r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => isRunning;
}
