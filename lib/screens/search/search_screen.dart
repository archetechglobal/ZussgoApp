import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/zuss_icons.dart';
import '../../config/animations.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/destination_images.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchC = TextEditingController();
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Mountains', 'Beaches', 'Heritage', 'Festivals'];
  static const _filterIcons = {
    'All': Icons.grid_view_rounded, 'Mountains': Icons.terrain_rounded,
    'Beaches': Icons.beach_access_rounded, 'Heritage': Icons.account_balance_rounded,
    'Festivals': Icons.celebration_rounded,
  };
  static const _catMap = {
    'Mountains': ['Manali', 'Ladakh', 'Spiti Valley', 'Shimla', 'Kasol', 'Dharamshala', 'Munnar', 'Coorg', 'Darjeeling'],
    'Beaches': ['Goa', 'Andaman', 'Gokarna', 'Pondicherry'],
    'Heritage': ['Jaipur', 'Varanasi', 'Udaipur', 'Hampi', 'Pushkar'],
    'Festivals': ['Pushkar', 'Varanasi', 'Jaipur', 'Rishikesh'],
  };

  @override
  void initState() { super.initState(); _searchC.addListener(_onSearchChanged); _load(); }

  @override
  void dispose() { _searchC.removeListener(_onSearchChanged); _searchC.dispose(); super.dispose(); }

  void _onSearchChanged() {
    final q = _searchC.text.trim().toLowerCase();
    if (q.isEmpty) { _applyFilter(); } else {
      setState(() { _filtered = _destinations.where((d) {
        final name = (d['name'] ?? '').toString().toLowerCase();
        final state = (d['state'] ?? '').toString().toLowerCase();
        return name.contains(q) || state.contains(q);
      }).toList(); });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') { _filtered = List.from(_destinations); }
      else { final names = _catMap[_selectedFilter] ?? []; _filtered = _destinations.where((d) => names.contains(d['name'])).toList(); }
    });
  }

  Future<void> _load() async {
    final r = await ApiService.getDestinations();
    if (mounted) setState(() {
      _isLoading = false;
      if (r['success'] == true && r['data'] != null) { _destinations = List<Map<String, dynamic>>.from(r['data']); _filtered = List.from(_destinations); }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final featured = _filtered.isNotEmpty ? _filtered.first : null;
    final gridDests = _filtered.length > 1 ? _filtered.sublist(1) : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(fit: StackFit.expand, children: [
        // Atmospheric glow
        Positioned(top: -60, left: -60, child: Container(width: 250, height: 250,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0x08FF6B4A), Colors.transparent])))),

        SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Title
            RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: c.text),
                children: [const TextSpan(text: 'Explore '), TextSpan(text: 'India', style: TextStyle(color: c.primary))])).zussHero(delay: 0),
            const SizedBox(height: 4),
            Text('Find your next destination', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
            const SizedBox(height: 16),

            // Search bar
            Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                child: Row(children: [
                  Icon(ZussIcons.search, size: 18, color: c.muted.withValues(alpha: 0.5)), const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _searchC, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.text),
                      decoration: InputDecoration(hintText: 'Search destinations…', hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
                  if (_searchC.text.isNotEmpty) GestureDetector(onTap: () { _searchC.clear(); }, child: Icon(Icons.close_rounded, size: 18, color: c.muted)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.primaryMid)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ZussIcons.location, size: 12, color: c.primary), const SizedBox(width: 3), Text('India', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary))])),
                ])).zussEntrance(index: 0, baseDelay: 100),
            const SizedBox(height: 16),

            // Filter chips
            SizedBox(height: 36, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _filters.length, itemBuilder: (_, i) {
              final f = _filters[i]; final isActive = f == _selectedFilter;
              return GestureDetector(onTap: () { setState(() => _selectedFilter = f); _searchC.clear(); _applyFilter(); },
                  child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(color: isActive ? c.primary : c.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? c.primary : c.border)),
                      alignment: Alignment.center,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_filterIcons[f] ?? Icons.grid_view_rounded, size: 14, color: isActive ? Colors.white : c.muted), const SizedBox(width: 6),
                        Text(f, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.white : c.muted)),
                      ]))).zussCascade(index: i);
            })),
            const SizedBox(height: 16),

            // ── FEATURED DESTINATION — full-width image card ──
            if (featured != null) Builder(builder: (_) {
              final fName = featured['name'] ?? '';
              final fSlug = featured['slug'] ?? fName.toLowerCase().replaceAll(' ', '-');
              final fImage = DestinationImages.getAssetPath(fSlug);
              return GestureDetector(
                onTap: () => context.push('/destination/$fSlug'),
                child: Container(height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(children: [
                    Positioned.fill(child: Image.asset(fImage, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(gradient: ZussGoTheme.gradientHero)))),
                    Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)], stops: const [0.3, 1.0])))),
                    Positioned(bottom: 20, left: 20, right: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 8)]),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ZussIcons.trending, size: 12, color: Colors.white), const SizedBox(width: 4),
                            Text('Most Popular', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))])),
                      const SizedBox(height: 8),
                      Text(fName, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('${featured['state'] ?? 'India'} · ${featured['travelerCount'] ?? 0} travelers', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                    ])),
                  ]),
                ),
              ).zussHero(delay: 200);
            }),
          ])),

          // ── DESTINATIONS GRID — staggered layout with real photos ──
          if (gridDests.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Top Destinations', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
              Text('${_filtered.length} places', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
            ])).zussEntrance(index: 0, baseDelay: 400),

            // Staggered layout: alternating tall/short cards
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _buildStaggeredGrid(gridDests, c)),
          ],

          // Empty search
          if (!_isLoading && _filtered.isEmpty && _searchC.text.isNotEmpty)
            Padding(padding: const EdgeInsets.all(40), child: Center(child: Column(children: [
              Icon(ZussIcons.search, size: 40, color: c.muted.withValues(alpha: 0.3)), const SizedBox(height: 12),
              Text('No destinations found for "${_searchC.text}"', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.muted), textAlign: TextAlign.center),
            ]))),

          if (_isLoading) Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))),
          const SizedBox(height: 16),
        ]))),

        const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 1)),
      ]),
    );
  }

  /// Staggered grid — alternating tall (180px) and short (130px) rows
  Widget _buildStaggeredGrid(List<Map<String, dynamic>> dests, ZussGoColors c) {
    final List<Widget> rows = [];
    for (int i = 0; i < dests.length; i += 2) {
      final isOddRow = (i ~/ 2) % 2 == 1;
      final left = dests[i];
      final right = i + 1 < dests.length ? dests[i + 1] : null;

      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(flex: isOddRow ? 5 : 6, child: _DestCard(
            dest: left, height: isOddRow ? 130 : 170, c: c,
            onTap: () => context.push('/destination/${left['slug'] ?? ''}'),
          ).zussEntrance(index: i, baseDelay: 500)),
          const SizedBox(width: 12),
          if (right != null)
            Expanded(flex: isOddRow ? 6 : 5, child: _DestCard(
              dest: right, height: isOddRow ? 170 : 130, c: c,
              onTap: () => context.push('/destination/${right['slug'] ?? ''}'),
            ).zussEntrance(index: i + 1, baseDelay: 500))
          else
            Expanded(flex: isOddRow ? 6 : 5, child: const SizedBox()),
        ]),
      ));
    }
    return Column(children: rows);
  }
}

/// Destination card with real photo background
class _DestCard extends StatelessWidget {
  final Map<String, dynamic> dest;
  final double height;
  final ZussGoColors c;
  final VoidCallback onTap;
  const _DestCard({required this.dest, required this.height, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = dest['name'] ?? '';
    final slug = dest['slug'] ?? name.toLowerCase().replaceAll(' ', '-');
    final count = dest['travelerCount'] ?? 0;
    final imagePath = DestinationImages.getAssetPath(slug);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(children: [
          Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: c.card, child: Center(child: Icon(ZussIcons.mountain, size: 32, color: c.muted.withValues(alpha: 0.3)))))),
          Positioned.fill(child: Container(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)], stops: const [0.35, 1.0])))),
          // Traveler count
          Positioned(top: 10, right: 10, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(ZussIcons.group, size: 10, color: Colors.white.withValues(alpha: 0.8)), const SizedBox(width: 3),
              Text('$count', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
            ]),
          )),
          // Name + state
          Positioned(bottom: 12, left: 12, right: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            if (dest['state'] != null) Text(dest['state'], style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
          ])),
        ]),
      ),
    );
  }
}