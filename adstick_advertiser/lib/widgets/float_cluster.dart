import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../l10n/app_l10n.dart';

// ──────────────────────────────────────────────────────────────
//  FloatCluster
//  Wraps any Scaffold body with a fixed bottom-right cluster:
//    🤖  AI chatbot button  →  opens in-app chat sheet
//    🔗  Social toggle      →  expands WA / FB / X above
// ──────────────────────────────────────────────────────────────
class FloatCluster extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  const FloatCluster({super.key, required this.child, required this.accentColor});

  @override
  State<FloatCluster> createState() => _FloatClusterState();
}

class _FloatClusterState extends State<FloatCluster>
    with SingleTickerProviderStateMixin {
  bool _socialOpen = false;
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleSocial() {
    setState(() => _socialOpen = !_socialOpen);
    _socialOpen ? _ctrl.forward() : _ctrl.reverse();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openChat() {
    if (_socialOpen) _toggleSocial();
    final locale = localeNotifier.value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChatSheet(accentColor: widget.accentColor, locale: locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // ── Social + AI chat cluster (right in EN, left in AR) ──
        ValueListenableBuilder<String>(
          valueListenable: localeNotifier,
          builder: (_, locale, __) => Positioned(
          bottom: 24,
          right: locale == 'en' ? 20 : null,
          left:  locale == 'ar' ? 20 : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Social icons (animated slide-in) ──
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SocBtn(
                        color: const Color(0xFF25D366),
                        icon: Icons.chat_rounded,
                        tooltip: 'WhatsApp',
                        onTap: () => _launch('https://wa.me/966500000000'),
                      ),
                      const SizedBox(height: 8),
                      _SocBtn(
                        color: const Color(0xFF1877F2),
                        icon: Icons.facebook_rounded,
                        tooltip: 'Facebook',
                        onTap: () => _launch('https://facebook.com/adstick'),
                      ),
                      const SizedBox(height: 8),
                      _SocBtn(
                        color: const Color(0xFF1A1A1A),
                        icon: Icons.alternate_email_rounded,
                        tooltip: 'X / Twitter',
                        onTap: () => _launch('https://x.com/adstick'),
                        border: Border.all(color: Colors.white24),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ── Social toggle button ──
              GestureDetector(
                onTap: _toggleSocial,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _socialOpen
                            ? Icons.close_rounded
                            : Icons.share_rounded,
                        key: ValueKey(_socialOpen),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── AI chatbot button ──
              GestureDetector(
                onTap: _openChat,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor,
                        widget.accentColor.withValues(alpha: 0.78),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 26)),
                  ),
                ),
              ),
            ],
          ),
        )),  // closes Positioned + ValueListenableBuilder
      ],
    );
  }
}

// ── Small social icon button ──────────────────────────────────
class _SocBtn extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final BoxBorder? border;
  const _SocBtn({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  _ChatSheet — in-app AI chat bottom sheet
// ──────────────────────────────────────────────────────────────
class _ChatSheet extends StatefulWidget {
  final Color accentColor;
  final String locale;
  const _ChatSheet({required this.accentColor, required this.locale});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _typing = false;

  static const _kb = <String, String>{
    'price':    'AdStick offers three plans: Starter (SAR 499/mo), Growth (SAR 999/mo), and Enterprise (custom pricing). Each plan includes GPS tracking, real-time impressions, and dashboard access.',
    'earn':     'Drivers earn SAR 800–2,400/month based on distance driven and campaign performance. Top Gold-tier drivers receive bonus payouts and exclusive partner perks.',
    'driver':   'Drivers earn SAR 800–2,400/month based on distance driven and campaign performance. Top Gold-tier drivers receive bonus payouts and exclusive partner perks.',
    'campaign': 'Campaigns start from SAR 4,000/month and can target specific zones, peak hours, and demographics. You get live impression data, heatmaps, and ROI reports.',
    'gps':      'Every vehicle has a real-time GPS tracker. You can view live positions on the map, track routes, and receive traffic density insights.',
    'payment':  'Drivers are paid monthly via bank transfer. Advertisers are billed monthly with detailed spend breakdowns and downloadable invoices.',
    'contact':  'Reach AdStick at info@adstick.sa or call +966 11 000 0000. WhatsApp support is available 9 AM–9 PM daily.',
    'sticker':  'Stickers are professionally installed on your vehicle roof or rear. They are weather-proof and regularly quality-checked by our QC team.',
    'app':      'The AdStick Driver App and Advertiser App are available on iOS and Android. Download from the App Store or Google Play.',
    'report':   'The reports panel gives you impressions by zone, day-parting analysis, ROI breakdown, and PDF export for all active campaigns.',
    'map':      'The Live Map shows all active vehicles in real time. You can filter by zone, status, and campaign to see coverage density.',
  };

  String _t(String key) => (widget.locale == 'ar' ? _chatAr : _chatEn)[key] ?? key;

  static const _chatEn = <String, String>{
    'greeting': '👋 Hi! I\'m AdStick AI. Ask me about pricing, campaigns, driver earnings, GPS tracking, and more!',
    'hello': 'Hello! How can I help you today? Ask me about pricing, campaigns, driver earnings, GPS, or anything about AdStick.',
    'fallback': 'Great question! Contact us at info@adstick.sa or tap the WhatsApp button. Available 9 AM–9 PM daily.',
    'hint': 'Ask me anything…',
    'title': 'AdStick AI',
    'sub': 'Online · Smart assistant',
    'qr_price': '💳 Pricing',
    'qr_earn': '🚗 Earnings',
    'qr_camp': '📢 Campaigns',
    'qr_gps': '📍 GPS',
    'qr_contact': '📞 Contact',
  };
  static const _chatAr = <String, String>{
    'greeting': '👋 مرحباً! أنا AdStick AI. اسألني عن الأسعار والحملات وأرباح السائقين وتتبع GPS والمزيد!',
    'hello': 'مرحباً! كيف يمكنني مساعدتك؟ اسألني عن الأسعار أو الحملات أو أرباح السائقين أو أي شيء عن AdStick.',
    'fallback': 'سؤال رائع! تواصل معنا على info@adstick.sa أو اضغط زر WhatsApp. فريقنا متاح 9 ص – 9 م يومياً.',
    'hint': 'اسألني أي شيء...',
    'title': 'AdStick AI',
    'sub': 'متصل · مساعد ذكي',
    'qr_price': '💳 الأسعار',
    'qr_earn': '🚗 الأرباح',
    'qr_camp': '📢 الحملات',
    'qr_gps': '📍 GPS',
    'qr_contact': '📞 تواصل',
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _addBot(_t('greeting'));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _addBot(String text) {
    if (!mounted) return;
    setState(() => _msgs.add(_Msg(text: text, isUser: false)));
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_Msg(text: text, isUser: true));
      _typing = true;
    });
    _scrollDown();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _typing = false);
    _addBot(_respond(text));
  }

  String _respond(String q) {
    final lower = q.toLowerCase();
    for (final entry in _kb.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey') ||
        lower.contains('مرحب') || lower.contains('سلام') || lower.contains('هلا')) {
      return _t('hello');
    }
    return _t('fallback');
  }

  List<String> get _quickReplies => [
    _t('qr_price'), _t('qr_earn'), _t('qr_camp'), _t('qr_gps'), _t('qr_contact'),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor,
                      widget.accentColor.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_t('title'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          Text(_t('sub'),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ── Messages ──
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(14),
                  itemCount: _msgs.length + (_typing ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _msgs.length && _typing) {
                      return _TypingIndicator(color: widget.accentColor);
                    }
                    return _MsgBubble(
                      msg: _msgs[i],
                      accentColor: widget.accentColor,
                    );
                  },
                ),
              ),

              // ── Quick-reply chips (shown until user sends first message) ──
              if (_msgs.length <= 1)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: _quickReplies.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final q = _quickReplies[i];
                      return GestureDetector(
                        onTap: () {
                          _ctrl.text = q.length > 2 ? q.substring(3) : q;
                          _send();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: widget.accentColor.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            q,
                            style: TextStyle(
                              color: widget.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // ── Input bar ──
              Container(
                padding: EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  MediaQuery.of(context).viewInsets.bottom + 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _t('hint'),
                          hintStyle: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 14),
                          filled: true,
                          fillColor: AppTheme.dark3,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.accentColor,
                              widget.accentColor.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Message data model ────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser;
  const _Msg({required this.text, required this.isUser});
}

// ── Chat bubble ───────────────────────────────────────────────
class _MsgBubble extends StatelessWidget {
  final _Msg msg;
  final Color accentColor;
  const _MsgBubble({super.key, required this.msg, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: msg.isUser ? 48 : 0,
        right: msg.isUser ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: msg.isUser ? accentColor : AppTheme.dark3,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight:
                      Radius.circular(msg.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, height: 1.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final Color color;
  const _TypingIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.dark3,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _Dot(delay: i * 200, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated dot for typing indicator ────────────────────────
class _Dot extends StatefulWidget {
  final int delay;
  final Color color;
  const _Dot({required this.delay, required this.color});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: FadeTransition(
        opacity: _a,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
              color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
