import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await AuthService.getSavedUser();
    _myUserId = me?['userId'];
    final r = await ApiService.getUserProfile(widget.travelerId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (r['success'] == true) _profile = r['data'];
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_myUserId == null) return;
    final r = await ApiService.sendMatchRequest(userId: _myUserId!, receiverId: widget.travelerId);
    if (mounted) {
      if (r['success'] == true) {
        setState(() => _requestSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(r['message'] ?? 'Failed to send request'), backgroundColor: context.colors.rose),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final p = _profile ?? {};
    final name = p['fullName'] ?? 'Traveler';
    final city = p['city'] ?? 'India';
    final age = p['age']?.toString() ?? '';
    final style = p['travelStyle'] ?? 'Explorer';
    final bio = p['bio'] ?? '';
    final interests = List<String>.from(p['interests'] ?? []);
    final rating = (p['rating'] as num?)?.toStringAsFixed(1) ?? '4.8';

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: c.border)),
                    child: Icon(Icons.arrow_back_rounded, color: c.text, size: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Companion', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
                const Spacer(),
                Text('⚑', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          if (_loading)
            Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Avatar ──
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(colors: [Color(0xFF2A3828), Color(0xFF1A2A1E)]),
                        border: Border.all(color: c.primaryMid, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(name.isNotEmpty ? '🧑‍💻' : '👤', style: const TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 14),

                    // ── Name ──
                    Text(name, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
                    const SizedBox(height: 4),
                    Text('📍 $city${age.isNotEmpty ? ' · ${age}y' : ''} · $style', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
                    const SizedBox(height: 10),

                    // ── Match Badge ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.primaryMid)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('94%', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.primary)),
                        const SizedBox(width: 6),
                        Text('Match Score', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // ── About ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('About', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: c.muted)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                          child: Text(
                            bio.isNotEmpty ? bio : 'Full-time traveler, part-time photographer. Love meeting new people on mountain trails.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // ── Tags ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(spacing: 6, runSpacing: 6, children: [
                        if (interests.isNotEmpty)
                          ...interests.map((i) => _Tag(label: i, color: c.primary, bg: c.primarySoft))
                        else ...[
                          _Tag(label: 'Adventure', color: c.primary, bg: c.primarySoft),
                          _Tag(label: 'Trekking', color: c.primary, bg: c.primarySoft),
                          _Tag(label: 'Budget', color: c.gold, bg: c.goldSoft),
                          _Tag(label: 'Photography', color: c.sage, bg: c.sageSoft),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // ── Stats ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
                      child: Row(children: [
                        _Stat(value: '23', label: 'Trips', color: c.primary),
                        _Stat(value: '$rating★', label: 'Rating', color: c.sage, divider: true),
                        _Stat(value: '48', label: 'Companions', color: c.gold, divider: true),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // ── Trust Score ──
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                      child: Row(children: [
                        const Text('🛡️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Trust Score: $rating', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)),
                          const SizedBox(height: 4),
                          Row(children: [
                            _TrustChip(label: '✓ Verified', color: c.sage, bg: c.sageSoft),
                            const SizedBox(width: 4),
                            _TrustChip(label: '🪪 ID', color: c.lavender, bg: c.lavenderSoft),
                          ]),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // ── Upcoming Trips ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Upcoming Trips', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: c.muted)),
                        const SizedBox(height: 8),
                        _TripCard(emoji: '🏔️', name: 'Spiti Valley', detail: 'May 12–18 · Looking for 2 more', c: c),
                        const SizedBox(height: 8),
                        _TripCard(emoji: '🏕️', name: 'Kasol–Kheerganga', detail: 'Jun 5–8 · Open to companions', c: c),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

          // ── Bottom Actions ──
          Container(
            padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: _requestSent ? null : _sendRequest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: _requestSent ? c.sage : c.primary, borderRadius: BorderRadius.circular(16), boxShadow: [if (!_requestSent) BoxShadow(color: const Color(0x30FF6B4A), blurRadius: 16)]),
                    child: Center(child: Text(_requestSent ? '✓ Request Sent' : '🤝 Send Companion Request', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 56, height: 48,
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.primaryMid, width: 2)),
                child: const Center(child: Text('💬', style: TextStyle(fontSize: 20))),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label; final Color color, bg;
  const _Tag({required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );
}

class _Stat extends StatelessWidget {
  final String value, label; final Color color; final bool divider;
  const _Stat({required this.value, required this.label, required this.color, this.divider = false});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: divider ? BoxDecoration(border: Border(left: BorderSide(color: c.border))) : null,
      child: Column(children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
      ]),
    ));
  }
}

class _TrustChip extends StatelessWidget {
  final String label; final Color color, bg;
  const _TrustChip({required this.label, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
  );
}

class _TripCard extends StatelessWidget {
  final String emoji, name, detail; final ZussGoColors c;
  const _TripCard({required this.emoji, required this.name, required this.detail, required this.c});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)),
        const SizedBox(height: 2),
        Text(detail, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
      ])),
      Text('›', style: GoogleFonts.outfit(fontSize: 16, color: c.primary)),
    ]),
  );
}