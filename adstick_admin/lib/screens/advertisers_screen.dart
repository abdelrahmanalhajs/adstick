import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class AdvertisersScreen extends StatelessWidget {
  const AdvertisersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📢 Advertisers')),
      body: StreamBuilder<List<Campaign>>(
        stream: fsService.allCampaignsStream(),
        builder: (_, campSnap) {
          // Build a lookup: advertiserId → list of campaigns
          final campsByAdv = <String, List<Campaign>>{};
          for (final c in campSnap.data ?? []) {
            campsByAdv.putIfAbsent(c.advertiserId, () => []).add(c);
          }

          return StreamBuilder<List<AdvertiserRecord>>(
            stream: fsService.allAdvertisersStream(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  campSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.brand));
              }
              final advertisers = snap.data ?? [];
              if (advertisers.isEmpty) {
                return const Center(
                  child: Text('No advertisers registered yet',
                      style:
                          TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                );
              }

              // Platform totals banner
              final totalBudget = advertisers.fold(
                  0.0, (s, a) => s + a.totalBudget);
              final totalSpent = (campSnap.data ?? []).fold(
                  0.0, (s, c) => s + c.spentBudget);
              final totalActive = (campSnap.data ?? [])
                  .where((c) => c.status == 'active')
                  .length;
              final totalImpressions = (campSnap.data ?? []).fold(
                  0, (s, c) => s + c.actualImpressions);

              return Column(children: [
                // ── Summary banner ────────────────────────────
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1E1035), Color(0xFF0F0F1F)]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.brand.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    _bannerStat('Advertisers',
                        '${advertisers.length}', AppTheme.brand),
                    _div(),
                    _bannerStat('Active Camps',
                        '$totalActive', AppTheme.green),
                    _div(),
                    _bannerStat('Spent / Budget',
                        'SAR ${_fmt(totalSpent)} / ${_fmt(totalBudget)}',
                        AppTheme.blue),
                    _div(),
                    _bannerStat('Impressions',
                        _fmtN(totalImpressions), AppTheme.yellow),
                  ]),
                ),

                // ── Advertiser list ───────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: advertisers.length,
                    itemBuilder: (_, i) => _AdvertiserCard(
                      advertiser: advertisers[i],
                      campaigns: campsByAdv[advertisers[i].uid] ?? [],
                      key: ValueKey(advertisers[i].uid),
                    ),
                  ),
                ),
              ]);
            },
          );
        },
      ),
    );
  }

  Widget _bannerStat(String lbl, String val, Color c) => Expanded(
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  color: c, fontSize: 15, fontWeight: FontWeight.w900)),
          Text(lbl,
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
        ]),
      );

  Widget _div() => Container(
      width: 1, height: 32, color: AppTheme.border,
      margin: const EdgeInsets.symmetric(horizontal: 4));

  static String _fmt(double v) {
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

// ── Advertiser card ───────────────────────────────────────────────
class _AdvertiserCard extends StatefulWidget {
  final AdvertiserRecord advertiser;
  final List<Campaign> campaigns;
  const _AdvertiserCard(
      {required this.advertiser, required this.campaigns, super.key});

  @override
  State<_AdvertiserCard> createState() => _AdvertiserCardState();
}

class _AdvertiserCardState extends State<_AdvertiserCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.advertiser;
    final camps = widget.campaigns;
    final activeCamps = camps.where((c) => c.status == 'active').length;
    final pendingCamps = camps.where((c) => c.status == 'pending').length;
    final totalImpressions =
        camps.fold(0, (s, c) => s + c.actualImpressions);
    final totalSpent = camps.fold(0.0, (s, c) => s + c.spentBudget);
    final budgetUsedPct = a.totalBudget > 0
        ? (totalSpent / a.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    a.companyName.isNotEmpty
                        ? a.companyName[0].toUpperCase()
                        : a.name.isNotEmpty
                            ? a.name[0].toUpperCase()
                            : '?',
                    style: const TextStyle(
                        color: AppTheme.brand,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    a.companyName.isNotEmpty ? a.companyName : a.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(a.name,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                  Text(a.email,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (activeCamps > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('$activeCamps active',
                        style: const TextStyle(
                            color: AppTheme.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                if (pendingCamps > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.yellow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('$pendingCamps pending',
                        style: const TextStyle(
                            color: AppTheme.yellow,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
            ]),

            const SizedBox(height: 12),

            // ── Stats row ─────────────────────────────────
            Row(children: [
              _stat('Budget',
                  'SAR ${_fmt(a.totalBudget)}', AppTheme.blue),
              _stat('Spent',
                  'SAR ${_fmt(totalSpent)}', AppTheme.brand),
              _stat('Impressions',
                  _fmtN(totalImpressions), AppTheme.green),
              _stat('Campaigns',
                  '${camps.length}', AppTheme.yellow),
            ]),

            const SizedBox(height: 8),

            // ── Budget progress ────────────────────────────
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text('Budget Used',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 9)),
                Text(
                    '${(budgetUsedPct * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                        color: budgetUsedPct > 0.9
                            ? Colors.red
                            : AppTheme.brand,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: budgetUsedPct,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                      budgetUsedPct > 0.9 ? Colors.red : AppTheme.brand),
                  minHeight: 5,
                ),
              ),
            ]),

            // ── Expand toggle ──────────────────────────────
            if (camps.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(children: [
                  Text(
                    _expanded
                        ? 'Hide campaigns'
                        : 'Show ${camps.length} campaign${camps.length == 1 ? "" : "s"}',
                    style: const TextStyle(
                        color: AppTheme.brand,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.brand, size: 16,
                  ),
                ]),
              ),
            ],
          ]),
        ),

        // ── Campaign list (expanded) ──────────────────────
        if (_expanded)
          Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border))),
            child: Column(
              children: camps.map((c) => _CampaignRow(campaign: c)).toList(),
            ),
          ),
      ]),
    );
  }

  Widget _stat(String lbl, String val, Color c) => Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lbl,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 9)),
          Text(val,
              style: TextStyle(
                  color: c, fontSize: 11, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis),
        ]),
      );

  static String _fmt(double v) {
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

// ── Campaign row (inside expanded advertiser card) ─────────────────
class _CampaignRow extends StatelessWidget {
  final Campaign campaign;
  const _CampaignRow({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final statusColor = _sc(campaign.status);
    final progress = campaign.totalBudget > 0
        ? (campaign.spentBudget / campaign.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 6, height: 6,
            decoration:
                BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(campaign.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999)),
            child: Text(campaign.status.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          _mini('Budget',
              'SAR ${campaign.totalBudget.toStringAsFixed(0)}', AppTheme.blue),
          _mini('Spent',
              'SAR ${campaign.spentBudget.toStringAsFixed(0)}', AppTheme.brand),
          _mini('Impressions',
              _fmtN(campaign.actualImpressions), AppTheme.green),
          _mini('Rate',
              'SAR ${campaign.ratePerKm.toStringAsFixed(1)}/km',
              AppTheme.yellow),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(
                progress > 0.9 ? Colors.red : AppTheme.brand),
            minHeight: 3,
          ),
        ),
      ]),
    );
  }

  Widget _mini(String lbl, String val, Color c) => Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lbl,
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 8)),
          Text(val,
              style: TextStyle(
                  color: c, fontSize: 10, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ]),
      );

  Color _sc(String s) {
    switch (s) {
      case 'active':    return AppTheme.green;
      case 'pending':   return AppTheme.yellow;
      case 'paused':    return AppTheme.blue;
      case 'completed': return AppTheme.textMuted;
      default:          return AppTheme.textMuted;
    }
  }

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
