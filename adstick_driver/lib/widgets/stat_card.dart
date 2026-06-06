import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.label, required this.value,
      required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            Icon(icon, color: color, size: 18),
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            if (unit.isNotEmpty) Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 2),
              child: Text(unit, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ),
          ]),
        ]),
      ),
    );
  }
}
