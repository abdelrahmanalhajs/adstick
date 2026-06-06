import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📢 My Campaigns'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_rounded, color: AppTheme.brand), onPressed: () {}),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _CampaignCard(name: '🥤 Coca-Cola Ramadan', status: 'Active', cars: 80, city: 'Riyadh',
          impressions: '680K', km: '18,240', budget: 'SAR 12,000', spent: 'SAR 8,160', pct: 0.68, color: AppTheme.brand),
        const SizedBox(height: 12),
        _CampaignCard(name: '🏦 Riyad Bank App Launch', status: 'Active', cars: 40, city: 'Jeddah',
          impressions: '420K', km: '9,840', budget: 'SAR 6,000', spent: 'SAR 2,700', pct: 0.45, color: AppTheme.blue),
        const SizedBox(height: 12),
        _CampaignCard(name: '👟 Extra Stores — Black Friday', status: 'Ended', cars: 0, city: 'Riyadh',
          impressions: '8.1M', km: '120,000', budget: 'SAR 40,000', spent: 'SAR 40,000', pct: 1.0, color: AppTheme.textMuted),
        const SizedBox(height: 20),
        ElevatedButton.icon(icon: const Icon(Icons.add_rounded), label: const Text('Launch New Campaign'), onPressed: () {}),
      ]),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final String name, status, city, impressions, km, budget, spent;
  final int cars; final double pct; final Color color;
  const _CampaignCard({required this.name, required this.status, required this.cars, required this.city,
      required this.impressions, required this.km, required this.budget, required this.spent,
      required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: (isActive ? AppTheme.green : AppTheme.textMuted).withOpacity(0.15),
              borderRadius: BorderRadius.circular(999)),
          child: Text(isActive ? '● $status' : status,
              style: TextStyle(color: isActive ? AppTheme.green : AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 4),
      Text('$city · $cars cars', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      const SizedBox(height: 12),
      Row(children: [
        _stat('Impressions', impressions, AppTheme.brand),
        const SizedBox(width: 20),
        _stat('KM Covered', km, AppTheme.blue),
      ]),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Budget: $budget', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        Text('Spent: $spent', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: pct, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(color), minHeight: 6)),
      const SizedBox(height: 4),
      Text('${(pct * 100).toInt()}% budget used', style: TextStyle(color: color, fontSize: 11)),
      if (isActive) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.pause_rounded, size: 16), label: const Text('Pause'),
              onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textMuted, side: const BorderSide(color: AppTheme.border)))),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.bar_chart_rounded, size: 16), label: const Text('Analytics'), onPressed: () {})),
        ]),
      ],
    ])));
  }

  Widget _stat(String lbl, String val, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(lbl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
    Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
  ]);
}
