import 'dart:math';
import 'package:flutter/material.dart';

class DistanceMeter extends StatefulWidget {
  final double distance;
  final double size;

  const DistanceMeter({super.key, required this.distance, this.size = 180});

  @override
  State<DistanceMeter> createState() => _DistanceMeterState();
}

class _DistanceMeterState extends State<DistanceMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = Tween<double>(begin: 0, end: widget.distance / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(DistanceMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distance != widget.distance) {
      _animation = Tween<double>(begin: _animation.value, end: widget.distance / 100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.6),
          painter: _ArcMeterPainter(_animation.value, widget.distance),
        );
      },
    );
  }
}

class _ArcMeterPainter extends CustomPainter {
  final double progress;
  final double distance;

  _ArcMeterPainter(this.progress, this.distance);

  Color get _color {
    if (distance <= 20) return const Color(0xFF4CAF50);
    if (distance <= 40) return const Color(0xFF8BC34A);
    if (distance <= 60) return const Color(0xFFFFEB3B);
    if (distance <= 80) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.95;
    final radius = size.width * 0.45;

    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    final fgPaint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      pi,
      pi * progress,
      false,
      fgPaint,
    );

    // Needle tip
    final angle = pi + pi * progress;
    final nx = cx + radius * cos(angle);
    final ny = cy + radius * sin(angle);
    canvas.drawCircle(Offset(nx, ny), 7, Paint()..color = _color);

    // Center dot
    canvas.drawCircle(
        Offset(cx, cy),
        6,
        Paint()
          ..color = Colors.grey[400]!
          ..style = PaintingStyle.fill);

    // Distance label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${distance.toInt()}',
        style: TextStyle(
          color: _color,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2,
            cy - textPainter.height - radius - 10));
  }

  @override
  bool shouldRepaint(_ArcMeterPainter old) =>
      old.progress != progress || old.distance != distance;
}
