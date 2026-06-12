import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📊 Reports & P&L'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Payouts'),
            Tab(text: 'Invoices'),
          ]),
        ),
        body: const TabBarView(children: [
          _PayoutsTab(),
          _InvoicesTab(),
        ]),
      ),
    );
  }
}

// ── Payouts management ────────────────────────────────────────────
class _PayoutsTab extends StatelessWidget {
  const _PayoutsTab();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<PayoutRequest>>(
        stream: fsService.allPayoutsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final payouts = snap.data ?? [];

          // Summary bar
          final pending = payouts.where((p) => p.status == 'pending');
          final totalPending =
              pending.fold(0.0, (s, p) => s + p.amount);

          return Column(children: [
            if (payouts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                      child: _miniBox(
                          'Total Payouts',
                          '${payouts.length}',
                          AppTheme.brand)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _miniBox(
                          'Pending',
                          '${pending.length}',
                          AppTheme.yellow)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _miniBox(
                          'Pending Amount',
                          'SAR ${totalPending.toStringAsFixed(0)}',
                          Colors.red)),
                ]),
              ),
            Expanded(
              child: payouts.isEmpty
                  ? const Center(
                      child: Text('No payout requests yet',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: payouts.length,
                      itemBuilder: (_, i) => _PayoutCard(
                          payout: payouts[i],
                          key: ValueKey(payouts[i].id)),
                    ),
            ),
          ]);
        },
      );

  Widget _miniBox(String lbl, String val, Color c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(val,
                style: TextStyle(
                    color: c,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
            Text(lbl,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ),
      );
}

// ── Payout card ───────────────────────────────────────────────────
class _PayoutCard extends StatelessWidget {
  final PayoutRequest payout;
  const _PayoutCard({required this.payout, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(payout.status);
    final isPending = payout.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Expanded(
              child: Text(payout.driverName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            Text('SAR ${payout.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: AppTheme.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 4),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text(
              payout.requestedAt != null
                  ? _fmt(payout.requestedAt!) : '—',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(payout.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          if (isPending) ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmAction(context,
                      payout, approve: false),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                  child: const Text('Reject',
                      style: TextStyle(
                          color: Colors.red, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmAction(context,
                      payout, approve: true),
                  child: const Text('Approve',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved': return AppTheme.green;
      case 'pending':  return AppTheme.yellow;
      case 'rejected': return Colors.red;
      default:         return AppTheme.textMuted;
    }
  }

  String _fmt(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }

  void _confirmAction(BuildContext context, PayoutRequest p,
      {required bool approve}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.dark2,
        title: Text(
          approve ? 'Approve Payout?' : 'Reject Payout?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${p.driverName} — SAR ${p.amount.toStringAsFixed(2)}',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            style: approve
                ? null
                : ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
            onPressed: () {
              if (approve) {
                fsService.approvePayout(p.id, p.driverId);
              } else {
                fsService.rejectPayout(
                    p.id, p.driverId, p.amount);
              }
              Navigator.pop(context);
            },
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}

// ── Invoices tab ──────────────────────────────────────────────────
class _InvoicesTab extends StatelessWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<Invoice>>(
        stream: fsService.allInvoicesStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final invoices = snap.data ?? [];

          final totalRevenue =
              invoices.fold(0.0, (s, i) => s + i.amount);
          final pendingRev = invoices
              .where((i) => i.status != 'paid')
              .fold(0.0, (s, i) => s + i.amount);

          return Column(children: [
            if (invoices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                      child: _box('Total Invoiced',
                          'SAR ${_fmt(totalRevenue)}',
                          AppTheme.blue)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _box('Platform Revenue (30%)',
                          'SAR ${_fmt(totalRevenue * 0.3)}',
                          AppTheme.green)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _box('Outstanding',
                          'SAR ${_fmt(pendingRev)}',
                          AppTheme.yellow)),
                ]),
              ),
            Expanded(
              child: invoices.isEmpty
                  ? const Center(
                      child: Text('No invoices yet',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: invoices.length,
                      itemBuilder: (_, i) => _InvoiceCard(
                          invoice: invoices[i],
                          key: ValueKey(invoices[i].id)),
                    ),
            ),
          ]);
        },
      );

  Widget _box(String lbl, String val, Color c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(val,
                style: TextStyle(
                    color: c,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis),
            Text(lbl,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 9)),
          ]),
        ),
      );

  static String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceCard({required this.invoice, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = invoice.status == 'paid'
        ? AppTheme.green
        : invoice.isOverdue
            ? Colors.red
            : AppTheme.yellow;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          const Icon(Icons.receipt_long_rounded,
              color: AppTheme.brand, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(invoice.campaignName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
              Text(invoice.advertiserName,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('SAR ${invoice.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(
                invoice.isOverdue
                    ? 'OVERDUE'
                    : invoice.status.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
