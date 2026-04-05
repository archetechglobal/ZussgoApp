import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/destination_data.dart';
import '../../services/destination_images.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
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
        if (destR['success'] == true) _destinations = List<Map<String, dynamic>>.from(destR['data'] ?? []);
        if (travR != null && travR['success'] == true) _travelers = List<Map<String, dynamic>>.from(travR['data'] ?? []);
        _events = eventsR;
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

  Color _tc(int i) {
    final cs = [context.colors.green, context.colors.sky, context.colors.amber, context.colors.rose, ZussGoTheme.lavender];
    return cs[i % cs.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgPage = ZussGoTheme.scaffoldBg(context);
    final bgCard = ZussGoTheme.cardBg(context);
    final bgMuted = ZussGoTheme.mutedBg(context);
    final borderCol = ZussGoTheme.border(context);
    final textPri = ZussGoTheme.primaryText(context);
    final textMut = ZussGoTheme.mutedText(context);
    final textSec = ZussGoTheme.secondaryText(context);

    return Scaffold(
      backgroundColor: bgPage,
      body: Stack(
        fit: StackFit.expand,
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
                            Text(_greeting, style: context.textTheme.bodySmall!.copyWith(color: textMut)),
                            Text('$_firstName', style: context.textTheme.displayMedium!.copyWith(color: textPri)),
                          ],
                        ),
                        Row(
                          children: [
                            _ModernThemeToggle(
                              isDark: isDark,
                              onToggle: () => context.read<ThemeService>().toggle(),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.push('/search'),
                              child: Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(color: bgMuted, borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.search_rounded, color: textMut, size: 20),
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
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderCol, width: 1.5))),
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
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? textPri : Colors.transparent, width: 1.5))),
                              child: Text(c, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? textPri : textMut)),
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
                          Text('Hot Destinations', style: context.textTheme.displaySmall!.copyWith(color: textPri)),
                          const SizedBox(width: 4),
                          Icon(Icons.local_fire_department_rounded, size: 16, color: context.colors.rose),
                        ]),
                        GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Text('See all', style: TextStyle(fontSize: 12, color: context.colors.green, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),

                  if (_isLoading)
                    SizedBox(height: 180, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))),

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
                          final imageUrl = DestinationImages.getImageFromData(d);

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => context.push('/destination/$slug'),
                              child: Container(
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      if (imageUrl != null)
                                        Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              color: bgCard,
                                              child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 1.5, color: context.colors.green.withValues(alpha: 0.4)))),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: bgMuted,
                                              child: Center(child: Icon(Icons.landscape_rounded, size: 36, color: ZussGoTheme.mutedText(context).withValues(alpha: 0.4))),
                                            );
                                          },
                                        )
                                      else
                                        Container(
                                          color: bgMuted,
                                          child: Center(child: Icon(Icons.landscape_rounded, size: 36, color: ZussGoTheme.mutedText(context).withValues(alpha: 0.4))),
                                        ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                                            stops: const [0.3, 1.0],
                                          ),
                                        ),
                                      ),
                                      if (isPeak)
                                        Positioned(
                                          top: 8, left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(color: const Color(0xE6E85D75), borderRadius: BorderRadius.circular(6)),
                                            child: const Text('Peak', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 0, left: 0, right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
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
                                                        Container(width: 4, height: 4, decoration: BoxDecoration(color: context.colors.mint, shape: BoxShape.circle)),
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
                            ),
                          );
                        },
                      ),
                    ),

                  // ── PEAK BANNER ──
                  if (!_isLoading && _peakDestinations.isNotEmpty) _buildPeakBanner(isDark: isDark, bgMuted: bgMuted),

                  // ── PEOPLE HEADING OUT ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('People Heading Out', style: context.textTheme.displaySmall!.copyWith(color: textPri)),
                        GestureDetector(
                          onTap: () => context.push('/see-all-travelers'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('See all →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.green)),
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
                        decoration: ZussGoTheme.cardDecoration(context),
                        child: Column(children: [
                          Icon(Icons.travel_explore_rounded, size: 38, color: textMut.withValues(alpha: 0.4)),
                          const SizedBox(height: 10),
                          Text('No travelers yet', style: context.textTheme.displaySmall!.copyWith(color: textPri)),
                          const SizedBox(height: 4),
                          Text('Be the first! Plan a trip.', style: context.textTheme.bodySmall!.copyWith(color: textMut), textAlign: TextAlign.center),
                        ]),
                      ),
                    ),

                  if (!_isLoading && _travelers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: List.generate(_travelers.length > 3 ? 3 : _travelers.length, (i) {
                          final t = _travelers[i];
                          return GestureDetector(
                            onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: ZussGoTheme.glassCardDecoration(context),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: _tc(i).withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(12)),
                                    alignment: Alignment.center,
                                    child: Text((t['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _tc(i), fontFamily: 'Playfair Display')),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t['fullName'] ?? 'Unknown', style: context.textTheme.labelLarge!.copyWith(fontSize: 13, color: textPri)),
                                        Text('${t['city'] ?? 'Explorer'} • ${t['travelStyle'] ?? 'Adventurer'}', style: context.textTheme.bodySmall!.copyWith(color: textMut)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(8)),
                                    child: Text('View', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.green)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                  // ── EVENTS ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Events & Festivals', style: context.textTheme.displaySmall!.copyWith(color: textPri)),
                        GestureDetector(
                          onTap: () => context.push('/see-all-events'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(8)),
                            child: Text('See all →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.colors.green)),
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
                        decoration: ZussGoTheme.glassCardDecoration(context),
                        child: Center(child: Text('No upcoming events', style: context.textTheme.bodySmall!.copyWith(color: textMut))),
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
                              color: bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderCol),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(color: context.colors.rose.withValues(alpha: isDark ? 0.2 : 0.08), borderRadius: BorderRadius.circular(8)),
                                    alignment: Alignment.center,
                                    child: Icon(Icons.celebration_rounded, size: 14, color: context.colors.rose),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(e['name'] ?? '', style: context.textTheme.labelLarge!.copyWith(fontSize: 11, color: textPri), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text('${e['destination'] ?? ''} • ${e['dates'] ?? ''}', style: context.textTheme.bodySmall!.copyWith(fontSize: 9, color: textMut), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ]),
                                  ),
                                ]),
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
                        Text('Your Status', style: context.textTheme.displaySmall!.copyWith(color: textPri)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final result = await showModalBottomSheet<bool>(
                              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                              builder: (_) => const PostStatusSheet(),
                            );
                            if (result == true) _loadAll();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: borderCol), borderRadius: BorderRadius.circular(14)),
                            child: Center(child: Text('+ Post where you\'re going', style: TextStyle(fontSize: 13, color: context.colors.green, fontWeight: FontWeight.w600))),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── QUOTE ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.green.withValues(alpha: isDark ? 0.08 : 0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(children: [
                      Text(
                        '"The world is a book and those who do not travel read only one page."',
                        style: TextStyle(fontFamily: 'Playfair Display', fontSize: 14, fontStyle: FontStyle.italic, color: textPri, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text('— Saint Augustine', style: context.textTheme.bodySmall!.copyWith(color: textMut)),
                    ]),
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

  Widget _buildPeakBanner({required bool isDark, required Color bgMuted}) {
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
      child: GestureDetector(
        key: ValueKey(_currentPeakIndex),
        onTap: () => context.push('/destination/$slug'),
        child: Container(
          margin: const EdgeInsets.fromLTRB(22, 12, 22, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.amber.withValues(alpha: isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.amber.withValues(alpha: isDark ? 0.15 : 0.08)),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$wIcon BEST TO VISIT NOW', style: TextStyle(fontSize: 10, color: context.colors.amber, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${d['name']} — $peakLabel', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.primaryText(context))),
                    Text('Best: $bestLabel • ${temp}°C', style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.secondaryText(context))),
                  ]),
                ),
                Column(children: [
                  Text(wIcon.toString(), style: const TextStyle(fontSize: 28)),
                  Text('$temp°C', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.amber)),
                ]),
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
                    color: isActive ? context.colors.amber : ZussGoTheme.border(context),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── MODERN THEME TOGGLE ──
class _ModernThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;
  const _ModernThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5EDEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFCFE1DC), width: 1.5),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              key: ValueKey<bool>(isDark),
              size: 20,
              color: context.colors.amber,
            ),
          ),
        ),
      ),
    );
  }
}