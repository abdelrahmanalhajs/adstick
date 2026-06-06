import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏷️ My Campaign')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Active campaign card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1a0533), Color(0xFF2d1b69)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.driverGreen.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Active Campaign', style: TextStyle(color: Colors.white60, fontSize: 12)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.driverGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                    child: const Text('● Verified', style: TextStyle(color: AppTheme.driverGreen, fontSize: 11, fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 12),
              const Text('🥤 Coca-Cola Ramadan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('Ends: June 20, 2026', style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 16),
              Row(children: [
                _campaignStat('KM Required', '2,000'),
                const SizedBox(width: 24),
                _campaignStat('KM Done', '1,245'),
                const SizedBox(width: 24),
                _campaignStat('Days Left', '14'),
              ]),
              const SizedBox(height: 16),
              const Text('Progress', style: TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                value: 1245 / 2000, backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppTheme.driverGreen), minHeight: 8,
              )),
              const SizedBox(height: 4),
              const Text('62.3% complete', style: TextStyle(color: AppTheme.driverGreen, fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Sticker Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Container(
                width: double.infinity, height: 160,
                decoration: BoxDecoration(color: const Color(0xFF0f2027), borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.camera_alt_rounded, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 8),
                  const Text('Tap to upload sticker photo', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(icon: const Icon(Icons.upload_rounded, size: 16), label: const Text('Upload Photo'), onPressed: () {}),
                ]),
              ),
              const SizedBox(height: 16),
              _checkRow(true, 'Sticker applied correctly'),
              _checkRow(true, 'Position verified by AI'),
              _checkRow(true, 'Dimensions match spec'),
              _checkRow(false, 'Next check-in due in 3 days'),
            ]),
          )),
          const SizedBox(height: 20),
          const Text('Campaign Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ...['Drive in the designated zones', 'Minimum 4 hours per day', 'No sticker damage allowed',
            'Report any issues within 24 hours'].map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.textMuted, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(r, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13))),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _campaignStat(String lbl, String val) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(lbl, style: const TextStyle(color: Colors.white60, fontSize: 10)),
    Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
  ]);

  Widget _checkRow(bool done, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: done ? AppTheme.driverGreen : AppTheme.textMuted, size: 18),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: done ? Colors.white : AppTheme.textMuted, fontSize: 13)),
    ]),
  );
}
