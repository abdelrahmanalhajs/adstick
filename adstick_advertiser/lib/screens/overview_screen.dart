import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Campaign Overview'),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(backgroundColor: AppTheme.brand.withOpacity(0.2),
                child: const Icon(Icons.business_rounded, color: AppTheme.brand, size: 20))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero stats
          Container(width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7c2d12), Color(0xFF9a3412)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Good morning, Ahmed 👋', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('1.2M impressions today', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Row(children: [
                _pill('120 active cars', AppTheme.brand),
                const SizedBox(width: 8),
                _pill('ROI 4.2×', AppTheme.green),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: const [
              _StatCard(label: 'Impressions Today', value: '1.2M', icon: Icons.visibility_rounded, color: AppTheme.brand),
              _StatCard(label: 'Active Cars', value: '120', icon: Icons.directions_car_rounded, color: AppTheme.green),
              _StatCard(label: 'KM This Month', value: '89.2K', icon: Icons.route_rounded, color: AppTheme.blue),
              _StatCard(label: 'Campaign ROI', value: '4.2×', icon: Icons.trending_up_rounded, color: AppTheme.yellow),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Active Campaigns', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          _campaignCard('🥤 Coca-Cola Ramadan', 'Riyadh · 80 cars', '68%', AppTheme.brand),
          const SizedBox(height: 10),
          _campaignCard('🏦 Riyad Bank — App', 'Jeddah · 40 cars', '45%', AppTheme.blue),
          const SizedBox(height: 20),
          const Text('Weekly Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _perfRow('Impressions', '1.2M / day', 0.82),
            _perfRow('KM Covered',  '2,980 km',   0.65),
            _perfRow('Budget Used', 'SAR 8,240',  0.74),
          ]))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Launch New Campaign'),
          )),
        ]),
      ),
    );
  }

  Widget _pill(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(999)),
    child: Text(t, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _campaignCard(String name, String detail, String pct, Color color) => Card(
    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
            child: const Text('● Active', style: TextStyle(color: AppTheme.green, fontSize: 10, fontWeight: FontWeight.w700))),
      ]),
      const SizedBox(height: 4),
      Text(detail, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      const SizedBox(height: 10),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: double.tryParse(pct.replaceAll('%', ''))! / 100,
        backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(color), minHeight: 6,
      )),
      const SizedBox(height: 4),
      Text('$pct budget used', style: TextStyle(color: color, fontSize: 11)),
    ])),
  );

  Widget _perfRow(String lbl, String val, double pct) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      SizedBox(width: 100, child: Text(lbl, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
        value: pct, backgroundColor: Colors.white12,
        valueColor: const AlwaysStoppedAnimation(AppTheme.brand), minHeight: 6,
      ))),
      const SizedBox(width: 8),
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        Icon(icon, color: color, size: 18),
      ]),
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
    ])));
}
