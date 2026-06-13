import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import '../models/models.dart';

// ── Singleton ────────────────────────────────────────────────
final fsService = FirestoreService._();

class FirestoreService {
  FirestoreService._();

  final _db = FirebaseFirestore.instance;

  final _rtdb = rtdb.FirebaseDatabase.instanceFor(
    app: rtdb.FirebaseDatabase.instance.app,
    databaseURL:
        'https://adstick-90329-default-rtdb.europe-west1.firebasedatabase.app',
  );

  // ── RTDB LIVE DRIVERS ────────────────────────────────────────
  /// Streams ALL driver nodes from RTDB — includes isActive, location,
  /// todayStats (distanceKm, durationMinutes, avgSpeedKmh).
  Stream<Map<String, Map<String, dynamic>>> allDriversRtdbStream() =>
      _rtdb.ref('drivers').onValue.map((event) {
        if (event.snapshot.value == null) return {};
        final raw = Map<String, dynamic>.from(
            event.snapshot.value as Map<dynamic, dynamic>);
        return raw.map((k, v) => MapEntry(
            k, Map<String, dynamic>.from(v as Map<dynamic, dynamic>)));
      });

  // ── PLATFORM STATS ───────────────────────────────────────────

  Stream<PlatformStats> platformStatsStream() => _db
      .collection('platform_stats')
      .doc('summary')
      .snapshots()
      .map((snap) => snap.exists
          ? PlatformStats.fromDoc(snap)
          : const PlatformStats());

  Future<void> updatePlatformStats(Map<String, dynamic> data) =>
      _db.collection('platform_stats').doc('summary').set(
            data,
            SetOptions(merge: true),
          );

  // ── DRIVERS ─────────────────────────────────────────────────
  // Note: orderBy on a different field from where() needs a composite index.
  // Sort in Dart instead to avoid index requirements.

  Stream<List<DriverRecord>> allDriversStream() => _db
      .collection('users')
      .where('role', isEqualTo: 'driver')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => DriverRecord.fromDoc(d)).toList();
        list.sort((a, b) => b.totalKm.compareTo(a.totalKm));
        return list;
      });

  Stream<List<DriverRecord>> activeDriversStream() => _db
      .collection('users')
      .where('role', isEqualTo: 'driver')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => DriverRecord.fromDoc(d)).toList();
        return list.where((d) => d.isActive).toList();
      });

  Future<DriverRecord?> getDriver(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return DriverRecord.fromDoc(doc);
  }

  Future<void> suspendDriver(String uid, {String? reason}) => _db
      .collection('users')
      .doc(uid)
      .update({'status': 'suspended', 'suspendReason': reason});

  Future<void> activateDriver(String uid) => _db
      .collection('users')
      .doc(uid)
      .update({'status': 'active'});

  Future<void> updateDriverTier(String uid, String tier) => _db
      .collection('users')
      .doc(uid)
      .update({'tier': tier});

  // ── ADVERTISERS ─────────────────────────────────────────────

  Stream<List<AdvertiserRecord>> allAdvertisersStream() => _db
      .collection('users')
      .where('role', isEqualTo: 'advertiser')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => AdvertiserRecord.fromDoc(d)).toList();
        list.sort((a, b) => b.totalBudget.compareTo(a.totalBudget));
        return list;
      });

  Stream<List<Campaign>> advertiserCampaignsStream(String uid) => _db
      .collection('campaigns')
      .where('advertiserId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => Campaign.fromDoc(d)).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      });

  // ── ACTIVITY FEED ────────────────────────────────────────────

  /// Most recent N campaigns (any status) for the activity feed.
  Stream<List<Campaign>> recentCampaignsStream({int limit = 8}) => _db
      .collection('campaigns')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Campaign.fromDoc(d)).toList());

  /// Most recent N payout requests for the activity feed.
  Stream<List<PayoutRequest>> recentPayoutsStream({int limit = 8}) => _db
      .collection('payouts')
      .orderBy('requestedAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => PayoutRequest.fromDoc(d)).toList());

  // ── CAMPAIGNS ───────────────────────────────────────────────

  Stream<List<Campaign>> allCampaignsStream() => _db
      .collection('campaigns')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Campaign.fromDoc(d)).toList());

  Stream<List<Campaign>> pendingCampaignsStream() => _db
      .collection('campaigns')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => Campaign.fromDoc(d)).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      });

  Stream<List<Campaign>> activeCampaignsStream() => _db
      .collection('campaigns')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Campaign.fromDoc(d)).toList());

  Future<void> approveCampaign(String campaignId) => _db
      .collection('campaigns')
      .doc(campaignId)
      .update({
        'status': 'active',
        'approvedAt': FieldValue.serverTimestamp(),
      });

  Future<void> rejectCampaign(String campaignId, String reason) => _db
      .collection('campaigns')
      .doc(campaignId)
      .update({'status': 'draft', 'rejectReason': reason});

  Future<void> pauseCampaign(String campaignId) => _db
      .collection('campaigns')
      .doc(campaignId)
      .update({'status': 'paused'});

  Future<void> updateCampaignRate(String campaignId, double rate) => _db
      .collection('campaigns')
      .doc(campaignId)
      .update({'ratePerKm': rate});

  // ── FRAUD ALERTS ─────────────────────────────────────────────

  Stream<List<FraudAlert>> fraudAlertsStream({String? status}) {
    Query<Map<String, dynamic>> q = _db.collection('fraud_alerts');
    if (status != null) q = q.where('status', isEqualTo: status);
    return q
        .limit(100)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => FraudAlert.fromDoc(d)).toList();
          list.sort((a, b) => (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0)));
          return list;
        });
  }

  Stream<List<FraudAlert>> openFraudAlertsStream() => _db
      .collection('fraud_alerts')
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => FraudAlert.fromDoc(d)).toList();
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        return list;
      });

  Future<void> createFraudAlert(FraudAlert alert) =>
      _db.collection('fraud_alerts').add(alert.toMap());

  Future<void> updateFraudAlertStatus(String alertId, String status) =>
      _db.collection('fraud_alerts').doc(alertId).update({
        'status': status,
        'resolvedAt': status == 'resolved'
            ? FieldValue.serverTimestamp()
            : null,
      });

  // ── QUALITY SCORES ───────────────────────────────────────────

  Stream<List<QualityScore>> qualityScoresStream() => _db
      .collection('quality_scores')
      .orderBy('score', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => QualityScore.fromDoc(d)).toList());

  Future<QualityScore?> getQualityScore(String driverId) async {
    final doc =
        await _db.collection('quality_scores').doc(driverId).get();
    if (!doc.exists) return null;
    return QualityScore.fromDoc(doc);
  }

  /// Compute and save quality score for a driver.
  Future<void> computeQualityScore(String driverId) async {
    final driver = await getDriver(driverId);
    if (driver == null) return;

    // Fetch last 30 days of earnings to compute active days ratio
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final cutoffStr = _dateKey(cutoff);
    final earningsSnap = await _db
        .collection('earnings')
        .doc(driverId)
        .collection('daily')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoffStr)
        .get();

    final activeDays = earningsSnap.docs.length;
    final activeHoursRatio = (activeDays / 30 * 100).clamp(0, 100).toDouble();

    // GPS consistency — based on whether fraud alerts exist
    final fraudSnap = await _db
        .collection('fraud_alerts')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'open')
        .get();
    final gpsConsistency =
        (100 - (fraudSnap.docs.length * 20)).clamp(0, 100).toDouble();

    // Campaign compliance
    final campaignCompliance = driver.currentCampaignId != null ? 90.0 : 70.0;

    // Customer rating (default 85 if not set)
    final customerRating = 85.0;

    final score = (gpsConsistency * 0.3 +
            activeHoursRatio * 0.3 +
            campaignCompliance * 0.25 +
            customerRating * 0.15)
        .clamp(0, 100)
        .toDouble();

    String tier;
    if (score >= 90) tier = 'elite';
    else if (score >= 75) tier = 'gold';
    else if (score >= 60) tier = 'silver';
    else tier = 'bronze';

    final qs = QualityScore(
      driverId: driverId,
      driverName: driver.name,
      score: score,
      gpsConsistency: gpsConsistency,
      activeHoursRatio: activeHoursRatio,
      campaignCompliance: campaignCompliance,
      customerRating: customerRating,
      computedTier: tier,
    );

    await _db
        .collection('quality_scores')
        .doc(driverId)
        .set(qs.toMap(), SetOptions(merge: true));

    // Also update driver's qualityScore and tier fields
    await _db.collection('users').doc(driverId).update({
      'qualityScore': score,
      'tier': tier,
    });
  }

  // ── PAYOUTS ─────────────────────────────────────────────────

  Stream<List<PayoutRequest>> pendingPayoutsStream() => _db
      .collection('payouts')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => PayoutRequest.fromDoc(d)).toList();
        list.sort((a, b) => (b.requestedAt ?? DateTime(0))
            .compareTo(a.requestedAt ?? DateTime(0)));
        return list;
      });

  Stream<List<PayoutRequest>> allPayoutsStream() => _db
      .collection('payouts')
      .orderBy('requestedAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => PayoutRequest.fromDoc(d)).toList());

  Future<void> approvePayout(String payoutId, String driverId) async {
    final batch = _db.batch();
    batch.update(_db.collection('payouts').doc(payoutId), {
      'status': 'completed',
      'processedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('platform_stats').doc('summary'), {
      'pendingPayouts': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Future<void> rejectPayout(String payoutId, String driverId, double amount) async {
    final batch = _db.batch();
    batch.update(_db.collection('payouts').doc(payoutId), {
      'status': 'rejected',
      'processedAt': FieldValue.serverTimestamp(),
    });
    // Refund wallet
    batch.update(_db.collection('users').doc(driverId), {
      'walletBalance': FieldValue.increment(amount),
      'totalWithdrawn': FieldValue.increment(-amount),
    });
    batch.update(_db.collection('platform_stats').doc('summary'), {
      'pendingPayouts': FieldValue.increment(-1),
      'pendingPayoutsAmount': FieldValue.increment(-amount),
    });
    await batch.commit();
  }

  // ── DYNAMIC PRICING ──────────────────────────────────────────

  Stream<List<DynamicPricingRule>> pricingRulesStream() => _db
      .collection('pricing_rules')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => DynamicPricingRule.fromDoc(d)).toList());

  Future<void> savePricingRule(DynamicPricingRule rule) async {
    if (rule.id.isEmpty) {
      await _db.collection('pricing_rules').add(rule.toMap());
    } else {
      await _db
          .collection('pricing_rules')
          .doc(rule.id)
          .set(rule.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> deletePricingRule(String ruleId) =>
      _db.collection('pricing_rules').doc(ruleId).delete();

  Future<void> togglePricingRule(String ruleId, bool isActive) =>
      _db
          .collection('pricing_rules')
          .doc(ruleId)
          .update({'isActive': isActive});

  // ── INVOICES ────────────────────────────────────────────────

  Stream<List<Invoice>> allInvoicesStream() => _db
      .collection('invoices')
      .orderBy('issuedDate', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Invoice.fromDoc(d)).toList());

  Stream<List<Invoice>> pendingInvoicesStream() => _db
      .collection('invoices')
      .where('status', isEqualTo: 'sent')
      .snapshots()
      .map((snap) {
        final list = snap.docs.map((d) => Invoice.fromDoc(d)).toList();
        list.sort((a, b) => (a.dueDate ?? DateTime(9999))
            .compareTo(b.dueDate ?? DateTime(9999)));
        return list;
      });

  Future<String> generateInvoice(Invoice invoice) async {
    final ref = _db.collection('invoices').doc();
    await ref.set(invoice.toMap());
    return ref.id;
  }

  Future<void> markInvoicePaid(String invoiceId, String advertiserId,
      double amount) async {
    final batch = _db.batch();
    batch.update(_db.collection('invoices').doc(invoiceId), {
      'status': 'paid',
      'paidDate': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('users').doc(advertiserId), {
      'totalSpent': FieldValue.increment(amount),
    });
    batch.update(_db.collection('platform_stats').doc('summary'), {
      'revenueThisMonth': FieldValue.increment(amount * 0.30),
      'revenueAllTime': FieldValue.increment(amount * 0.30),
    });
    await batch.commit();
  }

  // ── EVENTS ──────────────────────────────────────────────────

  Stream<List<PlatformEvent>> eventsStream() => _db
      .collection('events')
      .orderBy('date')
      .snapshots()
      .map((s) => s.docs.map(PlatformEvent.fromDoc).toList());

  Future<void> createEvent(PlatformEvent event) =>
      _db.collection('events').add(event.toMap());

  Future<void> deleteEvent(String id) =>
      _db.collection('events').doc(id).delete();

  Future<void> updateEventStatus(String id, String status) =>
      _db.collection('events').doc(id).update({'status': status});

  // ── PLATFORM SETTINGS ────────────────────────────────────────

  Stream<Map<String, dynamic>> platformSettingsStream() => _db
      .collection('platform_settings')
      .doc('config')
      .snapshots()
      .map((s) => Map<String, dynamic>.from(s.data() ?? _defaultSettings));

  Future<void> updatePlatformSetting(String key, dynamic value) =>
      _db.collection('platform_settings').doc('config').set(
          {key: value}, SetOptions(merge: true));

  static const _defaultSettings = {
    'commissionRate': 0.30,
    'minPayoutAmount': 50.0,
    'baseRatePerKm': 1.0,
    'peakMultiplier': 1.5,
    'maxActiveCampaigns': 10,
    'impressionsPerKm': 14,
    'referralBonus': 50.0,
    'streakBonusPerDay': 2.0,
  };

  // ── HELPERS ─────────────────────────────────────────────────

  String _dateKey(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
}
