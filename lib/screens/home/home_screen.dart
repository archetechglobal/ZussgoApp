import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/traveler_card.dart';
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
  String _userInitial = '';
  List<Map<String, dynamic>> _travelers = [];
  List<Map<String, dynamic>> _destinations = [];
  bool _isLoadingUsers = true;
  bool _isLoadingDestinations = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTravelers();
    _loadDestinations();
    _connectWebSocket();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getSavedUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user['fullName'] ?? 'Traveler';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Z';
      });
    }
  }

  Future<void> _loadTravelers() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() => _isLoadingUsers = false); return; }

    final result = await AuthService.getUsers(userId: userId);
    if (mounted) {
      setState(() {
        _isLoadingUsers = false;
        if (result["success"] == true && result["data"] != null) {
          _travelers = List<Map<String, dynamic>>.from(result["data"]);
        }
      });
    }
  }

  Future<void> _loadDestinations() async {
    final result = await ApiService.getDestinations();
    if (mounted) {
      setState(() {
        _isLoadingDestinations = false;
        if (result["success"] == true && result["data"] != null) {
          _destinations = List<Map<String, dynamic>>.from(result["data"]);
        }
      });
    }
  }

  Future<void> _connectWebSocket() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId != null) {
      ChatService.connect(userId);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName {
    final parts = _userName.split(' ');
    return parts.isNotEmpty ? parts[0] : 'Traveler';
  }

  Color _travelerColor(int index) {
    final colors = [ZussGoTheme.rose, ZussGoTheme.sky, ZussGoTheme.sage, ZussGoTheme.lavender, ZussGoTheme.amber];
    return colors[index % colors.length];
  }

  LinearGradient _destGradient(int index) {
    final gradients = [
      const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)]),
      const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFFA78BFA)]),
      const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFF59E0B)]),
      const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF38BDF8)]),
      const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFF43F5E)]),
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting, style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w300)),
                            Text('$_firstName ✨', style: ZussGoTheme.displayMedium),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center,
                            child: Text(_userInitial, style: ZussGoTheme.labelBold.copyWith(fontSize: 16, fontFamily: 'Playfair Display')),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZussGoTheme.borderDefault)),
                        child: Row(children: [
                          Icon(Icons.search_rounded, color: ZussGoTheme.textMuted.withValues(alpha: 0.5), size: 20),
                          const SizedBox(width: 10),
                          Text("Where's your next escape?", style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted, fontWeight: FontWeight.w300)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── TRENDING DESTINATIONS (from database) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trending Escapes', style: ZussGoTheme.displaySmall),
                        GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Text('View all', style: TextStyle(fontSize: 13, color: ZussGoTheme.amber, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_isLoadingDestinations)
                    SizedBox(
                      height: 195,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5))),
                    ),

                  if (!_isLoadingDestinations && _destinations.isNotEmpty)
                    SizedBox(
                      height: 195,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _destinations.length > 6 ? 6 : _destinations.length,
                        itemBuilder: (context, i) {
                          final d = _destinations[i];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => context.push('/destination/${d['slug']}'),
                              child: Container(
                                width: 155,
                                height: 195,
                                decoration: BoxDecoration(gradient: _destGradient(i), borderRadius: BorderRadius.circular(24)),
                                child: Stack(children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x8C000000)], stops: [0.2, 1.0]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(d['emoji'] ?? '🌍', style: const TextStyle(fontSize: 32)),
                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(d['name'] ?? '', style: ZussGoTheme.labelBold.copyWith(fontSize: 16)),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                                              Container(width: 5, height: 5, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)),
                                              const SizedBox(width: 4),
                                              Text('${d['travelerCount'] ?? 0} going', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
                                            ]),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 28),

                  // ── PEOPLE HEADING OUT ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('People Heading Out', style: ZussGoTheme.displaySmall),
                      const SizedBox(height: 4),
                      Text('Real travelers on the platform', style: ZussGoTheme.bodySmall),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  if (_isLoadingUsers)
                    Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5)))),

                  if (!_isLoadingUsers && _travelers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: ZussGoTheme.borderDefault)),
                        child: Column(children: [
                          const Text('🌍', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          Text('No travelers yet', style: ZussGoTheme.labelBold),
                          const SizedBox(height: 4),
                          Text('You\'re one of the first! Invite friends to join ZussGo.', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                        ]),
                      ),
                    ),

                  if (!_isLoadingUsers && _travelers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: List.generate(_travelers.length, (index) {
                          final t = _travelers[index];
                          return TravelerCard(
                            id: t['id'] ?? '', name: t['fullName'] ?? 'Unknown', age: t['age'] ?? 0,
                            destination: t['city'] ?? 'Exploring', dates: 'Open dates',
                            travelStyle: t['travelStyle'] ?? 'Explorer', avatar: (t['fullName'] ?? 'U')[0],
                            matchPercent: '—', accentColor: _travelerColor(index),
                          );
                        }),
                      ),
                    ),
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