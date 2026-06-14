import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Earnings'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.driverGreen,
          labelColor: AppTheme.driverGreen,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _TodayTab(uid: uid),
        _HistoryTab(uid: uid, days: 7, label: 'This Week'),
        _HistoryTab(uid: uid, days: 30, label: 'This Month'),
      ]),
    );
  }
}

// ── Today Tab ────────────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  final String uid;
  const _TodayTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: fsService.rtdbDriverStream(uid),
      builder: (ctx, rtdbSnap) {
        final rtdb  = rtdbSnap.data ?? {};
        final stats = (rtdb['todayStats'] as Map?) ?? {};
        final km    = double.tryParse(stats['distanceKm']?.toString() ?? '0') ?? 0;
        final baseEarnings    = km * 0.85;
        final peakBonus       = km * 0.10;
        final campaignBonus   = km * 0.05;
        final total           = baseEarnings + peakBonus + campaignBonus;
        final durationMin     = double.tryParse(stats['durationMinutes']?.toString() ?? '0') ?? 0;
        final isActive        = rtdb['isActive'] == true;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Live hero ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Total Earned',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.driverGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('● LIVE',
                          style: TextStyle(
                              color: AppTheme.driverGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ]),
                const SizedBox(height: 8),
                Text(
                  'SAR ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _mini('${km.toStringAsFixed(1)} km', 'Distance'),
                  _mini('SAR 0.85/km', 'Base Rate'),
                  _mini('${durationMin.toInt()} min', 'Drive Time'),
                ]),
              ]),
            ),

            const SizedBox(height: 20),
            const SectionHeader(title: 'Breakdown'),
            const SizedBox(height: 12),

            _row('Base earnings  (km × SAR 0.85)',
                'SAR ${baseEarnings.toStringAsFixed(2)}'),
            _row('Peak hour bonus  (+10%)',
                '+ SAR ${peakBonus.toStringAsFixed(2)}',
                color: AppTheme.driverGreen),
            _row('Campaign bonus  (+5%)',
                '+ SAR ${campaignBonus.toStringAsFixed(2)}',
                color: AppTheme.driverGreen),
            const Divider(color: AppTheme.border, height: 24),
            _row('Total', 'SAR ${total.toStringAsFixed(2)}', bold: true),

            const SizedBox(height: 20),
            const SectionHeader(title: 'Forecast'),
            const SizedBox(height: 12),
            _ForecastCard(kmSoFar: km),

            const SizedBox(height: 80),
          ]),
        );
      },
    );
  }

  Widget _mini(String val, String lbl) => Column(children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        Text(lbl,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
      ]);

  Widget _row(String l, String v, {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l,
                  style: TextStyle(
                      color: bold ? Colors.white : AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight:
                          bold ? FontWeight.w700 : FontWeight.w400)),
              Text(v,
                  style: TextStyle(
                      color: color ??
                          (bold ? Colors.white : AppTheme.textMuted),
                      fontSize: 14,
                      fontWeight: bold
                          ? FontWeight.w800
                          : FontWeight.w600)),
            ]),
      );
}

// ── History Tab (Week / Month) ────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final String uid;
  final int days;
  final String label;
  const _HistoryTab(
      {required this.uid, required this.days, required this.label});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EarningsEntry>>(
      stream: fsService.earningsStream(uid, days: days),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.driverGreen));
        }

        final entries = snap.data ?? [];
        final totalKm =
            entries.fold(0.0, (s, e) => s + e.km);
        final totalBase =
            entries.fold(0.0, (s, e) => s + e.baseEarnings);
        final totalPeak =
            entries.fold(0.0, (s, e) => s + e.peakBonus);
        final totalCampaign =
            entries.fold(0.0, (s, e) => s + e.campaignBonus);
        final totalStreak =
            entries.fold(0.0, (s, e) => s + e.streakBonus);
        final grandTotal =
            entries.fold(0.0, (s, e) => s + e.totalAmount);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('SAR ${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _mini('${totalKm.toStringAsFixed(1)} km',
                              'Distance'),
                          _mini('SAR 0.85/km', 'Base Rate'),
                          _mini('${entries.length} days',
                              'Active Days'),
                        ]),
                  ]),
                ),

                const SizedBox(height: 20),
                const SectionHeader(title: 'Breakdown'),
                const SizedBox(height: 12),
                _row('Base earnings',
                    'SAR ${totalBase.toStringAsFixed(2)}'),
                _row('Peak hour bonus',
                    '+ SAR ${totalPeak.toStringAsFixed(2)}',
                    color: AppTheme.driverGreen),
                _row('Campaign bonus',
                    '+ SAR ${totalCampaign.toStringAsFixed(2)}',
                    color: AppTheme.driverGreen),
                if (totalStreak > 0)
                  _row('Streak bonus',
                      '+ SAR ${totalStreak.toStringAsFixed(2)}',
                      color: const Color(0xFFF59E0B)),
                const Divider(color: AppTheme.border, height: 24),
                _row('Total',
                    'SAR ${grandTotal.toStringAsFixed(2)}',
                    bold: true),

                const SizedBox(height: 20),

                if (entries.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(children: const [
                        Icon(Icons.account_balance_wallet_outlined,
                            color: AppTheme.textMuted, size: 48),
                        SizedBox(height: 12),
                        Text('No earnings recorded yet',
                            style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14)),
                        SizedBox(height: 6),
                        Text('Start driving to see your earnings here',
                            style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12)),
                      ]),
                    ),
                  ),
                ] else ...[
                  const SectionHeader(title: 'Daily Breakdown'),
                  const SizedBox(height: 12),
                  ...entries.map((e) => _DayRow(entry: e)),
                ],

                const SizedBox(height: 20),
                const SectionHeader(title: 'Payout History'),
                const SizedBox(height: 12),
                _PayoutHistory(uid: uid),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.account_balance_rounded),
                    label: const Text('Request Payout'),
                    onPressed: grandTotal > 0
                        ? () => _showPayoutDialog(
                            context, uid, grandTotal)
                        : null,
                  ),
                ),
                const SizedBox(height: 80),
              ]),
        );
      },
    );
  }

  Widget _mini(String val, String lbl) => Column(children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        Text(lbl,
            style: const TextStyle(
                color: Colors.white60, fontSize: 11)),
      ]);

  Widget _row(String l, String v,
          {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l,
                  style: TextStyle(
                      color: bold ? Colors.white : AppTheme.textMuted,
                      fontSize: 14,
                      fontWeight: bold
                          ? FontWeight.w700
                          : FontWeight.w400)),
              Text(v,
                  style: TextStyle(
                      color: color ??
                          (bold ? Colors.white : AppTheme.textMuted),
                      fontSize: 14,
                      fontWeight: bold
                          ? FontWeight.w800
                          : FontWeight.w600)),
            ]),
      );

  void _showPayoutDialog(
      BuildContext context, String uid, double available) {
    showDialog(
      context: context,
      builder: (_) => _PayoutDialog(uid: uid, available: available),
    );
  }
}

// ── Payout dialog ─────────────────────────────────────────────────
class _PayoutDialog extends StatefulWidget {
  final String uid;
  final double available;
  const _PayoutDialog({required this.uid, required this.available});
  @override
  State<_PayoutDialog> createState() => _PayoutDialogState();
}

class _PayoutDialogState extends State<_PayoutDialog> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.available.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_ctrl.text.trim()) ?? 0;
    setState(() {
      _error = null;
      if (amount < 50) _error = 'Minimum payout is SAR 50';
      if (amount > widget.available) {
        _error = 'Amount exceeds available balance';
      }
    });
    if (_error != null) return;

    setState(() => _loading = true);
    try {
      final profile = await fsService.getDriverProfile(widget.uid);
      await fsService.requestPayout(
        uid: widget.uid,
        driverName: profile?.name ?? '',
        amount: amount,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Payout of SAR ${amount.toStringAsFixed(2)} requested'),
            backgroundColor: AppTheme.driverGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Request Payout',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          'Available: SAR ${widget.available.toStringAsFixed(2)}',
          style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: 'SAR  ',
            prefixStyle:
                const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.dark3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: _error,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Minimum payout: SAR 50',
            style: TextStyle(
                color: AppTheme.textMuted, fontSize: 11)),
      ]),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: AppTheme.textMuted)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Request'),
        ),
      ],
    );
  }
}

// ── Payout history list ───────────────────────────────────────────
class _PayoutHistory extends StatelessWidget {
  final String uid;
  const _PayoutHistory({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PayoutRequest>>(
      stream: fsService.payoutHistoryStream(uid),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
                color: AppTheme.driverGreen),
          ));
        }

        final payouts = snap.data ?? [];
        if (payouts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No payouts yet',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
          );
        }

        return Column(
          children: payouts.map((p) {
            final color = p.status == 'completed'
                ? AppTheme.driverGreen
                : p.status == 'processing'
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFFFBBF24);

            final dateStr = p.requestedAt != null
                ? '${p.requestedAt!.day} ${_month(p.requestedAt!.month)} ${p.requestedAt!.year}'
                : 'Pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded,
                      color: color, size: 20),
                ),
                title: Text(
                  'SAR ${p.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
                subtitle: Text(dateStr,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(p.status),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed':  return 'Paid';
      case 'processing': return 'Processing';
      case 'rejected':   return 'Rejected';
      default:           return 'Pending';
    }
  }

  String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}

// ── Day row ───────────────────────────────────────────────────────
class _DayRow extends StatelessWidget {
  final EarningsEntry entry;
  const _DayRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.driverGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(entry.dayLabel,
                style: const TextStyle(
                    color: AppTheme.driverGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        title: Text('SAR ${entry.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
        subtitle: Text('${entry.km.toStringAsFixed(1)} km',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        trailing: Text('${entry.impressions} impr.',
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
      ),
    );
  }
}

// ── Forecast card ─────────────────────────────────────────────────
class _ForecastCard extends StatelessWidget {
  final double kmSoFar;
  const _ForecastCard({required this.kmSoFar});

  @override
  Widget build(BuildContext context) {
    final targets = [20.0, 50.0, 100.0];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('If you drive...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...targets.map((target) {
            final remaining = (target - kmSoFar).clamp(0, double.infinity);
            final earn = target * 1.15; // base + bonuses
            if (remaining <= 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${remaining.toStringAsFixed(0)} more km',
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13),
                    ),
                    Text(
                      '→ SAR ${earn.toStringAsFixed(2)} total',
                      style: const TextStyle(
                          color: AppTheme.driverGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
            );
          }),
        ],
      ),
    );
  }
}
