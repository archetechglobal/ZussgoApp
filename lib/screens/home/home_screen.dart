import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/destination_data.dart';
import '../../services/weather_service.dart';
import 'post_status_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _travelers = [];
  List<Map<String, dynamic>> _events = [];
  Map<String, Map<String, dynamic>> _weatherData = {};
  List<Map<String, dynamic>> _peakDestinations = [];
  int _currentPeakIndex = 0;
  Timer? _peakTimer;
  bool _isLoading = true;
  String _selectedCat = 'All';
  final _cats = ['All', 'Beach', 'Mountain', 'Spiritual', 'Culture', 'Adventure'];

  @override
  void initState() {
    super.initState();
    _loadAll();
    _connectWs();
  }

  @override
  void dispose() {
    _peakTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final user = await AuthService.getSavedUser();
    if (user != null) _userName = user['fullName'] ?? 'Traveler';

    final destR = await ApiService.getDestinations();
    final userId = user?['userId'];
    Map<String, dynamic>? travR;
    if (userId != null) travR = await AuthService.getUsers(userId: userId);

    final eventsR = await DestinationData.getUpcomingEvents();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (destR["success"] == true) _destinations = List<Map<String, dynamic>>.from(destR["data"] ?? []);
        if (travR != null && travR["success"] == true) _travelers = List<Map<String, dynamic>>.from(travR["data"] ?? []);
        _events = eventsR;

        // Build peak destinations list
        final peakSlugs = DestinationData.getPeakDestinations();
        _peakDestinations = _destinations.where((d) => peakSlugs.contains(d['slug']?.toString() ?? '')).toList();
      });

      _startPeakRotation();
      _loadWeather();
    }
  }

  void _startPeakRotation() {
    _peakTimer?.cancel();
    if (_peakDestinations.length <= 1) return;
    _peakTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() => _currentPeakIndex = (_currentPeakIndex + 1) % _peakDestinations.length);
    });
  }

  Future<void> _loadWeather() async {
    final slugs = _destinations.map((d) => d['slug']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    if (slugs.isEmpty) return;
    final toFetch = slugs.length > 6 ? slugs.sublist(0, 6) : slugs;
    final weather = await WeatherService.getWeatherBatch(toFetch);
    if (mounted) setState(() => _weatherData = weather);
  }

  Future<void> _connectWs() async {
    final user = await AuthService.getSavedUser();
    if (user?['userId'] != null) ChatService.connect(user!['userId']);
  }

  String get _firstName => _userName.split(' ').first;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getCat(String? name) {
    const beach = ['Goa', 'Andaman', 'Gokarna', 'Pondicherry'];
    const mount = ['Manali', 'Ladakh', 'Spiti Valley', 'Shimla', 'Kasol', 'Dharamshala', 'Munnar', 'Coorg', 'Darjeeling'];
    const culture = ['Jaipur', 'Varanasi', 'Udaipur', 'Hampi', 'Pushkar'];
    const spirit = ['Rishikesh'];
    if (beach.contains(name)) return 'Beach';
    if (mount.contains(name)) return 'Mountain';
    if (culture.contains(name)) return 'Culture';
    if (spirit.contains(name)) return 'Spiritual';
    return 'Adventure';
  }

  List<Map<String, dynamic>> get _filtered =>
      _selectedCat == 'All' ? _destinations : _destinations.where((d) => _getCat(d['name']) == _selectedCat).toList();

  LinearGradient _dg(int i) {
    const gs = [
      LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF22D3EE)]),
      LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
      LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]),
      LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
      LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFF472B6)]),
    ];
    return gs[i % gs.length];
  }

  Color _tc(int i) {
    const cs = [ZussGoTheme.green, ZussGoTheme.sky, ZussGoTheme.amber, ZussGoTheme.rose, ZussGoTheme.lavender];
    return cs[i % cs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_greeting, style: ZussGoTheme.bodySmall),
                            Text('$_firstName 👋', style: ZussGoTheme.displayMedium),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/search'),
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.search_rounded, color: ZussGoTheme.textMuted, size: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.push('/settings'),
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)),
                                alignment: Alignment.center,
                                child: Text(
                                  _firstName.isNotEmpty ? _firstName[0] : 'Z',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Playfair Display'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── CATEGORIES ──
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault, width: 1.5))),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: _cats.map((c) {
                          final active = c == _selectedCat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCat = c),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 8, right: 20),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? ZussGoTheme.textPrimary : Colors.transparent, width: 1.5))),
                              child: Text(c, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? ZussGoTheme.textPrimary : ZussGoTheme.textMuted)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // ── HOT DESTINATIONS ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text('Hot Destinations', style: ZussGoTheme.displaySmall),
                          const SizedBox(width: 4),
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                        ]),
                        GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Text('See all', style: TextStyle(fontSize: 12, color: ZussGoTheme.green, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  if (_isLoading)
                    const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))),

                  if (!_isLoading)
                    SizedBox(
                      height: 195,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        itemCount: _filtered.length > 6 ? 6 : _filtered.length,
                        itemBuilder: (_, i) {
                          final d = _filtered[i];
                          final slug = d['slug']?.toString() ?? '';
                          final isPeak = DestinationData.isPeakNow(slug);
                          final w = _weatherData[slug];
                          final temp = w?['temp'] ?? '--';
                          final wIcon = w?['icon'] ?? '🌤️';

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => context.push('/destination/$slug'),
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  gradient: _dg(i),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: Stack(
                                  children: [
                                    Center(child: Opacity(opacity: 0.12, child: Text(d['emoji'] ?? '🌍', style: const TextStyle(fontSize: 60)))),
                                    if (isPeak)
                                      Positioned(
                                        top: 8, left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xE6E85D75), borderRadius: BorderRadius.circular(5)),
                                          child: const Text('🔥 Peak', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                                        ),
                                      ),
                                    Positioned(
                                      top: 8, right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(5)),
                                        child: Text('⭐ 4.${8 - (i % 3)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0, left: 0, right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)]),
                                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(d['name'] ?? '', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)),
                                                      const SizedBox(width: 3),
                                                      Text('${d['travelerCount'] ?? 0} going', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9))),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                                  child: Text('$temp°C $wIcon', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9))),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // ── ROTATING PEAK SEASON BANNER ──
                  if (!_isLoading && _peakDestinations.isNotEmpty)
                    _buildPeakBanner(),

                  // ── PEOPLE HEADING OUT (max 3 + see all) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('People Heading Out', style: ZussGoTheme.displaySmall),
                        GestureDetector(
                          onTap: () => context.push('/see-all-travelers'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('See all →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ZussGoTheme.green)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!_isLoading && _travelers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
                        width: double.infinity, padding: const EdgeInsets.all(24),
                        decoration: ZussGoTheme.cardDecoration,
                        child: Column(
                          children: [
                            const Text('🌍', style: TextStyle(fontSize: 32)),
                            const SizedBox(height: 10),
                            Text('No travelers yet', style: ZussGoTheme.displaySmall),
                            const SizedBox(height: 4),
                            Text('Be the first! Plan a trip.', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),

                  if (!_isLoading && _travelers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: List.generate(
                          _travelers.length > 3 ? 3 : _travelers.length,
                              (i) {
                            final t = _travelers[i];
                            return GestureDetector(
                              onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: ZussGoTheme.glassCard,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(color: _tc(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                                      alignment: Alignment.center,
                                      child: Text((t['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _tc(i), fontFamily: 'Playfair Display')),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(t['fullName'] ?? 'Unknown', style: ZussGoTheme.labelBold.copyWith(fontSize: 13)),
                                          Text('${t['city'] ?? 'Explorer'} • ${t['travelStyle'] ?? 'Adventurer'}', style: ZussGoTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(8)),
                                      child: Text('View', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ZussGoTheme.green)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  if (!_isLoading && _travelers.length > 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: GestureDetector(
                        onTap: () => context.push('/see-all-travelers'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: ZussGoTheme.borderDefault), borderRadius: BorderRadius.circular(14)),
                          child: Center(child: Text('View all ${_travelers.length} travelers →', style: TextStyle(fontSize: 12, color: ZussGoTheme.green, fontWeight: FontWeight.w600))),
                        ),
                      ),
                    ),

                  // ── EVENTS & FESTIVALS ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Events & Festivals 🎉', style: ZussGoTheme.displaySmall),
                        GestureDetector(
                          onTap: () => context.push('/see-all-events'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('See all →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ZussGoTheme.green)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_events.isEmpty && !_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: ZussGoTheme.glassCard,
                        child: Center(child: Text('No upcoming events', style: ZussGoTheme.bodySmall)),
                      ),
                    ),

                  if (_events.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        itemCount: _events.length > 5 ? 5 : _events.length,
                        itemBuilder: (_, i) {
                          final e = _events[i];
                          return Container(
                            width: 165,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28, height: 28,
                                      decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                                      alignment: Alignment.center,
                                      child: Text(e['emoji'] ?? '🎉', style: const TextStyle(fontSize: 14)),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(e['name'] ?? '', style: ZussGoTheme.labelBold.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text('${e['destination'] ?? ''} • ${e['dates'] ?? ''}', style: ZussGoTheme.bodySmall.copyWith(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(6)),
                                  child: Text('${e['emoji'] ?? ''} ${e['tag'] ?? 'Event'}', style: const TextStyle(fontSize: 9, color: ZussGoTheme.textMuted)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // ── YOUR STATUS ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Status', style: ZussGoTheme.displaySmall),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                              builder: (_) => const PostStatusSheet(),
                            );
                            if (result == true) _loadAll(); // refresh after posting
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: ZussGoTheme.borderDefault), borderRadius: BorderRadius.circular(14)),
                            child: Center(child: Text('+ Post where you\'re going', style: TextStyle(fontSize: 13, color: ZussGoTheme.green, fontWeight: FontWeight.w600))),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── QUOTE ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: ZussGoTheme.green.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Text(
                          '"The world is a book and those who do not travel read only one page."',
                          style: TextStyle(fontFamily: 'Playfair Display', fontSize: 14, fontStyle: FontStyle.italic, color: ZussGoTheme.textPrimary, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text('— Saint Augustine', style: ZussGoTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: ZussGoBottomNav(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  // ── PEAK BANNER WIDGET (extracted for cleanliness) ──
  Widget _buildPeakBanner() {
    final d = _peakDestinations[_currentPeakIndex % _peakDestinations.length];
    final slug = d['slug']?.toString() ?? '';
    final w = _weatherData[slug];
    final temp = w?['temp'] ?? '--';
    final wIcon = w?['icon'] ?? '🌤️';
    final peakLabel = DestinationData.getPeakLabel(slug);
    final bestLabel = DestinationData.getBestMonthsLabel(slug);
    final dotCount = _peakDestinations.length > 5 ? 5 : _peakDestinations.length;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: GestureDetector(
        key: ValueKey(_currentPeakIndex),
        onTap: () => context.push('/destination/$slug'),
        child: Container(
          margin: const EdgeInsets.fromLTRB(22, 12, 22, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ZussGoTheme.amber.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$wIcon BEST TO VISIT NOW', style: TextStyle(fontSize: 10, color: ZussGoTheme.amber, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${d['name']} — $peakLabel', style: ZussGoTheme.labelBold),
                        Text('Best: $bestLabel • ${temp}°C', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(wIcon.toString(), style: const TextStyle(fontSize: 28)),
                      Text('$temp°C', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ZussGoTheme.amber)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(dotCount, (i) {
                  final isActive = i == (_currentPeakIndex % dotCount);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: isActive ? 16 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive ? ZussGoTheme.amber : ZussGoTheme.borderDefault,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}