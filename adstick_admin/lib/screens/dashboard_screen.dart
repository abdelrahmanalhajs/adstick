import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.green, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('Admin Dashboard'),
        ]),
        actions: [
          IconButton(icon: Badge(label: const Text('3'), child: const Icon(Icons.notifications_rounded, color: AppTheme.textMuted)), onPressed: () {}),
          Padding(padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(radius: 16, backgroundColor: AppTheme.brand.withOpacity(0.2),
                child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.brand, size: 18))),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPI grid
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: const [
            _KPI(label: 'Active Cars', value: '847', delta: '+12 today', icon: Icons.directions_car_rounded, color: AppTheme.green),
            _KPI(label: 'KM Today', value: '74.2K', delta: '+8.4% vs last week', icon: Icons.route_rounded, color: AppTheme.blue),
            _KPI(label: 'Active Campaigns', value: '28', delta: '+3 this month', icon: Icons.campaign_rounded, color: AppTheme.brand),
            _KPI(label: 'Traffic Score', value: '8.4', delta: '▲ Morning peak', icon: Icons.traffic_rounded, color: AppTheme.yellow),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Fleet Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _bar('Active',    847, 1000, AppTheme.green),
          _bar('Idle',      124, 1000, AppTheme.yellow),
          _bar('Offline',    29, 1000, AppTheme.red),
          _bar('Sticker Issue', 8, 1000, AppTheme.brand),
        ]))),
        const SizedBox(height: 20),
        const Text('Revenue This Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SAR 284,500', style: TextStyle(color: AppTheme.brand, fontSize: 32, fontWeight: FontWeight.w900)),
          const Text('Total platform revenue · June 2026', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 16),
          _revRow('Advertiser Fees', 'SAR 210,000', 0.74),
          _revRow('Driver Payouts', 'SAR −58,000', null),
          _revRow('Data Subscriptions', 'SAR 18,500', 0.07),
          _revRow('Platform Fee (15%)', 'SAR 56,000', 0.20),
        ]))),
        const SizedBox(height: 20),
        const Text('Recent Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 12),
        ...[
          (AppTheme.yellow, Icons.warning_rounded, 'Sticker damage reported · CAR-204', '5 min ago'),
          (AppTheme.blue,   Icons.info_rounded,    'New campaign awaiting approval',    '12 min ago'),
          (AppTheme.green,  Icons.check_circle_rounded, 'CAR-089 reached 1,000 km milestone', '1 hr ago'),
          (AppTheme.red,    Icons.error_rounded,   'Driver offline 3h+ · DRV-412',     '2 hr ago'),
        ].map((a) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: Icon(a.$2, color: a.$1, size: 22),
          title: Text(a.$3, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          trailing: Text(a.$4, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ))),
      ])),
    );
  }

  Widget _bar(String lbl, int val, int max, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 90, child: Text(lbl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: val / max, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(color), minHeight: 6))),
      const SizedBox(width: 8),
      SizedBox(width: 36, child: Text('$val', textAlign: TextAlign.right,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );

  Widget _revRow(String lbl, String val, double? pct) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(lbl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      Text(val, style: TextStyle(color: pct != null ? AppTheme.brand : AppTheme.red,
          fontSize: 13, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _KPI extends StatelessWidget {
  final String label, value, delta; final IconData icon; final Color color;
  const _KPI({required this.label, required this.value, required this.delta, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        Icon(icon, color: color, size: 16),
      ]),
      Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
      Text(delta, style: const TextStyle(color: AppTheme.green, fontSize: 10)),
    ])));
}
