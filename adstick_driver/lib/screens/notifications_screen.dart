import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Notifications'),
        actions: [
          TextButton(
            onPressed: () => fsService.markAllNotificationsRead(uid),
            child: const Text('Mark all read',
                style: TextStyle(color: AppTheme.driverGreen, fontSize: 12)),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: fsService.notificationsStream(uid),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.driverGreen));
          }
          final notifications = snap.data ?? [];
          if (notifications.isEmpty) {
            return const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.notifications_none_rounded,
                    color: AppTheme.textMuted, size: 56),
                SizedBox(height: 16),
                Text('No notifications yet',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text('Earnings updates, campaign news\nand platform alerts will show here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ]),
            );
          }

          final unread = notifications.where((n) => !n.isRead).length;
          return Column(children: [
            if (unread > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: AppTheme.driverGreen.withValues(alpha: 0.1),
                child: Text(
                  '$unread unread notification${unread > 1 ? "s" : ""}',
                  style: const TextStyle(
                      color: AppTheme.driverGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (_, i) => _NotifCard(
                    notification: notifications[i],
                    uid: uid,
                    key: ValueKey(notifications[i].id)),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notification;
  final String uid;
  const _NotifCard({required this.notification, required this.uid, super.key});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final typeColor = _typeColor(notification.type);
    final typeIcon  = _typeIcon(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      onDismissed: (_) =>
          fsService.deleteNotification(uid, notification.id),
      child: GestureDetector(
        onTap: () => fsService.markNotificationRead(uid, notification.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isRead ? AppTheme.card : AppTheme.driverGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? AppTheme.border
                  : AppTheme.driverGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(typeIcon, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                      child: Text(notification.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.w800)),
                    ),
                    if (!isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                            color: AppTheme.driverGreen,
                            shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(notification.body,
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt!),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 10),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'earning':   return AppTheme.driverGreen;
      case 'payout':    return const Color(0xFFFBBF24);
      case 'campaign':  return const Color(0xFFFF6B2B);
      case 'tier':      return const Color(0xFFA78BFA);
      case 'streak':    return const Color(0xFFFB923C);
      case 'warning':   return Colors.red;
      default:          return AppTheme.textMuted;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'earning':   return Icons.account_balance_wallet_rounded;
      case 'payout':    return Icons.payment_rounded;
      case 'campaign':  return Icons.campaign_rounded;
      case 'tier':      return Icons.emoji_events_rounded;
      case 'streak':    return Icons.local_fire_department_rounded;
      case 'warning':   return Icons.warning_amber_rounded;
      default:          return Icons.notifications_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    if (diff.inDays < 7)     return '${diff.inDays}d ago';
    const m = ['', 'Jan','Feb','Mar','Apr','May','Jun',
               'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month]}';
  }
}
