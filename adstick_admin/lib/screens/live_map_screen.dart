import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  static const _cars = [
    ('V-001', 'King Fahd Rd', '82 km/h', 'Active'),
    ('V-002', 'Al-Olaya', '45 km/h', 'Active'),
    ('V-003', 'Tahlia St', '0 km/h', 'Idle'),
    ('V-004', 'Riyadh Front', '67 km/h', 'Active'),
    ('V-005', 'Airport Rd', '91 km/h', 'Active'),
    ('V-006', 'Al-Malaz', '0 km/h', 'Offline'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ Live Fleet Map'),
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () {})]),
      body: Column(children: [
        // Map placeholder
        Container(
          height: 280, width: double.infinity, margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0F2027), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
          child: Stack(children: [
            // Grid lines
            CustomPaint(painter: _GridPainter(), size: Size.infinite),
            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.map_rounded, color: AppTheme.brand, size: 48),
              const SizedBox(height: 8),
              const Text('Live Map', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Leaflet map integration · 23 active vehicles', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ])),
            // Status pill
            Positioned(top: 12, right: 12, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.2), borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.green.withOpacity(0.4))),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  SizedBox(width: 7, height: 7, child: DecoratedBox(decoration: BoxDecoration(color: AppTheme.green, shape: BoxShape.circle))),
                  SizedBox(width: 6),
                  Text('Live', style: TextStyle(color: AppTheme.green, fontSize: 11, fontWeight: FontWeight.w700)),
                ]))),
          ]),
        ),
        // Legend row
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          _legend(AppTheme.green, 'Active (18)'),
          const SizedBox(width: 16),
          _legend(AppTheme.yellow, 'Idle (3)'),
          const SizedBox(width: 16),
          _legend(AppTheme.textMuted, 'Offline (2)'),
        ])),
        const SizedBox(height: 12),
        // Vehicle list
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _cars.length,
          itemBuilder: (_, i) {
            final c = _cars[i];
            final color = c.$4 == 'Active' ? AppTheme.green : c.$4 == 'Idle' ? AppTheme.yellow : AppTheme.textMuted;
            return Card(margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.directions_car_rounded, color: color, size: 20)),
                title: Text(c.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text('${c.$2} · ${c.$3}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                    child: Text(c.$4, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
              ));
          },
        )),
      ]),
    );
  }

  Widget _legend(Color c, String label) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
  ]);
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF1E293B)..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (var y = 0.0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override bool shouldRepaint(_) => false;
}
