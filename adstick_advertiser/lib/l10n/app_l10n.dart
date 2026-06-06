import 'package:flutter/material.dart';

final localeNotifier = ValueNotifier<String>('en');

class AppL10n extends InheritedWidget {
  final String locale;
  const AppL10n({super.key, required this.locale, required super.child});

  static AppL10n of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppL10n>()!;

  String t(String key) => (locale == 'ar' ? _ar : _en)[key] ?? _en[key] ?? key;
  bool get isAr => locale == 'ar';
  TextDirection get dir => isAr ? TextDirection.rtl : TextDirection.ltr;

  @override
  bool updateShouldNotify(AppL10n old) => old.locale != locale;
}

const _en = <String, String>{
  'app_name': 'AdStick Advertiser',
  // Login
  'portal_title': 'Advertiser Portal',
  'welcome_back': 'Welcome back 👋',
  'sign_in_sub': 'Sign in to manage your campaigns',
  'email': 'Email',
  'password': 'Password',
  'sign_in': 'Sign In',
  'new_adv': 'New advertiser? Create account →',
  // Shell / nav
  'overview': 'Overview',
  'campaigns': 'Campaigns',
  'live_map': 'Live Map',
  'reports': 'Reports',
  'km_analytics': 'KM Analytics',
  'profile': 'Profile',
  'sign_out': 'Sign Out',
  'sec_camps': 'CAMPAIGNS & ANALYTICS',
  'sec_account': 'ACCOUNT',
  // Overview
  'ov_title': '📊 Campaign Overview',
  'good_morning': 'Good morning',
  'impressions_today': 'impressions today',
  'active_camps': 'Active Campaigns',
  'weekly_perf': 'Weekly Performance',
  'launch_camp': 'Launch New Campaign',
  'budget_used': 'budget used',
  // Campaigns
  'camps_title': '📢 My Campaigns',
  'launch_new': 'Launch New Campaign',
  'pause': 'Pause',
  'analytics': 'Analytics',
  'budget': 'Budget',
  'spent': 'Spent',
  'approve': 'Approve',
  'reject': 'Reject',
  'active': 'Active',
  'pending': 'Pending',
  'paused': 'Paused',
  // Live Map
  'map_title': '📍 My Cars — Live',
  'live_map_label': 'Live Car Map',
  'live_sub': '120 cars active · Riyadh',
  'real_time': '● Real-time · Updates every 30s',
  // Reports
  'rep_title': '📄 My Reports',
  'perf_summary': 'Performance Summary',
  'downloadable': 'Downloadable Reports',
  'top_zones': 'Top Performing Zones',
  'download': 'Download PDF',
  // KM Analytics
  'km_title': '📍 KM Analytics',
  'total_kms': 'Total KMs',
  'active_drivers': 'Active Drivers',
  'avg_km_day': 'Avg KM/Day',
  'coverage': 'Coverage %',
  'zone_heatmap': 'Zone Coverage Heatmap',
  'weekly_trend': 'Weekly KM Trend',
  'vehicle_breakdown': 'Vehicle KM Breakdown',
  'monthly_target': 'Monthly Target Progress',
  'today_lbl': 'today',
  // Profile
  'prof_title': '👤 Profile',
  'acc_details': 'Account Details',
  'billing': 'Billing & Payment',
  'notifications': 'Notifications',
  'spend_limits': 'Spend Limits',
  'help': 'Help & Support',
  // Chat
  'chat_title': 'AdStick AI',
  'chat_sub': 'Online · Smart assistant',
  'chat_greeting': '👋 Hi! I\'m AdStick AI. Ask me about campaigns, pricing, impressions, GPS zones, ROI, and more!',
  'chat_hello_reply': 'Hello! How can I help you today? Ask me about campaigns, pricing, ROI, impressions, or anything about AdStick.',
  'chat_fallback': 'Great question! Contact us at info@adstick.sa or tap the WhatsApp button. Available 9 AM–9 PM daily.',
  'chat_hint': 'Ask me anything…',
  'qr_price': '💳 Pricing',
  'qr_campaigns': '📢 Campaigns',
  'qr_roi': '📈 ROI',
  'qr_gps': '📍 Zones',
  'qr_contact': '📞 Contact',
};

const _ar = <String, String>{
  'app_name': 'AdStick للمعلنين',
  // Login
  'portal_title': 'بوابة المعلنين',
  'welcome_back': 'مرحباً بعودتك 👋',
  'sign_in_sub': 'سجّل دخولك لإدارة حملاتك',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'sign_in': 'تسجيل الدخول',
  'new_adv': 'معلن جديد؟ إنشاء حساب →',
  // Shell / nav
  'overview': 'نظرة عامة',
  'campaigns': 'الحملات',
  'live_map': 'الخريطة المباشرة',
  'reports': 'التقارير',
  'km_analytics': 'تحليلات الكيلومترات',
  'profile': 'الملف الشخصي',
  'sign_out': 'تسجيل الخروج',
  'sec_camps': 'الحملات والتحليلات',
  'sec_account': 'الحساب',
  // Overview
  'ov_title': '📊 نظرة عامة على الحملات',
  'good_morning': 'صباح الخير',
  'impressions_today': 'انطباع اليوم',
  'active_camps': 'الحملات النشطة',
  'weekly_perf': 'الأداء الأسبوعي',
  'launch_camp': 'إطلاق حملة جديدة',
  'budget_used': 'من الميزانية',
  // Campaigns
  'camps_title': '📢 حملاتي',
  'launch_new': 'إطلاق حملة جديدة',
  'pause': 'إيقاف مؤقت',
  'analytics': 'التحليلات',
  'budget': 'الميزانية',
  'spent': 'المنفق',
  'approve': 'موافقة',
  'reject': 'رفض',
  'active': 'نشطة',
  'pending': 'قيد المراجعة',
  'paused': 'موقوفة',
  // Live Map
  'map_title': '📍 سياراتي — مباشر',
  'live_map_label': 'خريطة السيارات المباشرة',
  'live_sub': '120 سيارة نشطة · الرياض',
  'real_time': '● مباشر · يتحدّث كل 30 ثانية',
  // Reports
  'rep_title': '📄 تقاريري',
  'perf_summary': 'ملخص الأداء',
  'downloadable': 'تقارير قابلة للتنزيل',
  'top_zones': 'أفضل المناطق أداءً',
  'download': 'تنزيل PDF',
  // KM Analytics
  'km_title': '📍 تحليلات الكيلومترات',
  'total_kms': 'إجمالي الكيلومترات',
  'active_drivers': 'السائقون النشطون',
  'avg_km_day': 'متوسط كم/يوم',
  'coverage': 'نسبة التغطية',
  'zone_heatmap': 'خريطة حرارة تغطية المناطق',
  'weekly_trend': 'الاتجاه الأسبوعي للكيلومترات',
  'vehicle_breakdown': 'توزيع كيلومترات المركبات',
  'monthly_target': 'تقدم الهدف الشهري',
  'today_lbl': 'اليوم',
  // Profile
  'prof_title': '👤 الملف الشخصي',
  'acc_details': 'تفاصيل الحساب',
  'billing': 'الفوترة والدفع',
  'notifications': 'الإشعارات',
  'spend_limits': 'حدود الإنفاق',
  'help': 'المساعدة والدعم',
  // Chat
  'chat_title': 'AdStick AI',
  'chat_sub': 'متصل · مساعد ذكي',
  'chat_greeting': '👋 مرحباً! أنا AdStick AI. اسألني عن الحملات والأسعار والانطباعات والمناطق والعائد على الاستثمار والمزيد!',
  'chat_hello_reply': 'مرحباً! كيف يمكنني مساعدتك؟ اسألني عن الحملات أو الأسعار أو العائد على الاستثمار أو أي شيء عن AdStick.',
  'chat_fallback': 'سؤال رائع! تواصل معنا على info@adstick.sa أو اضغط زر WhatsApp. فريقنا متاح 9 ص – 9 م يومياً.',
  'chat_hint': 'اسألني أي شيء...',
  'qr_price': '💳 الأسعار',
  'qr_campaigns': '📢 الحملات',
  'qr_roi': '📈 العائد',
  'qr_gps': '📍 المناطق',
  'qr_contact': '📞 تواصل',
};
