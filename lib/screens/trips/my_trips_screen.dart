import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/zuss_icons.dart';
import '../../config/animations.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});
  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  List<Map<String, dynamic>> _upcoming = [], _past = [], _groups = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    final uid = u?['userId'];
    if (uid == null) { setState(() => _loading = false); return; }

    final r = await ApiService.getMyTrips(uid);
    final gr = await ApiService.getMyGroups(uid);

    if (mounted) setState(() {
      _loading = false;
      if (r["success"] == true && r["data"] != null) {
        _upcoming = List<Map<String, dynamic>>.from(r["data"]["upcoming"] ?? []);
        _past = List<Map<String, dynamic>>.from(r["data"]["past"] ?? []);
      }
      if (gr["success"] == true && gr["data"] != null) {
        _groups = List<Map<String, dynamic>>.from(gr["data"]);
      }
    });
  }

  String _fmt(String? d) {
    if (d == null) return '';
    final dt = DateTime.tryParse(d);
    if (dt == null) return '';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[dt.month - 1]} ${dt.day}';
  }

  int _days(String? s, String? e) {
    final a = DateTime.tryParse(s ?? ''); final b = DateTime.tryParse(e ?? '');
    if (a == null || b == null) return 0; return b.difference(a).inDays;
  }

  static const _destEmojis = {
    'Goa': '🌴', 'Varanasi': '🕌', 'Manali': '🏔️', 'Ladakh': '🏔️',
    'Spiti Valley': '🏔️', 'Kasol': '🏕️', 'Rishikesh': '🕉️', 'Jaipur': '🏰',
  };

  static const _gradients = [
    [Color(0xFF2A1810), Color(0xFF1A1020)],
    [Color(0xFF1A2810), Color(0xFF102018)],
    [Color(0xFF10182A), Color(0xFF081020)],
    [Color(0xFF2A1028), Color(0xFF1A0818)],
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Journeys', style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: c.text)),
                  const SizedBox(height: 4),
                  Text('Adventures planned & memories made', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
                  const SizedBox(height: 20),

                  if (_loading)
                    Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),

                  // ── EMPTY STATE ──
                  if (!_loading && _upcoming.isEmpty && _past.isEmpty && _groups.isEmpty)
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.border)),
                      child: Column(children: [
                        Icon(Icons.flight_rounded, size: 40, color: c.muted.withValues(alpha: 0.4)),
                        const SizedBox(height: 10),
                        Text('No trips yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
                        const SizedBox(height: 6),
                        Text('Plan your first escape!', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.go('/search'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14)),
                            child: Text('Explore Destinations', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                      ]),
                    ),

                  // ── GROUP TRIPS ──
                  if (!_loading && _groups.isNotEmpty) ...[
                    Text('GROUP TRIPS', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.lavender, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ..._groups.map((g) {
                      final dest = g['destination'] ?? {};
                      final name = g['name'] ?? dest['name'] ?? 'Group Trip';
                      final emoji = dest['emoji'] ?? _destEmojis[dest['name']] ?? '🗺️';
                      final memberCount = g['memberCount'] ?? g['_count']?['members'] ?? 1;
                      return GestureDetector(
                        onTap: () => context.push('/group/${g['id']}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.lavenderMid)),
                          child: Row(children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: c.lavenderSoft, borderRadius: BorderRadius.circular(14)),
                              alignment: Alignment.center,
                              child: Text(emoji, style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
                              const SizedBox(height: 2),
                              Text('$memberCount members · ${_fmt(g['startDate'])}–${_fmt(g['endDate'])}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
                            ])),
                            Icon(Icons.chevron_right_rounded, size: 18, color: c.lavender),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],

                  // ── UPCOMING ──
                  if (!_loading && _upcoming.isNotEmpty) ...[
                    Text('UPCOMING', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.primary, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ...List.generate(_upcoming.length, (i) {
                      final t = _upcoming[i];
                      final d = t['destination'] ?? {};
                      final days = _days(t['startDate'], t['endDate']);
                      final emoji = d['emoji'] ?? _destEmojis[d['name']] ?? '🗺️';
                      final grad = _gradients[i % _gradients.length];

                      return GestureDetector(
                        onTap: () => context.push('/trip/${t['id']}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.border)),
                          child: Column(children: [
                            // Hero
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: grad),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                              ),
                              child: Stack(children: [
                                Center(child: Opacity(opacity: 0.15, child: Text(emoji, style: const TextStyle(fontSize: 60)))),
                                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)]), borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)))),
                                Positioned(bottom: 10, left: 14, child: Text(d['name'] ?? 'Trip', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white))),
                              ]),
                            ),
                            // Body
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(children: [
                                Row(children: [
                                  _DateChip(_fmt(t['startDate']), c),
                                  Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(gradient: LinearGradient(colors: [c.primary, c.sage]), borderRadius: BorderRadius.circular(1)))),
                                  _DateChip(_fmt(t['endDate']), c),
                                ]),
                                const SizedBox(height: 10),
                                Row(children: [
                                  _StatBox(value: '$days', label: 'Days', color: c.primary, c: c),
                                  const SizedBox(width: 6),
                                  _StatBox(value: '0', label: 'Matches', color: c.lavender, c: c),
                                  if (t['budget'] != null) ...[
                                    const SizedBox(width: 6),
                                    _StatBox(value: t['budget'], label: 'Budget', color: c.gold, c: c, small: true),
                                  ],
                                ]),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => context.push('/destination/${d['slug'] ?? ''}'),
                                  child: Text('Find Companions →', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.primary, fontWeight: FontWeight.w600)),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],

                  // ── PAST TRIPS ──
                  if (!_loading && _past.isNotEmpty) ...[
                    Text('MEMORIES', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    ..._past.map((t) {
                      final d = t['destination'] ?? {};
                      final emoji = d['emoji'] ?? _destEmojis[d['name']] ?? '🗺️';
                      return Opacity(
                        opacity: 0.7,
                        child: Container(
                          padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                          child: Row(children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: c.card2, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(emoji, style: const TextStyle(fontSize: 18))),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d['name'] ?? 'Trip', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
                              Text('${_fmt(t['startDate'])} — ${_fmt(t['endDate'])}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.textSecondary)),
                            ])),
                          ]),
                        ),
                      );
                    }),
                  ],

                  // ── Plan New Trip ──
                  if (!_loading) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => context.go('/search'),
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x30FF6B4A), blurRadius: 16)]),
                        child: Center(child: Text('+ Plan a New Escape', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 3)),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String text;
  final ZussGoColors c;
  const _DateChip(this.text, this.c);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: c.card2, borderRadius: BorderRadius.circular(10)),
    child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: c.textSecondary)),
  );
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  final ZussGoColors c;
  final bool small;
  const _StatBox({required this.value, required this.label, required this.color, required this.c, this.small = false});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: c.card2, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: GoogleFonts.outfit(fontSize: small ? 11 : 16, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: c.muted)),
      ]),
    ),
  );
}