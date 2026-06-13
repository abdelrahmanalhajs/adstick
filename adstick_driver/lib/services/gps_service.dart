import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

// ── Singleton ────────────────────────────────────────────────
final gpsService = GpsService._();

class GpsService {
  GpsService._();

  final _rtdb = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://adstick-90329-default-rtdb.europe-west1.firebasedatabase.app',
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

    // Mark driver as just-started in RTDB immediately
    await _rtdb.ref('drivers/$uid').update({
      'name':               name,
      'vehicleId':          vehicleId,
      'isActive':           true,
      'trackingStartedAt':  ServerValue.timestamp,
      'lastSeen':           ServerValue.timestamp,
    });

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // minimum 5 m between updates
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position pos) {
      // Accumulate distance
      if (lastPosition != null) {
        _totalDistanceM += Geolocator.distanceBetween(
          lastPosition!.latitude, lastPosition!.longitude,
          pos.latitude, pos.longitude,
        );
      }
      lastPosition = pos;
      routePoints.add(LatLng(pos.latitude, pos.longitude));
      if (routePoints.length > 500) routePoints.removeAt(0); // cap trail length

      _positionController.add(pos);

      // Push to Firebase RTDB
      final durationMin = _trackingStart != null
          ? DateTime.now().difference(_trackingStart!).inMinutes
          : 0;
      final speedKmh = pos.speed < 0 ? 0.0 : pos.speed * 3.6;

      _rtdb.ref('drivers/$uid').update({
        'name':      name,
        'vehicleId': vehicleId,
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
          'distanceKm':       (_totalDistanceM / 1000).toStringAsFixed(2),
          'durationMinutes':  durationMin,
          'avgSpeedKmh':      durationMin > 0
              ? ((_totalDistanceM / 1000) / (durationMin / 60)).toStringAsFixed(1)
              : '0',
        },
      });
    });

    return true;
  }

  // ── Stop tracking ────────────────────────────────────────
  Future<void> stopTracking(String uid) async {
    await _sub?.cancel();
    _sub = null;
    await _rtdb.ref('drivers/$uid').update({
      'isActive':  false,
      'stoppedAt': ServerValue.timestamp,
    });
  }

  // ── Today's stats ────────────────────────────────────────
  double get distanceKm => _totalDistanceM / 1000;
  int get durationMinutes =>
      _trackingStart != null
          ? DateTime.now().difference(_trackingStart!).inMinutes
          : 0;
  double get avgSpeedKmh =>
      durationMinutes > 0 ? distanceKm / (durationMinutes / 60) : 0;

  void dispose() {
    _sub?.cancel();
    _positionController.close();
  }
}
