import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:battery_plus/battery_plus.dart';

// ── Singleton ────────────────────────────────────────────────────────
final fraudService = FraudService._();

// ── Result returned after endSession() ──────────────────────────────
class FraudResult {
  final int riskScore;          // 0–100
  final String riskLevel;       // clean / watch / suspicious / block
  final double adjustedKm;      // after off-hours & geo-fence multipliers
  final double adjustedEarnings;
  final bool shouldBlock;       // score ≥ 76 → don't pay at all
  final bool shouldHold;        // score 21–75 → hold payout for review
  final List<String> signals;   // human-readable list of triggered checks

  const FraudResult({
    required this.riskScore,
    required this.riskLevel,
    required this.adjustedKm,
    required this.adjustedEarnings,
    required this.shouldBlock,
    required this.shouldHold,
    required this.signals,
  });

  // Clean result (no fraud detected, earnings unchanged)
  factory FraudResult.clean(double km) => FraudResult(
        riskScore: 0,
        riskLevel: 'clean',
        adjustedKm: km,
        adjustedEarnings: km * 1.0,
        shouldBlock: false,
        shouldHold: false,
        signals: [],
      );
}

// ── Main service ─────────────────────────────────────────────────────
class FraudService {
  FraudService._();

  final _db = FirebaseFirestore.instance;

  // ── Session identity ──────────────────────────────────────────────
  String _uid = '';
  String _name = '';
  String? _campaignCity;
  DateTime? _sessionStart;

  // ── Per-fix tracking state ────────────────────────────────────────
  Position? _prevPos;
  DateTime? _prevFixTime;
  Position? _firstPos;
  Position? _lastAcceptedPos;

  // Speed history (last 20 samples) for S3: smooth speed detection
  final List<double> _speedHistory = [];

  // Heading history (last 40 samples) for R5: repetitive pattern
  final List<double> _headingHistory = [];

  // Fix count bucketed by hour for T1: off-hours detection
  final Map<int, int> _fixesByHour = {};

  // ── Counters ─────────────────────────────────────────────────────
  int _totalFixes = 0;
  int _acceptedFixes = 0;
  int _lowSpeedStreak = 0;
  int _speedViolations = 0;
  int _teleportCount = 0;
  int _fixesOutsideZone = 0;
  int _mockedFixCount = 0;
  int _perfectAccuracyCount = 0;
  int _zeroAltitudeCount = 0;
  int _staleFixCount = 0;

  // ── Accumulated risk signals ──────────────────────────────────────
  // Each entry is unique per signal type (deduplicated)
  final List<_RiskEntry> _risks = [];

  // ── Accelerometer (C2) ────────────────────────────────────────────
  StreamSubscription? _accelSub;
  double _accelVariance = -1.0; // -1 = no data yet
  final List<double> _accelMagnitudes = [];

  // ── Battery (C3) ─────────────────────────────────────────────────
  Timer? _batteryTimer;
  final List<int> _batteryLevels = [];

  // ── City reference data ───────────────────────────────────────────
  // Minimum expected altitude (m) – zero/sea-level spoofed coordinates fail this
  static const Map<String, double> _cityMinAlt = {
    'Riyadh': 550, 'Medina': 580, 'Taif': 1800, 'Abha': 2200,
    'Jeddah': 0,   'Mecca':  200, 'Dammam': 0,
  };

  // City centre for R3: geo-fence (radius 80 km)
  static const Map<String, ({double lat, double lng})> _cityCentre = {
    'Riyadh': (lat: 24.7136, lng: 46.6753),
    'Jeddah': (lat: 21.4858, lng: 39.1925),
    'Mecca':  (lat: 21.3891, lng: 39.8579),
    'Medina': (lat: 24.5247, lng: 39.5692),
    'Dammam': (lat: 26.4207, lng: 50.0888),
    'Taif':   (lat: 21.2854, lng: 40.4150),
    'Abha':   (lat: 18.2164, lng: 42.5053),
  };

  // ════════════════════════════════════════════════════════════════════
  //  Session lifecycle
  // ════════════════════════════════════════════════════════════════════

  void startSession(String uid, String name, {String? campaignCity}) {
    _uid = uid;
    _name = name;
    _campaignCity = campaignCity;
    _sessionStart = DateTime.now();

    // Reset all state
    _prevPos = _firstPos = _lastAcceptedPos = _prevFixTime = null;
    _speedHistory.clear();
    _headingHistory.clear();
    _fixesByHour.clear();
    _risks.clear();
    _accelMagnitudes.clear();
    _batteryLevels.clear();
    _totalFixes = _acceptedFixes = _lowSpeedStreak = _speedViolations = 0;
    _teleportCount = _fixesOutsideZone = _mockedFixCount = 0;
    _perfectAccuracyCount = _zeroAltitudeCount = _staleFixCount = 0;
    _accelVariance = -1.0;

    _startAccelerometer();  // C2
    _startBatteryMonitor(); // C3
  }

  // ════════════════════════════════════════════════════════════════════
  //  Per-fix check — call on every Position update
  //  Returns true  → accept fix (count towards km)
  //  Returns false → discard fix (fraudulent or inaccurate)
  // ════════════════════════════════════════════════════════════════════

  bool checkFix(Position pos) {
    _totalFixes++;
    final now = DateTime.now();
    _fixesByHour[now.hour] = (_fixesByHour[now.hour] ?? 0) + 1;

    // ── D3: Mock location provider ─────────────────────────────────
    // Android exposes whether the position came from a mock GPS app.
    // On web this is always false, so the check is harmless everywhere.
    if (pos.isMocked) {
      _mockedFixCount++;
      if (_mockedFixCount >= 3) {
        _addRisk('mock_location', 40,
            '$_mockedFixCount fixes from mock location provider — GPS spoofing app detected');
        _writeAlert('mock_location',
            '$_mockedFixCount GPS positions came from a mock location provider. Likely using a GPS spoofing app.');
      }
      return false; // Always discard mocked fixes
    }

    // ── G1: GPS accuracy gate ──────────────────────────────────────
    // Reject fixes worse than 50 m — emulators often report 500+ m.
    if (pos.accuracy > 50) return false;

    // ── G4: Stale fix ──────────────────────────────────────────────
    // A cached browser/OS location can be many minutes old.
    final fixAgeSeconds = now.difference(pos.timestamp).inSeconds;
    if (fixAgeSeconds > 90) {
      _staleFixCount++;
      return false; // Discard stale fix
    }

    final speedKmh = pos.speed < 0 ? 0.0 : pos.speed * 3.6;

    // ── G2: Perfect accuracy at speed ──────────────────────────────
    // Real GPS at speed has accuracy 5–20 m. Sub-1m at speed = spoofed.
    if (pos.accuracy < 1.0 && speedKmh > 10) {
      _perfectAccuracyCount++;
      if (_perfectAccuracyCount >= 5) {
        _addRisk('perfect_gps_accuracy', 15,
            'GPS accuracy <1 m while moving at ${speedKmh.toStringAsFixed(0)} km/h '
            '($_perfectAccuracyCount occurrences) — characteristic of spoofing');
      }
    }

    // ── G3: Zero altitude in highland city ────────────────────────
    // Spoofing apps often generate lat/lng only and leave altitude = 0.
    final minAlt = _campaignCity != null ? (_cityMinAlt[_campaignCity] ?? 0) : 0;
    if (minAlt > 100 && pos.altitude.abs() < 5.0) {
      _zeroAltitudeCount++;
      if (_zeroAltitudeCount >= 3) {
        _addRisk('zero_altitude_highland', 20,
            'Altitude ≈0 m in $_campaignCity (expected >${minAlt.toInt()} m) '
            '— coordinates appear to be spoofed');
      }
    }

    // ── S1: Impossible speed ───────────────────────────────────────
    if (speedKmh > 150) {
      _speedViolations++;
      if (_speedViolations >= 3) {
        _addRisk('impossible_speed', 30,
            'Speed ${speedKmh.toStringAsFixed(0)} km/h on $_speedViolations fixes '
            '— physically impossible in a city');
        _writeAlert('impossible_speed',
            'Speed exceeded 150 km/h on $_speedViolations occasions '
            '(${speedKmh.toStringAsFixed(0)} km/h last recorded). Possible mock GPS.');
      }
      return false; // Discard — don't add to distance
    }

    // ── S2: Teleportation ──────────────────────────────────────────
    if (_prevPos != null && _prevFixTime != null) {
      final elapsedSec = now.difference(_prevFixTime!).inSeconds.clamp(1, 7200);
      final maxPossibleM = (150.0 / 3.6) * elapsedSec * 1.3; // 30% buffer
      final actualM = Geolocator.distanceBetween(
        _prevPos!.latitude, _prevPos!.longitude,
        pos.latitude, pos.longitude,
      );
      if (actualM > maxPossibleM) {
        _teleportCount++;
        if (_teleportCount >= 2) {
          _addRisk('teleportation', 30,
              'GPS jumped ${(actualM / 1000).toStringAsFixed(1)} km in ${elapsedSec}s '
              '(max possible at 150 km/h: ${(maxPossibleM / 1000).toStringAsFixed(1)} km)');
          _writeAlert('teleportation',
              'Position teleported ${(actualM / 1000).toStringAsFixed(1)} km in ${elapsedSec}s. '
              'Maximum physically possible: ${(maxPossibleM / 1000).toStringAsFixed(1)} km.');
        }
        return false; // Discard teleport fix
      }
    }

    // ── S3: Unnaturally smooth speed profile ───────────────────────
    _speedHistory.add(speedKmh);
    if (_speedHistory.length > 20) _speedHistory.removeAt(0);
    if (_speedHistory.length >= 20) {
      final avg = _avg(_speedHistory);
      final sd  = _stdDev(_speedHistory, avg);
      if (sd < 2.0 && avg > 20) {
        _addRisk('smooth_speed_profile', 15,
            'Speed σ=${sd.toStringAsFixed(1)} km/h over 20 fixes (avg ${avg.toStringAsFixed(0)} km/h) '
            '— real city driving has σ >8 km/h; this looks interpolated');
      }
    }

    // ── S4: Prolonged idle while active ────────────────────────────
    if (speedKmh < 2) {
      _lowSpeedStreak++;
      // 18 fixes at 5 m distanceFilter ≈ 30–40 min of zero movement
      if (_lowSpeedStreak >= 18 && _lowSpeedStreak % 18 == 0) {
        _addRisk('prolonged_idle', 10,
            'Speed <2 km/h for ~${(_lowSpeedStreak * 2).toStringAsFixed(0)} min '
            '— idle farming suspected');
        _writeAlert('prolonged_idle',
            'Driver marked active but speed <2 km/h for '
            '≈${(_lowSpeedStreak * 2 / 60).toStringAsFixed(1)}h.');
      }
    } else {
      _lowSpeedStreak = 0;
    }

    // ── R3: Campaign geo-fence ─────────────────────────────────────
    // Don't award km driven outside the campaign city (radius 80 km).
    if (_campaignCity != null && _cityCentre.containsKey(_campaignCity)) {
      final c = _cityCentre[_campaignCity!]!;
      final distKm = Geolocator.distanceBetween(
              pos.latitude, pos.longitude, c.lat, c.lng) / 1000;
      if (distKm > 80) {
        _fixesOutsideZone++;
        if (_fixesOutsideZone == 5) {
          _addRisk('outside_campaign_zone', 25,
              '${distKm.toStringAsFixed(0)} km from $_campaignCity — driver outside campaign zone');
          _writeAlert('outside_campaign_zone',
              'Driver is ${distKm.toStringAsFixed(0)} km from $_campaignCity campaign zone. '
              'Km driven outside zone are not counted.');
        }
        return false; // Don't count this km
      }
    }

    // ── R5: Repetitive heading pattern (loop detection) ────────────
    _headingHistory.add(pos.heading);
    if (_headingHistory.length > 40) _headingHistory.removeAt(0);
    if (_headingHistory.length >= 40) {
      // Bucket headings into 45° sectors and count distinct ones
      final buckets = _headingHistory.map((h) => (h / 45).round() % 8).toSet();
      if (buckets.length <= 3) {
        _addRisk('repetitive_heading', 20,
            'Only ${buckets.length} distinct heading directions in last 40 fixes '
            '— circular looping pattern detected');
      }
    }

    // ── C2: Accelerometer vs GPS speed mismatch ────────────────────
    // If accel data is available and shows near-zero variance while
    // GPS claims significant speed, the phone is likely stationary.
    if (_accelVariance >= 0 && speedKmh > 30 && _accelVariance < 0.3) {
      _addRisk('accel_gps_mismatch', 20,
          'GPS speed ${speedKmh.toStringAsFixed(0)} km/h but accelerometer variance '
          '${_accelVariance.toStringAsFixed(2)} m/s² — phone appears stationary');
    }

    // Fix accepted ✅
    if (_firstPos == null) _firstPos = pos;
    _lastAcceptedPos = pos;
    _prevPos = pos;
    _prevFixTime = now;
    _acceptedFixes++;
    return true;
  }

  // ════════════════════════════════════════════════════════════════════
  //  Session-end analysis
  //  Call after stopTracking() with the final session totals.
  // ════════════════════════════════════════════════════════════════════

  Future<FraudResult> endSession({
    required double kmDriven,
    required double durationMinutes,
  }) async {
    _stopAccelerometer();
    _stopBatteryMonitor();

    // ── R1: Circle farming ──────────────────────────────────────────
    if (kmDriven > 3 && _firstPos != null && _lastAcceptedPos != null) {
      final dispKm = Geolocator.distanceBetween(
            _firstPos!.latitude,  _firstPos!.longitude,
            _lastAcceptedPos!.latitude, _lastAcceptedPos!.longitude,
          ) / 1000;
      final loopRatio = kmDriven / max(dispKm, 0.1);
      if (loopRatio > 8 && kmDriven > 5) {
        _addRisk('circle_farming', 25,
            'Loop ratio ${loopRatio.toStringAsFixed(1)}× '
            '(${kmDriven.toStringAsFixed(1)} km driven, '
            '${dispKm.toStringAsFixed(1)} km net displacement)');
        await _writeAlert('circle_farming',
            'Driver drove ${kmDriven.toStringAsFixed(1)} km but only '
            '${dispKm.toStringAsFixed(1)} km from start point '
            '(loop ratio: ${loopRatio.toStringAsFixed(1)}×). Circular route suspected.');
      }
    }

    // ── R2: Low heading-change rate ─────────────────────────────────
    // City driving: ≥8 heading changes per km. Highways ~2/km.
    // Loop/script/fake: often near 0 distinct changes per km.
    if (_acceptedFixes > 20 && kmDriven > 2) {
      // Count distinct 45° bucket transitions
      int transitions = 0;
      for (int i = 1; i < _headingHistory.length; i++) {
        final prev = (_headingHistory[i - 1] / 45).round() % 8;
        final curr = (_headingHistory[i] / 45).round() % 8;
        if (prev != curr) transitions++;
      }
      final changesPerKm = transitions / max(kmDriven, 0.1);
      if (changesPerKm < 1.5 && kmDriven > 10) {
        _addRisk('low_heading_change_rate', 15,
            '${changesPerKm.toStringAsFixed(1)} heading changes/km '
            '(city driving expects ≥8/km) — possibly on an empty road or scripted GPS');
      }
    }

    // ── S5: Session average speed impossible ────────────────────────
    if (durationMinutes > 0) {
      final derivedAvg = kmDriven / (durationMinutes / 60);
      if (derivedAvg > 130) {
        _addRisk('impossible_session_avg', 30,
            'Session average ${derivedAvg.toStringAsFixed(0)} km/h '
            '(${kmDriven.toStringAsFixed(1)} km / ${durationMinutes.toStringAsFixed(0)} min) '
            '— impossible for city driving');
        await _writeAlert('impossible_session_avg',
            'Average speed ${derivedAvg.toStringAsFixed(0)} km/h over entire session. '
            'Client-reported stats appear manipulated.');
      }
    }

    // ── T1: Off-hours driving ───────────────────────────────────────
    // 00:00–05:00 = zero ad visibility. Don't block but reduce impressions.
    final totalF = _fixesByHour.values.fold(0, (a, b) => a + b);
    final offHoursF = _fixesByHour.entries
        .where((e) => e.key >= 0 && e.key < 5)
        .fold(0, (s, e) => s + e.value);
    final offHoursRatio = totalF > 0 ? offHoursF / totalF : 0.0;
    if (offHoursRatio > 0.8 && kmDriven > 5) {
      _addRisk('off_hours_driving', 10,
          '${(offHoursRatio * 100).toStringAsFixed(0)}% of session was 00:00–05:00 '
          '— no ad visibility during this time');
    }

    // ── T3 + T4: Historical pattern checks ─────────────────────────
    if (_uid.isNotEmpty) {
      try { await _checkHistoricalPatterns(kmDriven); } catch (_) {}
    }

    // ── C3: No battery drain ────────────────────────────────────────
    if (_batteryLevels.length >= 2) {
      final drop        = _batteryLevels.first - _batteryLevels.last;
      final sessionHrs  = durationMinutes / 60;
      final drainPerHr  = sessionHrs > 0 ? drop / sessionHrs : 0;
      // GPS active drains ~5–8%/h; < 0.5%/h suggests phone is charging at home
      if (sessionHrs > 1 && drainPerHr < 0.5) {
        _addRisk('no_battery_drain', 15,
            'Battery dropped only ${drop}% in ${sessionHrs.toStringAsFixed(1)}h with GPS active '
            '— phone likely plugged in/stationary');
      }
    }

    // ── Compute final risk score ────────────────────────────────────
    int score = 0;
    final signals = <String>[];
    for (final r in _risks) {
      score += r.points;
      signals.add('[${r.signal}] ${r.desc}');
    }
    score = score.clamp(0, 100);

    // ── Earnings adjustment multipliers ────────────────────────────
    double mult = 1.0;
    // Off-hours discount
    if (offHoursRatio > 0.8)      mult *= 0.1;
    else if (offHoursRatio > 0.5) mult *= 0.5;
    // Geo-fence: credit only the proportion of fixes inside the zone
    if (_totalFixes > 0 && _fixesOutsideZone > 0) {
      mult *= 1.0 - (_fixesOutsideZone / _totalFixes);
    }
    final adjKm  = (kmDriven * mult).clamp(0.0, kmDriven);
    final adjEar = adjKm * 1.0;

    final level = score >= 76 ? 'block'
        : score >= 51 ? 'suspicious'
        : score >= 21 ? 'watch'
        : 'clean';

    // Persist session risk record for admin review
    if (score > 20 && _uid.isNotEmpty) {
      try { await _writeSessionRisk(score, level, signals); } catch (_) {}
    }

    return FraudResult(
      riskScore:         score,
      riskLevel:         level,
      adjustedKm:        adjKm,
      adjustedEarnings:  adjEar,
      shouldBlock:       score >= 76,
      shouldHold:        score >= 21,
      signals:           signals,
    );
  }

  // ════════════════════════════════════════════════════════════════════
  //  Device checks — call once at session start (or login)
  // ════════════════════════════════════════════════════════════════════

  Future<void> runDeviceChecks(String uid) async {
    try {
      final info = DeviceInfoPlugin();
      String fingerprint;
      bool isEmulator = false;
      String platform;

      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        platform = 'web';
        fingerprint = _hash([
          web.userAgent ?? '',
          web.platform ?? '',
          web.vendor ?? '',
          '${web.hardwareConcurrency ?? 0}',
          '${web.deviceMemory ?? 0}',
          (web.languages ?? []).join(','),
        ].join('|'));
      } else {
        final android = await info.androidInfo;
        isEmulator = !android.isPhysicalDevice;
        platform = 'android';
        fingerprint = _hash([
          android.id,
          android.model,
          android.device,
          android.fingerprint,
        ].join('|'));
      }

      // D5: Emulator detection ────────────────────────────────────
      if (isEmulator) {
        await _writeAlert('emulator_detected',
            'Driver session started on Android emulator — GPS data cannot be trusted.');
      }

      // D6: Device fingerprint cross-account check ─────────────────
      final reg = await _db.collection('device_registry').doc(fingerprint).get();
      if (reg.exists) {
        final existingUid = reg.data()?['uid'] as String?;
        if (existingUid != null && existingUid != uid) {
          await _writeAlert('device_shared',
              'Device fingerprint $fingerprint is already registered to another driver account '
              '($existingUid). Possible account sharing.');
        }
      } else {
        await _db.collection('device_registry').doc(fingerprint).set({
          'uid':          uid,
          'registeredAt': FieldValue.serverTimestamp(),
          'platform':     platform,
        });
      }

      // Persist fingerprint on driver profile for audit trail
      await _db.collection('users').doc(uid).update({
        'lastDeviceId': fingerprint,
        'lastDevicePlatform': platform,
      });
    } catch (_) {
      // Device checks are non-critical — never crash the session
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  Accelerometer monitoring (C2)
  // ════════════════════════════════════════════════════════════════════

  void _startAccelerometer() {
    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 500),
      ).listen((event) {
        final mag = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z);
        _accelMagnitudes.add(mag);
        if (_accelMagnitudes.length > 40) _accelMagnitudes.removeAt(0);
        if (_accelMagnitudes.length >= 20) {
          final a = _avg(_accelMagnitudes);
          _accelVariance = _variance(_accelMagnitudes, a);
        }
      });
    } catch (_) {
      // Sensor not available on this platform — skip silently
    }
  }

  void _stopAccelerometer() {
    _accelSub?.cancel();
    _accelSub = null;
  }

  // ════════════════════════════════════════════════════════════════════
  //  Battery monitoring (C3)
  // ════════════════════════════════════════════════════════════════════

  void _startBatteryMonitor() {
    try {
      final bat = Battery();
      bat.batteryLevel.then((l) => _batteryLevels.add(l)).catchError((_) {});
      _batteryTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
        try {
          _batteryLevels.add(await bat.batteryLevel);
        } catch (_) {}
      });
    } catch (_) {}
  }

  void _stopBatteryMonitor() {
    _batteryTimer?.cancel();
    _batteryTimer = null;
  }

  // ════════════════════════════════════════════════════════════════════
  //  Historical pattern checks (T3 + T4)
  // ════════════════════════════════════════════════════════════════════

  Future<void> _checkHistoricalPatterns(double sessionKm) async {
    final cutoffKey = _dateKey(DateTime.now().subtract(const Duration(days: 15)));
    final snap = await _db
        .collection('earnings')
        .doc(_uid)
        .collection('daily')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoffKey)
        .get();

    final pastKm = snap.docs
        .map((d) => (d.data()['kmDriven'] as num?)?.toDouble() ?? 0.0)
        .toList();

    if (pastKm.isEmpty) return;

    final avg = _avg(pastKm);

    // T4: Earnings spike ─────────────────────────────────────────
    if (sessionKm > avg * 5 && sessionKm > 100 && pastKm.length >= 5) {
      final ratio = sessionKm / max(avg, 0.1);
      _addRisk('earnings_spike', 20,
          'Session ${sessionKm.toStringAsFixed(1)} km = '
          '${ratio.toStringAsFixed(1)}× 14-day average (${avg.toStringAsFixed(0)} km/day)');
      await _writeAlert('earnings_spike',
          'Session km (${sessionKm.toStringAsFixed(1)}) is '
          '${ratio.toStringAsFixed(1)}× their daily average of ${avg.toStringAsFixed(0)} km.');
    }

    // T3: Robotic daily consistency ──────────────────────────────
    if (pastKm.length >= 14) {
      final sd = _stdDev(pastKm, avg);
      if (sd < 0.5 && avg > 10) {
        _addRisk('robotic_consistency', 15,
            'Daily km σ=${sd.toStringAsFixed(2)} over ${pastKm.length} days '
            '(avg ${avg.toStringAsFixed(0)} km) — unnaturally consistent, may be automated');
        await _writeAlert('robotic_consistency',
            'Driver earns ${avg.toStringAsFixed(0)}±${sd.toStringAsFixed(1)} km/day '
            'for ${pastKm.length} consecutive days. Automated pattern suspected.');
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  Helpers
  // ════════════════════════════════════════════════════════════════════

  void _addRisk(String signal, int points, String desc) {
    // Deduplicate — keep first occurrence of each signal type
    if (!_risks.any((r) => r.signal == signal)) {
      _risks.add(_RiskEntry(signal, points, desc));
    }
  }

  Future<void> _writeAlert(String type, String desc) async {
    if (_uid.isEmpty) return;
    try {
      await _db.collection('fraud_alerts').add({
        'driverId':    _uid,
        'driverName':  _name,
        'type':        type,
        'description': desc,
        'status':      'open',
        'createdAt':   FieldValue.serverTimestamp(),
        'resolvedAt':  null,
      });
    } catch (_) {}
  }

  Future<void> _writeSessionRisk(
      int score, String level, List<String> signals) async {
    try {
      await _db.collection('session_risks').add({
        'driverId':    _uid,
        'driverName':  _name,
        'riskScore':   score,
        'riskLevel':   level,
        'signals':     signals,
        'sessionDate': _dateKey(DateTime.now()),
        'createdAt':   FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ── Math helpers ──────────────────────────────────────────────────

  static double _avg(List<double> xs) =>
      xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

  static double _variance(List<double> xs, double avg) => xs.isEmpty
      ? 0
      : xs.map((x) => pow(x - avg, 2).toDouble()).reduce((a, b) => a + b) /
            xs.length;

  static double _stdDev(List<double> xs, double avg) =>
      sqrt(_variance(xs, avg));

  static String _hash(String input) {
    // FNV-1a 32-bit hash — deterministic, no crypto dependency needed
    int hash = 0x811c9dc5;
    for (final byte in input.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static String _dateKey(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}'
      '${dt.day.toString().padLeft(2, '0')}';
}

// ── Internal risk entry ───────────────────────────────────────────────
class _RiskEntry {
  final String signal;
  final int points;
  final String desc;
  const _RiskEntry(this.signal, this.points, this.desc);
}
