import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KmAnalyticsScreen extends StatelessWidget {
  const KmAnalyticsScreen({super.key});

  static const _zones = [
    ('King Fahd Road', 12840, 0.91),
    ('Al-Olaya', 9240, 0.78),
    ('Tahlia Street', 8810, 0.74),
    ('Riyadh Front', 7320, 0.62),
    ('Al-Malaz', 5150, 0.44),
    ('Diplomatic Quarter', 4020, 0.34),
  ];

  static const _vehicles = [
    ('V-001', 'Toyota Camry', 'King Fahd Rd', 148, 'Active'),
    ('V-002', 'Hyundai Sonata', 'Al-Olaya', 134, 'Active'),
    ('V-003', 'Kia Sportage', 'Tahlia St', 127, 'Active'),
    ('V-004', 'Honda Accord', 'Al-Malaz', 112, 'Idle'),
    ('V-005', 'Nissan Altima', 'Riyadh Front', 98, 'Active'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📍 KM Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // KPI strip
          Row(children: [
            _kpi('Total KMs', '48,380', Icons.route_rounded, AppTheme.brand),
            const SizedBox(width: 10),
            _kpi('Active Drivers', '23', Icons.directions_car_rounded, AppTheme.green),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _kpi('Avg KM/Day', '2,104', Icons.speed_rounded, AppTheme.blue),
            const SizedBox(width: 10),
            _kpi('Coverage %', '74%', Icons.map_rounded, AppTheme.yellow),
          ]),
          const SizedBox(height: 24),

          // Zone heatmap bars
          const Text('Zone Coverage Heatmap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            ..._zones.map((z) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(z.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('${(z.$2 / 1000).toStringAsFixed(1)}K km', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                Stack(children: [
                  Container(height: 8, width: double.infinity, decoration: BoxDecoration(
                      color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
                  FractionallySizedBox(widthFactor: z.$3,
                      child: Container(height: 8, decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.brand, AppTheme.brand.withOpacity(0.6)]),
                        borderRadius: BorderRadius.circular(4),
                      ))),
                ]),
              ]),
            )),
          ]))),
          const SizedBox(height: 20),

          // Weekly KM trend (simple bar chart)
          const Text('Weekly KM Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _bar('Mon', 0.65),
              _bar('Tue', 0.78),
              _bar('Wed', 0.72),
              _bar('Thu', 0.91),
              _bar('Fri', 0.55),
              _bar('Sat', 0.88),
              _bar('Sun', 0.62),
            ]),
            const SizedBox(height: 8),
            const Text('This week · Total 14,692 km', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]))),
          const SizedBox(height: 20),

          // Vehicle KM breakdown
          const Text('Vehicle KM Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ..._vehicles.map((v) {
            final isActive = v.$5 == 'Active';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(
                    color: (isActive ? AppTheme.green : AppTheme.textMuted).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.directions_car_rounded, color: isActive ? AppTheme.green : AppTheme.textMuted, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(v.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Container(width: 7, height: 7, decoration: BoxDecoration(
                        color: isActive ? AppTheme.green : AppTheme.textMuted, shape: BoxShape.circle)),
                  ]),
                  Text('${v.$2} · ${v.$3}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${v.$4} km', style: const TextStyle(color: AppTheme.brand, fontSize: 14, fontWeight: FontWeight.w800)),
                  const Text('today', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ]),
              ])),
            );
          }),
          const SizedBox(height: 20),

          // Summary card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.brand.withOpacity(0.15), AppTheme.brand.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.brand.withOpacity(0.3)),
            ),
            child: Column(children: [
              const Text('Monthly Target Progress', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Text('48,380 / 65,000 km', style: TextStyle(color: AppTheme.brand, fontSize: 16, fontWeight: FontWeight.w800)),
                Text('74.4%', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                  value: 0.744, backgroundColor: AppTheme.brand.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.brand), minHeight: 10)),
              const SizedBox(height: 6),
              const Text('16,620 km remaining · 8 days left in month', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      ])),
    ]))),
  );

  Widget _bar(String day, double val) => Column(children: [
    Container(width: 28, height: (val * 80).toDouble(),
        decoration: BoxDecoration(
            color: val >= 0.85 ? AppTheme.brand : AppTheme.brand.withOpacity(0.45),
            borderRadius: BorderRadius.circular(4))),
    const SizedBox(height: 6),
    Text(day, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
  ]);
}
