import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎪 Event Intelligence')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppTheme.brand,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Event',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<PlatformEvent>>(
        stream: fsService.eventsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final events = snap.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('🎪', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('No events yet',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Add events to boost driver deployment\nin high-traffic areas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add First Event'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brand),
                ),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: events.length,
            itemBuilder: (_, i) =>
                _EventCard(event: events[i], key: ValueKey(events[i].id)),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.dark2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddEventSheet(),
    );
  }
}

class _EventCard extends StatelessWidget {
  final PlatformEvent event;
  const _EventCard({required this.event, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(event.status);
    final statusLabel = _statusLabel(event.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            const Text('🎪', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(event.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(event.location,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.calendar_month_rounded,
                color: AppTheme.textMuted, size: 13),
            const SizedBox(width: 4),
            Text(event.dateLabel.isNotEmpty ? event.dateLabel : 'TBD',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(width: 14),
            Icon(Icons.people_rounded,
                color: AppTheme.textMuted, size: 13),
            const SizedBox(width: 4),
            Text(
              event.expectedReach.isNotEmpty
                  ? '${event.expectedReach} reach'
                  : 'Reach TBD',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cycleStatus(event),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: BorderSide(
                        color: AppTheme.brand.withValues(alpha: 0.4))),
                child: const Text('Change Status',
                    style: TextStyle(
                        color: AppTheme.brand, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => fsService.deleteEvent(event.id),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  side: BorderSide(
                      color: AppTheme.red.withValues(alpha: 0.4))),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.red, size: 16),
            ),
          ]),
        ]),
      ),
    );
  }

  void _cycleStatus(PlatformEvent event) {
    final next = switch (event.status) {
      'planning'  => 'upcoming',
      'upcoming'  => 'active',
      'active'    => 'completed',
      _           => 'planning',
    };
    fsService.updateEventStatus(event.id, next);
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'active':    return AppTheme.green;
      case 'upcoming':  return AppTheme.blue;
      case 'completed': return AppTheme.textMuted;
      default:          return AppTheme.yellow;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'active':    return 'Active';
      case 'upcoming':  return 'Upcoming';
      case 'completed': return 'Completed';
      default:          return 'Planning';
    }
  }
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet();
  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _name      = TextEditingController();
  final _location  = TextEditingController();
  final _dateLabel = TextEditingController();
  final _reach     = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose(); _location.dispose();
    _dateLabel.dispose(); _reach.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Add Event',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _field(_name, 'Event Name *'),
          const SizedBox(height: 10),
          _field(_location, 'Location (e.g. Riyadh Front)'),
          const SizedBox(height: 10),
          _field(_dateLabel, 'Date Label (e.g. Jun 15–18)'),
          const SizedBox(height: 10),
          _field(_reach, 'Expected Reach (e.g. 850K)'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brand,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create Event',
                      style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) => TextField(
        controller: c,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppTheme.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.border)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
        ),
      );

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final event = PlatformEvent(
        id: '',
        name: _name.text.trim(),
        location: _location.text.trim(),
        dateLabel: _dateLabel.text.trim(),
        expectedReach: _reach.text.trim(),
        status: 'planning',
      );
      await fsService.createEvent(event);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
