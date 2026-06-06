import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ My Route')),
      body: Column(children: [
        // Map placeholder
        Container(
          height: 320,
          width: double.infinity,
          color: const Color(0xFF0f2027),
          child: Stack(children: [
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.map_rounded, size: 64, color: AppTheme.driverGreen),
              const SizedBox(height: 12),
              const Text('Live GPS Map', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Al-Olaya District, Riyadh', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.driverGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.driverGreen)),
                child: const Text('● Updates every 5 seconds', style: TextStyle(color: AppTheme.driverGreen, fontSize: 12)),
              ),
            ])),
            Positioned(top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.card.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.speed_rounded, color: AppTheme.driverGreen, size: 14),
                  SizedBox(width: 4),
                  Text('48 km/h', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: _infoCard('Distance Today', '87.4 km', Icons.route_rounded, AppTheme.driverGreen)),
                const SizedBox(width: 12),
                Expanded(child: _infoCard('Time Driven', '3h 42m', Icons.timer_rounded, const Color(0xFF60A5FA))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _infoCard('Avg Speed', '28 km/h', Icons.speed_rounded, const Color(0xFFF59E0B))),
                const SizedBox(width: 12),
                Expanded(child: _infoCard('Coverage Zones', '4 areas', Icons.location_on_rounded, const Color(0xFFA78BFA))),
              ]),
              const SizedBox(height: 20),
              const Text('Today\'s Route Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 12),
              ...[
                ('07:32', 'Started shift', 'Al-Malaz'),
                ('08:15', 'High-density zone', 'King Fahd Rd'),
                ('09:40', 'Peak traffic passed', 'Al-Olaya'),
                ('11:00', 'Break taken', 'Al-Woroud'),
                ('12:30', 'Resumed route', 'Al-Olaya'),
                ('14:00', 'Current position', 'Al-Olaya'),
              ].map((e) => _logRow(e.$1, e.$2, e.$3)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _infoCard(String lbl, String val, IconData icon, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    ])),
  );

  Widget _logRow(String time, String event, String place) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.driverGreen, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Text(time, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      const SizedBox(width: 12),
      Expanded(child: Text(event, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
      Text(place, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ]),
  );
}
