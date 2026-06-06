import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RoiScreen extends StatelessWidget {
  const RoiScreen({super.key});

  static const _campaigns = [
    ('Riyadh Retail Blitz', 'SAR 12,000', 'SAR 94,200', '785%', AppTheme.green),
    ('Tech Launch Q2', 'SAR 8,500', 'SAR 51,000', '600%', AppTheme.green),
    ('F&B Summer Drive', 'SAR 6,200', 'SAR 27,900', '450%', AppTheme.yellow),
    ('Auto Expo 2026', 'SAR 15,000', 'SAR 54,000', '360%', AppTheme.yellow),
    ('Real Estate Push', 'SAR 9,000', 'SAR 22,500', '250%', AppTheme.red),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 ROI Analytics')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Platform ROI summary
        Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1a0533), Color(0xFF0c2340)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Text('Platform Average ROI', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 6),
            const Text('484%', style: TextStyle(color: AppTheme.brand, fontSize: 48, fontWeight: FontWeight.w900)),
            const Text('Return on Ad Spend', style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
              _RoiStat('Total Invested', 'SAR 518K'),
              _RoiStat('Total Returns', 'SAR 2.5M'),
              _RoiStat('Net Profit', 'SAR 1.98M'),
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        // ROI by campaign
        const Text('Campaign ROI Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ..._campaigns.map((c) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c.$5, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Invested: ${c.$2} · Returns: ${c.$3}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: c.$5.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(c.$4, style: TextStyle(color: c.$5, fontSize: 13, fontWeight: FontWeight.w800))),
        ])))),
        const SizedBox(height: 20),

        // ROI by zone bar chart
        const Text('ROI by Advertising Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _zoneBar('King Fahd Rd', 0.92),
          _zoneBar('Al-Olaya', 0.78),
          _zoneBar('Tahlia St', 0.68),
          _zoneBar('Riyadh Front', 0.55),
          _zoneBar('Al-Malaz', 0.38),
        ]))),
        const SizedBox(height: 20),

        // Monthly trend
        const Text('Monthly ROI Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _bar('Jan', 0.6),
            _bar('Feb', 0.68),
            _bar('Mar', 0.72),
            _bar('Apr', 0.78),
            _bar('May', 0.84),
            _bar('Jun', 0.91),
          ]),
          const SizedBox(height: 8),
          const Text('Steady growth · +52% vs Q1', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ]))),
      ])),
    );
  }

  Widget _zoneBar(String label, double val) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
      Expanded(child: Stack(children: [
        Container(height: 8, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
        FractionallySizedBox(widthFactor: val, child: Container(height: 8, decoration: BoxDecoration(
            color: AppTheme.brand, borderRadius: BorderRadius.circular(4)))),
      ])),
      const SizedBox(width: 8),
      Text('${(val * 100).toInt()}%', style: const TextStyle(color: AppTheme.brand, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  );

  Widget _bar(String label, double val) => Column(children: [
    Container(width: 32, height: (val * 80).toDouble(), decoration: BoxDecoration(
        color: val >= 0.85 ? AppTheme.brand : AppTheme.brand.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4))),
    const SizedBox(height: 6),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
  ]);
}

class _RoiStat extends StatelessWidget {
  final String label, value;
  const _RoiStat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
  ]);
}
