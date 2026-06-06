import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});
  static const _drivers = [
    ('Ahmed Khalid',    'DRV-001', 'Active',   '1,724 km', '4.8⭐', 'Gold'),
    ('Mohammed Saad',   'DRV-002', 'Active',   '1,842 km', '4.9⭐', 'Gold'),
    ('Faisal Omar',     'DRV-003', 'Idle',     '900 km',   '4.7⭐', 'Silver'),
    ('Khalid Ibrahim',  'DRV-004', 'Offline',  '0 km',     '4.5⭐', 'Bronze'),
    ('Omar Yasser',     'DRV-005', 'Active',   '1,612 km', '4.8⭐', 'Gold'),
    ('Ibrahim Nasser',  'DRV-006', 'Issue',    '1,190 km', '4.3⭐', 'Silver'),
  ];

  Color _sc(String s) => switch(s) { 'Active' => AppTheme.green, 'Idle' => AppTheme.yellow, 'Offline' => AppTheme.red, _ => AppTheme.brand };
  Color _tc(String t) => switch(t) { 'Gold' => const Color(0xFFF59E0B), 'Silver' => const Color(0xFF9CA3AF), _ => const Color(0xFF92400E) };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👥 Drivers'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(icon: const Icon(Icons.person_add_rounded, size: 16), label: const Text('Invite'),
                onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)))),
        ]),
      body: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _drivers.length,
        itemBuilder: (_, i) {
          final d = _drivers[i];
          return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
            leading: CircleAvatar(radius: 22, backgroundColor: _sc(d.$3).withOpacity(0.15),
                child: Text(d.$1[0], style: TextStyle(color: _sc(d.$3), fontWeight: FontWeight.w800))),
            title: Row(children: [
              Text(d.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: _tc(d.$6).withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                  child: Text(d.$6, style: TextStyle(color: _tc(d.$6), fontSize: 9, fontWeight: FontWeight.w700))),
            ]),
            subtitle: Text('${d.$2} · ${d.$4} · ${d.$5}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            trailing: Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: _sc(d.$3), shape: BoxShape.circle)),
          ));
        }),
    );
  }
}
