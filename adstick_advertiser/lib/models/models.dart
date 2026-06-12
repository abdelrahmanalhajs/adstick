import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// AdvertiserProfile
// Firestore: users/{uid}
// ─────────────────────────────────────────────────────────────
class AdvertiserProfile {
  final String uid;
  final String name;
  final String companyName;
  final String email;
  final String phone;
  final String city;
  final String plan;
  final double totalBudget;
  final double totalSpent;
  final int totalCampaigns;
  final int totalImpressions;
  final int activeAds;
  final String? logoUrl;
  final String industry;
  final DateTime? createdAt;

  const AdvertiserProfile({
    required this.uid,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
    this.city = '',
    this.plan = 'starter',
    this.totalBudget = 0,
    this.totalSpent = 0,
    this.totalCampaigns = 0,
    this.totalImpressions = 0,
    this.activeAds = 0,
    this.logoUrl,
    this.industry = '',
    this.createdAt,
  });

  factory AdvertiserProfile.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return AdvertiserProfile(
      uid: doc.id,
      name: d['name'] ?? '',
      companyName: d['companyName'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      city: d['city'] ?? '',
      plan: d['plan'] ?? 'starter',
      totalBudget: (d['totalBudget'] ?? 0).toDouble(),
      totalSpent: (d['totalSpent'] ?? 0).toDouble(),
      totalCampaigns: (d['totalCampaigns'] ?? 0).toInt(),
      totalImpressions: (d['totalImpressions'] ?? 0).toInt(),
      activeAds: (d['activeAds'] ?? 0).toInt(),
      logoUrl: d['logoUrl'],
      industry: d['industry'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  double get budgetRemaining => (totalBudget - totalSpent).clamp(0, double.infinity);
  double get spendProgress =>
      totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0;
}

// ─────────────────────────────────────────────────────────────
// Campaign
// Firestore: campaigns/{id}
// ─────────────────────────────────────────────────────────────
class Campaign {
  final String id;
  final String advertiserId;
  final String advertiserName;
  final String name;
  final String? adImageUrl;
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
  final String targetDemographic;
  final String? abVariantA;
  final String? abVariantB;
  final double abVariantACtr;
  final double abVariantBCtr;
  final List<String> targetDays;       // mon,tue,...
  final List<int>    targetHours;      // 0-23
  final String       targetEvent;
  final DateTime? createdAt;

  const Campaign({
    required this.id,
    required this.advertiserId,
    required this.advertiserName,
    required this.name,
    this.adImageUrl,
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
    this.targetDemographic = '',
    this.abVariantA,
    this.abVariantB,
    this.abVariantACtr = 0,
    this.abVariantBCtr = 0,
    this.targetDays = const [],
    this.targetHours = const [],
    this.targetEvent = '',
    this.createdAt,
  });

  factory Campaign.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return Campaign(
      id: doc.id,
      advertiserId: d['advertiserId'] ?? '',
      advertiserName: d['advertiserName'] ?? '',
      name: d['name'] ?? '',
      adImageUrl: d['adImageUrl'],
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
      targetDemographic: d['targetDemographic'] ?? '',
      abVariantA: d['abVariantA'],
      abVariantB: d['abVariantB'],
      abVariantACtr: (d['abVariantACtr'] ?? 0).toDouble(),
      abVariantBCtr: (d['abVariantBCtr'] ?? 0).toDouble(),
      targetDays: List<String>.from(d['targetDays'] ?? []),
      targetHours: List<int>.from(d['targetHours'] ?? []),
      targetEvent: d['targetEvent'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap(String uid, String companyName) => {
        'advertiserId': uid,
        'advertiserName': companyName,
        'name': name,
        'adImageUrl': adImageUrl,
        'status': 'pending',
        'ratePerKm': ratePerKm,
        'totalBudget': totalBudget,
        'spentBudget': 0,
        'city': city,
        'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'targetImpressions': targetImpressions,
        'actualImpressions': 0,
        'activeCars': 0,
        'targetDemographic': targetDemographic,
        'abVariantA': abVariantA,
        'abVariantB': abVariantB,
        'abVariantACtr': 0,
        'abVariantBCtr': 0,
        'targetDays': targetDays,
        'targetHours': targetHours,
        'targetEvent': targetEvent,
        'createdAt': FieldValue.serverTimestamp(),
      };

  double get budgetProgress =>
      totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0;

  double get impressionProgress =>
      targetImpressions > 0
          ? (actualImpressions / targetImpressions).clamp(0.0, 1.0)
          : 0;

  /// Estimated KM covered: impressions ÷ 14 (14 impressions per km driven)
  double get kmCovered => actualImpressions / 14.0;

  /// Target KM: targetImpressions ÷ 14
  double get targetKm => targetImpressions / 14.0;

  bool get isActive => status == 'active';

  double get estimatedRoi {
    if (spentBudget <= 0) return 0;
    // Industry avg: 1 car impression = SAR 0.004 value
    final value = actualImpressions * 0.004;
    return value / spentBudget;
  }
}

// ─────────────────────────────────────────────────────────────
// ImpressionStat — daily stats per campaign
// Firestore: campaigns/{id}/stats/{yyyyMMdd}
// ─────────────────────────────────────────────────────────────
class ImpressionStat {
  final String date;
  final int impressions;
  final double kmCovered;
  final int activeCars;
  final double spend;
  final double estimatedReach; // unique people

  const ImpressionStat({
    required this.date,
    required this.impressions,
    required this.kmCovered,
    required this.activeCars,
    required this.spend,
    required this.estimatedReach,
  });

  factory ImpressionStat.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ImpressionStat(
      date: doc.id,
      impressions: (d['impressions'] ?? 0).toInt(),
      kmCovered: (d['kmCovered'] ?? 0).toDouble(),
      activeCars: (d['activeCars'] ?? 0).toInt(),
      spend: (d['spend'] ?? 0).toDouble(),
      estimatedReach: (d['estimatedReach'] ?? 0).toDouble(),
    );
  }

  String get dayLabel {
    if (date.length < 8) return '';
    final y = int.tryParse(date.substring(0, 4)) ?? 2025;
    final m = int.tryParse(date.substring(4, 6)) ?? 1;
    final day = int.tryParse(date.substring(6, 8)) ?? 1;
    final dt = DateTime(y, m, day);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(dt.weekday - 1) % 7];
  }
}

// ─────────────────────────────────────────────────────────────
// PhotoProof — driver-uploaded campaign photos
// Firestore: photo_proofs/{id}
// ─────────────────────────────────────────────────────────────
class PhotoProof {
  final String id;
  final String campaignId;
  final String campaignName;
  final String driverId;
  final String driverName;
  final String imageUrl;
  final String status; // pending | approved | rejected
  final DateTime? uploadedAt;
  final Map<String, dynamic> location;

  const PhotoProof({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.driverId,
    required this.driverName,
    required this.imageUrl,
    this.status = 'pending',
    this.uploadedAt,
    this.location = const {},
  });

  factory PhotoProof.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PhotoProof(
      id: doc.id,
      campaignId: d['campaignId'] ?? '',
      campaignName: d['campaignName'] ?? '',
      driverId: d['driverId'] ?? '',
      driverName: d['driverName'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      status: d['status'] ?? 'pending',
      uploadedAt: (d['uploadedAt'] as Timestamp?)?.toDate(),
      location: Map<String, dynamic>.from(d['location'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Invoice
// Firestore: invoices/{id}
// ─────────────────────────────────────────────────────────────
class Invoice {
  final String id;
  final String advertiserId;
  final String advertiserName;
  final String campaignId;
  final String campaignName;
  final double amount;
  final String status; // draft | sent | paid | overdue
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
      status: d['status'] ?? 'draft',
      issuedDate: (d['issuedDate'] as Timestamp?)?.toDate(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      paidDate: (d['paidDate'] as Timestamp?)?.toDate(),
      impressionsDelivered: (d['impressionsDelivered'] ?? 0).toInt(),
      kmCovered: (d['kmCovered'] ?? 0).toDouble(),
    );
  }

  bool get isOverdue =>
      status == 'sent' &&
      dueDate != null &&
      DateTime.now().isAfter(dueDate!);
}

// ─────────────────────────────────────────────────────────────
// RoiComparison — static benchmark data
// ─────────────────────────────────────────────────────────────
class RoiComparison {
  final String channel;
  final double cpm;     // cost per 1000 impressions (SAR)
  final double ctr;     // click-through rate %
  final double roi;     // × return
  final String color;   // hex

  const RoiComparison({
    required this.channel,
    required this.cpm,
    required this.ctr,
    required this.roi,
    required this.color,
  });

  static List<RoiComparison> benchmarks() => const [
        RoiComparison(channel: 'AdStick Cars', cpm: 3.2, ctr: 4.1, roi: 4.8, color: '#FF6B2B'),
        RoiComparison(channel: 'Billboard',    cpm: 18.0, ctr: 0.4, roi: 1.2, color: '#8B8BA0'),
        RoiComparison(channel: 'Google Display',cpm: 8.5, ctr: 0.8, roi: 2.1, color: '#4285F4'),
        RoiComparison(channel: 'Social Media', cpm: 6.0, ctr: 1.2, roi: 2.8, color: '#1DA1F2'),
      ];
}
