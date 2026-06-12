import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gps_service.dart';
import '../models/models.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});
  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _starting = false;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _toggleTracking(DriverProfile profile) async {
    setState(() => _starting = true);
    try {
      if (gpsService.isTracking) {
        await gpsService.stopTracking(profile.uid);
        // Commit session earnings to Firestore
        final earned = gpsService.distanceKm * 1.0; // SAR 1/km base
        if (gpsService.distanceKm > 0) {
          await fsService.commitSession(
            uid: profile.uid,
            kmDriven: gpsService.distanceKm,
            earnings: earned,
          );
          await fsService.updateStreak(profile.uid);
        }
      } else {
        final ok = await gpsService.startTracking(profile.uid, profile.name);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permission required to start tracking'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: fsService.rtdbDriverStream(uid),
            builder: (_, snap) {
              final active = snap.data?['isActive'] == true;
              return Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppTheme.driverGreen : AppTheme.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(active ? 'Driving Now' : 'My Overview'),
              ]);
            },
          ),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StreamBuilder<DriverProfile>(
              stream: fsService.driverProfileStream(uid),
              builder: (_, snap) {
                final tier = snap.data?.tier ?? 'bronze';
                return CircleAvatar(
                  backgroundColor: _tierColor(tier).withValues(alpha: 0.2),
                  child: Text(_tierEmoji(tier), style: const TextStyle(fontSize: 18)),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<DriverProfile>(
        stream: fsService.driverProfileStream(uid),
        builder: (ctx, profileSnap) {
          final profile = profileSnap.data;
          final loading = !profileSnap.hasData;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Hero card ──────────────────────────────────────
              StreamBuilder<Map<String, dynamic>>(
                stream: fsService.rtdbDriverStream(uid),
                builder: (_, rtdbSnap) {
                  final rtdb = rtdbSnap.data ?? {};
                  final stats = rtdb['todayStats'] as Map? ?? {};
                  final kmToday = double.tryParse(stats['distanceKm']?.toString() ?? '0') ?? 0;
                  final earningsToday = kmToday * 1.0; // SAR 1/km
                  final isActive = rtdb['isActive'] == true;
                  final name = profile?.name ?? '...';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${_greeting()}, ${name.split(' ').first} 👋',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        earningsToday > 0
                            ? 'SAR ${earningsToday.toStringAsFixed(2)} earned today'
                            : isActive ? 'Tracking in progress...' : 'Ready to start driving?',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),

                      // Forecast
                      if (!isActive && profile != null && earningsToday == 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Drive 20 km → earn SAR 20.00',
                          style: TextStyle(
                              color: AppTheme.driverGreen.withValues(alpha: 0.9),
                              fontSize: 12),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Row(children: [
                        _pill(
                          isActive ? '● Active' : '○ Offline',
                          isActive ? AppTheme.driverGreen : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 8),
                        if (kmToday > 0)
                          _pill(
                            '${kmToday.toStringAsFixed(1)} km today',
                            Colors.white30,
                          ),
                        if (profile != null && profile.streakDays >= 3) ...[
                          const SizedBox(width: 8),
                          _pill(
                            '🔥 ${profile.streakDays}-day streak',
                            const Color(0xFFF59E0B),
                          ),
                        ],
                      ]),

                      const SizedBox(height: 16),

                      // Start/Stop button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: loading || _starting || profile == null
                              ? null
                              : () => _toggleTracking(profile),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gpsService.isTracking
                                ? Colors.red.shade700
                                : AppTheme.driverGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _starting
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Icon(
                                  gpsService.isTracking
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded),
                          label: Text(
                            gpsService.isTracking ? 'Stop Driving' : 'Start Driving',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ]),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Today's stats grid ──────────────────────────────
              const SectionHeader(title: "Today's Stats"),
              const SizedBox(height: 12),
              StreamBuilder<Map<String, dynamic>>(
                stream: fsService.rtdbDriverStream(uid),
                builder: (_, rtdbSnap) {
                  final stats = (rtdbSnap.data?['todayStats'] as Map?) ?? {};
                  final kmToday = double.tryParse(
                          stats['distanceKm']?.toString() ?? '0') ?? 0;
                  final earningsToday = kmToday * 1.0;
                  final campaignName = profile?.currentCampaignId != null
                      ? 'Active'
                      : 'None';

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        label: 'KM Today',
                        value: kmToday.toStringAsFixed(1),
                        unit: 'km',
                        icon: Icons.route_rounded,
                        color: AppTheme.driverGreen,
                      ),
                      StatCard(
                        label: "Today's Earnings",
                        value: 'SAR ${earningsToday.toStringAsFixed(0)}',
                        unit: '.${((earningsToday % 1) * 100).toStringAsFixed(0).padLeft(2, '0')}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF60A5FA),
                      ),
                      StatCard(
                        label: 'Campaign',
                        value: campaignName,
                        unit: '',
                        icon: Icons.label_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                      StatCard(
                        label: 'Quality Score',
                        value: loading
                            ? '...'
                            : profile!.qualityScore.toStringAsFixed(0),
                        unit: '/100',
                        icon: Icons.star_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Tier progress ───────────────────────────────────
              if (profile != null && !profile.isElite) ...[
                const SectionHeader(title: 'Tier Progress'),
                const SizedBox(height: 12),
                _TierProgressCard(profile: profile),
                const SizedBox(height: 20),
              ],

              // ── Week summary ────────────────────────────────────
              const SectionHeader(title: 'Week Summary'),
              const SizedBox(height: 12),
              StreamBuilder<List<EarningsEntry>>(
                stream: fsService.earningsStream(uid, days: 7),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.driverGreen)),
                      ),
                    );
                  }

                  final entries = snap.data ?? [];
                  if (entries.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(children: const [
                            Icon(Icons.bar_chart_rounded,
                                color: AppTheme.textMuted, size: 40),
                            SizedBox(height: 8),
                            Text('No driving data yet this week',
                                style: TextStyle(
                                    color: AppTheme.textMuted, fontSize: 13)),
                          ]),
                        ),
                      ),
                    );
                  }

                  final maxEarnings = entries
                      .map((e) => e.totalAmount)
                      .fold(0.0, (a, b) => a > b ? a : b);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: entries.map((e) {
                          final pct = maxEarnings > 0
                              ? e.totalAmount / maxEarnings
                              : 0.0;
                          return _weekBar(e.dayLabel, pct,
                              'SAR ${e.totalAmount.toStringAsFixed(0)}');
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Quick actions ──────────────────────────────────
              const SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _actionBtn(
                    Icons.camera_alt_rounded,
                    'Upload Proof',
                    AppTheme.driverGreen,
                    () => _showPhotoProofDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionBtn(
                    Icons.support_agent_rounded,
                    'Support',
                    const Color(0xFF60A5FA),
                    () {},
                  ),
                ),
              ]),

              const SizedBox(height: 80),
            ]),
          );
        },
      ),
    );
  }

  void _showPhotoProofDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Upload Ad Proof',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'Take a photo of your ad sticker to verify campaign compliance.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📸 Photo submitted for review'),
                  backgroundColor: AppTheme.driverGreen,
                ),
              );
            },
            child: const Text('Open Camera'),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  Widget _weekBar(String day, double pct, String earn) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(
              width: 36,
              child: Text(day,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12))),
          Expanded(
              child: Stack(children: [
            Container(
                height: 8,
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
                widthFactor: pct.clamp(0.0, 1.0),
                child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: AppTheme.driverGreen,
                        borderRadius: BorderRadius.circular(4)))),
          ])),
          const SizedBox(width: 8),
          SizedBox(
              width: 52,
              child: Text(earn,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
        ]),
      );

  Widget _actionBtn(
          IconData icon, String label, Color color, VoidCallback onTap) =>
      ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );

  Color _tierColor(String tier) {
    switch (tier) {
      case 'silver': return const Color(0xFF94A3B8);
      case 'gold':   return const Color(0xFFFDE68A);
      case 'elite':  return const Color(0xFFA78BFA);
      default:       return const Color(0xFFCD7F32);
    }
  }

  String _tierEmoji(String tier) {
    switch (tier) {
      case 'silver': return '🥈';
      case 'gold':   return '🥇';
      case 'elite':  return '👑';
      default:       return '🥉';
    }
  }
}

// ── Tier progress card ──────────────────────────────────────────
class _TierProgressCard extends StatelessWidget {
  final DriverProfile profile;
  const _TierProgressCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final nextTier = DriverProfile.nextTier(profile.tier);
    final nextKm   = DriverProfile.tierMinKm(nextTier);
    final curKm    = profile.totalKm;
    final progress = nextKm > 0 ? (curKm / nextKm).clamp(0.0, 1.0) : 0.0;
    final remaining = (nextKm - curKm).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '${_tierLabel(profile.tier)} → ${_tierLabel(nextTier)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
                color: AppTheme.driverGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            valueColor:
                const AlwaysStoppedAnimation(AppTheme.driverGreen),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${remaining.toStringAsFixed(0)} km to ${_tierLabel(nextTier)}',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
      ]),
    );
  }

  String _tierLabel(String tier) {
    switch (tier) {
      case 'silver': return '🥈 Silver';
      case 'gold':   return '🥇 Gold';
      case 'elite':  return '👑 Elite';
      default:       return '🥉 Bronze';
    }
  }
}
