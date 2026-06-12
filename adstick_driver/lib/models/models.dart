import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// DriverProfile
// Firestore: users/{uid}
// ─────────────────────────────────────────────────────────────
class DriverProfile {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String tier; // bronze | silver | gold | elite
  final double totalKm;
  final double totalEarnings;
  final double totalWithdrawn;
  final double walletBalance;
  final int streakDays;
  final double qualityScore;
  final String? currentCampaignId;
  final String referralCode;
  final String status; // active | inactive | suspended
  final bool isActive;
  final String vehicleId;
  final DateTime? createdAt;

  const DriverProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.tier = 'bronze',
    this.totalKm = 0,
    this.totalEarnings = 0,
    this.totalWithdrawn = 0,
    this.walletBalance = 0,
    this.streakDays = 0,
    this.qualityScore = 80,
    this.currentCampaignId,
    this.referralCode = '',
    this.status = 'inactive',
    this.isActive = false,
    this.vehicleId = '',
    this.createdAt,
  });

  factory DriverProfile.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return DriverProfile(
      uid: doc.id,
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      tier: d['tier'] ?? 'bronze',
      totalKm: (d['totalKm'] ?? 0).toDouble(),
      totalEarnings: (d['totalEarnings'] ?? 0).toDouble(),
      totalWithdrawn: (d['totalWithdrawn'] ?? 0).toDouble(),
      walletBalance: (d['walletBalance'] ?? 0).toDouble(),
      streakDays: (d['streakDays'] ?? 0).toInt(),
      qualityScore: (d['qualityScore'] ?? 80).toDouble(),
      currentCampaignId: d['currentCampaignId'],
      referralCode: d['referralCode'] ?? '',
      status: d['status'] ?? 'inactive',
      isActive: d['isActive'] ?? false,
      vehicleId: d['vehicleId'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        'tier': tier,
        'totalKm': totalKm,
        'totalEarnings': totalEarnings,
        'totalWithdrawn': totalWithdrawn,
        'walletBalance': walletBalance,
        'streakDays': streakDays,
        'qualityScore': qualityScore,
        'currentCampaignId': currentCampaignId,
        'referralCode': referralCode,
        'status': status,
        'isActive': isActive,
        'vehicleId': vehicleId,
      };

  // Tier thresholds (km/month)
  static double tierMinKm(String tier) {
    switch (tier) {
      case 'silver': return 500;
      case 'gold':   return 1500;
      case 'elite':  return 3000;
      default:       return 0;
    }
  }

  static String nextTier(String current) {
    switch (current) {
      case 'bronze': return 'silver';
      case 'silver': return 'gold';
      case 'gold':   return 'elite';
      default:       return 'elite';
    }
  }

  double get tierProgressKm => tierMinKm(tier);
  double get nextTierKm     => tierMinKm(nextTier(tier));
  bool   get isElite        => tier == 'elite';
}

// ─────────────────────────────────────────────────────────────
// EarningsEntry
// Firestore: earnings/{uid}/daily/{yyyyMMdd}
// ─────────────────────────────────────────────────────────────
class EarningsEntry {
  final String date; // yyyyMMdd
  final double totalAmount;
  final double km;
  final double baseEarnings;   // km × ratePerKm
  final double peakBonus;      // +20% during peak hours
  final double campaignBonus;  // +10% if active campaign
  final double streakBonus;    // flat bonus if streak >= 5
  final int    impressions;    // km * 14 estimated
  final DateTime? createdAt;

  const EarningsEntry({
    required this.date,
    required this.totalAmount,
    required this.km,
    required this.baseEarnings,
    this.peakBonus = 0,
    this.campaignBonus = 0,
    this.streakBonus = 0,
    this.impressions = 0,
    this.createdAt,
  });

  factory EarningsEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return EarningsEntry(
      date: doc.id,
      totalAmount: (d['totalAmount'] ?? 0).toDouble(),
      km: (d['km'] ?? 0).toDouble(),
      baseEarnings: (d['baseEarnings'] ?? 0).toDouble(),
      peakBonus: (d['peakBonus'] ?? 0).toDouble(),
      campaignBonus: (d['campaignBonus'] ?? 0).toDouble(),
      streakBonus: (d['streakBonus'] ?? 0).toDouble(),
      impressions: (d['impressions'] ?? 0).toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory EarningsEntry.fromMap(String date, Map<String, dynamic> d) {
    return EarningsEntry(
      date: date,
      totalAmount: (d['totalAmount'] ?? 0).toDouble(),
      km: (d['km'] ?? 0).toDouble(),
      baseEarnings: (d['baseEarnings'] ?? 0).toDouble(),
      peakBonus: (d['peakBonus'] ?? 0).toDouble(),
      campaignBonus: (d['campaignBonus'] ?? 0).toDouble(),
      streakBonus: (d['streakBonus'] ?? 0).toDouble(),
      impressions: (d['impressions'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'totalAmount': totalAmount,
        'km': km,
        'baseEarnings': baseEarnings,
        'peakBonus': peakBonus,
        'campaignBonus': campaignBonus,
        'streakBonus': streakBonus,
        'impressions': impressions,
        'createdAt': FieldValue.serverTimestamp(),
      };

  // Day-of-week label from yyyyMMdd
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
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  double get budgetProgress =>
      totalBudget > 0 ? (spentBudget / totalBudget).clamp(0.0, 1.0) : 0;

  bool get isActive => status == 'active';
}

// ─────────────────────────────────────────────────────────────
// PayoutRequest
// Firestore: payouts/{id}
// ─────────────────────────────────────────────────────────────
class PayoutRequest {
  final String id;
  final String driverId;
  final double amount;
  final String status; // pending | processing | completed | rejected
  final DateTime? requestedAt;
  final DateTime? processedAt;
  final String? note;

  const PayoutRequest({
    required this.id,
    required this.driverId,
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
      amount: (d['amount'] ?? 0).toDouble(),
      status: d['status'] ?? 'pending',
      requestedAt: (d['requestedAt'] as Timestamp?)?.toDate(),
      processedAt: (d['processedAt'] as Timestamp?)?.toDate(),
      note: d['note'],
    );
  }

  Map<String, dynamic> toMap(String uid) => {
        'driverId': uid,
        'amount': amount,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'note': note,
      };
}

// ─────────────────────────────────────────────────────────────
// LeaderboardEntry
// Firestore: leaderboard/{period}/entries/{uid}
// ─────────────────────────────────────────────────────────────
class LeaderboardEntry {
  final String uid;
  final String name;
  final String tier;
  final double kmThisMonth;
  final double earningsThisMonth;
  final int rank;
  final double qualityScore;

  const LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.tier,
    required this.kmThisMonth,
    required this.earningsThisMonth,
    required this.rank,
    this.qualityScore = 80,
  });

  factory LeaderboardEntry.fromDoc(DocumentSnapshot doc, int rank) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return LeaderboardEntry(
      uid: doc.id,
      name: d['name'] ?? '',
      tier: d['tier'] ?? 'bronze',
      kmThisMonth: (d['kmThisMonth'] ?? 0).toDouble(),
      earningsThisMonth: (d['earningsThisMonth'] ?? 0).toDouble(),
      rank: rank,
      qualityScore: (d['qualityScore'] ?? 80).toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AppNotification
// Firestore: notifications/{uid}/items/{id}
// ─────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // earning_milestone | payout | campaign | streak | leaderboard | system
  final bool isRead;
  final DateTime? createdAt;
  final Map<String, dynamic> meta;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.createdAt,
    this.meta = const {},
  });

  factory AppNotification.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: d['type'] ?? 'system',
      isRead: d['isRead'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      meta: Map<String, dynamic>.from(d['meta'] ?? {}),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TimeSlot — AI route optimizer helper
// ─────────────────────────────────────────────────────────────
class TimeSlot {
  final String label;   // e.g. "Morning Rush"
  final String hours;   // e.g. "7:00 – 9:00 AM"
  final double multiplier;
  final String zone;
  final String reason;

  const TimeSlot({
    required this.label,
    required this.hours,
    required this.multiplier,
    required this.zone,
    required this.reason,
  });

  static List<TimeSlot> defaultSlots() => const [
        TimeSlot(
          label: 'Morning Rush',
          hours: '7:00 – 9:00 AM',
          multiplier: 1.5,
          zone: 'City Centre',
          reason: 'High office commuter traffic',
        ),
        TimeSlot(
          label: 'Midday',
          hours: '11:00 AM – 1:00 PM',
          multiplier: 1.1,
          zone: 'Commercial District',
          reason: 'Lunch crowd + retail',
        ),
        TimeSlot(
          label: 'Evening Rush',
          hours: '5:00 – 8:00 PM',
          multiplier: 1.6,
          zone: 'Downtown',
          reason: 'Peak impressions — highest ROI',
        ),
        TimeSlot(
          label: 'Night',
          hours: '9:00 PM – 12:00 AM',
          multiplier: 1.2,
          zone: 'Entertainment Zone',
          reason: 'Restaurants & nightlife crowd',
        ),
      ];
}
