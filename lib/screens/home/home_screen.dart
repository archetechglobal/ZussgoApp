import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String? _profilePhoto;
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _travelers = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadAll(); _connectWs(); }

  Future<void> _loadAll() async {
    final user = await AuthService.getSavedUser();
    if (user != null) {
      _userName = user['fullName'] ?? 'Traveler';
      _profilePhoto = user['profilePhotoUrl'];
    }
    final destR = await ApiService.getDestinations();
    final userId = user?['userId'];
    Map<String, dynamic>? travR;
    if (userId != null) {
      travR = await AuthService.getUsers(userId: userId);
      // Load pending companion requests
      final reqR = await ApiService.getPendingRequests(userId);
      if (reqR['success'] == true) _pendingRequests = List<Map<String, dynamic>>.from(reqR['data'] ?? []);
    }
    if (mounted) setState(() {
      _isLoading = false;
      if (destR['success'] == true) _destinations = List<Map<String, dynamic>>.from(destR['data'] ?? []);
      if (travR != null && travR['success'] == true) _travelers = List<Map<String, dynamic>>.from(travR['data'] ?? []);
    });
  }

  Future<void> _connectWs() async {
    final user = await AuthService.getSavedUser();
    if (user?['userId'] != null) ChatService.connect(user!['userId']);
  }

  Future<void> _acceptRequest(String requestId) async {
    final user = await AuthService.getSavedUser();
    if (user?['userId'] == null) return;
    final r = await ApiService.acceptMatchRequest(requestId, user!['userId']);
    if (r['success'] == true) _loadAll();
  }

  String get _firstName => _userName.split(' ').first;
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

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
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -1), radius: 1.5, colors: [Color(0x08FF6B4A), Colors.transparent])),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_greeting, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.text), children: [
                            const TextSpan(text: 'Hey, '),
                            TextSpan(text: _firstName, style: TextStyle(color: c.primary)),
                          ])),
                        ]),
                        GestureDetector(
                          onTap: () => context.go('/settings'),
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(colors: [c.primary, const Color(0xFFFF8A65)]),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: _profilePhoto != null
                                ? Image.network(_profilePhoto!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(_firstName.isNotEmpty ? _firstName[0] : 'Z', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))))
                                : Center(child: Text(_firstName.isNotEmpty ? _firstName[0] : 'Z', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Search bar
                      GestureDetector(
                        onTap: () => context.go('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
                          child: Row(children: [
                            Text('🔍', style: TextStyle(fontSize: 16, color: c.muted.withValues(alpha: 0.4))),
                            const SizedBox(width: 10),
                            Text('Where are you headed?', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.muted)),
                          ]),
                        ),
                      ),
                    ]),
                  ),

                  // ── COMPANION REQUESTS ──
                  if (_pendingRequests.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('New Companion Requests', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                        const Spacer(),
                        Text('${_pendingRequests.length}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: c.primary)),
                      ]),
                    ),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _pendingRequests.length,
                        itemBuilder: (_, i) {
                          final req = _pendingRequests[i];
                          final sender = req['sender'] ?? {};
                          return Container(
                            width: 280, margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(colors: [c.primarySoft, c.card]),
                            ),
                            child: Row(children: [
                              _UserAvatar(photoUrl: sender['profilePhotoUrl'], name: sender['fullName'] ?? 'User', size: 48),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(sender['fullName'] ?? 'Traveler', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
                                Text('${sender['city'] ?? 'India'} · ${sender['travelStyle'] ?? ''}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
                              ])),
                              GestureDetector(
                                onTap: () => _acceptRequest(req['id']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(10)),
                                  child: Text('Accept', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                                ),
                              ),
                            ]),
                          );
                        },
                      ),
                    ),
                  ],

                  // ── COMPANIONS CAROUSEL (photo cards) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Companions', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                      GestureDetector(
                        onTap: () => context.push('/see-all-travelers'),
                        child: Text('See All →', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
                      ),
                    ]),
                  ),

                  if (_isLoading)
                    SizedBox(height: 220, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),

                  if (!_isLoading && _travelers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 200, width: double.infinity,
                        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('🗺️', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 10),
                          Text('No companions yet', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: c.text)),
                          const SizedBox(height: 4),
                          Text('Explore destinations to find travelers', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
                        ]),
                      ),
                    ),

                  // Photo carousel cards
                  if (!_isLoading && _travelers.isNotEmpty)
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _travelers.length > 8 ? 8 : _travelers.length,
                        itemBuilder: (_, i) {
                          final t = _travelers[i];
                          final name = t['fullName'] ?? 'Traveler';
                          final age = t['age']?.toString() ?? '';
                          final city = t['city'] ?? 'India';
                          final style = t['travelStyle'] ?? 'Explorer';
                          final photo = t['profilePhotoUrl'];
                          final matchScore = 94 - (i * 4);

                          return GestureDetector(
                            onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
                            child: Container(
                              width: 170, margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: c.card,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(children: [
                                // Photo area (60-70% of card)
                                Positioned.fill(
                                  child: photo != null
                                      ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _PlaceholderPhoto(name: name, index: i))
                                      : _PlaceholderPhoto(name: name, index: i),
                                ),
                                // Gradient overlay
                                Positioned.fill(child: Container(
                                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.85)], stops: const [0.0, 0.45, 1.0])),
                                )),
                                // Match badge
                                Positioned(top: 12, right: 12, child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8)),
                                  child: Text('$matchScore%', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                                )),
                                // User info at bottom
                                Positioned(bottom: 0, left: 0, right: 0, child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text('${age.isNotEmpty ? '$age · ' : ''}$city', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                      child: Text(style, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9))),
                                    ),
                                  ]),
                                )),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),

                  // Browse Companions CTA
                  if (!_isLoading && _travelers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: GestureDetector(
                        onTap: () => context.go('/search'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text('Browse All Companions →', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: c.primary))),
                        ),
                      ),
                    ),

                  // ── TRENDING DESTINATIONS ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Trending Now', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                      GestureDetector(onTap: () => context.go('/search'), child: Text('Explore →', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary))),
                    ]),
                  ),

                  SizedBox(
                    height: 56,
                    child: _isLoading ? const SizedBox() : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _destinations.length > 6 ? 6 : _destinations.length,
                      itemBuilder: (_, i) {
                        final d = _destinations[i];
                        return GestureDetector(
                          onTap: () => context.push('/destination/${d['slug']}'),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14)),
                            child: Row(children: [
                              Text(d['emoji'] ?? '🗺️', style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(d['name'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: c.text)),
                                Text('${d['travelerCount'] ?? 0} active', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
                              ]),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 0)),
        ],
      ),
    );
  }
}

// Reusable user avatar with photo support
class _UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  const _UserAvatar({this.photoUrl, required this.name, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.35),
        gradient: LinearGradient(colors: [c.primary, const Color(0xFFFF8A65)]),
      ),
      clipBehavior: Clip.hardEdge,
      child: photoUrl != null
          ? Image.network(photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initial(c))
          : _initial(c),
    );
  }

  Widget _initial(ZussGoColors c) => Center(
    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'Z', style: GoogleFonts.outfit(fontSize: size * 0.4, fontWeight: FontWeight.w800, color: Colors.white)),
  );
}

// Placeholder gradient photo for users without profile photos
class _PlaceholderPhoto extends StatelessWidget {
  final String name;
  final int index;
  const _PlaceholderPhoto({required this.name, required this.index});

  static const _gradients = [
    [Color(0xFF2A3828), Color(0xFF1A2A1E)],
    [Color(0xFF382A1A), Color(0xFF2A1E10)],
    [Color(0xFF28203A), Color(0xFF1E1830)],
    [Color(0xFF2A1828), Color(0xFF1E1420)],
    [Color(0xFF1A2838), Color(0xFF101E28)],
  ];

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[index % _gradients.length];
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad)),
      child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white.withValues(alpha: 0.15)))),
    );
  }
}