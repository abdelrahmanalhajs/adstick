import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💲 Dynamic Pricing')),
      body: StreamBuilder<List<DynamicPricingRule>>(
        stream: fsService.pricingRulesStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final rules = snap.data ?? [];

          return Column(children: [
            // ── Header stats ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                    child: _statCard(
                  '${rules.length}',
                  'Total Rules',
                  AppTheme.brand,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                  '${rules.where((r) => r.isActive).length}',
                  'Active',
                  AppTheme.green,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard(
                  rules.isNotEmpty
                      ? 'SAR ${rules.map((r) => r.multiplier).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}'
                      : '—',
                  'Max Mult.',
                  AppTheme.yellow,
                )),
              ]),
            ),

            // ── Rules list ──────────────────────────────────────
            Expanded(
              child: rules.isEmpty
                  ? const Center(
                      child: Text('No pricing rules configured',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: rules.length,
                      itemBuilder: (_, i) => _RuleCard(
                          rule: rules[i],
                          key: ValueKey(rules[i].id)),
                    ),
            ),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRuleSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Rule'),
        backgroundColor: AppTheme.brand,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _statCard(String val, String lbl, Color c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(val,
                style: TextStyle(
                    color: c, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(lbl,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ),
      );

  void _showAddRuleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.dark2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddRuleSheet(),
    );
  }
}

// ── Pricing rule card ─────────────────────────────────────────────
class _RuleCard extends StatelessWidget {
  final DynamicPricingRule rule;
  const _RuleCard({required this.rule, super.key});

  @override
  Widget build(BuildContext context) {
    final isActive = rule.isActive;
    final multColor = rule.multiplier >= 1.5
        ? AppTheme.green
        : rule.multiplier >= 1.2
            ? AppTheme.yellow
            : AppTheme.textMuted;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            Expanded(
              child: Text(rule.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            Switch(
              value: isActive,
              activeColor: AppTheme.green,
              onChanged: (val) =>
                  fsService.togglePricingRule(rule.id, val),
            ),
          ]),
          const SizedBox(height: 4),
          Text(rule.reason.isNotEmpty ? rule.reason : rule.zone,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          Row(children: [
            _chip('${rule.multiplier.toStringAsFixed(2)}×',
                multColor, Icons.flash_on_rounded),
            const SizedBox(width: 8),
            _chip(_timeSlotLabel(rule.timeSlot),
                AppTheme.blue, Icons.schedule_rounded),
            if (rule.zone.isNotEmpty) ...[
              const SizedBox(width: 8),
              _chip(rule.zone,
                  AppTheme.brand, Icons.location_city_rounded),
            ],
          ]),
          const SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: AppTheme.brand, size: 18),
              onPressed: () =>
                  _showEditSheet(context, rule),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 18),
              onPressed: () =>
                  _confirmDelete(context, rule),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(String label, Color color, IconData icon) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  String _timeSlotLabel(String ts) {
    switch (ts) {
      case 'morning':   return 'Morning';
      case 'afternoon': return 'Afternoon';
      case 'evening':   return 'Evening';
      case 'night':     return 'Night';
      default:          return 'All Day';
    }
  }

  void _showEditSheet(BuildContext context, DynamicPricingRule rule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.dark2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddRuleSheet(existing: rule),
    );
  }

  void _confirmDelete(BuildContext context, DynamicPricingRule rule) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.dark2,
        title: const Text('Delete Rule?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${rule.name}"?',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              fsService.deletePricingRule(rule.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Add/Edit rule sheet ───────────────────────────────────────────
class _AddRuleSheet extends StatefulWidget {
  final DynamicPricingRule? existing;
  const _AddRuleSheet({this.existing});

  @override
  State<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<_AddRuleSheet> {
  late final TextEditingController _name;
  late final TextEditingController _zone;
  late final TextEditingController _reason;
  late final TextEditingController _mult;
  String _timeSlot = 'all_day';
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name   = TextEditingController(text: e?.name ?? '');
    _zone   = TextEditingController(text: e?.zone ?? '');
    _reason = TextEditingController(text: e?.reason ?? '');
    _mult   = TextEditingController(
        text: e?.multiplier.toStringAsFixed(2) ?? '1.5');
    if (e != null) {
      _timeSlot = e.timeSlot;
      _active = e.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(isEdit ? 'Edit Pricing Rule' : 'Add Pricing Rule',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _field(_name, 'Rule Name', Icons.label_rounded),
          const SizedBox(height: 12),
          _field(_zone, 'Zone / Area', Icons.location_city_rounded),
          const SizedBox(height: 12),
          _field(_reason, 'Reason / Notes', Icons.description_rounded),
          const SizedBox(height: 12),
          _field(_mult, 'Multiplier (e.g. 1.5)',
              Icons.flash_on_rounded,
              type: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _timeSlot,
            dropdownColor: AppTheme.dark2,
            decoration: InputDecoration(
              hintText: 'Time Slot',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(
                  value: 'all_day', child: Text('All Day')),
              DropdownMenuItem(
                  value: 'morning', child: Text('Morning')),
              DropdownMenuItem(
                  value: 'afternoon', child: Text('Afternoon')),
              DropdownMenuItem(
                  value: 'evening', child: Text('Evening')),
              DropdownMenuItem(
                  value: 'night', child: Text('Night')),
            ],
            onChanged: (v) => setState(() => _timeSlot = v!),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Active',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            Switch(
              value: _active,
              activeColor: AppTheme.green,
              onChanged: (v) => setState(() => _active = v),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? 'Save Changes' : 'Add Rule'),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? type}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(icon, color: AppTheme.brand, size: 18),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      );

  void _save() {
    final mult = double.tryParse(_mult.text.trim()) ?? 1.0;
    final e = widget.existing;
    final rule = DynamicPricingRule(
      id: e?.id ?? '',
      name: _name.text.trim(),
      zone: _zone.text.trim(),
      timeSlot: _timeSlot,
      multiplier: mult,
      isActive: _active,
      reason: _reason.text.trim(),
      daysOfWeek: e?.daysOfWeek ?? [],
    );
    fsService.savePricingRule(rule);
    Navigator.pop(context);
  }
}
