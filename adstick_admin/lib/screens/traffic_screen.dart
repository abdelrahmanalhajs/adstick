import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrafficScreen extends StatelessWidget {
  const TrafficScreen({super.key});

  static const _zones = [
    ('King Fahd Road', 9.1, 'Peak', AppTheme.red),
    ('Al-Olaya', 7.8, 'High', AppTheme.yellow),
    ('Tahlia Street', 7.2, 'High', AppTheme.yellow),
    ('Airport Road', 6.4, 'Medium', AppTheme.blue),
    ('Riyadh Front', 5.8, 'Medium', AppTheme.blue),
    ('Al-Malaz', 3.2, 'Low', AppTheme.green),
    ('Diplomatic Quarter', 2.5, 'Low', AppTheme.green),
  ];

  static const _hours = [
    ('06:00', 0.3), ('07:00', 0.55), ('08:00', 0.9), ('09:00', 0.75),
    ('10:00', 0.5), ('11:00', 0.45), ('12:00', 0.6), ('13:00', 0.55),
    ('14:00', 0.4), ('15:00', 0.5), ('16:00', 0.78), ('17:00', 0.95),
    ('18:00', 0.85), ('19:00', 0.6), ('20:00', 0.4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚦 Traffic Intelligence')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status cards
        Row(children: [
          _kpi('Current Density', '7.4/10', AppTheme.yellow),
          const SizedBox(width: 10),
          _kpi('Peak Zone', 'King Fahd', AppTheme.red),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _kpi('Vehicles Tracked', '23', AppTheme.green),
          const SizedBox(width: 10),
          _kpi('Optimal Routes', '14', AppTheme.blue),
        ]),
        const SizedBox(height: 24),

        // Hourly traffic
        const Text('Hourly Traffic Pattern', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          SizedBox(height: 100, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: _hours.map((h) {
            final high = h.$2 >= 0.8;
            return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 1.5), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(height: (h.$2 * 80).toDouble(),
                  decoration: BoxDecoration(color: high ? AppTheme.red : AppTheme.brand.withOpacity(0.6), borderRadius: const BorderRadius.vertical(top: Radius.circular(3)))),
            ])));
          }).toList())),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('06:00', style: TextStyle(color: AppTheme.textMuted, fontSize: 9)),
            const Text('Peak: 17:00', style: TextStyle(color: AppTheme.red, fontSize: 9, fontWeight: FontWeight.w700)),
            const Text('20:00', style: TextStyle(color: AppTheme.textMuted, fontSize: 9)),
          ]),
        ]))),
        const SizedBox(height: 24),

        // Zone density
        const Text('Zone Density Index', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._zones.map((z) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(z.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
                value: z.$2 / 10, backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(z.$4), minHeight: 6)),
          ])),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${z.$2}', style: TextStyle(color: z.$4, fontSize: 16, fontWeight: FontWeight.w800)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: z.$4.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                child: Text(z.$3, style: TextStyle(color: z.$4, fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
        ])))),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI Traffic Recommendation', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Re-route 4 vehicles from King Fahd Rd (9.1) to Riyadh Front (5.8) for 22% better impression efficiency.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.5)),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome_rounded, size: 15), label: const Text('Apply Recommendation'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brand, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 38))),
        ]))),
      ])),
    );
  }

  Widget _kpi(String label, String value, Color color) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ]))),
  );
}
