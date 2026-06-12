import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Platform Settings')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: fsService.platformSettingsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final cfg = snap.data ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Earnings ────────────────────────────────────────
              _sectionHeader('Earnings & Rates'),
              _PercentField(
                  label: 'Platform Commission Rate',
                  description: 'Percentage taken from each campaign spend',
                  icon: Icons.percent_rounded,
                  value: ((cfg['commissionRate'] ?? 0.30) * 100)
                      .toDouble(),
                  onSave: (v) => fsService.updatePlatformSetting(
                      'commissionRate', v / 100)),
              _CurrencyField(
                  label: 'Base Rate per KM',
                  description: 'SAR earned by driver per kilometre driven',
                  icon: Icons.route_rounded,
                  value: (cfg['baseRatePerKm'] ?? 1.0).toDouble(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('baseRatePerKm', v)),
              _MultiplierField(
                  label: 'Peak Hour Multiplier',
                  description: 'Rate multiplier during peak traffic hours',
                  icon: Icons.bolt_rounded,
                  value: (cfg['peakMultiplier'] ?? 1.5).toDouble(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('peakMultiplier', v)),

              const SizedBox(height: 8),

              // ── Payouts ─────────────────────────────────────────
              _sectionHeader('Payout Settings'),
              _CurrencyField(
                  label: 'Minimum Payout Amount',
                  description: 'Minimum wallet balance required to withdraw',
                  icon: Icons.payments_rounded,
                  value: (cfg['minPayoutAmount'] ?? 50.0).toDouble(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('minPayoutAmount', v)),

              const SizedBox(height: 8),

              // ── Campaigns ───────────────────────────────────────
              _sectionHeader('Campaign Limits'),
              _IntField(
                  label: 'Max Active Campaigns',
                  description: 'Maximum concurrent campaigns per advertiser',
                  icon: Icons.campaign_rounded,
                  value: (cfg['maxActiveCampaigns'] ?? 10).toInt(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('maxActiveCampaigns', v)),
              _IntField(
                  label: 'Impressions per KM',
                  description:
                      'How many ad impressions count per kilometre driven',
                  icon: Icons.visibility_rounded,
                  value: (cfg['impressionsPerKm'] ?? 14).toInt(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('impressionsPerKm', v)),

              const SizedBox(height: 8),

              // ── Bonuses ─────────────────────────────────────────
              _sectionHeader('Bonus Settings'),
              _CurrencyField(
                  label: 'Referral Bonus',
                  description: 'SAR reward for each successful driver referral',
                  icon: Icons.handshake_rounded,
                  value: (cfg['referralBonus'] ?? 50.0).toDouble(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('referralBonus', v)),
              _CurrencyField(
                  label: 'Streak Bonus per Day',
                  description: 'Extra SAR earned per active streak day',
                  icon: Icons.local_fire_department_rounded,
                  value: (cfg['streakBonusPerDay'] ?? 2.0).toDouble(),
                  onSave: (v) =>
                      fsService.updatePlatformSetting('streakBonusPerDay', v)),

              const SizedBox(height: 24),

              // ── Danger zone ─────────────────────────────────────
              _sectionHeader('Platform Info'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    _infoRow(Icons.cloud_rounded, 'Firebase Project',
                        'adstick-90329'),
                    const Divider(color: AppTheme.border, height: 16),
                    _infoRow(Icons.location_on_rounded, 'Region',
                        'europe-west1'),
                    const Divider(color: AppTheme.border, height: 16),
                    _infoRow(Icons.storage_rounded, 'Database',
                        'Firestore + RTDB'),
                    const Divider(color: AppTheme.border, height: 16),
                    _infoRow(Icons.web_rounded, 'Renderer',
                        'Flutter CanvasKit'),
                  ]),
                ),
              ),

              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );

  Widget _infoRow(IconData icon, String label, String val) =>
      Row(children: [
        Icon(icon, color: AppTheme.textMuted, size: 16),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        const Spacer(),
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]);
}

// ── Percent (0–100) ───────────────────────────────────────────

class _PercentField extends StatefulWidget {
  final String label, description;
  final IconData icon;
  final double value;
  final Future<void> Function(double) onSave;

  const _PercentField({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.onSave,
  });

  @override
  State<_PercentField> createState() => _PercentFieldState();
}

class _PercentFieldState extends State<_PercentField> {
  late TextEditingController _ctrl;
  bool _editing = false, _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.value.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(_PercentField old) {
    super.didUpdateWidget(old);
    if (!_editing) {
      _ctrl.text = widget.value.toStringAsFixed(0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _buildCard(
        context,
        value: '${widget.value.toStringAsFixed(0)}%',
        suffix: '%',
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        onSave: () async {
          final v = double.tryParse(_ctrl.text);
          if (v == null) return;
          setState(() => _saving = true);
          await widget.onSave(v.clamp(0, 100));
          if (mounted) setState(() { _saving = false; _editing = false; });
        },
      );

  Widget _buildCard(
    BuildContext context, {
    required String value,
    required String suffix,
    required TextInputType keyboardType,
    required Future<void> Function() onSave,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppTheme.brand.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.icon, color: AppTheme.brand, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    keyboardType: keyboardType,
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: widget.label,
                      hintStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                      suffixText: suffix,
                      suffixStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.dark2,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.brand)),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(widget.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(widget.description,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 10)),
                  ]),
          ),
          const SizedBox(width: 10),
          if (_editing)
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: AppTheme.brand, strokeWidth: 2))
                    : const Icon(Icons.check_rounded,
                        color: AppTheme.brand, size: 20),
                padding: EdgeInsets.zero,
                onPressed: _saving ? null : onSave,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.red, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _ctrl.text = widget.value.toStringAsFixed(0);
                  setState(() => _editing = false);
                },
              ),
            ])
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(value,
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: const Icon(Icons.edit_rounded,
                    color: AppTheme.textMuted, size: 16),
              ),
            ]),
        ]),
      ),
    );
  }
}

// ── Currency field ────────────────────────────────────────────

class _CurrencyField extends StatefulWidget {
  final String label, description;
  final IconData icon;
  final double value;
  final Future<void> Function(double) onSave;

  const _CurrencyField({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.onSave,
  });

  @override
  State<_CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<_CurrencyField> {
  late TextEditingController _ctrl;
  bool _editing = false, _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(_CurrencyField old) {
    super.didUpdateWidget(old);
    if (!_editing) _ctrl.text = widget.value.toStringAsFixed(1);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.icon, color: AppTheme.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      prefixText: 'SAR ',
                      prefixStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.dark2,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.green)),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(widget.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(widget.description,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 10)),
                  ]),
          ),
          const SizedBox(width: 10),
          if (_editing)
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: AppTheme.green, strokeWidth: 2))
                    : const Icon(Icons.check_rounded,
                        color: AppTheme.green, size: 20),
                padding: EdgeInsets.zero,
                onPressed: _saving
                    ? null
                    : () async {
                        final v = double.tryParse(_ctrl.text);
                        if (v == null) return;
                        setState(() => _saving = true);
                        await widget.onSave(v);
                        if (mounted) setState(() { _saving = false; _editing = false; });
                      },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.red, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _ctrl.text = widget.value.toStringAsFixed(1);
                  setState(() => _editing = false);
                },
              ),
            ])
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('SAR ${widget.value.toStringAsFixed(1)}',
                  style: const TextStyle(
                      color: AppTheme.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: const Icon(Icons.edit_rounded,
                    color: AppTheme.textMuted, size: 16),
              ),
            ]),
        ]),
      ),
    );
  }
}

// ── Multiplier field (e.g. 1.5×) ─────────────────────────────

class _MultiplierField extends StatefulWidget {
  final String label, description;
  final IconData icon;
  final double value;
  final Future<void> Function(double) onSave;

  const _MultiplierField({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.onSave,
  });

  @override
  State<_MultiplierField> createState() => _MultiplierFieldState();
}

class _MultiplierFieldState extends State<_MultiplierField> {
  late TextEditingController _ctrl;
  bool _editing = false, _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(_MultiplierField old) {
    super.didUpdateWidget(old);
    if (!_editing) _ctrl.text = widget.value.toStringAsFixed(2);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppTheme.yellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.icon, color: AppTheme.yellow, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      suffixText: '×',
                      suffixStyle: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12),
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.dark2,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.yellow)),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(widget.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(widget.description,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 10)),
                  ]),
          ),
          const SizedBox(width: 10),
          if (_editing)
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: AppTheme.yellow, strokeWidth: 2))
                    : const Icon(Icons.check_rounded,
                        color: AppTheme.yellow, size: 20),
                padding: EdgeInsets.zero,
                onPressed: _saving
                    ? null
                    : () async {
                        final v = double.tryParse(_ctrl.text);
                        if (v == null) return;
                        setState(() => _saving = true);
                        await widget.onSave(v);
                        if (mounted) setState(() { _saving = false; _editing = false; });
                      },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.red, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _ctrl.text = widget.value.toStringAsFixed(2);
                  setState(() => _editing = false);
                },
              ),
            ])
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${widget.value.toStringAsFixed(2)}×',
                  style: const TextStyle(
                      color: AppTheme.yellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: const Icon(Icons.edit_rounded,
                    color: AppTheme.textMuted, size: 16),
              ),
            ]),
        ]),
      ),
    );
  }
}

// ── Integer field ─────────────────────────────────────────────

class _IntField extends StatefulWidget {
  final String label, description;
  final IconData icon;
  final int value;
  final Future<void> Function(int) onSave;

  const _IntField({
    required this.label,
    required this.description,
    required this.icon,
    required this.value,
    required this.onSave,
  });

  @override
  State<_IntField> createState() => _IntFieldState();
}

class _IntFieldState extends State<_IntField> {
  late TextEditingController _ctrl;
  bool _editing = false, _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.value}');
  }

  @override
  void didUpdateWidget(_IntField old) {
    super.didUpdateWidget(old);
    if (!_editing) _ctrl.text = '${widget.value}';
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: AppTheme.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.icon, color: AppTheme.blue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _editing
                ? TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppTheme.dark2,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.blue)),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(widget.label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(widget.description,
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 10)),
                  ]),
          ),
          const SizedBox(width: 10),
          if (_editing)
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: AppTheme.blue, strokeWidth: 2))
                    : const Icon(Icons.check_rounded,
                        color: AppTheme.blue, size: 20),
                padding: EdgeInsets.zero,
                onPressed: _saving
                    ? null
                    : () async {
                        final v = int.tryParse(_ctrl.text);
                        if (v == null) return;
                        setState(() => _saving = true);
                        await widget.onSave(v);
                        if (mounted) setState(() { _saving = false; _editing = false; });
                      },
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppTheme.red, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  _ctrl.text = '${widget.value}';
                  setState(() => _editing = false);
                },
              ),
            ])
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('${widget.value}',
                  style: const TextStyle(
                      color: AppTheme.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: const Icon(Icons.edit_rounded,
                    color: AppTheme.textMuted, size: 16),
              ),
            ]),
        ]),
      ),
    );
  }
}
