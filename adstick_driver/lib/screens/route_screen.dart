import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/gps_service.dart';
import '../l10n/app_l10n.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});
  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final _mapCtrl = MapController();
  StreamSubscription<Position>? _posSub;
  LatLng? _currentPos;
  bool _tracking = false;
  bool _permissionDenied = false;
  String _startTime = '--';

  // Riyadh default center
  static const _defaultCenter = LatLng(24.7136, 46.6753);

  @override
  void initState() {
    super.initState();
    _checkExistingTracking();
    _listenPosition();
  }

  void _checkExistingTracking() {
    if (gpsService.isTracking) {
      setState(() {
        _tracking = true;
        if (gpsService.lastPosition != null) {
          _currentPos = LatLng(
              gpsService.lastPosition!.latitude,
              gpsService.lastPosition!.longitude);
        }
      });
    }
  }

  void _listenPosition() {
    _posSub = gpsService.positionStream.listen((pos) {
      if (!mounted) return;
      final p = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentPos = p);
      _mapCtrl.move(p, _mapCtrl.camera.zoom);
    });
  }

  Future<void> _toggleTracking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_tracking) {
      await gpsService.stopTracking(user.uid); // FraudResult ignored here — overview handles commit
      setState(() { _tracking = false; _startTime = '--'; });
    } else {
      // Get driver name + vehicleId from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      final name      = doc.data()?['name']      as String? ?? 'Driver';
      final vehicleId = doc.data()?['vehicleId'] as String? ?? '';

      final ok = await gpsService.startTracking(user.uid, name,
          vehicleId: vehicleId);
      if (!mounted) return;
      if (!ok) {
        setState(() => _permissionDenied = true);
        return;
      }
      setState(() {
        _tracking = true;
        _permissionDenied = false;
        _startTime = TimeOfDay.now().format(context);
      });
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final center = _currentPos ?? _defaultCenter;
    final speedKmh = gpsService.lastPosition?.speed ?? 0;
    final speedDisplay = speedKmh < 0 ? 0.0 : speedKmh * 3.6;

    return Scaffold(
      body: Column(children: [
        // ── Live Map ────────────────────────────────────────
        Expanded(
          flex: 5,
          child: Stack(children: [
            FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'sa.adstick.driver',
                ),
                // Route trail (polyline)
                if (gpsService.routePoints.length > 1)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: List.from(gpsService.routePoints),
                      strokeWidth: 4,
                      color: AppTheme.driverGreen.withValues(alpha: 0.85),
                    ),
                  ]),
                // Current position marker
                if (_currentPos != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _currentPos!,
                      width: 60, height: 60,
                      child: Column(mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.driverGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [BoxShadow(
                                  color: AppTheme.driverGreen
                                      .withValues(alpha: 0.5),
                                  blurRadius: 12,
                                )],
                              ),
                              child: const Icon(
                                  Icons.directions_car_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ]),
                    ),
                  ]),
              ],
            ),

            // Speed overlay
            Positioned(top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.dark.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.speed_rounded,
                      color: AppTheme.driverGreen, size: 16),
                  const SizedBox(width: 6),
                  Text('${speedDisplay.toStringAsFixed(0)} km/h',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ),

            // GPS status pill
            Positioned(top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (_tracking ? AppTheme.driverGreen : Colors.grey)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _tracking ? AppTheme.driverGreen : Colors.grey,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: _tracking
                          ? AppTheme.driverGreen : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tracking
                        ? (l.isAr ? 'تتبع نشط' : 'Live Tracking')
                        : (l.isAr ? 'متوقف' : 'Stopped'),
                    style: TextStyle(
                        color: _tracking
                            ? AppTheme.driverGreen : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
            ),

            // Center-on-me button
            if (_currentPos != null)
              Positioned(bottom: 12, right: 12,
                child: FloatingActionButton.small(
                  heroTag: 'center',
                  backgroundColor: AppTheme.card,
                  child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.driverGreen),
                  onPressed: () => _mapCtrl.move(
                      _currentPos!, _mapCtrl.camera.zoom),
                ),
              ),
          ]),
        ),

        // ── Stats + Controls ─────────────────────────────────
        Container(
          color: AppTheme.dark2,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Permission denied warning
            if (_permissionDenied)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.location_off_rounded,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    l.isAr
                        ? 'يرجى السماح بالوصول إلى الموقع في المتصفح'
                        : 'Allow location access in your browser to start tracking.',
                    style: const TextStyle(
                        color: Colors.orange, fontSize: 12),
                  )),
                ]),
              ),

            // Stats row
            Row(children: [
              _stat(
                label: l.isAr ? 'المسافة' : 'Distance',
                value: '${gpsService.distanceKm.toStringAsFixed(1)} km',
                icon: Icons.route_rounded,
                color: AppTheme.driverGreen,
              ),
              const SizedBox(width: 10),
              _stat(
                label: l.isAr ? 'المدة' : 'Duration',
                value: _formatDuration(gpsService.durationMinutes),
                icon: Icons.timer_rounded,
                color: const Color(0xFF60A5FA),
              ),
              const SizedBox(width: 10),
              _stat(
                label: l.isAr ? 'متوسط السرعة' : 'Avg Speed',
                value: '${gpsService.avgSpeedKmh.toStringAsFixed(0)} km/h',
                icon: Icons.speed_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ]),
            const SizedBox(height: 14),

            // Start/Stop button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleTracking,
                icon: Icon(_tracking
                    ? Icons.stop_rounded : Icons.play_arrow_rounded),
                label: Text(_tracking
                    ? (l.isAr ? 'إيقاف التتبع' : 'Stop Tracking')
                    : (l.isAr ? 'بدء التتبع' : 'Start Tracking'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tracking
                      ? Colors.red.shade700 : AppTheme.driverGreen,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _stat({required String label, required String value,
      required IconData icon, required Color color}) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 10)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
            color: Colors.white, fontSize: 13,
            fontWeight: FontWeight.w800)),
      ]),
    ));
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }
}
