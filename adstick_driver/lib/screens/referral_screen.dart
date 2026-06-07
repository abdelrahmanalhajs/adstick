import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../l10n/app_l10n.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    final refs = [
      ('Faisal Al-Ghamdi', l.isAr ? 'انضم مايو 2026'  : 'Joined May 2026',  l.isAr ? 'نشط'          : 'Active',  'SAR 120'),
      ('Omar Nasser',      l.isAr ? 'انضم أبريل 2026' : 'Joined Apr 2026',  l.isAr ? 'نشط'          : 'Active',  'SAR 240'),
      ('Yasser Khalid',    l.isAr ? 'انضم مارس 2026'  : 'Joined Mar 2026',  l.isAr ? 'نشط'          : 'Active',  'SAR 360'),
      ('Ibrahim Saad',     l.isAr ? 'انضم يونيو 2026' : 'Joined Jun 2026',  l.isAr ? 'قيد الانتظار' : 'Pending', 'SAR 0'),
    ];
    final activeLabel  = l.isAr ? 'نشط'          : 'Active';

    return Scaffold(
      appBar: AppBar(title: Text(l.t('ref_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Referral code card ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Text(l.t('your_code'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('AHK-2847',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'AHK-2847'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(l.t('copied')),
                          backgroundColor: AppTheme.driverGreen));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.copy_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _RefStat('4',       l.t('referred')),
                _RefStat('3',       l.isAr ? 'نشط' : 'Active'),
                _RefStat('SAR 720', l.t('earned')),
              ]),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, size: 16),
                label: Text(l.t('share_code')),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.driverGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44)),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── How it works ──────────────────────────────────────
          Text(l.t('how_works'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _howRow(context, '1',
                    l.isAr ? 'شارك كودك'           : 'Share your code',
                    l.isAr ? 'أرسله لصديق يقود سيارة' : 'Send it to a friend who drives'),
                const Divider(color: AppTheme.border, height: 20),
                _howRow(context, '2',
                    l.isAr ? 'يسجّل صديقك'          : 'Friend signs up',
                    l.isAr ? 'يسجّل باستخدام كود الإحالة الخاص بك' : 'They register using your referral code'),
                const Divider(color: AppTheme.border, height: 20),
                _howRow(context, '3',
                    l.isAr ? 'كلاكما يربح ١٢٠ ريال'  : 'Both earn SAR 120',
                    l.isAr ? 'بعد أول ١٠٠ كم يقودها'  : 'After their first 100 km driven'),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ── My referrals list ─────────────────────────────────
          Text(l.t('my_refs'),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ...refs.map((r) {
            final isActive = r.$3 == activeLabel;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: (isActive
                          ? AppTheme.driverGreen
                          : AppTheme.textMuted)
                      .withValues(alpha: 0.15),
                  child: Text(r.$1[0],
                      style: TextStyle(
                          color: isActive
                              ? AppTheme.driverGreen
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w800)),
                ),
                title: Text(r.$1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                subtitle: Text('${r.$2} · ${r.$3}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
                trailing: Text(r.$4,
                    style: TextStyle(
                        color: isActive
                            ? AppTheme.driverGreen
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
            );
          }),
          const SizedBox(height: 20),

          // ── Milestones ────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.t('milestones'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _milestone(l.isAr ? '٥ إحالات'  : '5 referrals',
                    l.isAr ? 'مكافأة ٢٠٠ ريال'                  : 'SAR 200 bonus', false),
                _milestone(l.isAr ? '١٠ إحالات' : '10 referrals',
                    l.isAr ? 'شارة ذهبية + ٥٠٠ ريال'            : 'Gold badge + SAR 500', false),
                _milestone(l.isAr ? '٢٥ إحالة'  : '25 referrals',
                    l.isAr ? '١٥٠٠ ريال + تأمين مجاني'           : 'SAR 1,500 + free insurance', false),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _howRow(BuildContext context, String num, String title, String desc) =>
      Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: AppTheme.driverGreen,
              borderRadius: BorderRadius.circular(8)),
          child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            Text(desc,
                style:
                    const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
      ]);

  Widget _milestone(String label, String reward, bool done) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: done ? AppTheme.driverGreen : AppTheme.textMuted,
              size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: done ? Colors.white : AppTheme.textMuted,
                    fontSize: 13)),
          ),
          Text(reward,
              style: TextStyle(
                  color: done ? AppTheme.driverGreen : AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _RefStat extends StatelessWidget {
  final String val, lbl;
  const _RefStat(this.val, this.lbl);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900)),
        Text(lbl,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]);
}
