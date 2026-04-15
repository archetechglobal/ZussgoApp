import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  final bool isGroup;
  const TripDetailScreen({super.key, required this.tripId, this.isGroup = false});
  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Map<String, dynamic>? _trip;
  bool _loading = true;
  bool _joining = false;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await AuthService.getSavedUser();
    _myUserId = me?['userId'];

    try {
      if (widget.isGroup) {
        final r = await http.get(Uri.parse('${ApiConfig.baseUrl}/groups/${widget.tripId}'), headers: {'Content-Type': 'application/json'});
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body);
          if (data['success'] == true) _trip = data['data'];
        }
      } else {
        final r = await http.get(Uri.parse(ApiConfig.tripById(widget.tripId)), headers: {'Content-Type': 'application/json'});
        if (r.statusCode == 200) {
          final data = jsonDecode(r.body);
          if (data['success'] == true) _trip = data['data'];
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _joinTrip() async {
    if (_myUserId == null) return;
    setState(() => _joining = true);

    try {
      if (widget.isGroup) {
        await ApiService.joinGroup(widget.tripId, _myUserId!);
      } else {
        // For solo trips, send a match request to the trip owner
        final ownerId = _trip?['userId'] ?? _trip?['user']?['id'];
        if (ownerId != null) {
          await ApiService.sendMatchRequest(userId: _myUserId!, receiverId: ownerId, tripId: widget.tripId);
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _joining = false);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  int _daysBetween(String? start, String? end) {
    if (start == null || end == null) return 0;
    final s = DateTime.tryParse(start);
    final e = DateTime.tryParse(end);
    if (s == null || e == null) return 0;
    return e.difference(s).inDays;
  }

  static const _destEmojis = {
    'Goa': '🌴', 'Varanasi': '🕌', 'Coorg': '🌿', 'Andaman': '🌊', 'Manali': '🏔️',
    'Ladakh': '🏔️', 'Spiti Valley': '🏔️', 'Shimla': '🌲', 'Kasol': '🏕️',
    'Dharamshala': '🛕', 'Rishikesh': '🕉️', 'Jaipur': '🏰', 'Udaipur': '🏰',
    'Munnar': '🌿', 'Hampi': '🏛️', 'Darjeeling': '🍵', 'Pushkar': '🐫',
  };

  static const _avGrads = [
    [Color(0xFF2A3828), Color(0xFF1A2A1E)],
    [Color(0xFF382A1A), Color(0xFF2A1E10)],
    [Color(0xFF28203A), Color(0xFF1E1830)],
  ];
  static const _emojis = ['🧑‍💻', '👩‍🎨', '🧔', '👩', '🧑‍🔬'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: _loading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
          : _trip == null
          ? Center(child: Text('Trip not found', style: GoogleFonts.plusJakartaSans(color: c.muted)))
          : Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: c.border)), child: Icon(Icons.arrow_back_rounded, color: c.text, size: 16)),
              ),
              const SizedBox(width: 10),
              Text('Trip Details', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
              const Spacer(),
              const Text('🔖', style: TextStyle(fontSize: 18)),
            ]),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero ──
                  _buildHero(c),
                  // ── Info Chips ──
                  _buildInfoRow(c),
                  // ── Companions ──
                  _buildCompanions(c),
                  // ── Itinerary ──
                  _buildItinerary(c),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Join CTA ──
          Container(
            padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
            child: GestureDetector(
              onTap: _joining ? null : _joinTrip,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x30FF6B4A), blurRadius: 16)]),
                child: Center(
                  child: _joining
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.isGroup ? '🤝 Request to Join Trip' : '🤝 Send Companion Request', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(ZussGoColors c) {
    final dest = _trip?['destination'] ?? {};
    final destName = dest['name'] ?? _trip?['name'] ?? 'Trip';
    final emoji = _destEmojis[destName] ?? dest['emoji'] ?? '🗺️';
    final state = dest['state'] ?? 'India';

    return Container(
      height: 200, margin: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A1810), Color(0xFF1A1020), Color(0xFF0E0818)])),
      child: Stack(children: [
        Center(child: Opacity(opacity: 0.15, child: Text(emoji, style: const TextStyle(fontSize: 100)))),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, c.surface], stops: const [0.4, 1.0]))),
        Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8)),
              child: Text('🔥 Trending', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
          const SizedBox(height: 8),
          Text(destName, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text('$state, India', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
        ])),
      ]),
    );
  }

  Widget _buildInfoRow(ZussGoColors c) {
    final startDate = _trip?['startDate']?.toString();
    final endDate = _trip?['endDate']?.toString();
    final days = _daysBetween(startDate, endDate);
    final budget = _trip?['budget'] ?? 'Budget';
    final maxMembers = _trip?['maxMembers'] ?? 6;
    final memberCount = (_trip?['memberCount'] ?? _trip?['_count']?['members'] ?? 1) as int;
    final spotsLeft = maxMembers - memberCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        _InfoChip(emoji: '📅', value: '${_formatDate(startDate)}–${_formatDate(endDate)}', label: '$days days', c: c),
        _InfoChip(emoji: '💰', value: budget, label: 'Budget', c: c),
        _InfoChip(emoji: '🌤️', value: '–°C', label: 'Avg temp', c: c),
        _InfoChip(emoji: '👥', value: '$spotsLeft/$maxMembers', label: 'Spots left', c: c),
      ]),
    );
  }

  Widget _buildCompanions(ZussGoColors c) {
    List<Map<String, dynamic>> members = [];

    if (widget.isGroup && _trip?['members'] != null) {
      members = List<Map<String, dynamic>>.from(_trip!['members']);
    } else if (_trip?['user'] != null) {
      members = [{'user': _trip!['user'], 'role': 'CREATOR'}];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Companions Going', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
            Text('Invite →', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
          ]),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: members.length + 1, // +1 for Join button
            itemBuilder: (_, i) {
              if (i == members.length) {
                // Join button
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: c.primaryMid, width: 2, style: BorderStyle.solid)),
                      alignment: Alignment.center,
                      child: Text('+', style: GoogleFonts.outfit(fontSize: 16, color: c.primary)),
                    ),
                    const SizedBox(height: 6),
                    Text('Join', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: c.primary)),
                  ]),
                );
              }

              final member = members[i];
              final user = member['user'] ?? member;
              final isHost = member['role'] == 'CREATOR';
              final grad = _avGrads[i % _avGrads.length];
              final emoji = _emojis[i % _emojis.length];

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: LinearGradient(colors: grad), border: Border.all(color: c.border, width: 2)),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                    if (isHost) Positioned(top: -3, right: -3, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: c.gold, borderRadius: BorderRadius.circular(4)),
                      child: Text('HOST', style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.black)),
                    )),
                  ]),
                  const SizedBox(height: 6),
                  Text((user['fullName'] ?? 'User').split(' ').first, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: c.muted)),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItinerary(ZussGoColors c) {
    // Generate mock itinerary based on trip dates
    final dest = _trip?['destination'] ?? {};
    final destName = dest['name'] ?? 'Destination';
    final days = _daysBetween(_trip?['startDate']?.toString(), _trip?['endDate']?.toString());

    final itinerary = <Map<String, dynamic>>[
      {'day': 1, 'title': 'Arrival at $destName', 'stops': ['Check in & settle', 'Explore nearby area']},
      if (days > 1) {'day': 2, 'title': 'Full Day Exploration', 'stops': ['Visit key attractions', 'Local food experience']},
      if (days > 2) {'day': 3, 'title': 'Adventure Day', 'stops': ['Outdoor activities', 'Evening campfire / social']},
      if (days > 3) {'day': days, 'title': 'Return Journey', 'stops': ['Pack up & checkout', 'Head back home']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Text('Itinerary', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
        ),
        ...itinerary.map((day) => Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(9)),
                alignment: Alignment.center,
                child: Text('${day['day']}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: c.primary)),
              ),
              const SizedBox(width: 10),
              Text(day['title'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
            ]),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Column(
                children: (day['stops'] as List).map<Widget>((stop) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(stop, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary)),
                  ]),
                )).toList(),
              ),
            ),
          ]),
        )),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String emoji, value, label;
  final ZussGoColors c;
  const _InfoChip({required this.emoji, required this.value, required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: c.text)),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
        ]),
      ]),
    );
  }
}