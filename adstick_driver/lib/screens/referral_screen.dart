import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const _refs = [
    ('Faisal Al-Ghamdi', 'Joined May 2026', 'Active', 'SAR 120'),
    ('Omar Nasser', 'Joined Apr 2026', 'Active', 'SAR 240'),
    ('Yasser Khalid', 'Joined Mar 2026', 'Active', 'SAR 360'),
    ('Ibrahim Saad', 'Joined Jun 2026', 'Pending', 'SAR 0'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🤝 Referrals')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Referral card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              const Text('Your Referral Code', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('AHK-2847', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'AHK-2847'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied!'), backgroundColor: AppTheme.driverGreen));
                  },
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
                      color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.copy_rounded, color: Colors.white, size: 18)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
                _RefStat('4', 'Referred'),
                _RefStat('3', 'Active'),
                _RefStat('SAR 720', 'Earned'),
              ]),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Share Your Code'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.driverGreen, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 44)),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          // How it works
          const Text('How It Works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _howRow('1', 'Share your code', 'Send it to a friend who drives'),
            const Divider(color: AppTheme.border, height: 20),
            _howRow('2', 'Friend signs up', 'They register using your referral code'),
            const Divider(color: AppTheme.border, height: 20),
            _howRow('3', 'Both earn SAR 120', 'After their first 100 km driven'),
          ]))),
          const SizedBox(height: 20),
          const Text('My Referrals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ..._refs.map((r) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(radius: 20, backgroundColor: (r.$3 == 'Active' ? AppTheme.driverGreen : AppTheme.textMuted).withOpacity(0.15),
                  child: Text(r.$1[0], style: TextStyle(color: r.$3 == 'Active' ? AppTheme.driverGreen : AppTheme.textMuted, fontWeight: FontWeight.w800))),
              title: Text(r.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: Text('${r.$2} · ${r.$3}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              trailing: Text(r.$4, style: TextStyle(color: r.$3 == 'Active' ? AppTheme.driverGreen : AppTheme.textMuted, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          )),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Referral Milestones', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _milestone('5 referrals', 'SAR 200 bonus', false),
            _milestone('10 referrals', 'Gold badge + SAR 500', false),
            _milestone('25 referrals', 'SAR 1,500 + free insurance', false),
          ]))),
        ]),
      ),
    );
  }

  Widget _howRow(String num, String title, String desc) => Row(children: [
    Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.driverGreen, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      Text(desc, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ]),
  ]);

  Widget _milestone(String label, String reward, bool done) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: done ? AppTheme.driverGreen : AppTheme.textMuted, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: TextStyle(color: done ? Colors.white : AppTheme.textMuted, fontSize: 13))),
      Text(reward, style: TextStyle(color: done ? AppTheme.driverGreen : AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _RefStat extends StatelessWidget {
  final String val, lbl;
  const _RefStat(this.val, this.lbl);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
    Text(lbl, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);
}
