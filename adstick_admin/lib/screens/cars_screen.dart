import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});
  @override State<CarsScreen> createState() => _State();
}
class _State extends State<CarsScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Idle', 'Offline', 'Issue'];
  static const _cars = [
    ('CAR-001', 'Ahmed K.', 'Active',  'Al-Olaya',     '247 km', '● Coca-Cola'),
    ('CAR-002', 'Faisal M.', 'Active',  'King Fahd Rd', '184 km', '● Riyad Bank'),
    ('CAR-003', 'Omar S.',  'Idle',    'Al-Malaz',     '90 km',  '● Paused'),
    ('CAR-004', 'Khalid A.', 'Offline', 'Unknown',      '0 km',   '● No signal'),
    ('CAR-005', 'Ibrahim N.', 'Issue',  'Tahlia St',    '132 km', '⚠ Sticker damage'),
    ('CAR-006', 'Yasser T.', 'Active',  'Al-Woroud',    '201 km', '● Pepsi'),
  ];

  Color _statusColor(String s) => switch (s) {
    'Active'  => AppTheme.green,
    'Idle'    => AppTheme.yellow,
    'Offline' => AppTheme.red,
    _         => AppTheme.brand,
  };

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _cars : _cars.where((c) => c.$3 == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('🚗 Cars & Fleet')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _filters.map((f) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f),
              selectedColor: AppTheme.brand.withOpacity(0.2),
              checkmarkColor: AppTheme.brand,
              labelStyle: TextStyle(color: _filter == f ? AppTheme.brand : AppTheme.textMuted, fontSize: 12)),
          )).toList()),
        )),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filtered.length,
          itemBuilder: (_, i) {
            final c = filtered[i];
            final color = _statusColor(c.$3);
            return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(c.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                    child: Text(c.$3, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 4),
                Text('Driver: ${c.$2}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(c.$4, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.route_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(c.$5, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 6),
                Text(c.$6, style: TextStyle(color: color, fontSize: 12)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.blue, side: const BorderSide(color: AppTheme.border), padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Track', style: TextStyle(fontSize: 12)))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textMuted, side: const BorderSide(color: AppTheme.border), padding: const EdgeInsets.symmetric(vertical: 8)),
                    child: const Text('Details', style: TextStyle(fontSize: 12)))),
                ]),
              ]),
            ));
          },
        )),
      ]),
    );
  }
}
