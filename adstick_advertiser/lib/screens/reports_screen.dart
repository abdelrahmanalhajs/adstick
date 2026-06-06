import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📄 My Reports')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Performance Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _metricCard('Total Impressions', '9.3M', Icons.visibility_rounded, AppTheme.brand)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard('Total KM', '128K', Icons.route_rounded, AppTheme.blue)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _metricCard('Avg Daily Reach', '310K', Icons.people_rounded, AppTheme.green)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard('Avg ROI', '4.2×', Icons.trending_up_rounded, AppTheme.yellow)),
        ]),
        const SizedBox(height: 20),
        const Text('Downloadable Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ...['June 2026 Full Report', 'May 2026 Full Report', 'Q2 2026 Summary', 'Coca-Cola Campaign Final'].map((r) =>
          Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.brand),
            title: Text(r, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            trailing: IconButton(icon: const Icon(Icons.download_rounded, color: AppTheme.textMuted), onPressed: () {}),
          )),
        ),
        const SizedBox(height: 20),
        const Text('Top Performing Zones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ...[('King Fahd Road', '840K', 0.92), ('Al-Olaya District', '720K', 0.78),
            ('Tahlia Street', '650K', 0.70), ('Al-Malaz', '480K', 0.52)].map((z) =>
          Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
            SizedBox(width: 130, child: Text(z.$1, style: const TextStyle(color: Colors.white, fontSize: 12))),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
              value: z.$3, backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppTheme.brand), minHeight: 6))),
            const SizedBox(width: 8),
            Text(z.$2, style: const TextStyle(color: AppTheme.brand, fontSize: 12, fontWeight: FontWeight.w700)),
          ])),
        ),
      ])),
    );
  }

  Widget _metricCard(String lbl, String val, IconData icon, Color color) => Card(child: Padding(
    padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 8),
      Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      Text(lbl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ])));
}
