import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});
  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final _mapCtrl = MapController();

  // Riyadh default center
  static const _center = LatLng(24.7136, 46.6753);

  // Selected driver for detail panel
  String? _selectedDriverId;
  Map<String, dynamic>? _selectedDriver;

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Live Fleet Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () => _mapCtrl.move(_center, 12),
            tooltip: 'Reset view',
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref('drivers').onValue,
        builder: (context, snapshot) {
          final drivers = <String, Map<String, dynamic>>{};

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final raw = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map);
            raw.forEach((uid, val) {
              if (val is Map) drivers[uid] = Map<String, dynamic>.from(val);
            });
          }

          final activeDrivers = drivers.entries
              .where((e) => e.value['isActive'] == true)
              .toList();
          final idleDrivers = drivers.entries
              .where((e) => e.value['isActive'] != true)
              .toList();

          final markers = <Marker>[];
          for (final entry in drivers.entries) {
            final d = entry.value;
            final loc = d['location'];
            if (loc == null) continue;
            final lat = double.tryParse(loc['lat']?.toString() ?? '');
            final lng = double.tryParse(loc['lng']?.toString() ?? '');
            if (lat == null || lng == null) continue;

            final isActive = d['isActive'] == true;
            final speed = double.tryParse(
                loc['speed']?.toString() ?? '0') ?? 0;
            final isSelected = _selectedDriverId == entry.key;

            markers.add(Marker(
              point: LatLng(lat, lng),
              width: isSelected ? 70 : 52,
              height: isSelected ? 70 : 52,
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedDriverId =
                      isSelected ? null : entry.key;
                  _selectedDriver = isSelected ? null : d;
                  if (!isSelected) _mapCtrl.move(LatLng(lat, lng), 15);
                }),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: isSelected ? 50 : 38,
                    height: isSelected ? 50 : 38,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.yellow : Colors.white,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [BoxShadow(
                        color: (isActive ? AppTheme.green : Colors.grey)
                            .withValues(alpha: 0.5),
                        blurRadius: 10,
                      )],
                    ),
                    child: Icon(
                      speed > 5
                          ? Icons.directions_car_rounded
                          : Icons.local_parking_rounded,
                      color: Colors.white,
                      size: isSelected ? 26 : 20,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        d['name'] ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ]),
              ),
            ));
          }

          return Stack(children: [
            // ── Map ──────────────────────────────────────────
            FlutterMap(
              mapController: _mapCtrl,
              options: const MapOptions(
                initialCenter: _center,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'sa.adstick.admin',
                ),
                MarkerLayer(markers: markers),
              ],
            ),

            // ── Stats bar ────────────────────────────────────
            Positioned(
              top: 12, left: 12, right: 12,
              child: Row(children: [
                _pill('${activeDrivers.length}', 'Active',
                    AppTheme.green),
                const SizedBox(width: 8),
                _pill('${idleDrivers.length}', 'Idle',
                    Colors.orange),
                const SizedBox(width: 8),
                _pill('${drivers.length}', 'Total',
                    AppTheme.brand),
                const Spacer(),
                // Live indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.dark.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: AppTheme.green.withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('Live',
                        style: TextStyle(
                            color: AppTheme.green, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),

            // ── Driver detail panel ──────────────────────────
            if (_selectedDriver != null)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: _DriverPanel(
                  data: _selectedDriver!,
                  onClose: () => setState(() {
                    _selectedDriverId = null;
                    _selectedDriver = null;
                  }),
                ),
              ),

            // ── Empty state ──────────────────────────────────
            if (drivers.isEmpty)
              Center(child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.dark.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(mainAxisSize: MainAxisSize.min,
                    children: [
                  Icon(Icons.location_off_rounded,
                      color: AppTheme.textMuted, size: 40),
                  SizedBox(height: 8),
                  Text('No drivers online yet',
                      style: TextStyle(color: AppTheme.textMuted,
                          fontSize: 14)),
                ]),
              )),
          ]);
        },
      ),
    );
  }

  Widget _pill(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.dark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text('$count $label',
          style: TextStyle(color: color, fontSize: 11,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ── Driver detail bottom panel ─────────────────────────────
class _DriverPanel extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClose;
  const _DriverPanel({required this.data, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final loc   = data['location'] as Map? ?? {};
    final stats = data['todayStats'] as Map? ?? {};
    final speed = double.tryParse(
        loc['speed']?.toString() ?? '0') ?? 0;
    final dist  = double.tryParse(
        stats['distanceKm']?.toString() ?? '0') ?? 0;
    final dur   = int.tryParse(
        stats['durationMinutes']?.toString() ?? '0') ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.dark2,
        border: Border(top: BorderSide(color: AppTheme.border)),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20)
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Drag handle
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: AppTheme.green, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['name'] ?? 'Unknown Driver',
                style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w800)),
            Row(children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                    color: AppTheme.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('Active',
                  style: TextStyle(
                      color: AppTheme.green, fontSize: 12)),
            ]),
          ])),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
            onPressed: onClose,
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _stat('${speed.toStringAsFixed(0)} km/h', 'Speed',
              Icons.speed_rounded, AppTheme.brand),
          const SizedBox(width: 10),
          _stat('${dist.toStringAsFixed(1)} km', 'Distance',
              Icons.route_rounded, AppTheme.green),
          const SizedBox(width: 10),
          _stat(_formatDur(dur), 'Online',
              Icons.timer_rounded, Colors.orange),
        ]),
      ]),
    );
  }

  Widget _stat(String val, String lbl, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(
            color: Colors.white, fontSize: 13,
            fontWeight: FontWeight.w800)),
        Text(lbl, style: const TextStyle(
            color: AppTheme.textMuted, fontSize: 10)),
      ]),
    ));
  }

  String _formatDur(int min) {
    if (min < 60) return '${min}m';
    return '${min ~/ 60}h ${min % 60}m';
  }
}
