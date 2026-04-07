import 'dart:math';
import 'package:flutter/material.dart';
import '../models/person.dart';
import '../widgets/person_avatar.dart';

const List<Color> _zoneColors = [
  Color(0xFF4CAF50),
  Color(0xFF8BC34A),
  Color(0xFFFFEB3B),
  Color(0xFFFF9800),
  Color(0xFFF44336),
];

const List<String> _zoneLabels = [
  '親密',
  '近い',
  '普通',
  '遠い',
  '疎遠',
];

class RelationshipMapPainter extends CustomPainter {
  final List<Person> persons;
  final double animationValue;

  RelationshipMapPainter({
    required this.persons,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = min(cx, cy) * 0.92;

    // Draw concentric zones (outermost first so inner circles paint on top)
    for (int i = 4; i >= 0; i--) {
      final r = maxR * ((i + 1) / 5) * animationValue;
      final paint = Paint()
        ..color = _zoneColors[i].withAlpha(40)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), r, paint);

      final borderPaint = Paint()
        ..color = _zoneColors[i].withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(cx, cy), r, borderPaint);

      // Zone label
      if (animationValue > 0.5) {
        final labelR = maxR * ((i + 0.5) / 5);
        final tp = TextPainter(
          text: TextSpan(
            text: _zoneLabels[i],
            style: TextStyle(
              color: _zoneColors[i].withAlpha(180),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - labelR - tp.height / 2));
      }
    }

    // Center user dot
    final userPaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 18 * animationValue, userPaint);

    final userText = TextPainter(
      text: const TextSpan(
        text: '自分',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (animationValue > 0.3) {
      userText.paint(
          canvas, Offset(cx - userText.width / 2, cy - userText.height / 2));
    }
  }

  @override
  bool shouldRepaint(RelationshipMapPainter old) =>
      old.animationValue != animationValue ||
      old.persons.length != persons.length;
}

class RelationshipMap extends StatefulWidget {
  final List<Person> persons;
  final void Function(Person)? onPersonTap;

  const RelationshipMap({
    super.key,
    required this.persons,
    this.onPersonTap,
  });

  @override
  State<RelationshipMap> createState() => _RelationshipMapState();
}

class _RelationshipMapState extends State<RelationshipMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Offset> _calculatePositions(Size size, List<Person> persons) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = min(cx, cy) * 0.92;

    final positions = <Offset>[];
    final angleStep = persons.isEmpty ? 0.0 : (2 * pi) / persons.length;

    for (int i = 0; i < persons.length; i++) {
      final d = persons[i].psychologicalDistance;
      final r = maxR * (d / 100) * _animation.value;
      // Offset angle slightly per index to reduce overlap
      final angle = angleStep * i - pi / 2;
      positions.add(Offset(cx + r * cos(angle), cy + r * sin(angle)));
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final positions =
                _calculatePositions(size, widget.persons);

            return GestureDetector(
              onTapUp: (details) {
                final pos = details.localPosition;
                for (int i = 0; i < positions.length; i++) {
                  if ((pos - positions[i]).distance < 22) {
                    widget.onPersonTap?.call(widget.persons[i]);
                    break;
                  }
                }
              },
              child: Stack(
                children: [
                  // Background painter
                  CustomPaint(
                    size: size,
                    painter: RelationshipMapPainter(
                      persons: widget.persons,
                      animationValue: _animation.value,
                    ),
                  ),
                  // Person avatars
                  ...List.generate(widget.persons.length, (i) {
                    final person = widget.persons[i];
                    final pos = positions[i];
                    final color =
                        avatarColors[person.colorIndex % avatarColors.length];
                    final initial = person.name.isNotEmpty
                        ? person.name[0]
                        : '?';
                    return Positioned(
                      left: pos.dx - 18,
                      top: pos.dy - 18,
                      child: GestureDetector(
                        onTap: () => widget.onPersonTap?.call(person),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: color,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(220),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                person.name,
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
