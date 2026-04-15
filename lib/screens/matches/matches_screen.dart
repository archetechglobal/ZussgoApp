import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/auth_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool _loading = true;
  int _balance = 0;
  String _tier = 'Explorer';
  String _tierEmoji = '🌱';
  int _cashbackValue = 0;
  Map<String, dynamic>? _nextTier;
  List<Map<String, dynamic>> _tiers = [];
  List<Map<String, dynamic>> _activity = [];
  List<Map<String, dynamic>> _offers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() => _loading = false); return; }

    try {
      final r = await http.get(Uri.parse('${ApiConfig.rewards}?userId=$userId'));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data['success'] == true && data['data'] != null) {
          final d = data['data'];
          if (mounted) {
            setState(() {
              _balance = d['balance'] ?? 0;
              _tier = d['tier'] ?? 'Explorer';
              _tierEmoji = d['tierEmoji'] ?? '🌱';
              _cashbackValue = d['cashbackValue'] ?? 0;
              _nextTier = d['nextTier'];
              _tiers = List<Map<String, dynamic>>.from(d['tiers'] ?? []);
              _activity = List<Map<String, dynamic>>.from(d['recentActivity'] ?? []);
              _offers = List<Map<String, dynamic>>.from(d['offers'] ?? []);
              _loading = false;
            });
          }
          return;
        }
      }
    } catch (_) {}

    // Fallback to defaults if API fails
    if (mounted) {
      setState(() {
        _loading = false;
        _tiers = [
          {'name': 'Explorer', 'emoji': '🌱', 'range': '0–499', 'isActive': _tier == 'Explorer'},
          {'name': 'Wanderer', 'emoji': '🗺️', 'range': '500–1999', 'isActive': _tier == 'Wanderer'},
          {'name': 'Nomad', 'emoji': '⛺', 'range': '2000–4999', 'isActive': _tier == 'Nomad'},
          {'name': 'Pathfinder', 'emoji': '🏔️', 'range': '5000+', 'isActive': _tier == 'Pathfinder'},
        ];
        _offers = [
          {'emoji': '💰', 'label': '₹50 Cashback', 'cost': '⭐ 500 TP'},
          {'emoji': '🚀', 'label': 'Profile Boost 7d', 'cost': '⭐ 300 TP'},
          {'emoji': '🏅', 'label': 'Verified Badge', 'cost': '⭐ 1000 TP'},
          {'emoji': '👥', 'label': 'Free Group Join', 'cost': '⭐ 750 TP'},
        ];
      });
    }
  }

  String _formatBalance(int b) {
    if (b >= 1000) {
      return '${b ~/ 1000},${(b % 1000).toString().padLeft(3, '0')}';
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progressFraction = _balance / 5000;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: _loading
                ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
                : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP BAR ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('REWARDS', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text), children: [
                            const TextSpan(text: 'Trek '),
                            TextSpan(text: 'Points', style: TextStyle(color: c.gold)),
                          ])),
                        ]),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
                          child: Stack(alignment: Alignment.center, children: [
                            const Text('🔔', style: TextStyle(fontSize: 18)),
                            Positioned(top: 6, right: 6, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle, border: Border.all(color: c.surface, width: 2)))),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  // ── HERO CARD ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(colors: [Color(0xFF2A1810), Color(0xFF1E1420), Color(0xFF14182A)]),
                      border: Border.all(color: c.borderWarm),
                    ),
                    child: Stack(children: [
                      Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0x15FFBD3D), Colors.transparent])))),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Tier badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.goldMid)),
                          child: Text('$_tierEmoji $_tier Tier', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c.gold)),
                        ),
                        const SizedBox(height: 12),
                        Text('YOUR BALANCE', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary)),
                        const SizedBox(height: 4),
                        Text(_formatBalance(_balance), style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, color: c.gold, height: 1, letterSpacing: -2)),
                        const SizedBox(height: 6),
                        RichText(text: TextSpan(style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary), children: [
                          const TextSpan(text: '≈ '),
                          TextSpan(text: '₹$_cashbackValue cashback', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)),
                          const TextSpan(text: ' value'),
                        ])),
                        const SizedBox(height: 18),
                        // Progress
                        if (_nextTier != null) ...[
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('$_tier $_tierEmoji', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary)),
                            Text('${_nextTier!['pointsNeeded']} to ${_nextTier!['name']} ${_nextTier!['emoji']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.gold, fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 7),
                        ],
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(height: 6, child: Stack(children: [
                            Container(color: const Color(0xFF2A2520)),
                            FractionallySizedBox(widthFactor: progressFraction.clamp(0, 1).toDouble(), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), gradient: LinearGradient(colors: [c.primary, c.gold])))),
                          ])),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text('Redeem Points →', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white))),
                        ),
                      ]),
                    ]),
                  ),

                  // ── TIERS ──
                  _sectionHeader('Your Journey', 'All Tiers →'),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _tiers.length,
                      itemBuilder: (_, i) {
                        final t = _tiers[i];
                        final isActive = t['isActive'] == true;
                        return Container(
                          width: 100, margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isActive ? null : c.card,
                            gradient: isActive ? const LinearGradient(colors: [Color(0xFF1E1510), Color(0xFF1A1420)]) : null,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: isActive ? c.primary : c.border),
                          ),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(t['emoji'] ?? '🌱', style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 6),
                              Text(t['name'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? c.primary : c.text)),
                              Text(t['range'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
                            ]),
                            if (isActive) Positioned(top: -10, right: -10, child: Container(width: 18, height: 18, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle), child: const Center(child: Text('✓', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white))))),
                          ]),
                        );
                      },
                    ),
                  ),

                  // ── OFFERS ──
                  _sectionHeader('Redeem', 'Browse All'),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _offers.length,
                      itemBuilder: (_, i) {
                        final o = _offers[i];
                        return Container(
                          width: 150, margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(o['emoji'] ?? '💰', style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 8),
                            Text(o['label'] ?? o['title'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c.text)),
                            Text(o['cost'] ?? '⭐ ${o['points'] ?? 0} TP', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: c.gold)),
                          ]),
                        );
                      },
                    ),
                  ),

                  // ── ACTIVITY ──
                  _sectionHeader('Recent Activity', 'View All'),
                  if (_activity.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                        child: Center(child: Text('No activity yet — start traveling!', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted))),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: _activity.map((a) {
                          final isEarn = a['isEarn'] == true || (a['amount'] is int && a['amount'] > 0);
                          final amt = a['amount'] is int ? (a['amount'] > 0 ? '+${a['amount']}' : '${a['amount']}') : (a['points'] ?? '');
                          final typeEmojis = {'TRIP_COMPLETED': '🏕️', 'COMPANION_MATCHED': '🤝', 'SIGNUP_BONUS': '🎉', 'CASHBACK_REDEEMED': '💸', 'RATING_GIVEN': '⭐'};
                          final emoji = typeEmojis[a['type']] ?? (isEarn ? '⭐' : '💸');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                            child: Row(children: [
                              Container(width: 38, height: 38, decoration: BoxDecoration(color: isEarn ? c.sageSoft : c.roseSoft, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: Text(emoji, style: const TextStyle(fontSize: 17))),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a['description'] ?? a['title'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)),
                                const SizedBox(height: 2),
                                Text(_formatTime(a['createdAt']), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
                              ])),
                              Text(amt.toString(), style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: isEarn ? c.sage : c.rose)),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 2)),
        ],
      ),
    );
  }

  String _formatTime(dynamic t) {
    if (t == null) return '';
    final dt = DateTime.tryParse(t.toString());
    if (dt == null) return t.toString();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _sectionHeader(String title, String link) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
        Text(link, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
      ]),
    );
  }
}