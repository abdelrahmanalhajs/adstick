import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'fraud_service.dart';

// ── Singleton ────────────────────────────────────────────────
final gpsService = GpsService._();

class GpsService {
  GpsService._();

  final _rtdb = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL:
        'https://adstick-90329-default-rtdb.europe-west1.firebasedatabase.app',
  );

  StreamSubscription<Position>? _sub;
  final _positionController = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _positionController.stream;

  Position? lastPosition;
  double _totalDistanceM = 0;
  DateTime? _trackingStart;
  final List<LatLng> routePoints = [];

  bool get isTracking => _sub != null;

  // ── Permission ───────────────────────────────────────────
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  // ── Start tracking ───────────────────────────────────────
  Future<bool> startTracking(String uid, String name,
      {String vehicleId = ''}) async {
    if (_sub != null) return true; // already tracking

    final ok = await requestPermission();
    if (!ok) return false;

    _trackingStart = DateTime.now();
    _totalDistanceM = 0;
    routePoints.clear();

    // ── Fetch campaign city for geo-fence check ──────────
    String? campaignCity;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final campaignId =
          (userDoc.data() ?? {})['currentCampaignId'] as String?;
      if (campaignId != null && campaignId.isNotEmpty) {
        final campDoc = await FirebaseFirestore.instance
            .collection('campaigns')
            .doc(campaignId)
            .get();
        campaignCity = (campDoc.data() ?? {})['city'] as String?;
      }
    } catch (_) {}

    // ── Initialise fraud session ──────────────────────────
    fraudService.startSession(uid, name, campaignCity: campaignCity);

    // Run device checks in background (non-blocking)
    fraudService.runDeviceChecks(uid);

    // Mark driver as active in RTDB immediately
    await _rtdb.ref('drivers/$uid').update({
      'name':              name,
      'vehicleId':         vehicleId,
      'role':              'driver',
      'isActive':          true,
      'trackingStartedAt': ServerValue.timestamp,
      'lastSeen':          ServerValue.timestamp,
    });

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // minimum 5 m between updates
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position pos) {
      // ── Fraud check — discard if fraudulent ────────────
      final accepted = fraudService.checkFix(pos);
      if (!accepted) return; // Fix rejected — don't accumulate distance

      // Accumulate distance only from accepted fixes
      if (lastPosition != null) {
        _totalDistanceM += Geolocator.distanceBetween(
          lastPosition!.latitude, lastPosition!.longitude,
          pos.latitude, pos.longitude,
        );
      }
      lastPosition = pos;
      routePoints.add(LatLng(pos.latitude, pos.longitude));
      if (routePoints.length > 500) routePoints.removeAt(0);

      _positionController.add(pos);

      // Push accepted fix to RTDB
      final durationMin = _trackingStart != null
          ? DateTime.now().difference(_trackingStart!).inMinutes
          : 0;
      final speedKmh = pos.speed < 0 ? 0.0 : pos.speed * 3.6;

      _rtdb.ref('drivers/$uid').update({
        'name':      name,
        'vehicleId': vehicleId,
        'role':      'driver',
        'isActive':  true,
        'lastSeen':  ServerValue.timestamp,
        'location': {
          'lat':       pos.latitude,
          'lng':       pos.longitude,
          'speed':     speedKmh.toStringAsFixed(1),
          'heading':   pos.heading.toStringAsFixed(0),
          'accuracy':  pos.accuracy.toStringAsFixed(0),
          'timestamp': pos.timestamp.millisecondsSinceEpoch,
        },
        'todayStats': {
          'distanceKm':      (_totalDistanceM / 1000).toStringAsFixed(2),
          'durationMinutes': durationMin,
          'avgSpeedKmh':     durationMin > 0
              ? ((_totalDistanceM / 1000) / (durationMin / 60))
                  .toStringAsFixed(1)
              : '0',
        },
      });
    });

    return true;
  }

  // ── Stop tracking ────────────────────────────────────────
  /// Stops GPS, runs session-end fraud analysis, returns FraudResult.
  Future<FraudResult> stopTracking(String uid) async {
    await _sub?.cancel();
    _sub = null;

    // Run session-end fraud checks before committing anything
    final result = await fraudService.endSession(
      kmDriven:        distanceKm,
      durationMinutes: durationMinutes.toDouble(),
    );

    await _rtdb.ref('drivers/$uid').update({
      'isActive':  false,
      'stoppedAt': ServerValue.timestamp,
    });

    return result;
  }

  // ── Today's stats ────────────────────────────────────────
  double get distanceKm => _totalDistanceM / 1000;

  int get durationMinutes => _trackingStart != null
      ? DateTime.now().difference(_trackingStart!).inMinutes
      : 0;

  double get avgSpeedKmh =>
      durationMinutes > 0 ? distanceKm / (durationMinutes / 60) : 0;

  void dispose() {
    _sub?.cancel();
    _positionController.close();
  }
}
