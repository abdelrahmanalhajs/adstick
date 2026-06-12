import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';
import 'campaigns_screen.dart' show CreateCampaignSheet;

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Campaign Overview'),
        actions: [
          StreamBuilder<AdvertiserProfile>(
            stream: fsService.advertiserProfileStream(uid),
            builder: (_, snap) {
              final name = snap.data?.companyName ?? '';
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: AppTheme.brand.withValues(alpha: 0.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                        color: AppTheme.brand,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Hero card (live summary) ───────────────────────────
          StreamBuilder<Map<String, dynamic>>(
            stream: fsService.summaryStream(uid),
            builder: (_, snap) {
              final data              = snap.data ?? {};
              final impressions       = (data['totalImpressions'] ?? 0) as int;
              final activeCars        = (data['activeCars'] ?? 0) as int;
              final roi               = (data['roi'] ?? 0.0) as double;
              final activeCampaigns   = (data['activeCampaigns'] ?? 0) as int;
              final isLoading         = snap.connectionState == ConnectionState.waiting;

              return StreamBuilder<AdvertiserProfile>(
                stream: fsService.advertiserProfileStream(uid),
                builder: (_, pSnap) {
                  final profile   = pSnap.data;
                  final greeting  = _greeting();
                  final firstName = profile?.name.split(' ').first ?? '';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7c2d12), Color(0xFF9a3412)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('$greeting${firstName.isNotEmpty ? ", $firstName" : ""} 👋',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      isLoading
                          ? const Text('Loading live stats...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900))
                          : Text(
                              impressions > 0
                                  ? '${_fmtNum(impressions)} impressions today'
                                  : activeCampaigns > 0
                                      ? '$activeCampaigns campaign${activeCampaigns > 1 ? "s" : ""} running'
                                      : 'Launch your first campaign',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        if (activeCars > 0)
                          _pill('$activeCars active cars', AppTheme.brand),
                        if (roi > 0)
                          _pill(
                              'ROI ${roi.toStringAsFixed(1)}×', AppTheme.green),
                        if (activeCampaigns == 0)
                          _pill('No active campaigns', AppTheme.textMuted),
                      ]),
                    ]),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // ── KPI grid ──────────────────────────────────────────
          StreamBuilder<Map<String, dynamic>>(
            stream: fsService.summaryStream(uid),
            builder: (_, snap) {
              final d = snap.data ?? {};
              final impressions = (d['totalImpressions'] ?? 0) as int;
              final activeCars  = (d['activeCars'] ?? 0) as int;
              final totalSpent  = (d['totalSpent'] ?? 0.0) as double;
              final roi         = (d['roi'] ?? 0.0) as double;

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    label: 'Impressions Today',
                    value: _fmtNum(impressions),
                    icon: Icons.visibility_rounded,
                    color: AppTheme.brand,
                  ),
                  _StatCard(
                    label: 'Active Cars',
                    value: '$activeCars',
                    icon: Icons.directions_car_rounded,
                    color: AppTheme.green,
                  ),
                  _StatCard(
                    label: 'Total Spent',
                    value: 'SAR ${_fmtNum(totalSpent.toInt())}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.blue,
                  ),
                  _StatCard(
                    label: 'Campaign ROI',
                    value: roi > 0
                        ? '${roi.toStringAsFixed(1)}×'
                        : '—',
                    icon: Icons.trending_up_rounded,
                    color: AppTheme.yellow,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Active campaigns ──────────────────────────────────
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            const Text('Active Campaigns',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            TextButton.icon(
              onPressed: () => _showCreateCampaign(context, uid),
              icon: const Icon(Icons.add_rounded,
                  color: AppTheme.brand, size: 16),
              label: const Text('New',
                  style: TextStyle(color: AppTheme.brand)),
            ),
          ]),
          const SizedBox(height: 12),
          StreamBuilder<List<Campaign>>(
            stream: fsService.myActiveCampaignsStream(uid),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                      color: AppTheme.brand),
                ));
              }

              final campaigns = snap.data ?? [];
              if (campaigns.isEmpty) {
                return _EmptyCampaigns(
                    onTap: () => _showCreateCampaign(context, uid));
              }

              return Column(
                children: campaigns
                    .map((c) => _CampaignTile(campaign: c, uid: uid))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── ROI comparison ────────────────────────────────────
          const Text('ROI vs Competitors',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 12),
          _RoiComparisonCard(),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateCampaign(context, uid),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Launch New Campaign'),
            ),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  void _showCreateCampaign(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.dark2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CreateCampaignSheet(uid: uid),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _pill(String t, Color c) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999)),
        child: Text(t,
            style: TextStyle(
                color: c, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  static String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Empty state ────────────────────────────────────────────────────
class _EmptyCampaigns extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyCampaigns({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.brand.withValues(alpha: 0.3),
                style: BorderStyle.solid),
          ),
          child: Column(children: [
            const Icon(Icons.campaign_rounded,
                color: AppTheme.brand, size: 40),
            const SizedBox(height: 12),
            const Text('No active campaigns',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Tap to launch your first campaign',
                style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ]),
        ),
      );
}

// ── Active campaign tile ──────────────────────────────────────────
class _CampaignTile extends StatelessWidget {
  final Campaign campaign;
  final String uid;
  const _CampaignTile({required this.campaign, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Expanded(
              child: Text(campaign.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999)),
              child: const Text('● Active',
                  style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            '${campaign.city.isNotEmpty ? "${campaign.city} · " : ""}${campaign.activeCars} cars',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: campaign.budgetProgress,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation(AppTheme.brand),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text(
              '${(campaign.budgetProgress * 100).toStringAsFixed(0)}% budget used',
              style: const TextStyle(
                  color: AppTheme.brand, fontSize: 11),
            ),
            Text(
              'SAR ${campaign.spentBudget.toStringAsFixed(0)} / ${campaign.totalBudget.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── ROI comparison card ───────────────────────────────────────────
class _RoiComparisonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final benchmarks = RoiComparison.benchmarks();
    final maxRoi =
        benchmarks.map((b) => b.roi).fold(0.0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ...benchmarks.map((b) {
            final isAdstick = b.channel == 'AdStick Cars';
            final color =
                Color(int.parse(b.color.replaceFirst('#', 'FF'), radix: 16));
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(b.channel,
                      style: TextStyle(
                          color: isAdstick ? Colors.white : AppTheme.textMuted,
                          fontSize: 13,
                          fontWeight: isAdstick
                              ? FontWeight.w700
                              : FontWeight.w400)),
                  Text('${b.roi.toStringAsFixed(1)}× ROI',
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: maxRoi > 0 ? b.roi / maxRoi : 0,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'CPM SAR ${b.cpm.toStringAsFixed(1)}  ·  CTR ${b.ctr.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10),
                ),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 10)),
                  Icon(icon, color: color, size: 18),
                ]),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ]),
        ),
      );
}
