import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_l10n.dart';

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    // Perks data — label/description bilingual
    final perks = [
      ('⛽', l.isAr ? 'وقود أرامكو'      : 'Aramco Fuel',
             l.isAr ? 'خصم ١٠٪ في جميع محطات أرامكو'    : '10% discount at all Aramco stations',
             l.isAr ? 'ذهبي' : 'Gold'),
      ('🔧', l.isAr ? 'مراكز الخدمة'     : 'Service Centers',
             l.isAr ? 'تغيير زيت مجاني كل ٥٠٠٠ كم'       : 'Free oil change every 5,000 km',
             l.isAr ? 'فضي' : 'Silver'),
      ('🚗', l.isAr ? 'غسيل السيارات'    : 'Car Wash',
             l.isAr ? 'غسيلتان مجانيتان شهرياً'           : '2 free washes per month',
             l.isAr ? 'برونزي' : 'Bronze'),
      ('📱', l.isAr ? 'باقة STC'         : 'STC Data',
             l.isAr ? 'إضافة ١٠ جيجا بايت شهرياً'         : 'Extra 10 GB monthly',
             l.isAr ? 'ذهبي' : 'Gold'),
      ('🏥', l.isAr ? 'رعاية Bupa'       : 'Bupa Healthcare',
             l.isAr ? 'خصم ٢٠٪ على الاستشارات الطبية'     : '20% off medical consultations',
             l.isAr ? 'ذهبي' : 'Gold'),
      ('🍔', l.isAr ? 'رصيد Careem Pay'  : 'Careem Pay',
             l.isAr ? 'رصيد ٥٠ ريال للطعام شهرياً'         : 'SAR 50 food credit monthly',
             l.isAr ? 'فضي' : 'Silver'),
    ];

    final insurance = [
      ('🛡️', l.isAr ? 'تأمين ولاء'       : 'Walaa Insurance',
              l.isAr ? 'تغطية شاملة للسيارة — حصري للذهبيين' : 'Comprehensive car coverage — Gold exclusive',
              l.isAr ? 'ذهبي' : 'Gold'),
      ('🏥', l.isAr ? 'صحة Bupa'         : 'Bupa Health',
              l.isAr ? 'خطة صحية أساسية لك ولعائلتك'         : 'Basic health plan for you and family',
              l.isAr ? 'فضي' : 'Silver'),
      ('🚨', l.isAr ? 'خدمة السحب'       : 'Towing Service',
              l.isAr ? 'مساعدة على الطريق ٢٤/٧'              : '24/7 roadside assistance',
              l.isAr ? 'برونزي' : 'Bronze'),
    ];

    const goldColor   = Color(0xFFF59E0B);
    const goldBg      = Color(0xFF78350F);
    const greenAccent = Color(0xFF86EFAC);
    const greenDark   = Color(0xFF064E3B);

    return Scaffold(
      appBar: AppBar(title: Text(l.t('ben_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Fuel card ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF78350F), Color(0xFF92400E)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.t('fuel_points'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const Text('2,840 pts',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(l.t('cash_eq'),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const Text('SAR 28.40',
                        style: TextStyle(
                            color: greenAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                  ]),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.57,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(greenAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.isAr
                    ? '٢١٦٠ نقطة للمستوى التالي · اكسب نقطة لكل كم'
                    : '2,160 pts to next reward tier · Earn 1 pt per km',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: greenAccent,
                        foregroundColor: greenDark),
                    child: Text(l.t('redeem')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30)),
                    child: Text(l.t('history')),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Partner perks ─────────────────────────────────────
          Row(children: [
            Text(l.t('partner_perks'),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: goldBg,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(
                l.t('gold_driver'),
                style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.6),
            itemCount: perks.length,
            itemBuilder: (_, i) {
              final p = perks[i];
              final isGold = p.$4 == (l.isAr ? 'ذهبي' : 'Gold');
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.$1,
                                  style: const TextStyle(fontSize: 24)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: (isGold
                                            ? goldColor
                                            : const Color(0xFF9CA3AF))
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999)),
                                child: Text(p.$4,
                                    style: TextStyle(
                                        color: isGold
                                            ? goldColor
                                            : const Color(0xFF9CA3AF),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ]),
                        const SizedBox(height: 6),
                        Text(p.$2,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        Text(p.$3,
                            style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10,
                                height: 1.3)),
                      ]),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // ── Insurance ─────────────────────────────────────────
          Text(l.t('insurance'),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 12),
          ...insurance.map((ins) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading:
                      Text(ins.$1, style: const TextStyle(fontSize: 24)),
                  title: Text(ins.$2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  subtitle: Text(ins.$3,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppTheme.driverGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999)),
                    child: Text(ins.$4,
                        style: const TextStyle(
                            color: AppTheme.driverGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              )),
        ]),
      ),
    );
  }
}
