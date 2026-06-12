import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📢 My Campaigns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.brand),
            onPressed: () => _showCreate(context, uid),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreate(context, uid),
        backgroundColor: AppTheme.brand,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Campaign',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<Campaign>>(
        stream: fsService.myCampaignsStream(uid),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }

          final all = snap.data ?? [];
          if (all.isEmpty) {
            return _EmptyState(onTap: () => _showCreate(context, uid));
          }

          // Group by status
          final active    = all.where((c) => c.status == 'active').toList();
          final pending   = all.where((c) => c.status == 'pending').toList();
          final paused    = all.where((c) => c.status == 'paused').toList();
          final completed = all.where((c) => c.status == 'completed').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              if (active.isNotEmpty) ...[
                _sectionLabel('Active', active.length, AppTheme.green),
                ...active.map((c) => _CampaignCard(campaign: c, uid: uid)),
              ],
              if (pending.isNotEmpty) ...[
                _sectionLabel('Pending Review', pending.length,
                    const Color(0xFFFBBF24)),
                ...pending.map((c) => _CampaignCard(campaign: c, uid: uid)),
              ],
              if (paused.isNotEmpty) ...[
                _sectionLabel('Paused', paused.length, AppTheme.textMuted),
                ...paused.map((c) => _CampaignCard(campaign: c, uid: uid)),
              ],
              if (completed.isNotEmpty) ...[
                _sectionLabel('Completed', completed.length,
                    AppTheme.textMuted),
                ...completed.map((c) => _CampaignCard(campaign: c, uid: uid)),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showCreate(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.dark2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CreateCampaignSheet(uid: uid),
    );
  }

  Widget _sectionLabel(String label, int count, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text('$label  ($count)',
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6)),
        ]),
      );
}

// ── Campaign card ─────────────────────────────────────────────────
class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final String uid;
  const _CampaignCard({required this.campaign, required this.uid});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(campaign.status);
    final impressions = campaign.actualImpressions;
    final kmCovered   = campaign.spentBudget / campaign.ratePerKm;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(campaign.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: campaign.status),
          ]),
          const SizedBox(height: 4),
          Text(
            [
              if (campaign.city.isNotEmpty) campaign.city,
              '${campaign.activeCars} cars',
              'SAR ${campaign.ratePerKm.toStringAsFixed(2)}/km',
            ].join(' · '),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // Stats row
          Row(children: [
            _statCol('Impressions',
                _fmtNum(impressions), AppTheme.brand),
            const SizedBox(width: 20),
            _statCol('KM Covered',
                '${_fmtNum(kmCovered.toInt())} km', AppTheme.blue),
            const SizedBox(width: 20),
            _statCol('ROI',
                campaign.estimatedRoi > 0
                    ? '${campaign.estimatedRoi.toStringAsFixed(1)}×'
                    : '—',
                AppTheme.green),
          ]),
          const SizedBox(height: 14),

          // Budget bar
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Budget: SAR ${campaign.totalBudget.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
            Text(
                'Spent: SAR ${campaign.spentBudget.toStringAsFixed(0)}',
                style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: campaign.budgetProgress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(campaign.budgetProgress * 100).toStringAsFixed(0)}% budget used',
            style: TextStyle(color: statusColor, fontSize: 11),
          ),

          // Action buttons (only for active/paused)
          if (campaign.status == 'active' || campaign.status == 'paused') ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(
                    campaign.status == 'active'
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 16,
                  ),
                  label: Text(
                      campaign.status == 'active' ? 'Pause' : 'Resume'),
                  onPressed: () => campaign.status == 'active'
                      ? fsService.pauseCampaign(campaign.id)
                      : fsService.resumeCampaign(campaign.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    side: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bar_chart_rounded, size: 16),
                  label: const Text('Analytics'),
                  onPressed: () =>
                      _showAnalytics(context, campaign),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  void _showAnalytics(BuildContext context, Campaign c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.dark2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CampaignAnalyticsSheet(campaign: c),
    );
  }

  Widget _statCol(String lbl, String val, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 10)),
        Text(val,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.w800)),
      ]);

  Color _statusColor(String status) {
    switch (status) {
      case 'active':    return AppTheme.green;
      case 'paused':    return const Color(0xFFFBBF24);
      case 'completed': return AppTheme.textMuted;
      case 'pending':   return const Color(0xFF60A5FA);
      default:          return AppTheme.textMuted;
    }
  }

  static String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Status badge ──────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'active':
        color = AppTheme.green; label = '● Active'; break;
      case 'paused':
        color = const Color(0xFFFBBF24); label = '⏸ Paused'; break;
      case 'pending':
        color = const Color(0xFF60A5FA); label = '⏳ Pending'; break;
      case 'completed':
        color = AppTheme.textMuted; label = '✓ Completed'; break;
      default:
        color = AppTheme.textMuted; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            const Text('📢', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('No campaigns yet',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Launch your first campaign to start reaching thousands of people through car advertising.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Launch First Campaign'),
            ),
          ]),
        ),
      );
}

// ── Analytics bottom sheet ────────────────────────────────────────
class _CampaignAnalyticsSheet extends StatelessWidget {
  final Campaign campaign;
  const _CampaignAnalyticsSheet({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text(campaign.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('by ${campaign.advertiserName}',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 20),

          // Stats
          Row(children: [
            _aStat('Impressions',
                _fmtN(campaign.actualImpressions), AppTheme.brand),
            const SizedBox(width: 12),
            _aStat('Active Cars',
                '${campaign.activeCars}', AppTheme.green),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _aStat('KM Covered',
                '${(campaign.spentBudget / campaign.ratePerKm).toStringAsFixed(0)} km',
                AppTheme.blue),
            const SizedBox(width: 12),
            _aStat('Budget Used',
                'SAR ${campaign.spentBudget.toStringAsFixed(0)}',
                AppTheme.yellow),
          ]),
          const SizedBox(height: 20),

          // A/B test (if any)
          if (campaign.abVariantA != null &&
              campaign.abVariantB != null) ...[
            const Text('A/B Test Results',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _abRow('Variant A', campaign.abVariantACtr, AppTheme.brand),
            const SizedBox(height: 6),
            _abRow('Variant B', campaign.abVariantBCtr, AppTheme.blue),
            const SizedBox(height: 20),
          ],

          // Photo proofs
          const Text('Photo Proofs',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          StreamBuilder<List<PhotoProof>>(
            stream: fsService.photoProofsStream(campaign.id),
            builder: (_, snap) {
              final proofs = snap.data ?? [];
              if (proofs.isEmpty) {
                return const Text('No photos uploaded yet',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13));
              }
              return SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: proofs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.dark3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Icon(Icons.photo_rounded,
                        color: AppTheme.textMuted),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _aStat(String lbl, String val, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(lbl,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
            const SizedBox(height: 4),
            Text(val,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ]),
        ),
      );

  Widget _abRow(String label, double ctr, Color color) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
          Text('${ctr.toStringAsFixed(1)}% CTR',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (ctr / 10).clamp(0.0, 1.0),
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ]);

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Create campaign sheet ─────────────────────────────────────────
class CreateCampaignSheet extends StatefulWidget {
  final String uid;
  const CreateCampaignSheet({super.key, required this.uid});
  @override
  State<CreateCampaignSheet> createState() => _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends State<CreateCampaignSheet> {
  final _nameCtrl   = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _cityCtrl   = TextEditingController();
  bool _submitting  = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name   = _nameCtrl.text.trim();
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    final city   = _cityCtrl.text.trim();

    setState(() => _error = null);
    if (name.isEmpty)   { setState(() => _error = 'Campaign name is required'); return; }
    if (budget < 500)   { setState(() => _error = 'Minimum budget is SAR 500'); return; }

    setState(() => _submitting = true);
    try {
      final profile = await fsService.getAdvertiserProfile(widget.uid);
      final campaign = Campaign(
        id: '',
        advertiserId: widget.uid,
        advertiserName: profile?.companyName ?? '',
        name: name,
        totalBudget: budget,
        city: city,
        ratePerKm: 1.0,
        targetImpressions: (budget * 300).toInt(), // ~300 impressions per SAR
      );
      await fsService.createCampaign(
        uid: widget.uid,
        companyName: profile?.companyName ?? '',
        campaign: campaign,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Campaign submitted for review'),
          backgroundColor: AppTheme.brand,
        ));
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 16),
        const Text('Launch New Campaign',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Submitted campaigns are reviewed within 24 hours.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 20),
        _field('Campaign Name', _nameCtrl, 'e.g. Summer Sale 2026'),
        const SizedBox(height: 12),
        _field('Total Budget (SAR)', _budgetCtrl, 'Min SAR 500',
            type: const TextInputType.numberWithOptions(decimal: true)),
        const SizedBox(height: 12),
        _field('City / Region', _cityCtrl, 'e.g. Riyadh'),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!,
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52)),
            child: _submitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Submit for Review',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            filled: true, fillColor: AppTheme.dark3,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ]);
}
