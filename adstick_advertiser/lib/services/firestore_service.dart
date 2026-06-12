import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

// ── Singleton ────────────────────────────────────────────────
final fsService = FirestoreService._();

class FirestoreService {
  FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // ── ADVERTISER PROFILE ───────────────────────────────────────

  Stream<AdvertiserProfile> advertiserProfileStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => AdvertiserProfile.fromDoc(snap));

  Future<AdvertiserProfile?> getAdvertiserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AdvertiserProfile.fromDoc(doc);
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  /// Alias used by profile_screen.dart
  Future<void> updateAdvertiserProfile(
          String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  // ── CAMPAIGNS ───────────────────────────────────────────────

  /// Stream all campaigns belonging to this advertiser.
  Stream<List<Campaign>> myCampaignsStream(String uid) => _db
      .collection('campaigns')
      .where('advertiserId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Campaign.fromDoc(d)).toList());

  /// Stream only active campaigns for this advertiser.
  Stream<List<Campaign>> myActiveCampaignsStream(String uid) => _db
      .collection('campaigns')
      .where('advertiserId', isEqualTo: uid)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Campaign.fromDoc(d)).toList());

  Future<Campaign?> getCampaign(String campaignId) async {
    final doc = await _db.collection('campaigns').doc(campaignId).get();
    if (!doc.exists) return null;
    return Campaign.fromDoc(doc);
  }

  /// Create a new campaign — starts as 'pending' (admin must approve).
  Future<String> createCampaign({
    required String uid,
    required String companyName,
    required Campaign campaign,
  }) async {
    final ref = _db.collection('campaigns').doc();
    await ref.set(campaign.toMap(uid, companyName));

    // Update advertiser's totalBudget
    await _db.collection('users').doc(uid).update({
      'totalBudget': FieldValue.increment(campaign.totalBudget),
    });

    return ref.id;
  }

  Future<void> pauseCampaign(String campaignId) =>
      _db.collection('campaigns').doc(campaignId).update({'status': 'paused'});

  Future<void> resumeCampaign(String campaignId) =>
      _db.collection('campaigns').doc(campaignId).update({'status': 'active'});

  // ── IMPRESSION STATS ─────────────────────────────────────────

  /// Stream daily stats for a campaign over the last [days] days.
  Stream<List<ImpressionStat>> campaignStatsStream(
      String campaignId, {required int days}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffStr = _dateKey(cutoff);
    return _db
        .collection('campaigns')
        .doc(campaignId)
        .collection('stats')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoffStr)
        .orderBy(FieldPath.documentId, descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ImpressionStat.fromDoc(d)).toList());
  }

  /// Aggregate total stats across all of an advertiser's campaigns.
  Future<Map<String, dynamic>> aggregateStats(String uid) async {
    final campaigns = await _db
        .collection('campaigns')
        .where('advertiserId', isEqualTo: uid)
        .get();

    int totalImpressions = 0;
    double totalKm = 0;
    int totalCars = 0;
    double totalSpent = 0;

    for (final doc in campaigns.docs) {
      final d = doc.data();
      totalImpressions += (d['actualImpressions'] ?? 0) as int;
      totalKm += ((d['spentBudget'] ?? 0) as num).toDouble();
      totalCars += (d['activeCars'] ?? 0) as int;
      totalSpent += ((d['spentBudget'] ?? 0) as num).toDouble();
    }

    return {
      'totalImpressions': totalImpressions,
      'totalKm': totalKm,
      'activeCars': totalCars,
      'totalSpent': totalSpent,
      'campaigns': campaigns.docs.length,
    };
  }

  // ── PHOTO PROOFS ─────────────────────────────────────────────

  /// Stream photo proofs for a specific campaign.
  Stream<List<PhotoProof>> photoProofsStream(String campaignId) => _db
      .collection('photo_proofs')
      .where('campaignId', isEqualTo: campaignId)
      .orderBy('uploadedAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((d) => PhotoProof.fromDoc(d)).toList());

  /// Stream all photo proofs across all of an advertiser's campaigns.
  Stream<List<PhotoProof>> allPhotoProofsStream(String uid) => _db
      .collection('photo_proofs')
      .where('advertiserId', isEqualTo: uid)
      .orderBy('uploadedAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snap) => snap.docs.map((d) => PhotoProof.fromDoc(d)).toList());

  // ── INVOICES ────────────────────────────────────────────────

  Stream<List<Invoice>> invoicesStream(String uid) => _db
      .collection('invoices')
      .where('advertiserId', isEqualTo: uid)
      .orderBy('issuedDate', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Invoice.fromDoc(d)).toList());

  Future<Invoice?> getInvoice(String invoiceId) async {
    final doc = await _db.collection('invoices').doc(invoiceId).get();
    if (!doc.exists) return null;
    return Invoice.fromDoc(doc);
  }

  // ── SUMMARY STREAM ───────────────────────────────────────────

  /// Aggregated live summary: total impressions, active cars, ROI.
  /// Merges data from all active campaigns in one stream.
  Stream<Map<String, dynamic>> summaryStream(String uid) =>
      _db
          .collection('campaigns')
          .where('advertiserId', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .snapshots()
          .map((snap) {
        int totalImpressions = 0;
        int activeCars = 0;
        double totalSpent = 0;
        double totalBudget = 0;

        for (final doc in snap.docs) {
          final d = doc.data();
          totalImpressions += (d['actualImpressions'] ?? 0) as int;
          activeCars += (d['activeCars'] ?? 0) as int;
          totalSpent += ((d['spentBudget'] ?? 0) as num).toDouble();
          totalBudget += ((d['totalBudget'] ?? 0) as num).toDouble();
        }

        final roiValue = totalImpressions * 0.004; // SAR value
        final roi = totalSpent > 0 ? roiValue / totalSpent : 0.0;

        return {
          'totalImpressions': totalImpressions,
          'activeCars': activeCars,
          'totalSpent': totalSpent,
          'totalBudget': totalBudget,
          'roi': roi,
          'activeCampaigns': snap.docs.length,
        };
      });

  // ── HELPERS ─────────────────────────────────────────────────

  String _dateKey(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
}
