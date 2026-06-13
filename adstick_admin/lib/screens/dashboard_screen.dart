import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏠 Platform Dashboard')),
      body: StreamBuilder<Map<String, Map<String, dynamic>>>(
        stream: fsService.allDriversRtdbStream(),
        builder: (_, rtdbSnap) {
          final rtdbDrivers = rtdbSnap.data ?? {};

          // Compute live stats directly from RTDB
          final activeDrivers = rtdbDrivers.values
              .where((d) => d['isActive'] == true)
              .length;
          final totalKmToday = rtdbDrivers.values.fold<double>(
            0,
            (sum, d) {
              final km = double.tryParse(
                  (d['todayStats'] as Map?)?['distanceKm']?.toString() ?? '0') ?? 0;
              return sum + km;
            },
          );
          final totalImpressionsToday = (totalKmToday * 14).round();

          return StreamBuilder<PlatformStats>(
            stream: fsService.platformStatsStream(),
            builder: (_, statsSnap) {
              final stats = statsSnap.data;
              final isLoading =
                  statsSnap.connectionState == ConnectionState.waiting &&
                  rtdbSnap.connectionState == ConnectionState.waiting;

              // Merge: RTDB provides live counts; Firestore provides revenue/totals
              final mergedStats = _MergedStats(
                totalDrivers: stats?.totalDrivers ?? rtdbDrivers.length,
                activeDrivers: activeDrivers,
                totalKmToday: totalKmToday,
                totalKmAllTime: stats?.totalKmAllTime ?? 0,
                revenueToday: stats?.revenueToday ?? 0,
                revenueThisMonth: stats?.revenueThisMonth ?? 0,
                revenueAllTime: stats?.revenueAllTime ?? 0,
                activeCampaigns: stats?.activeCampaigns ?? 0,
                totalCampaigns: stats?.totalCampaigns ?? 0,
                totalImpressionsToday: totalImpressionsToday,
                avgQualityScore: stats?.avgQualityScore ?? 0,
                fraudAlertsOpen: stats?.fraudAlertsOpen ?? 0,
                pendingPayouts: stats?.pendingPayouts ?? 0,
                pendingPayoutsAmount: stats?.pendingPayoutsAmount ?? 0,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                  // ── Live health banner ──────────────────────────
                  _LiveBanner(
                    activeDrivers: activeDrivers,
                    totalKmToday: totalKmToday,
                  ),
                  const SizedBox(height: 20),

                  // ── KPI grid ────────────────────────────────────
                  const Text('Platform KPIs',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppTheme.brand),
                    ))
                  else
                    _KpiGrid(stats: mergedStats),
                  const SizedBox(height: 24),

                  // ── Revenue overview ──────────────────────────────
                  const Text('Revenue Overview',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  _RevenueCard(stats: mergedStats),
                  const SizedBox(height: 24),

                  // ── Pending actions ───────────────────────────────
                  const Text('Pending Actions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  const _PendingActions(),
                  const SizedBox(height: 24),

                  // ── Recent fraud alerts ───────────────────────────
                  const Text('Recent Fraud Alerts',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  const _RecentFraudAlerts(),
                  const SizedBox(height: 80),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Merged stats from RTDB + Firestore ────────────────────────────
class _MergedStats {
  final int totalDrivers, activeDrivers, activeCampaigns, totalCampaigns,
      totalImpressionsToday, fraudAlertsOpen, pendingPayouts;
  final double totalKmToday, totalKmAllTime, revenueToday,
      revenueThisMonth, revenueAllTime, avgQualityScore, pendingPayoutsAmount;

  const _MergedStats({
    required this.totalDrivers,
    required this.activeDrivers,
    required this.totalKmToday,
    required this.totalKmAllTime,
    required this.revenueToday,
    required this.revenueThisMonth,
    required this.revenueAllTime,
    required this.activeCampaigns,
    required this.totalCampaigns,
    required this.totalImpressionsToday,
    required this.avgQualityScore,
    required this.fraudAlertsOpen,
    required this.pendingPayouts,
    required this.pendingPayoutsAmount,
  });
}

// ── Live banner ───────────────────────────────────────────────────
class _LiveBanner extends StatelessWidget {
  final int activeDrivers;
  final double totalKmToday;
  const _LiveBanner({required this.activeDrivers, required this.totalKmToday});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(
                  color: AppTheme.green, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activeDrivers > 0
                  ? '$activeDrivers drivers on-road · ${totalKmToday.toStringAsFixed(1)} km today'
                  : 'No active drivers currently',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const Text('LIVE',
              style: TextStyle(
                  color: AppTheme.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
        ]),
      );
}

// ── KPI grid ──────────────────────────────────────────────────────
class _KpiGrid extends StatelessWidget {
  final _MergedStats stats;
  const _KpiGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _KpiCard(
          label: 'Total Drivers',
          value: '${stats.totalDrivers}',
          sub: '${stats.activeDrivers} active now',
          icon: Icons.person_pin_rounded,
          color: AppTheme.brand,
        ),
        _KpiCard(
          label: 'Active Campaigns',
          value: '${stats.activeCampaigns}',
          sub: '${stats.totalCampaigns} total',
          icon: Icons.campaign_rounded,
          color: AppTheme.blue,
        ),
        _KpiCard(
          label: 'Revenue MTD',
          value: 'SAR ${_fmtD(stats.revenueThisMonth)}',
          sub: '30% platform fee',
          icon: Icons.attach_money_rounded,
          color: AppTheme.green,
        ),
        _KpiCard(
          label: 'Pending Payouts',
          value: '${stats.pendingPayouts}',
          sub: 'SAR ${_fmtD(stats.pendingPayoutsAmount)}',
          icon: Icons.pending_actions_rounded,
          color: AppTheme.yellow,
        ),
        _KpiCard(
          label: 'Impressions Today',
          value: _fmtN(stats.totalImpressionsToday),
          sub: '${stats.activeDrivers > 0 ? "Live from RTDB" : "No drivers active"}',
          icon: Icons.visibility_rounded,
          color: AppTheme.brand,
        ),
        _KpiCard(
          label: 'KM Covered Today',
          value: stats.totalKmToday > 0
              ? stats.totalKmToday.toStringAsFixed(1)
              : '0',
          sub: 'Live from active drivers',
          icon: Icons.route_rounded,
          color: const Color(0xFF60A5FA),
        ),
      ],
    );
  }

  static String _fmtD(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.sub,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Flexible(
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(icon, color: color, size: 16),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              Text(sub,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10)),
            ]),
          ]),
        ),
      );
}

// ── Revenue card ──────────────────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  final _MergedStats stats;
  const _RevenueCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final gross = stats.revenueThisMonth;
    final commission = gross * 0.30;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            const Text('This Month',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999)),
              child: const Text('MTD',
                  style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _revItem('Gross Revenue',
                    'SAR ${_fmt(gross)}', AppTheme.blue)),
            const SizedBox(width: 12),
            Expanded(
                child: _revItem('Platform (30%)',
                    'SAR ${_fmt(commission)}', AppTheme.green)),
            const SizedBox(width: 12),
            Expanded(
                child: _revItem('Driver Pool (70%)',
                    'SAR ${_fmt(gross - commission)}', AppTheme.brand)),
          ]),
        ]),
      ),
    );
  }

  Widget _revItem(String lbl, String val, Color c) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(val,
            style: TextStyle(
                color: c, fontSize: 14, fontWeight: FontWeight.w800)),
        Text(lbl,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 9)),
      ]);

  static String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Pending actions ───────────────────────────────────────────────
class _PendingActions extends StatelessWidget {
  const _PendingActions();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PayoutRequest>>(
      stream: fsService.pendingPayoutsStream(),
      builder: (_, paySnap) {
        final pendingPayouts = paySnap.data?.length ?? 0;
        final payoutAmount =
            paySnap.data?.fold(0.0, (s, p) => s + p.amount) ?? 0.0;
        return StreamBuilder<List<Campaign>>(
          stream: fsService.pendingCampaignsStream(),
          builder: (_, campSnap) {
            final pendingCamps = campSnap.data?.length ?? 0;
            return StreamBuilder<List<FraudAlert>>(
              stream: fsService.openFraudAlertsStream(),
              builder: (_, fraudSnap) {
                final openFraud = fraudSnap.data?.length ?? 0;
                return Column(children: [
                  _ActionRow(
                    icon: Icons.pending_actions_rounded,
                    color: AppTheme.yellow,
                    label: 'Payout Requests',
                    count: pendingPayouts,
                    sub: 'SAR ${payoutAmount.toStringAsFixed(0)} total',
                  ),
                  const SizedBox(height: 8),
                  _ActionRow(
                    icon: Icons.campaign_rounded,
                    color: AppTheme.blue,
                    label: 'Campaign Approvals',
                    count: pendingCamps,
                    sub: 'Awaiting admin review',
                  ),
                  const SizedBox(height: 8),
                  _ActionRow(
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    label: 'Open Fraud Alerts',
                    count: openFraud,
                    sub: 'Needs investigation',
                  ),
                ]);
              },
            );
          },
        );
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, sub;
  final int count;
  const _ActionRow(
      {required this.icon,
      required this.color,
      required this.label,
      required this.sub,
      required this.count});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          subtitle: Text(sub,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11)),
          trailing: count > 0
              ? Container(
                  width: 28, height: 28,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text('$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                )
              : const Icon(Icons.check_circle_rounded,
                  color: AppTheme.green, size: 24),
        ),
      );
}

// ── Recent fraud alerts ───────────────────────────────────────────
class _RecentFraudAlerts extends StatelessWidget {
  const _RecentFraudAlerts();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<FraudAlert>>(
        stream: fsService.openFraudAlertsStream(),
        builder: (_, snap) {
          final alerts = snap.data?.take(3).toList() ?? [];
          if (alerts.isEmpty) {
            return Card(
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.shield_rounded,
                        color: AppTheme.green, size: 20),
                    SizedBox(width: 8),
                    Text('No open fraud alerts',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 13)),
                  ]),
                ),
              ),
            );
          }
          return Column(
            children: alerts
                .map((a) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange, size: 20),
                        title: Text(a.typeLabel,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          a.description.isNotEmpty
                              ? a.description
                              : 'Flagged for review',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11),
                        ),
                        trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textMuted),
                      ),
                    ))
                .toList(),
          );
        },
      );
}
