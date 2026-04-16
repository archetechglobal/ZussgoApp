import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../config/zuss_icons.dart';
import '../../config/animations.dart';
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
  int _cashbackValue = 0;
  Map<String, dynamic>? _nextTier;
  List<Map<String, dynamic>> _tiers = [];
  List<Map<String, dynamic>> _activity = [];
  List<Map<String, dynamic>> _offers = [];
  String? _userId;

  static const _tierIcons = <String, IconData>{'Explorer': Icons.eco_rounded, 'Wanderer': Icons.map_rounded, 'Nomad': Icons.cabin_rounded, 'Pathfinder': Icons.terrain_rounded};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = await AuthService.getSavedUser();
    _userId = user?['userId'];
    if (_userId == null) { setState(() => _loading = false); return; }

    try {
      final r = await http.get(Uri.parse('${ApiConfig.rewards}?userId=$_userId'));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data['success'] == true && data['data'] != null) {
          final d = data['data'];
          if (mounted) setState(() { _balance = d['balance'] ?? 0; _tier = d['tier'] ?? 'Explorer'; _cashbackValue = d['cashbackValue'] ?? 0;
          _nextTier = d['nextTier']; _tiers = List<Map<String, dynamic>>.from(d['tiers'] ?? []); _activity = List<Map<String, dynamic>>.from(d['recentActivity'] ?? []);
          _offers = List<Map<String, dynamic>>.from(d['offers'] ?? []); _loading = false; });
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() { _loading = false;
    _tiers = [{'name': 'Explorer', 'range': '0–499', 'isActive': _tier == 'Explorer'}, {'name': 'Wanderer', 'range': '500–1999', 'isActive': _tier == 'Wanderer'},
      {'name': 'Nomad', 'range': '2000–4999', 'isActive': _tier == 'Nomad'}, {'name': 'Pathfinder', 'range': '5000+', 'isActive': _tier == 'Pathfinder'}];
    _offers = [{'label': '₹50 Cashback', 'cost': '500 TP', 'icon': 'cashback', 'points': 500}, {'label': 'Profile Boost 7d', 'cost': '300 TP', 'icon': 'bolt', 'points': 300},
      {'label': 'Verified Badge', 'cost': '1000 TP', 'icon': 'badge', 'points': 1000}, {'label': 'Free Group Join', 'cost': '750 TP', 'icon': 'group', 'points': 750}];
    });
  }

  Future<void> _redeemOffer(Map<String, dynamic> offer) async {
    final c = context.colors;
    final pts = offer['points'] ?? 0;
    if (_balance < pts) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not enough Trek Points (need $pts, have $_balance)'), backgroundColor: c.rose));
      return;
    }
    // Show confirmation
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: c.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Redeem ${offer['label']}?', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
      content: Text('This will use $pts Trek Points.', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: c.textSecondary))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Redeem', style: GoogleFonts.plusJakartaSans(color: c.primary, fontWeight: FontWeight.w600))),
      ],
    ));
    if (confirm != true || _userId == null) return;

    try {
      final r = await http.post(Uri.parse(ApiConfig.rewardsRedeem), headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': _userId, 'offerId': offer['id'] ?? offer['label'], 'points': pts}));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${offer['label']} redeemed!'), backgroundColor: c.sage));
          _load();
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Redemption not available yet'), backgroundColor: c.gold));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Redemption coming soon!'), backgroundColor: c.gold));
    }
  }

  IconData _offerIcon(String? key) { switch (key) { case 'cashback': return ZussIcons.cashback; case 'bolt': return ZussIcons.bolt; case 'badge': return ZussIcons.badge; case 'group': return ZussIcons.group; default: return ZussIcons.gift; } }
  static const _activityIcons = <String, IconData>{'TRIP_COMPLETED': Icons.check_circle_rounded, 'COMPANION_MATCHED': Icons.handshake_rounded, 'SIGNUP_BONUS': Icons.celebration_rounded, 'CASHBACK_REDEEMED': Icons.payments_rounded, 'RATING_GIVEN': Icons.star_rounded};
  String _formatBalance(int b) { if (b >= 1000) return '${b ~/ 1000},${(b % 1000).toString().padLeft(3, '0')}'; return b.toString(); }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progressFraction = _balance / 5000;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(fit: StackFit.expand, children: [
        SafeArea(bottom: false, child: _loading ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
            : SingleChildScrollView(padding: const EdgeInsets.only(bottom: 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Top bar
          Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('REWARDS', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)), const SizedBox(height: 4),
              RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text), children: [const TextSpan(text: 'Trek '), TextSpan(text: 'Points', style: TextStyle(color: c.gold))])),
            ]),
            Container(width: 40, height: 40, decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
                child: Stack(alignment: Alignment.center, children: [Icon(ZussIcons.notification, size: 18, color: c.textSecondary),
                  Positioned(top: 6, right: 6, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle, border: Border.all(color: c.surface, width: 2))))])),
          ])).zussHero(delay: 0),

          // Hero card
          Container(
            margin: const EdgeInsets.fromLTRB(24, 14, 24, 0), padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFF2A1810), Color(0xFF1E1420), Color(0xFF14182A)]),
                border: Border.all(color: c.borderWarm), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))]),
            child: Stack(children: [
              Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0x15FFBD3D), Colors.transparent])))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.goldMid)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_tierIcons[_tier] ?? Icons.eco_rounded, size: 13, color: c.gold), const SizedBox(width: 4),
                      Text('$_tier Tier', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c.gold))])),
                const SizedBox(height: 12),
                Text('YOUR BALANCE', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary)), const SizedBox(height: 4),
                Text(_formatBalance(_balance), style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, color: c.gold, height: 1, letterSpacing: -2)).zussPop(delay: 200),
                const SizedBox(height: 6),
                RichText(text: TextSpan(style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary), children: [
                  const TextSpan(text: '≈ '), TextSpan(text: '₹$_cashbackValue cashback', style: TextStyle(color: c.primary, fontWeight: FontWeight.w700)), const TextSpan(text: ' value')])),
                const SizedBox(height: 18),
                if (_nextTier != null) ...[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [Icon(_tierIcons[_tier] ?? Icons.eco_rounded, size: 12, color: c.textSecondary), const SizedBox(width: 4), Text(_tier, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary))]),
                    Text('${_nextTier!['pointsNeeded']} to ${_nextTier!['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.gold, fontWeight: FontWeight.w600)),
                  ]), const SizedBox(height: 7),
                ],
                ClipRRect(borderRadius: BorderRadius.circular(99), child: SizedBox(height: 6, child: Stack(children: [
                  Container(color: const Color(0xFF2A2520)),
                  FractionallySizedBox(widthFactor: progressFraction.clamp(0, 1).toDouble(), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), gradient: LinearGradient(colors: [c.primary, c.gold])))),
                ]))),
                const SizedBox(height: 14),
                // REDEEM BUTTON — now tappable
                GestureDetector(
                  onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Redeem store coming soon!'), backgroundColor: c.gold)); },
                  child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ZussIcons.gift, size: 16, color: Colors.white), const SizedBox(width: 6), Text('Redeem Points', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white))])),
                ),
              ]),
            ]),
          ).zussHero(delay: 100),

          // Tiers — tappable
          _sectionHeader('Your Journey', 'All Tiers').zussEntrance(index: 0, baseDelay: 300),
          SizedBox(height: 110, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), itemCount: _tiers.length,
            itemBuilder: (_, i) {
              final t = _tiers[i]; final isActive = t['isActive'] == true; final tierName = t['name'] ?? 'Explorer'; final tierIcon = _tierIcons[tierName] ?? Icons.eco_rounded;
              return GestureDetector(
                onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$tierName: ${t['range']} Trek Points'), backgroundColor: context.colors.card, behavior: SnackBarBehavior.floating)); },
                child: Container(width: 100, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: isActive ? ZussGoTheme.accentCardDecoration(context, c.primary) : BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(tierIcon, size: 26, color: isActive ? c.primary : c.muted), const SizedBox(height: 6),
                        Text(tierName, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? c.primary : c.text)),
                        Text(t['range'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted))]),
                      if (isActive) Positioned(top: -10, right: -10, child: Container(width: 18, height: 18, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 11, color: Colors.white))),
                    ])),
              ).zussCascade(index: i);
            },
          )),

          // Offers — tappable with redeem flow
          _sectionHeader('Redeem', 'Browse All').zussEntrance(index: 1, baseDelay: 400),
          SizedBox(height: 120, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), itemCount: _offers.length,
            itemBuilder: (_, i) {
              final o = _offers[i];
              return GestureDetector(
                onTap: () => _redeemOffer(o),
                child: Container(width: 150, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(16), decoration: ZussGoTheme.warmCardDecoration(context),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Icon(_offerIcon(o['icon']), size: 26, color: c.primary), const SizedBox(height: 8),
                      Text(o['label'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c.text)),
                      Row(mainAxisSize: MainAxisSize.min, children: [Icon(ZussIcons.star, size: 13, color: c.gold), const SizedBox(width: 3),
                        Text(o['cost'] ?? '${o['points'] ?? 0} TP', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: c.gold))]),
                    ])),
              ).zussCascade(index: i);
            },
          )),

          // Activity
          _sectionHeader('Recent Activity', 'View All').zussEntrance(index: 2, baseDelay: 500),
          if (_activity.isEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Container(padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ZussIcons.compass, size: 18, color: c.muted.withValues(alpha: 0.4)), const SizedBox(width: 8),
                Text('No activity yet — start traveling!', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted))])))
          else Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: _activity.asMap().entries.map((entry) {
            final i = entry.key; final a = entry.value;
            final isEarn = a['isEarn'] == true || (a['amount'] is int && a['amount'] > 0);
            final amt = a['amount'] is int ? (a['amount'] > 0 ? '+${a['amount']}' : '${a['amount']}') : (a['points'] ?? '');
            final actIcon = _activityIcons[a['type']] ?? (isEarn ? ZussIcons.star : ZussIcons.cashback);
            return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                child: Row(children: [ZussIcon(actIcon, size: 17, color: isEarn ? c.sage : c.rose, bgColor: isEarn ? c.sageSoft : c.roseSoft, bgSize: 38, bgRadius: 12), const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['description'] ?? a['title'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)), const SizedBox(height: 2),
                    Text(_formatTime(a['createdAt']), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted))])),
                  Text(amt.toString(), style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: isEarn ? c.sage : c.rose))])).zussEntrance(index: i, baseDelay: 600);
          }).toList())),
          const SizedBox(height: 16),
        ]))),
        const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 2)),
      ]),
    );
  }

  String _formatTime(dynamic t) { if (t == null) return ''; final dt = DateTime.tryParse(t.toString()); if (dt == null) return t.toString(); final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago'; if (diff.inHours < 24) return '${diff.inHours}h ago'; return '${diff.inDays}d ago'; }

  Widget _sectionHeader(String title, String link) { final c = context.colors;
  return Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
    Text(link, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary))])); }
}