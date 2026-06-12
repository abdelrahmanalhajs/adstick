import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_l10n.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('lb_title')),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.driverGreen,
          labelColor: AppTheme.driverGreen,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'This Month'), Tab(text: 'All Time')],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _LeaderboardTab(period: _currentMonthKey()),
        _LeaderboardTab(period: 'alltime'),
      ]),
    );
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}';
  }
}

// ── Leaderboard tab ───────────────────────────────────────────────
class _LeaderboardTab extends StatelessWidget {
  final String period;
  const _LeaderboardTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    final l   = AppL10n.of(context);

    return StreamBuilder<List<LeaderboardEntry>>(
      stream: fsService.leaderboardStream(monthKey: period),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.driverGreen));
        }

        final entries = snap.data ?? [];

        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆',
                        style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    const Text('Leaderboard is empty',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to drive and claim the #1 spot!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ]),
            ),
          );
        }

        // Find current user's entry
        final myEntry = entries.where((e) => e.uid == uid).firstOrNull;
        final myRank  = myEntry?.rank;
        final top1Km  = entries.first.kmThisMonth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── My rank card ───────────────────────────────────
                if (myEntry != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF78350F), Color(0xFF92400E)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            '#$myRank',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.t('your_rank'),
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12)),
                              Text(
                                _rankLabel(myRank!),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              if (myRank > 1) ...[
                                Text(
                                  '${(entries[myRank - 2].kmThisMonth - myEntry.kmThisMonth).toStringAsFixed(0)} km to reach #${myRank - 1}',
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12),
                                ),
                              ] else
                                const Text(
                                  '🏆 You are #1!',
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                            ]),
                      ),
                      const Text('🚀', style: TextStyle(fontSize: 36)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Top 3 podium ───────────────────────────────────
                if (entries.length >= 3) ...[
                  _Podium(entries: entries.take(3).toList()),
                  const SizedBox(height: 20),
                ],

                // ── Full list ──────────────────────────────────────
                Text(l.t('top_drivers'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 12),
                ...entries.map((e) {
                  final isMe = e.uid == uid;
                  return _DriverRow(
                    entry: e,
                    isMe: isMe,
                    top1Km: top1Km,
                  );
                }),

                const SizedBox(height: 20),

                // ── Badges ─────────────────────────────────────────
                Text(l.t('badges'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 12),
                _BadgesGrid(myEntry: myEntry),
                const SizedBox(height: 80),
              ]),
        );
      },
    );
  }

  String _rankLabel(int rank) {
    switch (rank) {
      case 1: return '1st Place 🥇';
      case 2: return '2nd Place 🥈';
      case 3: return '3rd Place 🥉';
      default: return '${rank}th Place';
    }
  }
}

// ── Podium ────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    final first  = entries[0];
    final second = entries[1];
    final third  = entries[2];

    return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd
          Expanded(child: _PodiumItem(entry: second, height: 80,
              medal: '🥈', bgColor: const Color(0xFF374151))),
          const SizedBox(width: 8),
          // 1st
          Expanded(child: _PodiumItem(entry: first, height: 110,
              medal: '🥇', bgColor: const Color(0xFF78350F))),
          const SizedBox(width: 8),
          // 3rd
          Expanded(child: _PodiumItem(entry: third, height: 65,
              medal: '🥉', bgColor: const Color(0xFF374151))),
        ]);
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final String medal;
  final Color bgColor;
  const _PodiumItem(
      {required this.entry,
      required this.height,
      required this.medal,
      required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(medal, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 4),
      Text(entry.name.split(' ').first,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
      Text('${entry.kmThisMonth.toStringAsFixed(0)} km',
          style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 10)),
      const SizedBox(height: 4),
      Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Center(
          child: Text('#${entry.rank}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20)),
        ),
      ),
    ]);
  }
}

// ── Driver row ────────────────────────────────────────────────────
class _DriverRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;
  final double top1Km;
  const _DriverRow(
      {required this.entry, required this.isMe, required this.top1Km});

  @override
  Widget build(BuildContext context) {
    final progress = top1Km > 0
        ? (entry.kmThisMonth / top1Km).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMe
            ? AppTheme.driverGreen.withValues(alpha: 0.1)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isMe
                ? AppTheme.driverGreen.withValues(alpha: 0.4)
                : AppTheme.border),
      ),
      child: Column(children: [
        Row(children: [
          SizedBox(
            width: 28,
            child: Text(
              _medal(entry.rank),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      isMe ? 'You — ${entry.name}' : entry.name,
                      style: TextStyle(
                          color: isMe
                              ? AppTheme.driverGreen
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    _TierBadge(tier: entry.tier),
                  ]),
                  Text(
                    '${entry.kmThisMonth.toStringAsFixed(0)} km',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                ]),
          ),
          Text(
            'SAR ${entry.earningsThisMonth.toStringAsFixed(0)}',
            style: TextStyle(
                color:
                    isMe ? AppTheme.driverGreen : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(
                isMe ? AppTheme.driverGreen : AppTheme.textMuted),
            minHeight: 3,
          ),
        ),
      ]),
    );
  }

  String _medal(int rank) {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '·';
    }
  }
}

// ── Tier badge ────────────────────────────────────────────────────
class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (tier) {
      case 'elite':
        bg = const Color(0xFF4C1D95); fg = const Color(0xFFA78BFA);
        label = '👑 Elite'; break;
      case 'gold':
        bg = const Color(0xFF78350F); fg = const Color(0xFFFDE68A);
        label = '🥇 Gold'; break;
      case 'silver':
        bg = const Color(0xFF1F2937); fg = const Color(0xFF94A3B8);
        label = '🥈 Silver'; break;
      default:
        bg = const Color(0xFF1C1007); fg = const Color(0xFFCD7F32);
        label = '🥉 Bronze';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Badges grid ───────────────────────────────────────────────────
class _BadgesGrid extends StatelessWidget {
  final LeaderboardEntry? myEntry;
  const _BadgesGrid({this.myEntry});

  @override
  Widget build(BuildContext context) {
    final km = myEntry?.kmThisMonth ?? 0;
    final badges = [
      ('🚀', '1K KM', km >= 1000),
      ('⭐', '5-Star', (myEntry?.qualityScore ?? 0) >= 90),
      ('🔥', '30-Day Streak', false), // from profile stream
      ('💎', 'Gold Driver', myEntry?.tier == 'gold' || myEntry?.tier == 'elite'),
      ('👑', 'Elite Driver', myEntry?.tier == 'elite'),
      ('🏆', 'Top 5', (myEntry?.rank ?? 99) <= 5),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: badges
          .map((b) => _BadgeItem(emoji: b.$1, label: b.$2, earned: b.$3))
          .toList(),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji, label;
  final bool earned;
  const _BadgeItem(
      {required this.emoji, required this.label, required this.earned});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: earned
              ? AppTheme.driverGreen.withValues(alpha: 0.1)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: earned
                  ? AppTheme.driverGreen.withValues(alpha: 0.3)
                  : AppTheme.border),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji,
              style: TextStyle(
                  fontSize: 28,
                  color: earned ? null : const Color(0xFF444444))),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: earned ? Colors.white : AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}
