import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('📄 Reports & Analytics')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fsService.aggregateStats(uid),
        builder: (_, aggSnap) {
          final agg = aggSnap.data ?? {};
          final totalImpressions = (agg['totalImpressions'] ?? 0) as int;
          final totalSpent = (agg['totalSpent'] ?? 0.0) as double;
          final campaigns = (agg['campaigns'] ?? 0) as int;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // ── Performance summary ──────────────────────────
              const Text('Performance Summary',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _MetricCard(
                  label: 'Total Impressions',
                  value: _fmtNum(totalImpressions),
                  icon: Icons.visibility_rounded,
                  color: AppTheme.brand,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: 'Total Spend',
                  value: 'SAR ${_fmtNum(totalSpent.toInt())}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppTheme.blue,
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _MetricCard(
                  label: 'Campaigns Run',
                  value: '$campaigns',
                  icon: Icons.campaign_rounded,
                  color: AppTheme.green,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                  label: 'Est. Avg ROI',
                  value: totalSpent > 0
                      ? '${(totalImpressions * 0.004 / totalSpent).toStringAsFixed(1)}×'
                      : '—',
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.yellow,
                )),
              ]),
              const SizedBox(height: 24),

              // ── ROI comparison vs competitors ────────────────
              const Text('ROI vs Other Channels',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              _RoiTable(),
              const SizedBox(height: 24),

              // ── Campaign performance list ─────────────────────
              const Text('Campaign Performance',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              StreamBuilder<List<Campaign>>(
                stream: fsService.myCampaignsStream(uid),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.brand));
                  }
                  final campaigns = snap.data ?? [];
                  if (campaigns.isEmpty) {
                    return const Text('No campaigns yet',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 13));
                  }
                  return Column(
                    children: campaigns
                        .map((c) => _CampaignPerfRow(campaign: c))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Invoices ──────────────────────────────────────
              const Text('Invoices',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              StreamBuilder<List<Invoice>>(
                stream: fsService.invoicesStream(uid),
                builder: (_, snap) {
                  final invoices = snap.data ?? [];
                  if (invoices.isEmpty) {
                    return Card(
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('No invoices yet',
                              style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 13)),
                        ),
                      ),
                    );
                  }
                  return Column(
                      children: invoices.map((inv) => _InvoiceRow(invoice: inv)).toList());
                },
              ),

              const SizedBox(height: 24),

              // ── Top zones ─────────────────────────────────────
              const Text('Top Performing Zones',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              _TopZones(),
              const SizedBox(height: 80),
            ]),
          );
        },
      ),
    );
  }

  static String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── ROI comparison table ──────────────────────────────────────────
class _RoiTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final benchmarks = RoiComparison.benchmarks();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Header
          Row(children: const [
            Expanded(
                flex: 3,
                child: Text('Channel',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700))),
            Expanded(
                child: Text('CPM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 10))),
            Expanded(
                child: Text('CTR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 10))),
            Expanded(
                child: Text('ROI',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 10))),
          ]),
          const Divider(color: AppTheme.border, height: 16),
          ...benchmarks.map((b) {
            final isUs = b.channel == 'AdStick Cars';
            final color = Color(
                int.parse(b.color.replaceFirst('#', 'FF'), radix: 16));
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: Row(children: [
                    Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(b.channel,
                        style: TextStyle(
                            color: isUs ? Colors.white : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: isUs
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ]),
                ),
                Expanded(
                    child: Text(
                  'SAR ${b.cpm.toStringAsFixed(1)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11),
                )),
                Expanded(
                    child: Text(
                  '${b.ctr.toStringAsFixed(1)}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11),
                )),
                Expanded(
                    child: Text(
                  '${b.roi.toStringAsFixed(1)}×',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                )),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

// ── Campaign performance row ──────────────────────────────────────
class _CampaignPerfRow extends StatelessWidget {
  final Campaign campaign;
  const _CampaignPerfRow({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final statusColor = campaign.status == 'active'
        ? AppTheme.green
        : AppTheme.textMuted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Expanded(
              child: Text(campaign.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            Text(
              campaign.status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _mini('Impressions',
                _fmtN(campaign.actualImpressions), AppTheme.brand),
            const SizedBox(width: 16),
            _mini('Spent',
                'SAR ${campaign.spentBudget.toStringAsFixed(0)}',
                AppTheme.blue),
            const SizedBox(width: 16),
            _mini('ROI',
                campaign.estimatedRoi > 0
                    ? '${campaign.estimatedRoi.toStringAsFixed(1)}×'
                    : '—',
                AppTheme.green),
          ]),
        ]),
      ),
    );
  }

  Widget _mini(String lbl, String val, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 9)),
        Text(val,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w800)),
      ]);

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Invoice row ───────────────────────────────────────────────────
class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final color = invoice.status == 'paid'
        ? AppTheme.green
        : invoice.isOverdue
            ? Colors.red
            : const Color(0xFFFBBF24);

    final dateStr = invoice.issuedDate != null
        ? _fmt(invoice.issuedDate!)
        : 'Pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: AppTheme.brand.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.receipt_long_rounded,
              color: AppTheme.brand, size: 20),
        ),
        title: Text(invoice.campaignName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis),
        subtitle: Text('SAR ${invoice.amount.toStringAsFixed(2)}  ·  $dateStr',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 11)),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999)),
          child: Text(
            _statusLabel(invoice.status, invoice.isOverdue),
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String s, bool overdue) {
    if (overdue) return 'Overdue';
    switch (s) {
      case 'paid':  return 'Paid';
      case 'sent':  return 'Due';
      case 'draft': return 'Draft';
      default:      return s;
    }
  }

  String _fmt(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }
}

// ── Top zones (static data — would be Firestore in production) ────
class _TopZones extends StatelessWidget {
  static const _zones = [
    ('King Fahd Road',     840000, 0.92),
    ('Al-Olaya District',  720000, 0.78),
    ('Tahlia Street',      650000, 0.70),
    ('Al-Malaz',           480000, 0.52),
    ('Diplomatic Quarter', 310000, 0.34),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _zones.map((z) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(
                  width: 130,
                  child: Text(z.$1,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: z.$3,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(
                          AppTheme.brand),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmtN(z.$2),
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
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
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
      );
}
