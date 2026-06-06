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
  'app_name': 'AdStick Admin',
  // Login
  'portal_title': 'Admin Portal',
  'welcome_back': 'Welcome back 👋',
  'sign_in_sub': 'Sign in to the control panel',
  'email': 'Email',
  'password': 'Password',
  'sign_in': 'Sign In',
  // AppBar
  'admin_title': 'AdStick Admin',
  // Drawer nav items
  'dashboard': 'Dashboard',
  'live_map': 'Live Map',
  'reports': 'Reports',
  'predictions': 'Predictions',
  'cars': 'Cars',
  'fleet': 'Fleet Management',
  'drivers': 'Drivers',
  'traffic': 'Traffic Intel',
  'campaigns': 'Campaigns',
  'roi': 'ROI Analytics',
  'marketplace': 'Marketplace',
  'events': 'Events',
  'cities': 'Cities',
  'quality': 'Quality Control',
  'audit': 'Audit Log',
  'carbon': 'Carbon & ESG',
  'sign_out': 'Sign Out',
  // Drawer sections
  'sec_overview': 'OVERVIEW',
  'sec_fleet': 'FLEET & DRIVERS',
  'sec_revenue': 'CAMPAIGNS & REVENUE',
  'sec_platform': 'PLATFORM',
  'sec_govern': 'GOVERNANCE',
  // Dashboard
  'dash_title': '📊 Dashboard',
  'total_revenue': 'Total Revenue',
  'active_drivers': 'Active Drivers',
  'fleet_size': 'Fleet Size',
  'active_camps': 'Active Campaigns',
  'fleet_health': 'Fleet Health Overview',
  'revenue_breakdown': 'Revenue Breakdown',
  'alert_feed': 'Alert Feed',
  // Cars
  'cars_title': '🚗 Fleet Cars',
  'all': 'All',
  'active': 'Active',
  'idle': 'Idle',
  'maintenance': 'Maintenance',
  'track': 'Track',
  'details': 'Details',
  // Campaigns
  'camps_title': '📢 All Campaigns',
  'approve': 'Approve',
  'reject': 'Reject',
  'pending': 'Pending',
  // Drivers
  'drv_title': '👥 Drivers',
  // Reports
  'rep_title': '📈 Platform Reports',
  'platform_kpis': 'Platform KPIs',
  'city_perf': 'City Performance',
  'export': 'Export Report',
  // Live Map
  'map_title': '🗺️ Live Fleet Map',
  // Traffic
  'traffic_title': '🚦 Traffic Intelligence',
  'current_density': 'Current Density',
  'peak_zone': 'Peak Zone',
  'vehicles_tracked': 'Vehicles Tracked',
  'optimal_routes': 'Optimal Routes',
  'hourly_pattern': 'Hourly Traffic Pattern',
  'zone_density': 'Zone Density Index',
  'ai_recommend': 'AI Traffic Recommendation',
  'apply_rec': 'Apply Recommendation',
  // ROI
  'roi_title': '💰 ROI Analytics',
  'platform_roi': 'Platform Average ROI',
  'roi_breakdown': 'Campaign ROI Breakdown',
  'roi_by_zone': 'ROI by Advertising Zone',
  'monthly_trend': 'Monthly ROI Trend',
  // Events
  'events_title': '🎉 Event Intelligence',
  'active_zones': 'Active Event Zones',
  'event_calendar': 'Event Calendar',
  // Predictions
  'pred_title': '🔮 AI Predictions',
  'growth_forecast': 'Growth Forecasts',
  'conf_label': 'Forecast Confidence',
  'risk_register': 'Risk Register',
  // Fleet
  'fleet_title': '🚗 Fleet Management',
  'fleet_health_title': 'Fleet Health Overview',
  'vehicle_register': 'Vehicle Register',
  // Marketplace
  'mkt_title': '🛒 Marketplace',
  'ad_slots': 'Ad Slots',
  'advertisers': 'Advertisers',
  'deals': 'Deals',
  'book_slot': 'Book Slot',
  'view_deal': 'View Deal',
  // Cities
  'cities_title': '🏙️ City Coverage',
  'national_sum': 'National Summary',
  'cities_live': 'Cities Live',
  'city_perf_title': 'City Performance',
  // Quality
  'qual_title': '✅ Quality Control',
  'pass_rate': 'Pass Rate',
  'failures': 'Failures',
  'quality_metrics': 'Quality Metrics',
  'recent_checks': 'Recent QC Checks',
  'run_batch': 'Run New Verification Batch',
  // Audit
  'audit_title': '📋 Audit Log',
  'total_actions': 'Total Actions',
  // Carbon
  'carbon_title': '🌿 Carbon & Sustainability',
  'green_score': 'AdStick Green Score',
  'co2_saved': 'CO₂ Saved vs Billboards',
  'fuel_eff': 'Fuel Efficiency',
  'ev_count': 'Electric Vehicles',
  'offset': 'Carbon Offset',
  'monthly_co2': 'Monthly CO₂ Reduction',
  'initiatives': 'Green Initiatives',
  'dl_report': 'Download PDF Report',
  // Chat
  'chat_title': 'AdStick AI',
  'chat_sub': 'Online · Smart assistant',
  'chat_greeting': '👋 Hi Admin! I\'m AdStick AI. Ask me about fleet performance, campaign ROI, driver management, or platform analytics.',
  'chat_hello_reply': 'Hello! How can I help you today? Ask about fleet, campaigns, drivers, ROI, cities, or anything on the platform.',
  'chat_fallback': 'For detailed support, contact info@adstick.sa or tap WhatsApp. Available 9 AM–9 PM daily.',
  'chat_hint': 'Ask me anything…',
  'qr_fleet': '🚗 Fleet',
  'qr_revenue': '💰 Revenue',
  'qr_campaigns': '📢 Campaigns',
  'qr_drivers': '👥 Drivers',
  'qr_contact': '📞 Contact',
};

const _ar = <String, String>{
  'app_name': 'AdStick للإدارة',
  // Login
  'portal_title': 'لوحة الإدارة',
  'welcome_back': 'مرحباً بعودتك 👋',
  'sign_in_sub': 'سجّل دخولك إلى لوحة التحكم',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'sign_in': 'تسجيل الدخول',
  // AppBar
  'admin_title': 'إدارة AdStick',
  // Drawer nav items
  'dashboard': 'لوحة المعلومات',
  'live_map': 'الخريطة المباشرة',
  'reports': 'التقارير',
  'predictions': 'التنبؤات',
  'cars': 'السيارات',
  'fleet': 'إدارة الأسطول',
  'drivers': 'السائقون',
  'traffic': 'ذكاء المرور',
  'campaigns': 'الحملات',
  'roi': 'تحليلات العائد',
  'marketplace': 'السوق',
  'events': 'الفعاليات',
  'cities': 'المدن',
  'quality': 'ضبط الجودة',
  'audit': 'سجل التدقيق',
  'carbon': 'الكربون والاستدامة',
  'sign_out': 'تسجيل الخروج',
  // Drawer sections
  'sec_overview': 'نظرة عامة',
  'sec_fleet': 'الأسطول والسائقون',
  'sec_revenue': 'الحملات والإيرادات',
  'sec_platform': 'المنصة',
  'sec_govern': 'الحوكمة',
  // Dashboard
  'dash_title': '📊 لوحة المعلومات',
  'total_revenue': 'إجمالي الإيرادات',
  'active_drivers': 'السائقون النشطون',
  'fleet_size': 'حجم الأسطول',
  'active_camps': 'الحملات النشطة',
  'fleet_health': 'نظرة عامة على صحة الأسطول',
  'revenue_breakdown': 'توزيع الإيرادات',
  'alert_feed': 'تغذية التنبيهات',
  // Cars
  'cars_title': '🚗 سيارات الأسطول',
  'all': 'الكل',
  'active': 'نشطة',
  'idle': 'خاملة',
  'maintenance': 'صيانة',
  'track': 'تتبع',
  'details': 'تفاصيل',
  // Campaigns
  'camps_title': '📢 جميع الحملات',
  'approve': 'موافقة',
  'reject': 'رفض',
  'pending': 'قيد المراجعة',
  // Drivers
  'drv_title': '👥 السائقون',
  // Reports
  'rep_title': '📈 تقارير المنصة',
  'platform_kpis': 'مؤشرات أداء المنصة',
  'city_perf': 'أداء المدن',
  'export': 'تصدير التقرير',
  // Live Map
  'map_title': '🗺️ خريطة الأسطول المباشرة',
  // Traffic
  'traffic_title': '🚦 ذكاء المرور',
  'current_density': 'الكثافة الحالية',
  'peak_zone': 'منطقة الذروة',
  'vehicles_tracked': 'المركبات المُتتبَّعة',
  'optimal_routes': 'المسارات المثلى',
  'hourly_pattern': 'نمط المرور الساعي',
  'zone_density': 'مؤشر كثافة المناطق',
  'ai_recommend': 'توصية الذكاء الاصطناعي للمرور',
  'apply_rec': 'تطبيق التوصية',
  // ROI
  'roi_title': '💰 تحليلات العائد',
  'platform_roi': 'متوسط عائد المنصة',
  'roi_breakdown': 'تفصيل عائد الحملات',
  'roi_by_zone': 'العائد حسب المنطقة الإعلانية',
  'monthly_trend': 'اتجاه العائد الشهري',
  // Events
  'events_title': '🎉 ذكاء الفعاليات',
  'active_zones': 'مناطق الفعاليات النشطة',
  'event_calendar': 'تقويم الفعاليات',
  // Predictions
  'pred_title': '🔮 تنبؤات الذكاء الاصطناعي',
  'growth_forecast': 'توقعات النمو',
  'conf_label': 'ثقة التنبؤات',
  'risk_register': 'سجل المخاطر',
  // Fleet
  'fleet_title': '🚗 إدارة الأسطول',
  'fleet_health_title': 'نظرة عامة على صحة الأسطول',
  'vehicle_register': 'سجل المركبات',
  // Marketplace
  'mkt_title': '🛒 السوق',
  'ad_slots': 'مواضع الإعلان',
  'advertisers': 'المعلنون',
  'deals': 'الصفقات',
  'book_slot': 'حجز موضع',
  'view_deal': 'عرض الصفقة',
  // Cities
  'cities_title': '🏙️ التغطية الجغرافية',
  'national_sum': 'الملخص الوطني',
  'cities_live': 'المدن الحية',
  'city_perf_title': 'أداء المدن',
  // Quality
  'qual_title': '✅ ضبط الجودة',
  'pass_rate': 'معدل النجاح',
  'failures': 'الإخفاقات',
  'quality_metrics': 'مقاييس الجودة',
  'recent_checks': 'فحوصات الجودة الأخيرة',
  'run_batch': 'تشغيل دفعة تحقق جديدة',
  // Audit
  'audit_title': '📋 سجل التدقيق',
  'total_actions': 'إجمالي الإجراءات',
  // Carbon
  'carbon_title': '🌿 الكربون والاستدامة',
  'green_score': 'النقاط الخضراء لـ AdStick',
  'co2_saved': 'CO₂ موفّر مقارنةً باللوحات الإعلانية',
  'fuel_eff': 'كفاءة الوقود',
  'ev_count': 'المركبات الكهربائية',
  'offset': 'تعويض الكربون',
  'monthly_co2': 'خفض CO₂ الشهري',
  'initiatives': 'المبادرات الخضراء',
  'dl_report': 'تنزيل تقرير PDF',
  // Chat
  'chat_title': 'AdStick AI',
  'chat_sub': 'متصل · مساعد ذكي',
  'chat_greeting': '👋 مرحباً أيها المدير! أنا AdStick AI. اسألني عن أداء الأسطول والعائد على الحملات وإدارة السائقين وتحليلات المنصة.',
  'chat_hello_reply': 'مرحباً! كيف يمكنني مساعدتك؟ اسألني عن الأسطول أو الحملات أو السائقين أو العائد أو المدن.',
  'chat_fallback': 'للدعم التفصيلي، تواصل معنا على info@adstick.sa أو اضغط زر WhatsApp. متاح 9 ص – 9 م يومياً.',
  'chat_hint': 'اسألني أي شيء...',
  'qr_fleet': '🚗 الأسطول',
  'qr_revenue': '💰 الإيرادات',
  'qr_campaigns': '📢 الحملات',
  'qr_drivers': '👥 السائقون',
  'qr_contact': '📞 تواصل',
};
