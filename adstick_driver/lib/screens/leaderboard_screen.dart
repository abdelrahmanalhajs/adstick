import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const _drivers = [
    ('1', '🥇', 'Mohammed K.', '1,842 km', 'SAR 1,842'),
    ('2', '🥈', 'Faisal A.', '1,764 km', 'SAR 1,764'),
    ('3', '🥉', 'Ahmed H.', '1,724 km', 'SAR 1,724'),
    ('4', '🏅', 'Omar S.', '1,680 km', 'SAR 1,680'),
    ('5', '🏅', 'Khalid M.', '1,612 km', 'SAR 1,612'),
    ('6', '·', 'You — Ahmed K.', '1,245 km', 'SAR 1,245'),
    ('7', '·', 'Ibrahim N.', '1,190 km', 'SAR 1,190'),
    ('8', '·', 'Yasser A.', '1,055 km', 'SAR 1,055'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Leaderboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // My rank card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF78350F), Color(0xFF92400E)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('#6', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Your Rank This Month', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Text('6th place', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('479 km to reach #5', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
              const Text('🚀', style: TextStyle(fontSize: 36)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Top Drivers — June 2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ..._drivers.asMap().entries.map((e) {
            final d = e.value;
            final isMe = d.$1 == '6';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.driverGreen.withOpacity(0.1) : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isMe ? AppTheme.driverGreen.withOpacity(0.4) : AppTheme.border),
              ),
              child: Row(children: [
                SizedBox(width: 28, child: Text(d.$2, style: const TextStyle(fontSize: 18))),
                const SizedBox(width: 4),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.$3, style: TextStyle(color: isMe ? AppTheme.driverGreen : Colors.white,
                      fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(d.$4, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ])),
                Text(d.$5, style: TextStyle(color: isMe ? AppTheme.driverGreen : Colors.white,
                    fontWeight: FontWeight.w800, fontSize: 13)),
              ]),
            );
          }),
          const SizedBox(height: 20),
          const Text('Badges Earned', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.0,
            children: [
              _badge('🚀', '1K KM', true),
              _badge('⭐', '5-Star', true),
              _badge('🔥', '30-Day Streak', true),
              _badge('💎', 'Gold Driver', false),
              _badge('🏙️', '5 Cities', false),
              _badge('👑', 'Top 5', false),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _badge(String emoji, String lbl, bool earned) => Container(
    decoration: BoxDecoration(
      color: earned ? AppTheme.driverGreen.withOpacity(0.1) : AppTheme.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: earned ? AppTheme.driverGreen.withOpacity(0.3) : AppTheme.border),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(emoji, style: TextStyle(fontSize: 28, color: earned ? null : const Color(0xFF444))),
      const SizedBox(height: 4),
      Text(lbl, style: TextStyle(color: earned ? Colors.white : AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );
}
