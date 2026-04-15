import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchC = TextEditingController();
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _travelers = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  static const _filters = ['All', '⛰️ Mountains', '🏖️ Beaches', '🕌 Heritage', '🎉 Festivals'];

  static const _catMap = {
    '⛰️ Mountains': ['Manali', 'Ladakh', 'Spiti Valley', 'Shimla', 'Kasol', 'Dharamshala', 'Munnar', 'Coorg', 'Darjeeling'],
    '🏖️ Beaches': ['Goa', 'Andaman', 'Gokarna', 'Pondicherry'],
    '🕌 Heritage': ['Jaipur', 'Varanasi', 'Udaipur', 'Hampi', 'Pushkar'],
    '🎉 Festivals': ['Pushkar', 'Varanasi', 'Jaipur', 'Rishikesh'],
  };

  static const _destEmojis = {
    'Goa': '🌴', 'Varanasi': '🕌', 'Coorg': '🌿', 'Andaman': '🌊',
    'Manali': '🏔️', 'Ladakh': '🏔️', 'Spiti Valley': '🏔️', 'Shimla': '🌲',
    'Kasol': '🏕️', 'Dharamshala': '🛕', 'Rishikesh': '🕉️', 'Jaipur': '🏰',
    'Udaipur': '🏰', 'Munnar': '🌿', 'Hampi': '🏛️', 'Darjeeling': '🍵',
  };

  static const _destGrads = [
    [Color(0xFF2A1E0A), Color(0xFF1A1008)],
    [Color(0xFF1A1028), Color(0xFF100820)],
    [Color(0xFF0E1A10), Color(0xFF081008)],
    [Color(0xFF2A0A18), Color(0xFF180810)],
  ];

  static const _avGrads = [
    [Color(0xFF2A3828), Color(0xFF1A2A1E)],
    [Color(0xFF2A1828), Color(0xFF1E1420)],
    [Color(0xFF28203A), Color(0xFF1E1830)],
  ];
  static const _emojis = ['🧑‍💻', '👩', '🧔'];

  @override
  void initState() {
    super.initState();
    _searchC.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _searchC.removeListener(_onSearchChanged);
    _searchC.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchC.text.trim().toLowerCase();
    if (q.isEmpty) {
      _applyFilter();
    } else {
      setState(() {
        _filtered = _destinations.where((d) {
          final name = (d['name'] ?? '').toString().toLowerCase();
          final state = (d['state'] ?? '').toString().toLowerCase();
          return name.contains(q) || state.contains(q);
        }).toList();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filtered = List.from(_destinations);
      } else {
        final names = _catMap[_selectedFilter] ?? [];
        _filtered = _destinations.where((d) => names.contains(d['name'])).toList();
      }
    });
  }

  Future<void> _load() async {
    final r = await ApiService.getDestinations();
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    Map<String, dynamic>? travR;
    if (userId != null) travR = await AuthService.getUsers(userId: userId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (r['success'] == true && r['data'] != null) {
          _destinations = List<Map<String, dynamic>>.from(r['data']);
          _filtered = List.from(_destinations);
        }
        if (travR != null && travR['success'] == true) {
          _travelers = List<Map<String, dynamic>>.from(travR['data'] ?? []);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final featured = _filtered.isNotEmpty ? _filtered.first : null;
    final gridDests = _filtered.length > 1 ? _filtered.sublist(1, _filtered.length > 5 ? 5 : _filtered.length) : <Map<String, dynamic>>[];

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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        RichText(text: TextSpan(
                          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: c.text),
                          children: [
                            const TextSpan(text: 'Explore '),
                            TextSpan(text: 'India', style: TextStyle(color: c.primary)),
                          ],
                        )),
                        const SizedBox(height: 4),
                        Text('Destinations, companions & live trips', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
                        const SizedBox(height: 16),

                        // ── WORKING Search bar ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                          child: Row(
                            children: [
                              Text('🔍', style: TextStyle(fontSize: 15, color: c.muted.withValues(alpha: 0.4))),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchC,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.text),
                                  decoration: InputDecoration(
                                    hintText: 'Search destinations…',
                                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_searchC.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () { _searchC.clear(); },
                                  child: Icon(Icons.close_rounded, size: 18, color: c.muted),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.primaryMid)),
                                child: Text('📍 India', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filter chips
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            itemBuilder: (_, i) {
                              final f = _filters[i];
                              final isActive = f == _selectedFilter;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedFilter = f);
                                  _searchC.clear();
                                  _applyFilter();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: isActive ? c.primary : c.card,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isActive ? c.primary : c.border),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(f, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : c.muted)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Featured Destination ──
                        if (featured != null)
                          GestureDetector(
                            onTap: () => context.push('/destination/${featured['slug']}'),
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(colors: [Color(0xFF2A1810), Color(0xFF1A1020), Color(0xFF0E0818)]),
                                border: Border.all(color: c.border),
                              ),
                              child: Stack(children: [
                                Center(child: Opacity(opacity: 0.15, child: Text(_destEmojis[featured['name']] ?? featured['emoji'] ?? '🏔️', style: const TextStyle(fontSize: 80)))),
                                Positioned.fill(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)], stops: const [0.3, 1.0])))),
                                Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8)),
                                      child: Text('🔥 Most Popular', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
                                  const SizedBox(height: 8),
                                  Text(featured['name'] ?? '', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('${featured['state'] ?? 'India'} · ${featured['travelerCount'] ?? 0} travelers', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                                ])),
                              ]),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Top Destinations Grid ──
                  if (gridDests.isNotEmpty) ...[
                    _sectionHeader('Top Destinations', 'See All →', () {}),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.3),
                        itemCount: gridDests.length,
                        itemBuilder: (_, i) {
                          final d = gridDests[i];
                          final name = d['name'] ?? '';
                          final emoji = _destEmojis[name] ?? d['emoji'] ?? '🗺️';
                          final grad = _destGrads[i % _destGrads.length];
                          return GestureDetector(
                            onTap: () => context.push('/destination/${d['slug']}'),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: grad), border: Border.all(color: c.border)),
                              child: Stack(children: [
                                Center(child: Text(emoji, style: const TextStyle(fontSize: 44))),
                                Positioned(bottom: 0, left: 0, right: 0, child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                                  decoration: BoxDecoration(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)])),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                                    Text('${d['travelerCount'] ?? 0} active', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: c.primary)),
                                  ]),
                                )),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // ── Looking for Companions ──
                  if (_travelers.isNotEmpty) ...[
                    _sectionHeader('Looking for Companions', 'All →', () {}),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: List.generate(_travelers.length > 3 ? 3 : _travelers.length, (i) {
                          final t = _travelers[i];
                          final matchScore = 94 - (i * 7);
                          return GestureDetector(
                            onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
                              child: Row(children: [
                                Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: _avGrads[i % _avGrads.length])),
                                    alignment: Alignment.center, child: Text(_emojis[i % _emojis.length], style: const TextStyle(fontSize: 22))),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${t['fullName'] ?? 'Traveler'} · ${t['travelStyle'] ?? 'Adventure'}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: c.text)),
                                  Text('${t['city'] ?? 'India'}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.textSecondary)),
                                ])),
                                Text('$matchScore%', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: c.primary)),
                                const SizedBox(width: 8),
                                Container(width: 36, height: 36, decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(11), border: Border.all(color: c.primaryMid)),
                                    alignment: Alignment.center, child: const Text('👋', style: TextStyle(fontSize: 14))),
                              ]),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],

                  // ── Empty search results ──
                  if (!_isLoading && _filtered.isEmpty && _searchC.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Column(children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No destinations found for "${_searchC.text}"', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.muted), textAlign: TextAlign.center),
                      ])),
                    ),

                  if (_isLoading)
                    Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 1)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String link, VoidCallback onTap) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
        GestureDetector(onTap: onTap, child: Text(link, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary))),
      ]),
    );
  }
}