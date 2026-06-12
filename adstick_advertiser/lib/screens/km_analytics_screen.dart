import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class KmAnalyticsScreen extends StatelessWidget {
  const KmAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('📍 KM & Impression Analytics')),
      body: StreamBuilder<List<Campaign>>(
        stream: fsService.myCampaignsStream(uid),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final campaigns = snap.data ?? [];
          if (campaigns.isEmpty) {
            return _EmptyState();
          }

          // Aggregate totals
          int totalKm = 0;
          int totalImpressions = 0;
          double totalBudget = 0;
          for (final c in campaigns) {
            totalKm += (c.kmCovered * 10).toInt(); // store as tenths for precision
            totalImpressions += c.actualImpressions;
            totalBudget += c.spentBudget;
          }
          final totalKmD = totalKm / 10.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // ── Summary metrics ───────────────────────────────
              Row(children: [
                Expanded(
                    child: _MetricCard(
                  label: 'Total KM Covered',
                  value: '${totalKmD.toStringAsFixed(1)} km',
                  icon: Icons.route_rounded,
                  color: AppTheme.brand,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: 'Total Impressions',
                  value: _fmtN(totalImpressions),
                  icon: Icons.visibility_rounded,
                  color: AppTheme.blue,
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _MetricCard(
                  label: 'Avg CPM',
                  value: totalImpressions > 0
                      ? 'SAR ${(totalBudget / totalImpressions * 1000).toStringAsFixed(2)}'
                      : '—',
                  icon: Icons.price_change_rounded,
                  color: AppTheme.green,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: 'Imp / KM',
                  value: totalKmD > 0
                      ? (totalImpressions / totalKmD).toStringAsFixed(1)
                      : '—',
                  icon: Icons.show_chart_rounded,
                  color: AppTheme.yellow,
                )),
              ]),
              const SizedBox(height: 24),

              // ── Per-campaign breakdown ────────────────────────
              const Text('Campaign Breakdown',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              ...campaigns.map((c) => _CampaignBreakdown(campaign: c)),
              const SizedBox(height: 24),

              // ── Impression trend (30 day) ─────────────────────
              if (campaigns.isNotEmpty) ...[
                const Text('30-Day Impression Trend',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 12),
                _ImpressionTrendCard(
                    campaignId: campaigns
                        .firstWhere((c) => c.status == 'active',
                            orElse: () => campaigns.first)
                        .id),
              ],

              const SizedBox(height: 24),

              // ── Peak hours heat map ───────────────────────────
              const Text('Peak Impression Hours',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              _PeakHoursGrid(),

              const SizedBox(height: 80),
            ]),
          );
        },
      ),
    );
  }

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Campaign breakdown card ───────────────────────────────────────
class _CampaignBreakdown extends StatelessWidget {
  final Campaign campaign;
  const _CampaignBreakdown({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final cpmVal = campaign.spentBudget > 0 && campaign.actualImpressions > 0
        ? campaign.spentBudget / campaign.actualImpressions * 1000
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Expanded(
              child: Text(campaign.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            Text(campaign.city,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCol('KM Covered',
                '${campaign.kmCovered.toStringAsFixed(1)} km',
                AppTheme.brand),
            _statCol('Impressions',
                _fmtN(campaign.actualImpressions), AppTheme.blue),
            _statCol('CPM',
                cpmVal > 0
                    ? 'SAR ${cpmVal.toStringAsFixed(2)}'
                    : '—',
                AppTheme.green),
            _statCol('Cars', '${campaign.activeCars}', AppTheme.yellow),
          ]),
          const SizedBox(height: 10),
          // KM progress bar
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              const Text('Coverage Progress',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 10)),
              Text(
                '${campaign.kmCovered.toStringAsFixed(1)} / ${campaign.targetKm.toStringAsFixed(0)} km',
                style: const TextStyle(
                    color: AppTheme.brand, fontSize: 10),
              ),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: campaign.targetKm > 0
                    ? (campaign.kmCovered / campaign.targetKm)
                        .clamp(0.0, 1.0)
                    : 0,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.brand),
                minHeight: 6,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _statCol(String lbl, String val, Color color) => Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(lbl,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 9)),
          Text(val,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
        ]),
      );

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Impression trend (real Firestore data) ────────────────────────
class _ImpressionTrendCard extends StatelessWidget {
  final String campaignId;
  const _ImpressionTrendCard({required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ImpressionStat>>(
      stream: fsService.campaignStatsStream(campaignId, days: 30),
      builder: (_, snap) {
        final stats = snap.data ?? [];
        if (stats.isEmpty) {
          return Card(
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No impression data yet',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13)),
              ),
            ),
          );
        }

        final maxImp = stats
            .map((s) => s.impressions)
            .fold(0, (a, b) => a > b ? a : b);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: stats.take(30).map((s) {
                    final ratio = maxImp > 0
                        ? s.impressions / maxImp
                        : 0.0;
                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 1),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                          Container(
                            height: (ratio * 80).clamp(2.0, 80.0),
                            decoration: BoxDecoration(
                              color: AppTheme.brand
                                  .withValues(alpha: 0.6 + ratio * 0.4),
                              borderRadius:
                                  BorderRadius.circular(2),
                            ),
                          ),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text(
                  stats.isNotEmpty ? _dateLabel(stats.first.date) : '',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 9),
                ),
                Text(
                  stats.isNotEmpty ? _dateLabel(stats.last.date) : '',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 9),
                ),
              ]),
            ]),
          ),
        );
      },
    );
  }

  /// Parses yyyyMMdd string → "1 Jan"
  static String _dateLabel(String yyyyMMdd) {
    if (yyyyMMdd.length < 8) return yyyyMMdd;
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = int.tryParse(yyyyMMdd.substring(4, 6)) ?? 1;
    final day   = int.tryParse(yyyyMMdd.substring(6, 8)) ?? 1;
    return '$day ${m[month]}';
  }
}

// ── Peak hours ────────────────────────────────────────────────────
class _PeakHoursGrid extends StatelessWidget {
  // Synthetic peak hour profile based on urban driving patterns
  static const _hourMultipliers = [
    0.1, 0.0, 0.0, 0.0, 0.1, 0.2,  // 0-5
    0.5, 0.9, 1.0, 0.8, 0.6, 0.7,  // 6-11
    0.8, 0.6, 0.5, 0.5, 0.7, 1.0,  // 12-17
    0.9, 0.7, 0.5, 0.4, 0.3, 0.2,  // 18-23
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Expected impression density by hour',
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 11)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(24, (h) {
              final val = _hourMultipliers[h];
              final isNow = h == now.hour;
              Color bg;
              if (val >= 0.8) bg = AppTheme.brand;
              else if (val >= 0.5) bg = AppTheme.brand.withValues(alpha: 0.5);
              else if (val >= 0.2) bg = AppTheme.brand.withValues(alpha: 0.2);
              else bg = Colors.white12;

              return Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(6),
                  border: isNow
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${h.toString().padLeft(2, "0")}h',
                  style: TextStyle(
                    color: isNow ? Colors.white : Colors.white70,
                    fontSize: 10,
                    fontWeight: isNow
                        ? FontWeight.w900
                        : FontWeight.w400,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _legend(AppTheme.brand, 'Peak (>80%)'),
            const SizedBox(width: 16),
            _legend(AppTheme.brand.withValues(alpha: 0.5), 'Medium'),
            const SizedBox(width: 16),
            _legend(Colors.white12, 'Low'),
          ]),
        ]),
      ),
    );
  }

  Widget _legend(Color c, String lbl) => Row(children: [
        Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(lbl,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 10)),
      ]);
}

// ── Empty state ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            Icon(Icons.route_rounded, color: AppTheme.brand, size: 48),
            SizedBox(height: 16),
            Text('No campaign data yet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text(
              'Launch a campaign to start seeing\nKM and impression analytics here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ]),
        ),
      );
}

// ── Metric card ───────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ),
      );
}
