import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Platform Reports')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Platform KPIs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: const [
            _KPI('Total Revenue', 'SAR 284K', AppTheme.brand),
            _KPI('Total Campaigns', '28 active', AppTheme.blue),
            _KPI('Fleet Utilization', '84.7%', AppTheme.green),
            _KPI('Driver Satisfaction', '4.8 / 5', AppTheme.yellow),
          ],
        ),
        const SizedBox(height: 20),
        const Text('City Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _cityRow('Riyadh',  '412 cars', 'SAR 142K', 0.88),
          _cityRow('Jeddah',  '198 cars', 'SAR 68K',  0.72),
          _cityRow('Dammam',  '112 cars', 'SAR 38K',  0.58),
          _cityRow('Medina',  '68 cars',  'SAR 22K',  0.44),
          _cityRow('Mecca',   '42 cars',  'SAR 11K',  0.28),
          _cityRow('Khobar',  '15 cars',  'SAR 3.5K', 0.15),
        ]))),
        const SizedBox(height: 20),
        const Text('Export Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ...['Platform Monthly Summary', 'Fleet Utilization Report', 'Revenue Breakdown', 'Driver Performance Report',
            'Campaign Analytics Export'].map((r) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.brand),
          title: Text(r, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.share_rounded, color: AppTheme.textMuted, size: 20), onPressed: () {}),
            IconButton(icon: const Icon(Icons.download_rounded, color: AppTheme.textMuted, size: 20), onPressed: () {}),
          ]),
        ))),
      ])),
    );
  }

  Widget _cityRow(String city, String cars, String rev, double pct) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 60, child: Text(city, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
      SizedBox(width: 64, child: Text(cars, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
        value: pct, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(AppTheme.brand), minHeight: 5))),
      const SizedBox(width: 8),
      Text(rev, style: const TextStyle(color: AppTheme.brand, fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _KPI extends StatelessWidget {
  final String label, value; final Color color;
  const _KPI(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
    ])));
}
