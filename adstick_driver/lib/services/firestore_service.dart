import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/models.dart';
import 'fraud_service.dart';

// ── Singleton ────────────────────────────────────────────────
final fsService = FirestoreService._();

class FirestoreService {
  FirestoreService._();

  final _db = FirebaseFirestore.instance;

  final _rtdb = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL:
        'https://adstick-90329-default-rtdb.europe-west1.firebasedatabase.app',
  );

  // ── DRIVER PROFILE ──────────────────────────────────────────

  Stream<DriverProfile> driverProfileStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => DriverProfile.fromDoc(snap));

  Future<DriverProfile?> getDriverProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return DriverProfile.fromDoc(doc);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  // ── EARNINGS ────────────────────────────────────────────────

  /// Stream of last [days] daily earnings entries for a driver.
  Stream<List<EarningsEntry>> earningsStream(String uid,
      {required int days}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr = _dateKey(cutoff);
    return _db
        .collection('earnings')
        .doc(uid)
        .collection('daily')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoffStr)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EarningsEntry.fromDoc(d)).toList());
  }

  /// Single today's entry from Firestore (may not exist yet).
  Future<EarningsEntry?> getTodayEntry(String uid) async {
    final key = _dateKey(DateTime.now());
    final doc =
        await _db.collection('earnings').doc(uid).collection('daily').doc(key).get();
    if (!doc.exists) return null;
    return EarningsEntry.fromDoc(doc);
  }

  /// Write/merge today's earnings entry (call after each GPS update).
  Future<void> saveTodayEarnings(String uid, EarningsEntry entry) => _db
      .collection('earnings')
      .doc(uid)
      .collection('daily')
      .doc(entry.date)
      .set(entry.toMap(), SetOptions(merge: true));

  /// Update platform stats and driver totals after a driving session.
  ///
  /// Pass [fraudResult] from gpsService.stopTracking() so financial controls
  /// and fraud-adjusted earnings are applied before writing to Firestore.
  ///
  /// Returns a [SessionCommitResult] describing what action was taken.
  Future<SessionCommitResult> commitSession({
    required String uid,
    required double kmDriven,
    required double earnings,
    FraudResult? fraudResult,
  }) async {
    // ── F1: Daily earnings cap ────────────────────────────────────
    // Maximum physically possible: ~350 km/day (8 h × ~44 km/h avg).
    const double dailyCapKm = 350.0;
    final todayEntry = await getTodayEntry(uid);
    final kmAlreadyToday = todayEntry?.km ?? 0.0;
    final headroomKm = (dailyCapKm - kmAlreadyToday).clamp(0.0, dailyCapKm);
    if (kmDriven > headroomKm) {
      // Trim to cap — don't reject, just limit
      kmDriven  = headroomKm;
      earnings  = kmDriven * 1.0;
    }

    // ── Apply fraud adjustments ───────────────────────────────────
    if (fraudResult != null) {
      // Use fraud-adjusted km/earnings (off-hours discount, geo-fence)
      kmDriven = fraudResult.adjustedKm.clamp(0.0, kmDriven);
      earnings = fraudResult.adjustedEarnings.clamp(0.0, earnings);
    }

    // Guard: nothing to commit
    if (kmDriven <= 0) {
      return SessionCommitResult(
        action: 'skipped',
        kmCommitted: 0,
        earningsCommitted: 0,
        riskScore: fraudResult?.riskScore ?? 0,
        message: 'No valid km to commit (capped or all fixes rejected).',
      );
    }

    // ── Fraud gate ────────────────────────────────────────────────
    if (fraudResult?.shouldBlock == true) {
      return SessionCommitResult(
        action: 'blocked',
        kmCommitted: 0,
        earningsCommitted: 0,
        riskScore: fraudResult!.riskScore,
        message: 'Session blocked (risk score ${fraudResult.riskScore}/100). '
            'Earnings withheld pending admin review.',
      );
    }

    // ── Payout hold flag ─────────────────────────────────────────
    // If risk score 21–75, credit km/earnings but mark wallet as held
    final onHold = fraudResult?.shouldHold == true;
    final holdNote = onHold
        ? ' (under review — risk score ${fraudResult!.riskScore}/100)'
        : '';

    // ── Fetch campaign for impression tracking ─────────────────────
    final userDoc    = await _db.collection('users').doc(uid).get();
    final campaignId = (userDoc.data() ?? {})['currentCampaignId'] as String?;

    final batch = _db.batch();

    // Update user totals (wallet flagged if on hold)
    batch.update(_db.collection('users').doc(uid), {
      'totalKm':       FieldValue.increment(kmDriven),
      'totalEarnings': FieldValue.increment(earnings),
      'walletBalance': FieldValue.increment(onHold ? 0 : earnings),
      if (onHold) 'heldBalance': FieldValue.increment(earnings),
      if (onHold) 'lastHoldReason': 'fraud_review${holdNote}',
    });

    // Update leaderboard
    final monthKey = _monthKey(DateTime.now());
    batch.set(
      _db.collection('leaderboard').doc(monthKey).collection('entries').doc(uid),
      {
        'kmThisMonth':       FieldValue.increment(kmDriven),
        'earningsThisMonth': FieldValue.increment(earnings),
        'lastUpdated':       FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Update platform-wide stats
    final platformRevenue = earnings * (30 / 70);
    batch.set(
      _db.collection('platform_stats').doc('summary'),
      {
        'totalKmAllTime':   FieldValue.increment(kmDriven),
        'revenueThisMonth': FieldValue.increment(platformRevenue),
        'revenueAllTime':   FieldValue.increment(platformRevenue),
        'revenueToday':     FieldValue.increment(platformRevenue),
        'lastUpdated':      FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Credit campaign impressions (Impressions = 14 per km)
    if (campaignId != null && campaignId.isNotEmpty) {
      final impressions = (kmDriven * 14).round();
      batch.update(_db.collection('campaigns').doc(campaignId), {
        'spentBudget':       FieldValue.increment(earnings),
        'actualImpressions': FieldValue.increment(impressions),
        'lastActivityAt':    FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    return SessionCommitResult(
      action: onHold ? 'held' : 'paid',
      kmCommitted: kmDriven,
      earningsCommitted: earnings,
      riskScore: fraudResult?.riskScore ?? 0,
      message: onHold
          ? 'SAR ${earnings.toStringAsFixed(2)} held for review$holdNote'
          : 'SAR ${earnings.toStringAsFixed(2)} added to wallet',
    );
  }

  // ── RTDB LIVE STREAM ─────────────────────────────────────────

  /// Streams live driver data from RTDB (location, todayStats, isActive).
  Stream<Map<String, dynamic>> rtdbDriverStream(String uid) =>
      _rtdb.ref('drivers/$uid').onValue.map((event) {
        if (event.snapshot.value == null) return <String, dynamic>{};
        final raw = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        return raw;
      });

  // ── CAMPAIGNS ───────────────────────────────────────────────

  Future<Campaign?> getCampaign(String campaignId) async {
    final doc =
        await _db.collection('campaigns').doc(campaignId).get();
    if (!doc.exists) return null;
    return Campaign.fromDoc(doc);
  }

  Stream<List<Campaign>> activeCampaignsStream() => _db
      .collection('campaigns')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Campaign.fromDoc(d)).toList());

  // ── PAYOUTS ─────────────────────────────────────────────────

  Stream<List<PayoutRequest>> payoutHistoryStream(String uid) => _db
      .collection('payouts')
      .where('driverId', isEqualTo: uid)
      .orderBy('requestedAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => PayoutRequest.fromDoc(d)).toList());

  Future<void> requestPayout({
    required String uid,
    required String driverName,
    required double amount,
  }) async {
    // Basic validation
    final profile = await getDriverProfile(uid);
    if (profile == null) throw Exception('Profile not found');
    if (profile.walletBalance < amount) {
      throw Exception('Insufficient wallet balance');
    }
    if (amount < 50) throw Exception('Minimum payout is SAR 50');

    // ── F4: Payout velocity limit — max 1 per 7 days ─────────────
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentPayouts = await _db
        .collection('payouts')
        .where('driverId', isEqualTo: uid)
        .where('status', whereIn: ['pending', 'completed'])
        .get();
    final hasRecentPayout = recentPayouts.docs.any((doc) {
      final ts = doc.data()['requestedAt'] as Timestamp?;
      if (ts == null) return false;
      return ts.toDate().isAfter(sevenDaysAgo);
    });
    if (hasRecentPayout) {
      throw Exception(
          'You can only request one payout per 7 days. '
          'Please wait before requesting again.');
    }

    // ── F2: New account hold ──────────────────────────────────────
    // Accounts < 30 days old or < 500 km get manual review status
    final accountAgedays = profile.createdAt != null
        ? DateTime.now().difference(profile.createdAt!).inDays
        : 999;
    final isNewAccount = accountAgedays < 30 || profile.totalKm < 500;
    final payoutStatus = isNewAccount ? 'pending_review' : 'pending';
    final note = isNewAccount
        ? 'New account hold: < 30 days old or < 500 km driven. Manual review required.'
        : null;

    final batch = _db.batch();

    final payoutRef = _db.collection('payouts').doc();
    batch.set(payoutRef, {
      'driverId':    uid,
      'driverName':  driverName,
      'amount':      amount,
      'status':      payoutStatus,
      'requestedAt': FieldValue.serverTimestamp(),
      'processedAt': null,
      'note':        note,
    });

    // Deduct from wallet
    batch.update(_db.collection('users').doc(uid), {
      'walletBalance':  FieldValue.increment(-amount),
      'totalWithdrawn': FieldValue.increment(amount),
    });

    // Update platform stats
    batch.update(_db.collection('platform_stats').doc('summary'), {
      'pendingPayouts':       FieldValue.increment(1),
      'pendingPayoutsAmount': FieldValue.increment(amount),
    });

    await batch.commit();

    // Surface new-account hold to caller
    if (isNewAccount) {
      throw Exception(
          'Payout submitted for manual review. '
          'Accounts under 30 days or with < 500 km are reviewed before payment.');
    }
  }

  // ── LEADERBOARD ─────────────────────────────────────────────

  Stream<List<LeaderboardEntry>> leaderboardStream({String? monthKey}) {
    final key = monthKey ?? _monthKey(DateTime.now());
    return _db
        .collection('leaderboard')
        .doc(key)
        .collection('entries')
        .orderBy('kmThisMonth', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      final entries = <LeaderboardEntry>[];
      for (int i = 0; i < snap.docs.length; i++) {
        entries.add(LeaderboardEntry.fromDoc(snap.docs[i], i + 1));
      }
      return entries;
    });
  }

  // ── NOTIFICATIONS ───────────────────────────────────────────

  Stream<List<AppNotification>> notificationsStream(String uid) => _db
      .collection('notifications')
      .doc(uid)
      .collection('items')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => AppNotification.fromDoc(d)).toList());

  Future<int> unreadCount(String uid) async {
    final snap = await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> markNotificationRead(String uid, String notifId) => _db
      .collection('notifications')
      .doc(uid)
      .collection('items')
      .doc(notifId)
      .update({'isRead': true});

  Future<void> markAllNotificationsRead(String uid) async {
    final snap = await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> addNotification(
      String uid, AppNotification notif) async {
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .add({
      'title': notif.title,
      'body': notif.body,
      'type': notif.type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'meta': notif.meta,
    });
  }

  Future<void> deleteNotification(String uid, String notifId) =>
      _db.collection('notifications').doc(uid).collection('items').doc(notifId).delete();

  // ── STREAK ──────────────────────────────────────────────────

  /// Call at end of each active driving day to update streak.
  Future<void> updateStreak(String uid) async {
    final profile = await getDriverProfile(uid);
    if (profile == null) return;

    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    // Check if drove yesterday
    final yDoc = await _db
        .collection('earnings')
        .doc(uid)
        .collection('daily')
        .doc(yesterday)
        .get();

    final newStreak = yDoc.exists ? profile.streakDays + 1 : 1;

    await _db.collection('users').doc(uid).update({
      'streakDays': newStreak,
      'lastDriveDate': today,
    });

    // Award streak bonus notification
    if (newStreak == 3 || newStreak == 5 || newStreak == 7 || newStreak % 10 == 0) {
      await addNotification(
        uid,
        AppNotification(
          id: '',
          title: '🔥 ${newStreak}-Day Streak!',
          body: newStreak >= 5
              ? 'Amazing! You earned a SAR 10 streak bonus.'
              : 'Keep it up! Drive tomorrow for a streak bonus.',
          type: 'streak',
          meta: {'streakDays': newStreak},
        ),
      );
    }
  }

  // ── HELPERS ─────────────────────────────────────────────────

  /// Format date as yyyyMMdd for document keys.
  String _dateKey(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';

  /// Format month as yyyyMM for leaderboard keys.
  String _monthKey(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}';
}

// ── Result of a commitSession call ───────────────────────────────────
class SessionCommitResult {
  /// 'paid' | 'held' | 'blocked' | 'skipped'
  final String action;
  final double kmCommitted;
  final double earningsCommitted;
  final int riskScore;
  final String message;

  const SessionCommitResult({
    required this.action,
    required this.kmCommitted,
    required this.earningsCommitted,
    required this.riskScore,
    required this.message,
  });

  bool get wasBlocked  => action == 'blocked';
  bool get wasHeld     => action == 'held';
  bool get wasPaid     => action == 'paid';
}
