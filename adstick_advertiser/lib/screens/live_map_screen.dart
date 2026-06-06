import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📍 My Cars — Live')),
      body: Column(children: [
        Expanded(flex: 3, child: Container(
          color: const Color(0xFF0f1923),
          child: Stack(children: [
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.map_rounded, size: 72, color: AppTheme.brand),
              const SizedBox(height: 12),
              const Text('Live Car Map', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('120 cars active · Riyadh', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.brand.withOpacity(0.15), borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.brand)),
                  child: const Text('● Real-time · Updates every 30s', style: TextStyle(color: AppTheme.brand, fontSize: 12))),
            ])),
            ...List.generate(8, (i) => Positioned(
              top: 60.0 + (i * 35),
              left: 40.0 + ((i % 4) * 80),
              child: Icon(Icons.directions_car_rounded, color: AppTheme.brand.withOpacity(0.6 + (i % 3) * 0.13), size: 22),
            )),
          ]),
        )),
        Expanded(flex: 2, child: ListView(padding: const EdgeInsets.all(12), children: [
          _carRow('CAR-001', 'Al-Olaya District', '52 km/h', AppTheme.green),
          _carRow('CAR-002', 'King Fahd Road', '38 km/h', AppTheme.brand),
          _carRow('CAR-003', 'Al-Malaz', '0 km/h — Stopped', AppTheme.textMuted),
          _carRow('CAR-004', 'Al-Woroud', '44 km/h', AppTheme.green),
          _carRow('CAR-005', 'Tahlia Street', '61 km/h', AppTheme.yellow),
        ])),
      ]),
    );
  }

  Widget _carRow(String id, String loc, String speed, Color color) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.directions_car_rounded, color: color, size: 18)),
      title: Text(id, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(loc, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      trailing: Text(speed, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    ),
  );
}
