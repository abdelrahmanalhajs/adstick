import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key});

  static const _vehicles = [
    ('V-001', 'Toyota Camry 2024', 'Ahmed Khalid', 142800, '2026-09-15', 'Good', 92),
    ('V-002', 'Hyundai Sonata 2023', 'Faisal Al-Ghamdi', 98600, '2026-07-01', 'Good', 88),
    ('V-003', 'Kia Sportage 2025', 'Omar Nasser', 41200, '2027-01-20', 'Excellent', 97),
    ('V-004', 'Honda Accord 2022', 'Yasser Khalid', 187400, '2026-05-30', 'Fair', 64),
    ('V-005', 'Nissan Altima 2024', 'Ibrahim Saad', 73100, '2026-11-10', 'Good', 85),
    ('V-006', 'Toyota Corolla 2023', 'Unassigned', 120500, '2026-08-22', 'Fair', 71),
  ];

  Color _healthColor(int h) => h >= 85 ? AppTheme.green : h >= 65 ? AppTheme.yellow : AppTheme.red;
  Color _condColor(String c) => c == 'Excellent' ? AppTheme.green : c == 'Good' ? AppTheme.blue : c == 'Fair' ? AppTheme.yellow : AppTheme.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚗 Fleet Management'),
          actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary row
        Row(children: [
          _kpi('Total', '47', AppTheme.blue),
          const SizedBox(width: 8),
          _kpi('Active', '23', AppTheme.green),
          const SizedBox(width: 8),
          _kpi('Idle', '18', AppTheme.yellow),
          const SizedBox(width: 8),
          _kpi('Maint.', '6', AppTheme.red),
        ]),
        const SizedBox(height: 20),

        // Fleet health overview
        const Text('Fleet Health Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
            _DonutStat('Excellent', '12', AppTheme.green),
            _DonutStat('Good', '22', AppTheme.blue),
            _DonutStat('Fair', '9', AppTheme.yellow),
            _DonutStat('Poor', '4', AppTheme.red),
          ]),
          const SizedBox(height: 14),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: Row(children: [
            Expanded(flex: 25, child: Container(height: 10, color: AppTheme.green)),
            Expanded(flex: 47, child: Container(height: 10, color: AppTheme.blue)),
            Expanded(flex: 19, child: Container(height: 10, color: AppTheme.yellow)),
            Expanded(flex: 9, child: Container(height: 10, color: AppTheme.red)),
          ])),
        ]))),
        const SizedBox(height: 20),

        // Vehicle cards
        const Text('Vehicle Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._vehicles.map((v) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(
                color: _healthColor(v.$7).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.directions_car_rounded, color: _healthColor(v.$7), size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.$1, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
              Text(v.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(
                color: _condColor(v.$6).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                child: Text(v.$6, style: TextStyle(color: _condColor(v.$6), fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _detail(Icons.person_rounded, v.$3)),
            Expanded(child: _detail(Icons.speed_rounded, '${(v.$4 / 1000).toStringAsFixed(0)}K km')),
            Expanded(child: _detail(Icons.calendar_today_rounded, 'Exp ${v.$5.substring(0, 7)}')),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Health:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(width: 6),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
                value: v.$7 / 100, backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(_healthColor(v.$7)), minHeight: 7))),
            const SizedBox(width: 6),
            Text('${v.$7}%', style: TextStyle(color: _healthColor(v.$7), fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () {},
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6), side: BorderSide(color: AppTheme.brand.withOpacity(0.4))),
                child: const Text('Track', style: TextStyle(color: AppTheme.brand, fontSize: 12)))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () {},
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6), side: BorderSide(color: AppTheme.textMuted.withOpacity(0.3))),
                child: const Text('Details', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)))),
          ]),
        ])))),
      ])),
    );
  }

  Widget _kpi(String label, String val, Color c) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
      Text(val, style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    ]))),
  );

  Widget _detail(IconData icon, String text) => Row(children: [
    Icon(icon, color: AppTheme.textMuted, size: 13),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
  ]);
}

class _DonutStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _DonutStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
  ]);
}
