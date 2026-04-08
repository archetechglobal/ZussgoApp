import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/destination_images.dart';
import '../../widgets/destination_image.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context),body: Stack(fit: StackFit.expand, children: [

      SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 90), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Journeys', style: context.textTheme.displayLarge!.copyWith(fontSize: 26)),
        Text('Adventures planned & memories made', style: context.textTheme.bodySmall!.adaptive(context)),
        const SizedBox(height: 16),

        if (_loading) Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))),

        if (!_loading && _upcoming.isEmpty && _past.isEmpty)
          Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: ZussGoTheme.cardDecoration(context),
              child: Column(children: [Icon(Icons.flight_takeoff_rounded, size: 40, color: ZussGoTheme.mutedText(context).withValues(alpha: 0.4)), SizedBox(height: 10), Text('No trips yet', style: context.textTheme.displaySmall!.adaptive(context)), SizedBox(height: 6),
                Text('Plan your first escape!', style: context.textTheme.bodySmall!.adaptive(context), textAlign: TextAlign.center), SizedBox(height: 16), GradientButton(text: 'Explore Destinations', onPressed: () => context.go('/search'))])),

        if (!_loading && _upcoming.isNotEmpty) ...[
          Text('UPCOMING', style: TextStyle(fontSize: 10, color: context.colors.green, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_upcoming.length, (i) {
            final t = _upcoming[i]; final d = t['destination'] ?? {}; final days = _days(t['startDate'], t['endDate']);
            return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(22), border: isDark ? Border.all(color: ZussGoTheme.border(context)) : null, boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 3))]),
                child: Column(children: [
                  // Hero
                  Builder(
                    builder: (context) {
                      return Container(
                        height: 100,
                        decoration: BoxDecoration(gradient: _dg(i), borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22))),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                              child: DestinationImage(
                                destination: d,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)]),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                              ),
                            ),
                            Positioned(bottom: 10, left: 14, child: Text(d['name'] ?? 'Trip', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),
                          ],
                        ),
                      );
                    }
                  ),
                  // Body
                  Padding(padding: const EdgeInsets.all(14), child: Column(children: [
                    // Date row with flight line
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)),
                          child: Text(_fmt(t['startDate']), style: context.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500, color: ZussGoTheme.secondaryText(context)))),
                      Expanded(child: Stack(alignment: Alignment.center, children: [
                        Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(gradient: LinearGradient(colors: [context.colors.green, context.colors.mint]), borderRadius: BorderRadius.circular(1))),
                        Icon(Icons.flight_rounded, size: 14, color: context.colors.green),
                      ])),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)),
                          child: Text(_fmt(t['endDate']), style: context.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500, color: ZussGoTheme.secondaryText(context)))),
                    ]),
                    const SizedBox(height: 10),
                    // Stats
                    Row(children: [
                      Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [Text('$days', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.green)), Text('Days', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))]))),
                      const SizedBox(width: 6),
                      Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [Text('0', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.sky)), Text('Matches', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))]))),
                      const SizedBox(width: 6),
                      if (t['budget'] != null) Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(12)),
                          child: Column(children: [Text(t['budget'], style: TextStyle(fontFamily: 'Playfair Display', fontSize: 11, fontWeight: FontWeight.w700, color: context.colors.amber)), Text('Budget', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))]))),
                    ]),
                    const SizedBox(height: 10),
                    GestureDetector(onTap: () => context.push('/destination/${d['slug'] ?? ''}'),
                        child: Center(child: Text('Find Companions →', style: TextStyle(fontSize: 13, color: context.colors.green, fontWeight: FontWeight.w600)))),
                  ])),
                ]));
          }),
          const SizedBox(height: 14),
        ],

        if (!_loading && _past.isNotEmpty) ...[
          Text('MEMORIES', style: TextStyle(fontSize: 10, color: ZussGoTheme.mutedText(context), fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          ...List.generate(_past.length, (i) {
            final t = _past[i]; final d = t['destination'] ?? {};
            return Opacity(opacity: 0.7, child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(16), border: isDark ? Border.all(color: ZussGoTheme.border(context)) : null, boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(8)),
                    clipBehavior: Clip.hardEdge,
                    child: DestinationImage(
                      destination: d,
                      fit: BoxFit.cover,
                    ),
                  ), 
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['name'] ?? 'Trip', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.primaryText(context))), Text('${_fmt(t['startDate'])} — ${_fmt(t['endDate'])}', style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.secondaryText(context)))])])));
          }),
        ],

        if (!_loading) ...[const SizedBox(height: 14), GradientButton(text: '+ Plan a New Escape', onPressed: () => context.go('/search'))],
      ]))),
      const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 3)),
    ]));
  }
}