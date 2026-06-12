import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class RoiScreen extends StatelessWidget {
  const RoiScreen({super.key});

  static const _benchmarks = {
    'AdStick': 4.8,
    'Billboard': 1.2,
    'Google Display': 2.1,
    'Social Ads': 2.8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 ROI Analytics')),
      body: StreamBuilder<List<Campaign>>(
        stream: fsService.allCampaignsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final campaigns = snap.data ?? [];
          final active = campaigns
              .where((c) => c.status == 'active' || c.status == 'completed')
              .toList();

          final totalSpend   = active.fold(0.0, (s, c) => s + c.spentBudget);
          final totalRevenue = totalSpend * 4.8;
          final platformCut  = totalSpend * 0.30;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader('Platform Performance'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      _kpi('Total Spend', 'SAR ${_fmt(totalSpend)}',
                          AppTheme.blue),
                      const SizedBox(width: 8),
                      _kpi('Est. Revenue', 'SAR ${_fmt(totalRevenue)}',
                          AppTheme.green),
                      const SizedBox(width: 8),
                      _kpi('Platform Cut', 'SAR ${_fmt(platformCut)}',
                          AppTheme.yellow),
                    ]),
                    const SizedBox(height: 14),
                    Row(children: [
                      const Text('Avg ROI',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                      const Spacer(),
                      Text(
                        '${totalSpend > 0 ? (totalRevenue / totalSpend).toStringAsFixed(1) : "4.8"}×',
                        style: const TextStyle(
                            color: AppTheme.green,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      ),
                    ]),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('vs. Industry Benchmarks'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _benchmarks.entries.map((e) {
                      final isUs = e.key == 'AdStick';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          SizedBox(
                            width: 110,
                            child: Text(e.key,
                                style: TextStyle(
                                    color: isUs
                                        ? AppTheme.brand
                                        : AppTheme.textMuted,
                                    fontSize: 12,
                                    fontWeight: isUs
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value / 6.0,
                                backgroundColor: AppTheme.border,
                                valueColor: AlwaysStoppedAnimation(
                                    isUs ? AppTheme.brand : AppTheme.textMuted),
                                minHeight: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value}×',
                              style: TextStyle(
                                  color: isUs
                                      ? AppTheme.brand
                                      : AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('Campaign ROI Breakdown'),
              if (active.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No active/completed campaigns',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 13)),
                  ),
                )
              else
                ...active.map((c) => _CampaignRoiCard(campaign: c)),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );

  Widget _kpi(String label, String val, Color c) => Expanded(
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  color: c, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
        ]),
      );

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
}

class _CampaignRoiCard extends StatelessWidget {
  final Campaign campaign;
  const _CampaignRoiCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final estimatedRevenue = (campaign.actualImpressions / 1000) * 25;
    final roi = campaign.spentBudget > 0
        ? estimatedRevenue / campaign.spentBudget
        : 4.8;
    final roiColor = roi >= 4.0
        ? AppTheme.green
        : roi >= 2.5
            ? AppTheme.yellow
            : AppTheme.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(campaign.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(campaign.advertiserName,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: roiColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${roi.toStringAsFixed(1)}×',
                  style: TextStyle(
                      color: roiColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _stat('Spend', 'SAR ${campaign.spentBudget.toStringAsFixed(0)}'),
            _stat('Impressions',
                '${(campaign.actualImpressions / 1000).toStringAsFixed(1)}K'),
            _stat('Est. Revenue',
                'SAR ${estimatedRevenue.toStringAsFixed(0)}'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Budget used: ',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: campaign.budgetProgress,
                  backgroundColor: AppTheme.border,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.brand),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${(campaign.budgetProgress * 100).toInt()}%',
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(String label, String val) => Expanded(
        child: Column(children: [
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
        ]),
      );
}
