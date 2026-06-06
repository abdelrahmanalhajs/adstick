import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.driverGreen, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text('My Overview'),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(backgroundColor: AppTheme.driverGreen.withOpacity(0.2),
                child: const Icon(Icons.directions_car_rounded, color: AppTheme.driverGreen, size: 20)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Driver greeting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Good morning, Ahmed 👋', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              const Text('SAR 87.40 earned today', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Row(children: [
                _pill('● Active', AppTheme.driverGreen),
                const SizedBox(width: 8),
                _pill('87.4 km today', Colors.white30),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Today\'s Stats'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: const [
              StatCard(label: 'KM Today', value: '87.4', unit: 'km', icon: Icons.route_rounded, color: AppTheme.driverGreen),
              StatCard(label: 'Today\'s Earnings', value: 'SAR 87', unit: '.40', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF60A5FA)),
              StatCard(label: 'Active Campaign', value: 'Coca‑Cola', unit: '', icon: Icons.label_rounded, color: Color(0xFFF59E0B)),
              StatCard(label: 'My Rating', value: '4.8', unit: '⭐', icon: Icons.star_rounded, color: Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Week Summary'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _weekBar('Mon', 0.6, 'SAR 52'),
                _weekBar('Tue', 0.8, 'SAR 68'),
                _weekBar('Wed', 0.9, 'SAR 78'),
                _weekBar('Thu', 1.0, 'SAR 87'),
                _weekBar('Fri', 0.75, 'SAR 64'),
                _weekBar('Sat', 0.5, 'SAR 43'),
                _weekBar('Sun', 0.3, 'SAR 26'),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _actionBtn(Icons.qr_code_scanner_rounded, 'Scan Sticker', AppTheme.driverGreen)),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn(Icons.support_agent_rounded, 'Support', const Color(0xFF60A5FA))),
          ]),
        ]),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _weekBar(String day, double pct, String earn) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 36, child: Text(day, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
      Expanded(child: Stack(children: [
        Container(height: 8, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(4))),
        FractionallySizedBox(widthFactor: pct, child: Container(height: 8,
            decoration: BoxDecoration(color: AppTheme.driverGreen, borderRadius: BorderRadius.circular(4)))),
      ])),
      const SizedBox(width: 8),
      SizedBox(width: 52, child: Text(earn, textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _actionBtn(IconData icon, String label, Color color) => ElevatedButton.icon(
    onPressed: () {},
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.15),
        foregroundColor: color, side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: 14)),
  );
}
