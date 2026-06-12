import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('🏷️ My Campaign')),
      body: StreamBuilder<DriverProfile>(
        stream: fsService.driverProfileStream(uid),
        builder: (_, profileSnap) {
          if (profileSnap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.driverGreen));
          }

          final profile = profileSnap.data;
          final campaignId = profile?.currentCampaignId;

          if (campaignId == null || campaignId.isEmpty) {
            return _NoCampaign();
          }

          return FutureBuilder<Campaign?>(
            future: fsService.getCampaign(campaignId),
            builder: (_, campSnap) {
              if (campSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.driverGreen));
              }

              final campaign = campSnap.data;
              if (campaign == null) return _NoCampaign();

              return _CampaignBody(campaign: campaign, profile: profile!);
            },
          );
        },
      ),
    );
  }
}

// ── No campaign state ─────────────────────────────────────────────
class _NoCampaign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.driverGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.label_off_rounded,
                  color: AppTheme.driverGreen, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('No Active Campaign',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              "You're not assigned to a campaign yet.\nAn admin will assign one based on your tier and location.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(children: [
                _tip(Icons.route_rounded,
                    'Keep driving to improve your quality score'),
                const SizedBox(height: 8),
                _tip(Icons.star_rounded,
                    'Higher tier drivers get premium campaigns'),
                const SizedBox(height: 8),
                _tip(Icons.notifications_rounded,
                    "You'll be notified when assigned"),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tip(IconData icon, String text) => Row(children: [
        Icon(icon, color: AppTheme.driverGreen, size: 16),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12))),
      ]);
}

// ── Active campaign body ──────────────────────────────────────────
class _CampaignBody extends StatelessWidget {
  final Campaign campaign;
  final DriverProfile profile;
  const _CampaignBody(
      {required this.campaign, required this.profile});

  @override
  Widget build(BuildContext context) {
    final kmRequired = campaign.totalBudget / campaign.ratePerKm;
    final kmDone = (campaign.spentBudget / campaign.ratePerKm)
        .clamp(0, kmRequired);
    final progress =
        kmRequired > 0 ? (kmDone / kmRequired).clamp(0.0, 1.0) : 0.0;
    final daysLeft = campaign.endDate != null
        ? campaign.endDate!.difference(DateTime.now()).inDays
        : 0;
    final myImpressions = (kmDone * 14).toInt(); // ~14 impressions/km
    final myEarnings = kmDone * campaign.ratePerKm;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Hero card ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1a0533), Color(0xFF2d1b69)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.driverGreen.withValues(alpha: 0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Campaign',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12)),
                      _statusBadge(campaign.status),
                    ]),
                const SizedBox(height: 12),
                Text(campaign.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text('by ${campaign.advertiserName}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
                if (campaign.endDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ends: ${_fmtDate(campaign.endDate!)}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
                Row(children: [
                  _campStat('KM Required',
                      kmRequired.toStringAsFixed(0)),
                  const SizedBox(width: 24),
                  _campStat('KM Done', kmDone.toStringAsFixed(0)),
                  const SizedBox(width: 24),
                  _campStat('Days Left',
                      daysLeft > 0 ? '$daysLeft' : 'Ended'),
                ]),
                const SizedBox(height: 16),
                const Text('Progress',
                    style: TextStyle(
                        color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(
                        AppTheme.driverGreen),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% complete',
                  style: const TextStyle(
                      color: AppTheme.driverGreen, fontSize: 11),
                ),
              ]),
        ),
        const SizedBox(height: 20),

        // ── Your contribution ─────────────────────────────────────
        const Text('Your Contribution',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 12),
        Row(children: [
          _ContribCard(
            icon: Icons.remove_red_eye_rounded,
            label: 'Impressions',
            value: _fmtNum(myImpressions),
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: 12),
          _ContribCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'My Earnings',
            value: 'SAR ${myEarnings.toStringAsFixed(2)}',
            color: AppTheme.driverGreen,
          ),
        ]),
        const SizedBox(height: 20),

        // ── Rate card ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(children: [
            const Icon(Icons.monetization_on_rounded,
                color: AppTheme.driverGreen),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text('Your Rate',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
              Text(
                'SAR ${campaign.ratePerKm.toStringAsFixed(2)} per km',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ]),
            const Spacer(),
            if (campaign.city.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(campaign.city,
                    style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Photo proof ───────────────────────────────────────────
        const Text('Ad Verification',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              GestureDetector(
                onTap: () => _showPhotoDialog(context),
                child: Container(
                  width: double.infinity, height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f2027),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.driverGreen
                            .withValues(alpha: 0.2)),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded,
                            size: 48, color: AppTheme.textMuted),
                        const SizedBox(height: 8),
                        const Text('Tap to upload ad photo',
                            style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_rounded,
                              size: 16),
                          label: const Text('Upload Photo'),
                          onPressed: () => _showPhotoDialog(context),
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              _checkRow(true, 'Sticker applied correctly'),
              _checkRow(true, 'Position verified'),
              _checkRow(true, 'Dimensions match spec'),
              _checkRow(false, 'Next check-in due in 3 days'),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // ── Campaign rules ────────────────────────────────────────
        const Text('Campaign Rules',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 12),
        ...[
          'Drive in the designated zones',
          'Minimum 4 hours per day',
          'No sticker damage allowed',
          'Report any issues within 24 hours',
          'Keep the vehicle clean at all times',
        ].map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppTheme.textMuted, size: 16),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(r,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13))),
              ]),
            )),
        const SizedBox(height: 80),
      ]),
    );
  }

  void _showPhotoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Upload Ad Photo',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'Take a clear photo of your ad sticker on the car. This helps verify campaign compliance.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📸 Photo submitted for review'),
                  backgroundColor: AppTheme.driverGreen,
                ),
              );
            },
            icon: const Icon(Icons.camera_alt_rounded, size: 16),
            label: const Text('Open Camera'),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'active'
        ? AppTheme.driverGreen
        : status == 'paused'
            ? const Color(0xFFFBBF24)
            : AppTheme.textMuted;
    final label = status == 'active'
        ? '● Active'
        : status == 'paused'
            ? '⏸ Paused'
            : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _campStat(String lbl, String val) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lbl,
            style: const TextStyle(
                color: Colors.white60, fontSize: 10)),
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
      ]);

  Widget _checkRow(bool done, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(
            done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: done ? AppTheme.driverGreen : AppTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: done ? Colors.white : AppTheme.textMuted,
                  fontSize: 13)),
        ]),
      );

  String _fmtDate(DateTime dt) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Contribution card ─────────────────────────────────────────────
class _ContribCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _ContribCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
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
                        color: AppTheme.textMuted,
                        fontSize: 11)),
              ]),
        ),
      );
}
