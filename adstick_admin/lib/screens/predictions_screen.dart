import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  static const _forecasts = [
    ('Fleet Size', '47 → 62', '+32%', 'by Dec 2026', AppTheme.blue, Icons.directions_car_rounded),
    ('Monthly Revenue', 'SAR 320K → 485K', '+52%', 'by Q4 2026', AppTheme.green, Icons.trending_up_rounded),
    ('Impressions/Month', '4.2M → 7.1M', '+69%', 'by Q3 2026', AppTheme.brand, Icons.visibility_rounded),
    ('Advertiser Base', '18 → 28', '+56%', 'by Q4 2026', AppTheme.yellow, Icons.business_rounded),
  ];

  static const _risks = [
    ('High Driver Churn Risk', 'Sub-tier drivers showing lower engagement — 4 at risk', AppTheme.red, 'High'),
    ('Ad Zone Saturation', 'King Fahd Rd approaching 95% capacity', AppTheme.yellow, 'Medium'),
    ('Seasonal Demand Drop', 'Ramadan period: expect -30% activity', AppTheme.yellow, 'Medium'),
    ('New Competitor Entry', 'Similar platform launching in Jeddah Q3', AppTheme.blue, 'Low'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔮 AI Predictions')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // AI hero
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1a0533), Color(0xFF2d1b69)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFA78BFA), size: 20),
              const SizedBox(width: 8),
              const Text('AI-Powered Forecasts', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            const Text('6-Month Platform Outlook', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Powered by historical data + market signals', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 20),

        // Forecast cards
        const Text('Growth Forecasts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4),
          itemCount: _forecasts.length,
          itemBuilder: (_, i) {
            final f = _forecasts[i];
            return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(f.$6, color: f.$5, size: 22),
              const Spacer(),
              Text(f.$1, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              Text(f.$2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              Row(children: [
                Text(f.$3, style: TextStyle(color: f.$5, fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                Text(f.$4, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              ]),
            ])));
          },
        ),
        const SizedBox(height: 20),

        // Confidence chart (static bars)
        const Text('Forecast Confidence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _confBar('Revenue Forecast', 0.89, AppTheme.green),
          _confBar('Fleet Growth', 0.82, AppTheme.blue),
          _confBar('Impressions', 0.76, AppTheme.brand),
          _confBar('Churn Prediction', 0.71, AppTheme.yellow),
          _confBar('Market Expansion', 0.58, AppTheme.red),
        ]))),
        const SizedBox(height: 20),

        // Risk register
        const Text('Risk Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._risks.map((r) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: r.$3, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(r.$2, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4)),
          ])),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: r.$3.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(r.$4, style: TextStyle(color: r.$3, fontSize: 11, fontWeight: FontWeight.w700))),
        ])))),
      ])),
    );
  }

  Widget _confBar(String label, double val, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        Text('${(val * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 5),
      ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
          value: val, backgroundColor: AppTheme.border,
          valueColor: AlwaysStoppedAnimation(color), minHeight: 7)),
    ]),
  );
}
