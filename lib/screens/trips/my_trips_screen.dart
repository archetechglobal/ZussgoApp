import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});
  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  List<Map<String, dynamic>> _upcoming = [], _past = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser(); final uid = u?['userId']; if (uid == null) { setState(() => _loading = false); return; }
    final r = await ApiService.getMyTrips(uid);
    if (mounted) setState(() {
      _loading = false;
      if (r["success"] == true && r["data"] != null) { _upcoming = List<Map<String, dynamic>>.from(r["data"]["upcoming"] ?? []); _past = List<Map<String, dynamic>>.from(r["data"]["past"] ?? []); }
    });
  }

  String _fmt(String? d) { if (d == null) return ''; final dt = DateTime.tryParse(d); if (dt == null) return ''; const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${m[dt.month - 1]} ${dt.day}'; }
  int _days(String? s, String? e) { final a = DateTime.tryParse(s ?? ''); final b = DateTime.tryParse(e ?? ''); if (a == null || b == null) return 0; return b.difference(a).inDays; }

  LinearGradient _dg(int i) {
    const gs = [LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF22D3EE)]), LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
      LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]), LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)])];
    return gs[i % gs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: Stack(children: [
      SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 90), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Journeys', style: ZussGoTheme.displayLarge.copyWith(fontSize: 26)),
        Text('Adventures planned & memories made', style: ZussGoTheme.bodySmall),
        const SizedBox(height: 16),

        if (_loading) Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))),

        if (!_loading && _upcoming.isEmpty && _past.isEmpty)
          Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: ZussGoTheme.cardDecoration,
              child: Column(children: [const Text('✈️', style: TextStyle(fontSize: 36)), const SizedBox(height: 10), Text('No trips yet', style: ZussGoTheme.displaySmall), const SizedBox(height: 6),
                Text('Plan your first escape!', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center), const SizedBox(height: 16), GradientButton(text: 'Explore Destinations', onPressed: () => context.go('/search'))])),

        if (!_loading && _upcoming.isNotEmpty) ...[
          Text('UPCOMING', style: TextStyle(fontSize: 10, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_upcoming.length, (i) {
            final t = _upcoming[i]; final d = t['destination'] ?? {}; final days = _days(t['startDate'], t['endDate']);
            return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3))]),
                child: Column(children: [
                  // Hero
                  Container(height: 100, decoration: BoxDecoration(gradient: _dg(i), borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))),
                      child: Stack(children: [
                        Center(child: Opacity(opacity: 0.1, child: Text(d['emoji'] ?? '✈️', style: const TextStyle(fontSize: 50)))),
                        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)]),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)))),
                        Positioned(bottom: 10, left: 14, child: Text('${d['emoji'] ?? '✈️'} ${d['name'] ?? 'Trip'}', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),
                      ])),
                  // Body
                  Padding(padding: const EdgeInsets.all(14), child: Column(children: [
                    // Date row with flight line
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)),
                          child: Text('📅 ${_fmt(t['startDate'])}', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w500, color: ZussGoTheme.textSecondary))),
                      Expanded(child: Stack(alignment: Alignment.center, children: [
                        Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(gradient: LinearGradient(colors: [ZussGoTheme.green, ZussGoTheme.mint]), borderRadius: BorderRadius.circular(1))),
                        const Text('✈️', style: TextStyle(fontSize: 12)),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)),
                          child: Text('📅 ${_fmt(t['endDate'])}', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w500, color: ZussGoTheme.textSecondary))),
                    ]),
                    const SizedBox(height: 10),
                    // Stats
                    Row(children: [
                      Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [Text('$days', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 16, fontWeight: FontWeight.w700, color: ZussGoTheme.green)), Text('Days', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted))]))),
                      const SizedBox(width: 6),
                      Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [Text('0', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 16, fontWeight: FontWeight.w700, color: ZussGoTheme.sky)), Text('Matches', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted))]))),
                      const SizedBox(width: 6),
                      if (t['budget'] != null) Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [Text(t['budget'], style: TextStyle(fontFamily: 'Playfair Display', fontSize: 11, fontWeight: FontWeight.w700, color: ZussGoTheme.amber)), Text('Budget', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted))]))),
                    ]),
                    const SizedBox(height: 10),
                    GestureDetector(onTap: () => context.push('/destination/${d['slug'] ?? ''}'),
                        child: Center(child: Text('Find Companions →', style: TextStyle(fontSize: 13, color: ZussGoTheme.green, fontWeight: FontWeight.w600)))),
                  ])),
                ]));
          }),
          const SizedBox(height: 14),
        ],

        if (!_loading && _past.isNotEmpty) ...[
          Text('MEMORIES', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_past.length, (i) {
            final t = _past[i]; final d = t['destination'] ?? {};
            return Opacity(opacity: 0.5, child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 6), decoration: ZussGoTheme.glassCard,
                child: Row(children: [Text('${d['emoji'] ?? '✈️'}', style: const TextStyle(fontSize: 18)), const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['name'] ?? 'Trip', style: ZussGoTheme.labelBold), Text('${_fmt(t['startDate'])} — ${_fmt(t['endDate'])}', style: ZussGoTheme.bodySmall)])])));
          }),
        ],

        if (!_loading) ...[const SizedBox(height: 14), GradientButton(text: '+ Plan a New Escape', onPressed: () => context.go('/search'))],
      ]))),
      const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 3)),
    ]));
  }
}