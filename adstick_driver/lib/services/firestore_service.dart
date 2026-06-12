import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/models.dart';

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
  Future<void> commitSession({
    required String uid,
    required double kmDriven,
    required double earnings,
  }) async {
    final batch = _db.batch();

    // Update user totals
    batch.update(_db.collection('users').doc(uid), {
      'totalKm': FieldValue.increment(kmDriven),
      'totalEarnings': FieldValue.increment(earnings),
      'walletBalance': FieldValue.increment(earnings),
    });

    // Update leaderboard entry for current month
    final monthKey = _monthKey(DateTime.now());
    final lbRef = _db
        .collection('leaderboard')
        .doc(monthKey)
        .collection('entries')
        .doc(uid);

    batch.set(
      lbRef,
      {
        'kmThisMonth': FieldValue.increment(kmDriven),
        'earningsThisMonth': FieldValue.increment(earnings),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
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
    // Validate wallet balance first
    final profile = await getDriverProfile(uid);
    if (profile == null) throw Exception('Profile not found');
    if (profile.walletBalance < amount) {
      throw Exception('Insufficient wallet balance');
    }
    if (amount < 50) throw Exception('Minimum payout is SAR 50');

    final batch = _db.batch();

    // Create payout document
    final payoutRef = _db.collection('payouts').doc();
    batch.set(payoutRef, {
      'driverId': uid,
      'driverName': driverName,
      'amount': amount,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
      'processedAt': null,
      'note': null,
    });

    // Deduct from wallet
    batch.update(_db.collection('users').doc(uid), {
      'walletBalance': FieldValue.increment(-amount),
      'totalWithdrawn': FieldValue.increment(amount),
    });

    // Update platform stats
    batch.update(_db.collection('platform_stats').doc('summary'), {
      'pendingPayouts': FieldValue.increment(1),
      'pendingPayoutsAmount': FieldValue.increment(amount),
    });

    await batch.commit();
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
