import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_l10n.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountCtrl = TextEditingController();
  final _ibanCtrl   = TextEditingController();
  String _method    = 'bank';
  bool   _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _ibanCtrl.dispose();
    super.dispose();
  }

  void _setAmount(double pct, double available) {
    final v = (available * pct).toStringAsFixed(2);
    setState(() => _amountCtrl.text = v);
  }

  Future<void> _submit(AppL10n l, double available, String driverName) async {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amt < 50) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.t('min_withdraw')),
          backgroundColor: Colors.red.shade700));
      return;
    }
    if (amt > available) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Amount exceeds available balance'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _submitting = true);
    try {
      final uid = authService.currentUser!.uid;
      await fsService.requestPayout(
        uid: uid,
        driverName: driverName,
        amount: amt,
      );
      if (!mounted) return;
      _amountCtrl.clear();
      _ibanCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.t('withdraw_success')),
          backgroundColor: AppTheme.driverGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l   = AppL10n.of(context);
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('wallet_title'))),
      body: StreamBuilder<DriverProfile>(
        stream: fsService.driverProfileStream(uid),
        builder: (ctx, snap) {
          final profile  = snap.data;
          final available = profile?.walletBalance ?? 0;
          final totalEarned = profile?.totalEarnings ?? 0;
          final totalWithdrawn = profile?.totalWithdrawn ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Balance card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.driverGreen,
                             AppTheme.driverGreen.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                    color: AppTheme.driverGreen.withValues(alpha: 0.35),
                    blurRadius: 20, offset: const Offset(0, 6),
                  )],
                ),
                child: Column(children: [
                  Text(l.t('avail_balance'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  snap.connectionState == ConnectionState.waiting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('SAR ${available.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 36,
                              fontWeight: FontWeight.w900)),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: _BalStat(
                        label: l.t('total_earned'),
                        value: 'SAR ${totalEarned.toStringAsFixed(0)}')),
                    Container(width: 1, height: 36, color: Colors.white24),
                    Expanded(child: _BalStat(
                        label: l.t('total_withdrawn'),
                        value: 'SAR ${totalWithdrawn.toStringAsFixed(0)}')),
                  ]),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Withdrawal request ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.card, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.t('withdrawal_req'),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),

                  Text(l.t('withdraw_amount'),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _QuickBtn(
                        label: l.t('withdraw_all'),
                        onTap: () => _setAmount(1.0, available),
                        accent: AppTheme.driverGreen),
                    const SizedBox(width: 8),
                    _QuickBtn(
                        label: l.t('pct_75'),
                        onTap: () => _setAmount(0.75, available)),
                    const SizedBox(width: 8),
                    _QuickBtn(
                        label: l.t('pct_50'),
                        onTap: () => _setAmount(0.50, available)),
                    const SizedBox(width: 8),
                    _QuickBtn(
                        label: l.t('pct_25'),
                        onTap: () => _setAmount(0.25, available)),
                  ]),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      prefixText: 'SAR  ',
                      prefixStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 14),
                      hintText: '0.00',
                      hintStyle:
                          const TextStyle(color: AppTheme.textMuted),
                      filled: true, fillColor: AppTheme.dark3,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l.t('min_withdraw'),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11)),
                  ),
                  const SizedBox(height: 16),

                  Text(l.t('pay_method'),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _MethodTile(
                      icon: Icons.account_balance_rounded,
                      label: l.t('bank_transfer'),
                      selected: _method == 'bank',
                      onTap: () => setState(() => _method = 'bank'),
                      accent: AppTheme.driverGreen,
                    ),
                    const SizedBox(width: 10),
                    _MethodTile(
                      icon: Icons.phone_iphone_rounded,
                      label: l.t('stc_pay'),
                      selected: _method == 'stc',
                      onTap: () => setState(() => _method = 'stc'),
                      accent: AppTheme.driverGreen,
                    ),
                  ]),
                  const SizedBox(height: 14),

                  Text(l.t('iban_label'),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ibanCtrl,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14,
                        letterSpacing: 1.2),
                    decoration: InputDecoration(
                      hintText: l.t('iban_hint'),
                      hintStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13),
                      filled: true, fillColor: AppTheme.dark3,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_submitting || available < 50)
                          ? null
                          : () => _submit(l, available,
                              profile?.name ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.driverGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(l.t('submit_withdraw'),
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                    ),
                  ),

                  if (available < 50)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Drive more to reach the SAR 50 minimum payout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppTheme.textMuted.withValues(alpha: 0.7),
                            fontSize: 11),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Recent payouts ──────────────────────────────────
              Text(l.t('recent_txns'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _PayoutList(uid: uid),
              const SizedBox(height: 16),
            ]),
          );
        },
      ),
    );
  }
}

// ── Payout list ───────────────────────────────────────────────────
class _PayoutList extends StatelessWidget {
  final String uid;
  const _PayoutList({required this.uid});

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

        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No payouts yet',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13)),
              ),
            ),
          );
        }

        return Column(
          children: items.map((p) {
            final statusColor = p.status == 'completed'
                ? AppTheme.driverGreen
                : p.status == 'processing'
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFFFBBF24);

            final dateStr = p.requestedAt != null
                ? _fmt(p.requestedAt!)
                : 'Pending';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.driverGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: AppTheme.driverGreen, size: 20),
                ),
                title: Text('SAR ${p.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                subtitle: Text(dateStr,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(p.status),
                    style: TextStyle(
                        color: statusColor,
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

  String _fmt(DateTime dt) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed':  return 'Paid';
      case 'processing': return 'Processing';
      case 'rejected':   return 'Rejected';
      default:           return 'Pending';
    }
  }
}

// ── Helper widgets ─────────────────────────────────────────────────

class _BalStat extends StatelessWidget {
  final String label, value;
  const _BalStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
      ]);
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color accent;
  const _QuickBtn(
      {required this.label,
      required this.onTap,
      this.accent = AppTheme.textMuted});
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: accent.withValues(
                  alpha: accent == AppTheme.driverGreen ? 0.15 : 0.06),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: accent == AppTheme.driverGreen
                          ? AppTheme.driverGreen
                          : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  const _MethodTile(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap,
      required this.accent});
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color:
                  selected ? accent.withValues(alpha: 0.15) : AppTheme.dark3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected ? accent : AppTheme.border,
                  width: 1.5),
            ),
            child:
                Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  color:
                      selected ? accent : AppTheme.textMuted,
                  size: 22),
              const SizedBox(height: 5),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: selected ? accent : AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}
