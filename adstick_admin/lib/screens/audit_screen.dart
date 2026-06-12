import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🔍 Fraud & Audit'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Open Alerts'),
            Tab(text: 'All Alerts'),
          ]),
        ),
        body: const TabBarView(children: [
          _OpenAlertsTab(),
          _AllAlertsTab(),
        ]),
      ),
    );
  }
}

class _OpenAlertsTab extends StatelessWidget {
  const _OpenAlertsTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<FraudAlert>>(
        stream: fsService.openFraudAlertsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final alerts = snap.data ?? [];
          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Icon(Icons.shield_rounded,
                    color: AppTheme.green, size: 48),
                SizedBox(height: 12),
                Text('No open fraud alerts',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Platform looks clean ✓',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 13)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (_, i) => _AlertCard(
                alert: alerts[i],
                key: ValueKey(alerts[i].id)),
          );
        },
      );
}

class _AllAlertsTab extends StatelessWidget {
  const _AllAlertsTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<FraudAlert>>(
        stream: fsService.fraudAlertsStream(),
        builder: (_, snap) {
          final alerts = snap.data ?? [];
          if (alerts.isEmpty) {
            return const Center(
              child: Text('No fraud alerts recorded',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (_, i) => _AlertCard(
                alert: alerts[i],
                key: ValueKey(alerts[i].id)),
          );
        },
      );
}

// ── Alert card ────────────────────────────────────────────────────
class _AlertCard extends StatelessWidget {
  final FraudAlert alert;
  const _AlertCard({required this.alert, super.key});

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(alert.severity);
    final isOpen = alert.status == 'open';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.warning_amber_rounded,
                  color: severityColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(alert.typeLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text('Driver: ${alert.driverName}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ]),
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(alert.severity.toUpperCase(),
                    style: TextStyle(
                        color: severityColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Text(
                isOpen ? 'OPEN' : alert.status.toUpperCase(),
                style: TextStyle(
                    color: isOpen ? Colors.red : AppTheme.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ]),
          ]),
          if (alert.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(alert.description,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
          ],
          if (alert.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Detected: ${_fmt(alert.createdAt!)}',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
          if (isOpen) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => fsService.updateFraudAlertStatus(
                      alert.id, 'dismissed'),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppTheme.textMuted)),
                  child: const Text('Dismiss',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => fsService.updateFraudAlertStatus(
                      alert.id, 'resolved'),
                  child: const Text('Resolve', style: TextStyle(fontSize: 12)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Color _severityColor(String s) {
    switch (s) {
      case 'high':   return Colors.red;
      case 'medium': return Colors.orange;
      default:       return AppTheme.yellow;
    }
  }

  String _fmt(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${m[dt.month]}  ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';
  }
}
