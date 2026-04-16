import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/zuss_icons.dart';
import '../../config/animations.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class TravelerProfileScreen extends StatefulWidget {
  final String travelerId;
  const TravelerProfileScreen({super.key, required this.travelerId});
  @override
  State<TravelerProfileScreen> createState() => _TravelerProfileScreenState();
}

class _TravelerProfileScreenState extends State<TravelerProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _requestSent = false;
  String? _myUserId;
  int _matchScore = 87;

  // Safe number parser — handles String, int, double, null
  int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  String _safeRating(dynamic v, [String fallback = '4.8']) {
    if (v == null) return fallback;
    if (v is String) return v;
    if (v is num) return v.toStringAsFixed(1);
    return fallback;
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final me = await AuthService.getSavedUser();
    _myUserId = me?['userId'];
    try {
      final r = await ApiService.getUserProfile(widget.travelerId);
      if (mounted) setState(() {
        _loading = false;
        if (r['success'] == true) {
          _profile = r['data'];
          _matchScore = _safeInt(_profile?['matchScore'], 87);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendRequest() async {
    if (_myUserId == null) return;
    final r = await ApiService.sendMatchRequest(userId: _myUserId!, receiverId: widget.travelerId);
    if (mounted) {
      if (r['success'] == true) { setState(() => _requestSent = true); }
      else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Failed to send request'), backgroundColor: context.colors.rose)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = _profile ?? {};
    final name = (p['fullName'] ?? 'Traveler').toString();
    final city = (p['city'] ?? 'India').toString();
    final age = (p['age'] ?? '').toString();
    final style = (p['travelStyle'] ?? 'Explorer').toString();
    final bio = (p['bio'] ?? '').toString();
    final interests = List<String>.from(p['interests'] ?? []);
    final rating = _safeRating(p['rating']);
    final tripsCount = _safeInt(p['tripsCount']).toString();
    final companionsCount = _safeInt(p['friendsCount'] ?? p['companionsCount']).toString();

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
          child: Row(children: [
            GestureDetector(onTap: () => context.pop(), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: c.border)), child: Icon(ZussIcons.back, color: c.text, size: 16))),
            const SizedBox(width: 10),
            Text('Companion', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
            const Spacer(),
            Icon(ZussIcons.flag, size: 18, color: c.muted),
          ]),
        ),
        if (_loading) Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)))
        else if (_profile == null) Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ZussIcons.profile, size: 40, color: c.muted.withValues(alpha: 0.3)), const SizedBox(height: 12),
          Text('Profile not found', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)), const SizedBox(height: 8),
          GestureDetector(onTap: () => context.pop(), child: Text('Go back', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: c.primary))),
        ])))
        else Expanded(child: SingleChildScrollView(child: Column(children: [
            // Hero
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1420), Color(0xFF0D0B0E)])),
              child: Stack(children: [
                Positioned(top: -20, left: 0, right: 0, child: Center(child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.primary.withValues(alpha: 0.08), Colors.transparent]))))),
                Column(children: [
                  Container(width: 90, height: 90, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF2A3828), Color(0xFF1A2A1E)]), border: Border.all(color: c.primaryMid, width: 3)),
                    clipBehavior: Clip.hardEdge, alignment: Alignment.center,
                    child: p['profilePhotoUrl'] != null ? Image.network(p['profilePhotoUrl'].toString(), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Text(name.isNotEmpty ? name[0] : '?', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w800, color: c.primary)))
                        : Text(name.isNotEmpty ? name[0] : '?', style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w800, color: c.primary)),
                  ).zussHero(delay: 0),
                  const SizedBox(height: 14),
                  Text(name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)).zussEntrance(index: 0, baseDelay: 100),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(ZussIcons.location, size: 13, color: c.textSecondary), const SizedBox(width: 3),
                    Text('$city${age.isNotEmpty && age != '0' ? ' · ${age}y' : ''} · $style', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
                  ]),
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.primaryMid), boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.15), blurRadius: 12)]),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('$_matchScore%', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.primary)),
                        const SizedBox(width: 6), Text('Match Score', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                      ])).zussPop(delay: 300),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            // About
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('About', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: c.muted)), const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: ZussGoTheme.floatingCardDecoration(context),
                  child: Text(bio.isNotEmpty ? bio : 'Full-time traveler, part-time photographer.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6))),
            ])).zussEntrance(index: 1, baseDelay: 350),
            const SizedBox(height: 14),

            // Tags
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Wrap(spacing: 6, runSpacing: 6, children: [
              if (interests.isNotEmpty) ...interests.asMap().entries.map((e) => _Tag(label: e.value, color: c.primary, bg: c.primarySoft).zussCascade(index: e.key))
              else ...[_Tag(label: 'Adventure', color: c.primary, bg: c.primarySoft), _Tag(label: 'Trekking', color: c.primary, bg: c.primarySoft), _Tag(label: 'Budget', color: c.gold, bg: c.goldSoft)],
            ])),
            const SizedBox(height: 14),

            // Stats
            Container(margin: const EdgeInsets.symmetric(horizontal: 24), decoration: ZussGoTheme.frostedCardDecoration(context),
                child: Row(children: [_Stat(value: tripsCount, label: 'Trips', color: c.primary), _Stat(value: rating, label: 'Rating', color: c.sage, divider: true), _Stat(value: companionsCount, label: 'Companions', color: c.gold, divider: true)])).zussEntrance(index: 2, baseDelay: 450),
            const SizedBox(height: 14),

            // Trust
            Container(margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.all(12), decoration: ZussGoTheme.accentCardDecoration(context, c.sage),
                child: Row(children: [Icon(ZussIcons.shield, size: 22, color: c.sage), const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Trust Score: $rating', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)), const SizedBox(height: 4),
                    Row(children: [_TrustChip(icon: ZussIcons.verified, label: 'Verified', color: c.sage, bg: c.sageSoft), const SizedBox(width: 4), _TrustChip(icon: ZussIcons.id, label: 'ID', color: c.lavender, bg: c.lavenderSoft)]),
                  ]))])).zussEntrance(index: 3, baseDelay: 500),
            const SizedBox(height: 24),
          ]))),

        // Bottom actions
        if (!_loading && _profile != null)
          Container(padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
            child: Row(children: [
              Expanded(child: GestureDetector(onTap: _requestSent ? null : _sendRequest,
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(color: _requestSent ? c.sage : c.primary, borderRadius: BorderRadius.circular(16), boxShadow: [if (!_requestSent) BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_requestSent ? Icons.check_rounded : ZussIcons.handshake, size: 16, color: Colors.white), const SizedBox(width: 8),
                        Text(_requestSent ? 'Request Sent' : 'Send Companion Request', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                      ])))),
              const SizedBox(width: 10),
              Container(width: 56, height: 48, decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.primaryMid, width: 2)),
                  child: Icon(ZussIcons.chat, size: 20, color: c.primary)),
            ]),
          ),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label; final Color color, bg;
  const _Tag({required this.label, required this.color, required this.bg});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color)));
}

class _Stat extends StatelessWidget {
  final String value, label; final Color color; final bool divider;
  const _Stat({required this.value, required this.label, required this.color, this.divider = false});
  @override Widget build(BuildContext context) { final c = context.colors;
  return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: divider ? BoxDecoration(border: Border(left: BorderSide(color: c.border))) : null,
      child: Column(children: [Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: color)), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted))]))); }
}

class _TrustChip extends StatelessWidget {
  final IconData icon; final String label; final Color color, bg;
  const _TrustChip({required this.icon, required this.label, required this.color, required this.bg});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: color), const SizedBox(width: 3), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: color))]));
}