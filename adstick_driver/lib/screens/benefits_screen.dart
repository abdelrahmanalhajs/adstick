import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  static const _perks = [
    ('⛽', 'Aramco Fuel', '10% discount at all Aramco stations', 'Gold'),
    ('🔧', 'Service Centers', 'Free oil change every 5,000 km', 'Silver'),
    ('🚗', 'Car Wash', '2 free washes per month', 'Bronze'),
    ('📱', 'STC Data', 'Extra 10 GB monthly', 'Gold'),
    ('🏥', 'Bupa Healthcare', '20% off medical consultations', 'Gold'),
    ('🍔', 'Careem Pay', 'SAR 50 food credit monthly', 'Silver'),
  ];

  static const _insurance = [
    ('🛡️', 'Walaa Insurance', 'Comprehensive car coverage — Gold exclusive', 'Gold'),
    ('🏥', 'Bupa Health', 'Basic health plan for you and family', 'Silver'),
    ('🚨', 'Towing Service', '24/7 roadside assistance', 'Bronze'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎁 My Benefits')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Fuel card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF78350F), Color(0xFF92400E)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fuel Card Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('2,840 pts', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Cash Equivalent', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('SAR 28.40', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
              ]),
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(
                value: 0.57, backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(Color(0xFF86EFAC)), minHeight: 8)),
              const SizedBox(height: 6),
              const Text('2,160 pts to next reward tier · Earn 1 pt per km', style: TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: ElevatedButton(onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF86EFAC), foregroundColor: const Color(0xFF064E3B)),
                    child: const Text('Redeem Points'))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton(onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white30)),
                    child: const Text('History'))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Tier badge
          Row(children: [
            const Text('Partner Perks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF78350F), borderRadius: BorderRadius.circular(999)),
                child: const Text('🥇 Gold Driver', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6),
            itemCount: _perks.length,
            itemBuilder: (_, i) {
              final p = _perks[i];
              final isGold = p.$4 == 'Gold';
              return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(p.$1, style: const TextStyle(fontSize: 24)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: (isGold ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF)).withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                      child: Text(p.$4, style: TextStyle(color: isGold ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF), fontSize: 9, fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 6),
                Text(p.$2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                Text(p.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, height: 1.3)),
              ])));
            },
          ),
          const SizedBox(height: 20),
          const Text('🛡️ Insurance Partners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ..._insurance.map((ins) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(ins.$1, style: const TextStyle(fontSize: 24)),
              title: Text(ins.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: Text(ins.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.driverGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
                  child: Text(ins.$4, style: const TextStyle(color: AppTheme.driverGreen, fontSize: 10, fontWeight: FontWeight.w700))),
            ),
          )),
        ]),
      ),
    );
  }
}
