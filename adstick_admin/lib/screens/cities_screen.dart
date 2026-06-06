import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key});

  static const _cities = [
    ('Riyadh', 'HQ', 23, 18, 'SAR 320K', 0.91, 'Active'),
    ('Jeddah', 'Expansion', 8, 6, 'SAR 98K', 0.68, 'Active'),
    ('Dammam', 'Pilot', 4, 3, 'SAR 44K', 0.52, 'Active'),
    ('Khobar', 'Pilot', 3, 2, 'SAR 31K', 0.45, 'Active'),
    ('Mecca', 'Planned', 0, 0, '—', 0.0, 'Planning'),
    ('Medina', 'Planned', 0, 0, '—', 0.0, 'Planning'),
    ('Abha', 'Planned', 0, 0, '—', 0.0, 'Planning'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏙️ City Coverage'),
          actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // National summary
        Row(children: [
          _kpi('Cities Live', '4', AppTheme.green),
          const SizedBox(width: 10),
          _kpi('Total Vehicles', '38', AppTheme.blue),
          const SizedBox(width: 10),
          _kpi('Monthly Rev', 'SAR 493K', AppTheme.brand),
        ]),
        const SizedBox(height: 24),

        // Coverage map placeholder
        Container(height: 160, width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFF0F2027), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.public_rounded, color: AppTheme.brand, size: 40),
            SizedBox(height: 8),
            Text('Saudi Arabia Coverage Map', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('4 active cities · 3 planned', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ])),
        ),
        const SizedBox(height: 20),

        const Text('City Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._cities.map((c) {
          final isActive = c.$7 == 'Active';
          final isPilot = c.$2 == 'Pilot';
          final badgeColor = isActive ? (c.$2 == 'HQ' ? AppTheme.brand : isPilot ? AppTheme.yellow : AppTheme.green) : AppTheme.textMuted;
          return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.location_city_rounded, color: badgeColor, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                Text(c.$2, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ])),
              Text(c.$5, style: const TextStyle(color: AppTheme.brand, fontSize: 14, fontWeight: FontWeight.w800)),
            ]),
            if (isActive) ...[
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _cityStat('Vehicles', '${c.$3}'),
                _cityStat('Active', '${c.$4}'),
                _cityStat('Coverage', '${(c.$6 * 100).toInt()}%'),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                  value: c.$6, backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(badgeColor), minHeight: 6)),
            ] else ...[
              const SizedBox(height: 8),
              const Text('Expansion coming Q4 2026', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ])));
        }),
      ])),
    );
  }

  Widget _kpi(String label, String val, Color c) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Text(val, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10), textAlign: TextAlign.center),
    ]))),
  );

  Widget _cityStat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
  ]);
}
