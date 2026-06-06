import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  static const _logs = [
    ('Campaign Approved', 'admin@adstick.com', '2026-06-06 09:14', 'Campaign: Riyadh Retail Blitz', AppTheme.green, Icons.check_circle_rounded),
    ('Driver Suspended', 'admin@adstick.com', '2026-06-06 08:47', 'Driver ID: D-0034 · Reason: QC Fail', AppTheme.red, Icons.block_rounded),
    ('Budget Updated', 'ops@adstick.com', '2026-06-05 16:32', 'Tech Launch Q2: SAR 8,000 → SAR 8,500', AppTheme.blue, Icons.edit_rounded),
    ('Vehicle Added', 'ops@adstick.com', '2026-06-05 14:10', 'V-023 · Toyota Camry 2025', AppTheme.brand, Icons.add_circle_rounded),
    ('Advertiser Onboarded', 'admin@adstick.com', '2026-06-05 11:55', 'AutoDrive Arabia · Growth Plan', AppTheme.green, Icons.person_add_rounded),
    ('Payout Processed', 'finance@adstick.com', '2026-06-04 18:00', 'Batch #42 · SAR 47,320 · 23 drivers', AppTheme.yellow, Icons.payments_rounded),
    ('City Zone Updated', 'ops@adstick.com', '2026-06-04 10:20', 'Jeddah zone boundary extended', AppTheme.blue, Icons.map_rounded),
    ('System Alert Cleared', 'system', '2026-06-03 22:14', 'GPS dropout · V-007 · Resolved', AppTheme.textMuted, Icons.notifications_rounded),
  ];

  static const _stats = [
    ('Total Actions', '1,247', AppTheme.blue),
    ('This Month', '284', AppTheme.brand),
    ('Alerts', '12', AppTheme.yellow),
    ('Violations', '3', AppTheme.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📋 Audit Log'),
          actions: [
            IconButton(icon: const Icon(Icons.download_rounded), onPressed: () {}),
            IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
          ]),
      body: Column(children: [
        // Stats
        Padding(padding: const EdgeInsets.all(16), child: Row(children: _stats.map((s) {
          final last = s == _stats.last;
          return Expanded(child: Row(children: [
            Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
              Text(s.$2, style: TextStyle(color: s.$3, fontSize: 16, fontWeight: FontWeight.w800)),
              Text(s.$1, style: const TextStyle(color: AppTheme.textMuted, fontSize: 9), textAlign: TextAlign.center),
            ])))),
            if (!last) const SizedBox(width: 6),
          ]));
        }).toList())),

        // Log list
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _logs.length,
          itemBuilder: (_, i) {
            final l = _logs[i];
            return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: l.$5.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
                  child: Icon(l.$6, color: l.$5, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l.$4, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person_outline_rounded, color: AppTheme.textMuted, size: 11),
                  const SizedBox(width: 3),
                  Text(l.$2, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                  const Spacer(),
                  Text(l.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ]),
              ])),
            ])));
          },
        )),
      ]),
    );
  }
}
