import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// PlatformStats
// Firestore: platform_stats/summary
// ─────────────────────────────────────────────────────────────
class PlatformStats {
  final int    totalDrivers;
  final int    activeDrivers;
  final double totalKmToday;
  final double totalKmAllTime;
  final double revenueToday;
  final double revenueThisMonth;
  final double revenueAllTime;
  final int    activeCampaigns;
  final int    totalCampaigns;
  final int    totalImpressionsToday;
  final double avgQualityScore;
  final int    fraudAlertsOpen;
  final int    pendingPayouts;
  final double pendingPayoutsAmount;
  final DateTime? lastUpdated;

  const PlatformStats({
    this.totalDrivers = 0,
    this.activeDrivers = 0,
    this.totalKmToday = 0,
    this.totalKmAllTime = 0,
    this.revenueToday = 0,
    this.revenueThisMonth = 0,
    this.revenueAllTime = 0,
    this.activeCampaigns = 0,
    this.totalCampaigns = 0,
    this.totalImpressionsToday = 0,
    this.avgQualityScore = 0,
    this.fraudAlertsOpen = 0,
    this.pendingPayouts = 0,
    this.pendingPayoutsAmount = 0,
    this.lastUpdated,
  });

  factory PlatformStats.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PlatformStats(
      totalDrivers: (d['totalDrivers'] ?? 0).toInt(),
      activeDrivers: (d['activeDrivers'] ?? 0).toInt(),
      totalKmToday: (d['totalKmToday'] ?? 0).toDouble(),
      totalKmAllTime: (d['totalKmAllTime'] ?? 0).toDouble(),
      revenueToday: (d['revenueToday'] ?? 0).toDouble(),
      revenueThisMonth: (d['revenueThisMonth'] ?? 0).toDouble(),
      revenueAllTime: (d['revenueAllTime'] ?? 0).toDouble(),
      activeCampaigns: (d['activeCampaigns'] ?? 0).toInt(),
      totalCampaigns: (d['totalCampaigns'] ?? 0).toInt(),
      totalImpressionsToday: (d['totalImpressionsToday'] ?? 0).toInt(),
      avgQualityScore: (d['avgQualityScore'] ?? 0).toDouble(),
      fraudAlertsOpen: (d['fraudAlertsOpen'] ?? 0).toInt(),
      pendingPayouts: (d['pendingPayouts'] ?? 0).toInt(),
      pendingPayoutsAmount: (d['pendingPayoutsAmount'] ?? 0).toDouble(),
      lastUpdated: (d['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'totalDrivers': totalDrivers,
        'activeDrivers': activeDrivers,
        'totalKmToday': totalKmToday,
        'totalKmAllTime': totalKmAllTime,
        'revenueToday': revenueToday,
        'revenueThisMonth': revenueThisMonth,
        'revenueAllTime': revenueAllTime,
        'activeCampaigns': activeCampaigns,
        'totalCampaigns': totalCampaigns,
        'totalImpressionsToday': totalImpressionsToday,
        'avgQualityScore': avgQualityScore,
        'fraudAlertsOpen': fraudAlertsOpen,
        'pendingPayouts': pendingPayouts,
        'pendingPayoutsAmount': pendingPayoutsAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
}

// ─────────────────────────────────────────────────────────────
// DriverRecord — admin view of a driver
// Firestore: users/{uid}  (role == 'driver')
// ─────────────────────────────────────────────────────────────
class DriverRecord {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String tier;
  final double totalKm;
  final double totalEarnings;
  final double walletBalance;
  final int    streakDays;
  final double qualityScore;
  final String status;    // active | inactive | suspended
  final bool   isActive;
  final String vehicleId;
  final String? currentCampaignId;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  const DriverRecord({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.tier = 'bronze',
    this.totalKm = 0,
    this.totalEarnings = 0,
    this.walletBalance = 0,
    this.streakDays = 0,
    this.qualityScore = 80,
    this.status = 'inactive',
    this.isActive = false,
    this.vehicleId = '',
    this.currentCampaignId,
    this.createdAt,
    this.lastSeen,
  });

  factory DriverRecord.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return DriverRecord(
      uid: doc.id,
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      tier: d['tier'] ?? 'bronze',
      totalKm: (d['totalKm'] ?? 0).toDouble(),
      totalEarnings: (d['totalEarnings'] ?? 0).toDouble(),
      walletBalance: (d['walletBalance'] ?? 0).toDouble(),
      streakDays: (d['streakDays'] ?? 0).toInt(),
      qualityScore: (d['qualityScore'] ?? 80).toDouble(),
      status: d['status'] ?? 'inactive',
      isActive: d['isActive'] ?? false,
      vehicleId: d['vehicleId'] ?? '',
      currentCampaignId: d['currentCampaignId'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      lastSeen: (d['lastSeen'] as Timestamp?)?.toDate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AdvertiserRecord — admin view of an advertiser
// Firestore: users/{uid}  (role == 'advertiser')
// ─────────────────────────────────────────────────────────────
class AdvertiserRecord {
  final String uid;
  final String name;
  final String companyName;
  final String email;
  final String phone;
  final double totalBudget;
  final double totalSpent;
  final int    activeAds;
  final DateTime? createdAt;

  const AdvertiserRecord({
    required this.uid,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
    this.totalBudget = 0,
    this.totalSpent = 0,
    this.activeAds = 0,
    this.createdAt,
  });

  factory AdvertiserRecord.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return AdvertiserRecord(
      uid: doc.id,
      name: d['name'] ?? '',
      companyName: d['companyName'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      totalBudget: (d['totalBudget'] ?? 0).toDouble(),
      totalSpent: (d['totalSpent'] ?? 0).toDouble(),
      activeAds: (d['activeAds'] ?? 0).toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Campaign — admin view
// Firestore: campaigns/{id}
// ─────────────────────────────────────────────────────────────
class Campaign {
  final String id;
  final String advertiserId;
  final String advertiserName;
  final String name;
  final String status; // draft | pending | active | paused | completed
  final double ratePerKm;
  final double totalBudget;
  final double spentBudget;
  final String city;
  final DateTime? startDate;
  final DateTime? endDate;
  final int targetImpressions;
  final int actualImpressions;
  final int activeCars;
  final DateTime? createdAt;

  const Campaign({
    required this.id,
    required this.advertiserId,
    required this.advertiserName,
    required this.name,
    this.status = 'pending',
    this.ratePerKm = 1.0,
    this.totalBudget = 0,
    this.spentBudget = 0,
    this.city = '',
    this.startDate,
    this.endDate,
    this.targetImpressions = 0,
    this.actualImpressions = 0,
    this.activeCars = 0,
    this.createdAt,
  });

  factory Campaign.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return Campaign(
      id: doc.id,
      advertiserId: d['advertiserId'] ?? '',
      advertiserName: d['advertiserName'] ?? '',
      name: d['name'] ?? '',
      status: d['status'] ?? 'pending',
      ratePerKm: (d['ratePerKm'] ?? 1.0).toDouble(),
      totalBudget: (d['totalBudget'] ?? 0).toDouble(),
      spentBudget: (d['spentBudget'] ?? 0).toDouble(),
      city: d['city'] ?? '',
      startDate: (d['startDate'] as Timestamp?)?.toDate(),
      endDate: (d['endDate'] as Timestamp?)?.toDate(),
      targetImpressions: (d['targetImpressions'] ?? 0).toInt(),
      actualImpressions: (d['actualImpressions'] ?? 0).toInt(),
      activeCars: (d['activeCars'] ?? 0).toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  double get budgetProgress =>
      totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0;

  double get pl => spentBudget - (spentBudget * 0.3); // 30% platform commission
}

// ─────────────────────────────────────────────────────────────
// FraudAlert
// Firestore: fraud_alerts/{id}
// ─────────────────────────────────────────────────────────────
class FraudAlert {
  final String id;
  final String driverId;
  final String driverName;
  final String type;        // gps_spoof | static_driver | unusual_pattern | fake_km
  final String description;
  final String severity;    // low | medium | high
  final String status;      // open | investigating | resolved | dismissed
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final Map<String, dynamic> evidence;

  const FraudAlert({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.type,
    required this.description,
    this.severity = 'medium',
    this.status = 'open',
    this.createdAt,
    this.resolvedAt,
    this.evidence = const {},
  });

  factory FraudAlert.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return FraudAlert(
      id: doc.id,
      driverId: d['driverId'] ?? '',
      driverName: d['driverName'] ?? '',
      type: d['type'] ?? 'unusual_pattern',
      description: d['description'] ?? '',
      severity: d['severity'] ?? 'medium',
      status: d['status'] ?? 'open',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      resolvedAt: (d['resolvedAt'] as Timestamp?)?.toDate(),
      evidence: Map<String, dynamic>.from(d['evidence'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'driverId': driverId,
        'driverName': driverName,
        'type': type,
        'description': description,
        'severity': severity,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'resolvedAt': null,
        'evidence': evidence,
      };

  String get typeLabel {
    switch (type) {
      case 'gps_spoof':         return 'GPS Spoofing';
      case 'static_driver':     return 'Static Vehicle';
      case 'unusual_pattern':   return 'Unusual Pattern';
      case 'fake_km':           return 'Fake Mileage';
      default:                  return type;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// QualityScore
// Firestore: quality_scores/{driverUid}
// ─────────────────────────────────────────────────────────────
class QualityScore {
  final String driverId;
  final String driverName;
  final double score;             // 0-100 composite
  final double gpsConsistency;    // 0-100
  final double activeHoursRatio;  // 0-100
  final double campaignCompliance;// 0-100
  final double customerRating;    // 0-100 (from 5-star → ×20)
  final String computedTier;      // bronze | silver | gold | elite
  final DateTime? lastComputed;

  const QualityScore({
    required this.driverId,
    required this.driverName,
    required this.score,
    this.gpsConsistency = 0,
    this.activeHoursRatio = 0,
    this.campaignCompliance = 0,
    this.customerRating = 0,
    this.computedTier = 'bronze',
    this.lastComputed,
  });

  factory QualityScore.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return QualityScore(
      driverId: doc.id,
      driverName: d['driverName'] ?? '',
      score: (d['score'] ?? 0).toDouble(),
      gpsConsistency: (d['gpsConsistency'] ?? 0).toDouble(),
      activeHoursRatio: (d['activeHoursRatio'] ?? 0).toDouble(),
      campaignCompliance: (d['campaignCompliance'] ?? 0).toDouble(),
      customerRating: (d['customerRating'] ?? 0).toDouble(),
      computedTier: d['computedTier'] ?? 'bronze',
      lastComputed: (d['lastComputed'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'driverName': driverName,
        'score': score,
        'gpsConsistency': gpsConsistency,
        'activeHoursRatio': activeHoursRatio,
        'campaignCompliance': campaignCompliance,
        'customerRating': customerRating,
        'computedTier': computedTier,
        'lastComputed': FieldValue.serverTimestamp(),
      };

  String get scoreLabel {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Average';
    return 'Needs Improvement';
  }
}

// ─────────────────────────────────────────────────────────────
// DynamicPricingRule
// Firestore: pricing_rules/{id}
// ─────────────────────────────────────────────────────────────
class DynamicPricingRule {
  final String id;
  final String name;
  final String zone;
  final String timeSlot;      // morning | afternoon | evening | night | all_day
  final double multiplier;    // e.g. 1.5 = +50%
  final bool   isActive;
  final List<String> daysOfWeek; // mon,tue,...
  final String reason;
  final DateTime? createdAt;

  const DynamicPricingRule({
    required this.id,
    required this.name,
    required this.zone,
    required this.timeSlot,
    required this.multiplier,
    this.isActive = true,
    this.daysOfWeek = const [],
    this.reason = '',
    this.createdAt,
  });

  factory DynamicPricingRule.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return DynamicPricingRule(
      id: doc.id,
      name: d['name'] ?? '',
      zone: d['zone'] ?? '',
      timeSlot: d['timeSlot'] ?? 'all_day',
      multiplier: (d['multiplier'] ?? 1.0).toDouble(),
      isActive: d['isActive'] ?? true,
      daysOfWeek: List<String>.from(d['daysOfWeek'] ?? []),
      reason: d['reason'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'zone': zone,
        'timeSlot': timeSlot,
        'multiplier': multiplier,
        'isActive': isActive,
        'daysOfWeek': daysOfWeek,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// ─────────────────────────────────────────────────────────────
// Invoice — admin view
// Firestore: invoices/{id}
// ─────────────────────────────────────────────────────────────
class Invoice {
  final String id;
  final String advertiserId;
  final String advertiserName;
  final String campaignId;
  final String campaignName;
  final double amount;
  final double platformFee;  // 30% commission
  final String status;       // draft | sent | paid | overdue
  final DateTime? issuedDate;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final int impressionsDelivered;
  final double kmCovered;

  const Invoice({
    required this.id,
    required this.advertiserId,
    required this.advertiserName,
    required this.campaignId,
    required this.campaignName,
    required this.amount,
    this.platformFee = 0,
    this.status = 'draft',
    this.issuedDate,
    this.dueDate,
    this.paidDate,
    this.impressionsDelivered = 0,
    this.kmCovered = 0,
  });

  factory Invoice.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return Invoice(
      id: doc.id,
      advertiserId: d['advertiserId'] ?? '',
      advertiserName: d['advertiserName'] ?? '',
      campaignId: d['campaignId'] ?? '',
      campaignName: d['campaignName'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      platformFee: (d['platformFee'] ?? 0).toDouble(),
      status: d['status'] ?? 'draft',
      issuedDate: (d['issuedDate'] as Timestamp?)?.toDate(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      paidDate: (d['paidDate'] as Timestamp?)?.toDate(),
      impressionsDelivered: (d['impressionsDelivered'] ?? 0).toInt(),
      kmCovered: (d['kmCovered'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'advertiserId': advertiserId,
        'advertiserName': advertiserName,
        'campaignId': campaignId,
        'campaignName': campaignName,
        'amount': amount,
        'platformFee': amount * 0.30,
        'status': 'sent',
        'issuedDate': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'paidDate': null,
        'impressionsDelivered': impressionsDelivered,
        'kmCovered': kmCovered,
      };

  bool get isOverdue =>
      status == 'sent' && dueDate != null && DateTime.now().isAfter(dueDate!);

  double get netRevenue => platformFee > 0 ? platformFee : amount * 0.30;
}

// ─────────────────────────────────────────────────────────────
// PayoutRequest — admin view
// Firestore: payouts/{id}
// ─────────────────────────────────────────────────────────────
class PayoutRequest {
  final String id;
  final String driverId;
  final String driverName;
  final double amount;
  final String status;  // pending | processing | completed | rejected
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String? note;

  const PayoutRequest({
    required this.id,
    required this.driverId,
    this.driverName = '',
    required this.amount,
    this.status = 'pending',
    this.requestedAt,
    this.processedAt,
    this.note,
  });

  factory PayoutRequest.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PayoutRequest(
      id: doc.id,
      driverId: d['driverId'] ?? '',
      driverName: d['driverName'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      status: d['status'] ?? 'pending',
      requestedAt: (d['requestedAt'] as Timestamp?)?.toDate(),
      processedAt: (d['processedAt'] as Timestamp?)?.toDate(),
      note: d['note'],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PlatformEvent — event intelligence
// Firestore: events/{id}
// ─────────────────────────────────────────────────────────────
class PlatformEvent {
  final String id;
  final String name;
  final String location;
  final String dateLabel;   // e.g. "Jun 15–18"
  final String expectedReach; // e.g. "850K"
  final String status;      // upcoming | active | planning | completed
  final DateTime? date;
  final DateTime? createdAt;

  const PlatformEvent({
    required this.id,
    required this.name,
    required this.location,
    required this.dateLabel,
    this.expectedReach = '',
    this.status = 'planning',
    this.date,
    this.createdAt,
  });

  factory PlatformEvent.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PlatformEvent(
      id: doc.id,
      name: d['name'] ?? '',
      location: d['location'] ?? '',
      dateLabel: d['dateLabel'] ?? '',
      expectedReach: d['expectedReach'] ?? '',
      status: d['status'] ?? 'planning',
      date: (d['date'] as Timestamp?)?.toDate(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'location': location,
    'dateLabel': dateLabel,
    'expectedReach': expectedReach,
    'status': status,
    'date': date != null ? Timestamp.fromDate(date!) : null,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
