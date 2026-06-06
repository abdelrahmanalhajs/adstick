import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CarbonScreen extends StatelessWidget {
  const CarbonScreen({super.key});

  static const _metrics = [
    ('CO₂ Saved vs Billboards', '18.4 t', AppTheme.green, Icons.eco_rounded),
    ('Fuel Efficiency', '12.3 L/100km', AppTheme.blue, Icons.local_gas_station_rounded),
    ('Electric Vehicles', '6 / 47', AppTheme.green, Icons.electric_car_rounded),
    ('Carbon Offset', '23%', AppTheme.yellow, Icons.forest_rounded),
  ];

  static const _monthly = [
    ('Jan', 0.6), ('Feb', 0.65), ('Mar', 0.72), ('Apr', 0.78), ('May', 0.84), ('Jun', 0.91),
  ];

  static const _initiatives = [
    ('EV Fleet Transition', 'Phase 1: 10 EVs by Q3 2026', 0.32, AppTheme.green),
    ('Carbon Offset Program', 'Tree planting partnership with NEOM', 0.23, AppTheme.green),
    ('Route Optimization', 'AI-minimized unnecessary km driven', 0.65, AppTheme.blue),
    ('Solar Charging Hubs', 'Pilot at 3 Riyadh locations', 0.15, AppTheme.yellow),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌿 Carbon & Sustainability')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Green hero
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF052e16), Color(0xFF14532d)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Icon(Icons.eco_rounded, color: Color(0xFF86EFAC), size: 40),
            const SizedBox(height: 8),
            const Text('AdStick Green Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('74/100', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 48, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(
                value: 0.74, backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(Color(0xFF86EFAC)), minHeight: 10)),
            const SizedBox(height: 6),
            const Text('26 pts to reach Platinum Green status', style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 20),

        // Metric cards
        GridView.count(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6,
          children: _metrics.map((m) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(m.$4, color: m.$3, size: 22),
            const Spacer(),
            Text(m.$2, style: TextStyle(color: m.$3, fontSize: 15, fontWeight: FontWeight.w800)),
            Text(m.$1, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ])))).toList(),
        ),
        const SizedBox(height: 20),

        // Monthly CO2 savings trend
        const Text('Monthly CO₂ Reduction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: _monthly.map((m) =>
            Column(children: [
              Container(width: 32, height: (m.$2 * 80).toDouble(), decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.7 + m.$2 * 0.3),
                  borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 6),
              Text(m.$1, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ])).toList(),
          ),
          const SizedBox(height: 8),
          const Text('Trend: +52% vs Jan · Goal on track', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ]))),
        const SizedBox(height: 20),

        // Initiatives
        const Text('Green Initiatives', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._initiatives.map((ini) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(ini.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
            Text('${(ini.$3 * 100).toInt()}%', style: TextStyle(color: ini.$4, fontSize: 13, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 3),
          Text(ini.$2, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
              value: ini.$3, backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(ini.$4), minHeight: 7)),
        ])))),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sustainability Report', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Download full ESG report for Q1–Q2 2026', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 16), label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40))),
        ]))),
      ])),
    );
  }
}
