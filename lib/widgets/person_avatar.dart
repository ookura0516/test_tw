import 'package:flutter/material.dart';
import '../models/person.dart';

const List<Color> avatarColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.indigo,
];

class PersonAvatar extends StatelessWidget {
  final Person person;
  final double radius;
  final VoidCallback? onTap;

  const PersonAvatar({
    super.key,
    required this.person,
    this.radius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = avatarColors[person.colorIndex % avatarColors.length];
    final initial =
        person.name.isNotEmpty ? person.name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
