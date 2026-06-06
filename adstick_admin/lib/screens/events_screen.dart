import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static const _events = [
    ('Gitex Arabia 2026', 'Riyadh Front', 'Jun 15–18', '850K', 'Upcoming', AppTheme.blue),
    ('Saudi National Day', 'City-wide', 'Sep 23', '3.2M', 'Upcoming', AppTheme.green),
    ('Formula E Riyadh', 'Al-Diriyah', 'Nov 5–6', '140K', 'Planning', AppTheme.yellow),
    ('Riyadh Season', 'Multiple', 'Oct–Jan', '8M+', 'Planning', AppTheme.brand),
    ('FIFA World Cup Prep', 'Sports City', 'Dec', '500K', 'Planning', AppTheme.yellow),
    ('Eid Al-Adha Drive', 'City-wide', 'Past', '2.1M', 'Completed', AppTheme.textMuted),
  ];

  static const _active = [
    ('Pop-up Zone A', 'Tahlia St', '12 vehicles', 'Active'),
    ('Event Ring B', 'KAFD', '8 vehicles', 'Active'),
    ('Airport Corridor', 'King Khalid', '6 vehicles', 'Idle'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎉 Event Intelligence'),
          actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPI row
        Row(children: [
          _kpi('Active Events', '2', AppTheme.green),
          const SizedBox(width: 10),
          _kpi('Upcoming', '4', AppTheme.blue),
          const SizedBox(width: 10),
          _kpi('Total Reach', '14.3M', AppTheme.brand),
        ]),
        const SizedBox(height: 20),

        // Active event zones
        const Text('Active Event Zones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._active.map((a) {
          final isActive = a.$4 == 'Active';
          return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(
                color: (isActive ? AppTheme.green : AppTheme.yellow).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.place_rounded, color: isActive ? AppTheme.green : AppTheme.yellow, size: 20)),
            title: Text(a.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            subtitle: Text('${a.$2} · ${a.$3}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: (isActive ? AppTheme.green : AppTheme.yellow).withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(a.$4, style: TextStyle(color: isActive ? AppTheme.green : AppTheme.yellow, fontSize: 11, fontWeight: FontWeight.w700))),
          ));
        }),
        const SizedBox(height: 20),

        // Event calendar
        const Text('Event Calendar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._events.map((e) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: e.$6.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.event_rounded, color: AppTheme.brand, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            Text('${e.$2} · ${e.$3}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(e.$4, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: e.$6.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                child: Text(e.$5, style: TextStyle(color: e.$6, fontSize: 10, fontWeight: FontWeight.w700))),
          ]),
        ])))),
      ])),
    );
  }

  Widget _kpi(String label, String value, Color color) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, height: 1.4), textAlign: TextAlign.center),
    ]))),
  );
}
