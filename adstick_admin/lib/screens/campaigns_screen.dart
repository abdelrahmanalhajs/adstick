import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});
  static const _camps = [
    ('🥤 Coca-Cola Ramadan', 'PizzaHut KSA', 'Active', 80, 'Riyadh', 'SAR 12,000', 0.68),
    ('🏦 Riyad Bank App', 'Riyad Bank', 'Active', 40, 'Jeddah', 'SAR 6,000', 0.45),
    ('👟 Extra Stores', 'Extra Stores', 'Pending', 0, 'Multi-city', 'SAR 25,000', 0.0),
    ('🍔 McDonald\'s Lunch', 'McDonald\'s KSA', 'Active', 30, 'Dammam', 'SAR 4,500', 0.82),
    ('🏠 Tamimi Markets', 'Tamimi', 'Paused', 20, 'Riyadh', 'SAR 8,000', 0.31),
  ];

  Color _color(String s) => switch(s) {
    'Active'  => AppTheme.green,
    'Pending' => AppTheme.yellow,
    'Paused'  => AppTheme.textMuted,
    _         => AppTheme.red,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📢 All Campaigns'),
        actions: [IconButton(icon: const Icon(Icons.filter_list_rounded, color: AppTheme.textMuted), onPressed: () {})]),
      body: ListView.builder(padding: const EdgeInsets.all(12), itemCount: _camps.length,
        itemBuilder: (_, i) {
          final c = _camps[i];
          final col = _color(c.$3);
          return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(c.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: Text(c.$3, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 4),
            Text('${c.$2} · ${c.$5} · ${c.$4} cars', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Budget: ${c.$6}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Text('${(c.$7 * 100).toInt()}% used', style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
              value: c.$7, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(col), minHeight: 5)),
            if (c.$3 == 'Pending') ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Approve', style: TextStyle(fontSize: 12)))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red, side: const BorderSide(color: AppTheme.red)),
                  child: const Text('Reject', style: TextStyle(fontSize: 12)))),
              ]),
            ],
          ])));
        }),
    );
  }
}
