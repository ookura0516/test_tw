import 'package:flutter/material.dart';

class MetricBar extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;
  final String? description;

  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text('$value',
                  style: TextStyle(color: barColor, fontWeight: FontWeight.bold)),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 2),
            Text(description!,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
