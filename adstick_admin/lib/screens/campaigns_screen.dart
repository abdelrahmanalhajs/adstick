import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📣 Campaigns'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'All'),
          ]),
        ),
        body: const TabBarView(children: [
          _PendingTab(),
          _ActiveTab(),
          _AllCampaignsTab(),
        ]),
      ),
    );
  }
}

// ── Pending approvals ─────────────────────────────────────────────
class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<Campaign>>(
        stream: fsService.pendingCampaignsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.brand));
          }
          final campaigns = snap.data ?? [];
          if (campaigns.isEmpty) {
            return const Center(
              child: Text('No campaigns pending approval',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (_, i) => _CampaignCard(
                campaign: campaigns[i],
                showApproval: true,
                key: ValueKey(campaigns[i].id)),
          );
        },
      );
}

// ── Active campaigns ──────────────────────────────────────────────
class _ActiveTab extends StatelessWidget {
  const _ActiveTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<Campaign>>(
        stream: fsService.activeCampaignsStream(),
        builder: (_, snap) {
          final campaigns = snap.data ?? [];
          if (campaigns.isEmpty) {
            return const Center(
              child: Text('No active campaigns',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (_, i) => _CampaignCard(
                campaign: campaigns[i],
                key: ValueKey(campaigns[i].id)),
          );
        },
      );
}

// ── All campaigns ─────────────────────────────────────────────────
class _AllCampaignsTab extends StatelessWidget {
  const _AllCampaignsTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<Campaign>>(
        stream: fsService.allCampaignsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.brand));
          }
          final campaigns = snap.data ?? [];
          if (campaigns.isEmpty) {
            return const Center(
              child: Text('No campaigns yet',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campaigns.length,
            itemBuilder: (_, i) => _CampaignCard(
                campaign: campaigns[i],
                key: ValueKey(campaigns[i].id)),
          );
        },
      );
}

// ── Campaign card ─────────────────────────────────────────────────
class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final bool showApproval;
  const _CampaignCard(
      {required this.campaign, this.showApproval = false, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(campaign.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(campaign.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            'Advertiser: ${campaign.advertiserName}  ·  ${campaign.city.isNotEmpty ? campaign.city : "—"}',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _stat('Budget', 'SAR ${campaign.totalBudget.toStringAsFixed(0)}', AppTheme.blue),
            _stat('Spent', 'SAR ${campaign.spentBudget.toStringAsFixed(0)}', AppTheme.brand),
            _stat('Impressions', _fmtN(campaign.actualImpressions), AppTheme.green),
            _stat('Rate', 'SAR ${campaign.ratePerKm.toStringAsFixed(2)}/km', AppTheme.yellow),
          ]),
          const SizedBox(height: 8),
          // Budget progress
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: campaign.totalBudget > 0
                    ? (campaign.spentBudget / campaign.totalBudget)
                        .clamp(0.0, 1.0)
                    : 0,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation(AppTheme.brand),
                minHeight: 5,
              ),
            ),
          ]),

          if (showApproval) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReject(context, campaign),
                  icon: const Icon(Icons.close_rounded,
                      size: 16, color: Colors.red),
                  label: const Text('Reject',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      fsService.approveCampaign(campaign.id),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve'),
                ),
              ),
            ]),
          ],

          if (!showApproval &&
              (campaign.status == 'active' ||
                  campaign.status == 'paused')) ...[
            const SizedBox(height: 8),
            Row(children: [
              // Rate editor
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _editRate(context, campaign),
                  icon: const Icon(Icons.edit_rounded,
                      size: 14, color: AppTheme.brand),
                  label: const Text('Edit Rate',
                      style: TextStyle(
                          color: AppTheme.brand, fontSize: 12)),
                ),
              ),
              Expanded(
                child: campaign.status == 'active'
                    ? TextButton.icon(
                        onPressed: () =>
                            fsService.pauseCampaign(campaign.id),
                        icon: const Icon(Icons.pause_rounded,
                            size: 14, color: AppTheme.yellow),
                        label: const Text('Pause',
                            style: TextStyle(
                                color: AppTheme.yellow, fontSize: 12)),
                      )
                    : TextButton.icon(
                        onPressed: () =>
                            fsService.approveCampaign(campaign.id),
                        icon: const Icon(Icons.play_arrow_rounded,
                            size: 14, color: AppTheme.green),
                        label: const Text('Resume',
                            style: TextStyle(
                                color: AppTheme.green, fontSize: 12)),
                      ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _stat(String lbl, String val, Color c) => Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(lbl,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 9)),
          Text(val,
              style: TextStyle(
                  color: c,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ]),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'active':    return AppTheme.green;
      case 'pending':   return AppTheme.yellow;
      case 'paused':    return AppTheme.blue;
      case 'completed': return AppTheme.textMuted;
      default:          return AppTheme.textMuted;
    }
  }

  void _confirmReject(BuildContext context, Campaign c) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.dark2,
        title: const Text('Reject Campaign',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Reason for rejection',
            hintStyle: TextStyle(color: AppTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              fsService.rejectCampaign(
                  c.id, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _editRate(BuildContext context, Campaign c) {
    final ctrl = TextEditingController(
        text: c.ratePerKm.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.dark2,
        title: const Text('Edit Rate (SAR/km)',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            prefixText: 'SAR ',
            prefixStyle: TextStyle(color: AppTheme.brand),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            onPressed: () {
              final rate = double.tryParse(ctrl.text.trim());
              if (rate != null && rate > 0) {
                fsService.updateCampaignRate(c.id, rate);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
