import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  static const _checks = [
    ('V-001', 'Sticker Integrity', 'Pass', '2026-06-05', AppTheme.green),
    ('V-002', 'Sticker Integrity', 'Pass', '2026-06-04', AppTheme.green),
    ('V-003', 'GPS Accuracy', 'Pass', '2026-06-06', AppTheme.green),
    ('V-004', 'Sticker Damage', 'Fail', '2026-06-02', AppTheme.red),
    ('V-005', 'Ad Placement', 'Warning', '2026-06-03', AppTheme.yellow),
    ('V-006', 'Cleanliness', 'Fail', '2026-06-01', AppTheme.red),
  ];

  static const _rules = [
    ('Sticker Coverage', 95, '≥ 90% surface integrity'),
    ('GPS Up-time', 99, '≥ 98% daily'),
    ('Photo Submission', 88, '≥ 85% on-time'),
    ('Driver Rating', 92, '≥ 4.5/5.0 avg'),
    ('Vehicle Cleanliness', 78, '≥ 80% pass rate'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✅ Quality Control')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Overview
        Row(children: [
          _kpi('Pass Rate', '78%', AppTheme.green),
          const SizedBox(width: 10),
          _kpi('Pending', '12', AppTheme.yellow),
          const SizedBox(width: 10),
          _kpi('Failures', '4', AppTheme.red),
        ]),
        const SizedBox(height: 20),

        // Quality metrics
        const Text('Quality Metrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          ..._rules.map((r) {
            final ok = r.$2 >= 85;
            final warn = r.$2 >= 70 && r.$2 < 85;
            final color = ok ? AppTheme.green : warn ? AppTheme.yellow : AppTheme.red;
            return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(r.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${r.$2}%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 4),
              Text(r.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              const SizedBox(height: 5),
              ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
                  value: r.$2 / 100, backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(color), minHeight: 7)),
            ]));
          }),
        ]))),
        const SizedBox(height: 20),

        // Recent checks
        const Text('Recent QC Checks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._checks.map((c) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: c.$5.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(c.$3 == 'Pass' ? Icons.check_rounded : c.$3 == 'Warning' ? Icons.warning_amber_rounded : Icons.close_rounded,
                  color: c.$5, size: 18)),
          title: Text('${c.$1} – ${c.$2}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(c.$4, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.$5.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(c.$3, style: TextStyle(color: c.$5, fontSize: 11, fontWeight: FontWeight.w700))),
        ))),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: const Text('Run New Verification Batch'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brand, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 44)),
        ),
      ])),
    );
  }

  Widget _kpi(String label, String val, Color c) => Expanded(
    child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      Text(val, style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    ]))),
  );
}
