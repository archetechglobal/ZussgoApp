import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/destination_images.dart';
import '../../widgets/destination_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchC = TextEditingController();
  List<Map<String, dynamic>> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await ApiService.getDestinations();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (r['success'] == true && r['data'] != null) {
          _destinations = List<Map<String, dynamic>>.from(r['data']);
          _destinations.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        }
      });
    }
  }

  Future<void> _search(String q) async {
    if (q.length < 2) { _load(); return; }
    setState(() => _isLoading = true);
    final r = await ApiService.searchDestinations(q);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (r['success'] == true && r['data'] != null) {
          _destinations = List<Map<String, dynamic>>.from(r['data']);
          _destinations.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgPage  = ZussGoTheme.scaffoldBg(context);
    final bgMuted = ZussGoTheme.mutedBg(context);
    final bgCard  = ZussGoTheme.cardBg(context);
    final textPri = ZussGoTheme.primaryText(context);
    final textMut = ZussGoTheme.mutedText(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgPage,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Search Bar ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: bgMuted, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.arrow_back_rounded, color: textMut, size: 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchC,
                            style: context.textTheme.bodyMedium!.copyWith(color: textPri),
                            decoration: InputDecoration(
                              hintText: 'Search destinations...',
                              hintStyle: context.textTheme.bodyMedium!.copyWith(color: textMut),
                              prefixIcon: Icon(Icons.search_rounded, color: textMut, size: 18),
                              filled: true,
                              fillColor: bgMuted,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: context.colors.green.withValues(alpha: 0.3)),
                              ),
                            ),
                            onChanged: _search,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Text(
                      _searchC.text.isEmpty ? 'All Destinations' : 'Search Results',
                      style: context.textTheme.displaySmall!.copyWith(color: textPri),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green)),
                      ),

                    if (!_isLoading && _destinations.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(children: [
                            Icon(Icons.search_rounded, size: 44, color: context.colors.green.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text('No destinations found', style: context.textTheme.labelLarge!.copyWith(color: textPri)),
                          ]),
                        ),
                      ),

                    if (!_isLoading && _destinations.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
                        ),
                        itemCount: _destinations.length,
                        itemBuilder: (_, i) {
                          final d = _destinations[i];
                          return GestureDetector(
                            onTap: () => context.push('/destination/${d['slug']}'),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                      DestinationImage(
                                        destination: d,
                                        fit: BoxFit.cover,
                                      ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                                          stops: const [0.4, 1.0],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0, left: 0, right: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(d['name'] ?? '', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                                            if (d['state'] != null)
                                              Text(d['state'], style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(width: 4, height: 4, decoration: BoxDecoration(color: context.colors.mint, shape: BoxShape.circle)),
                                                  const SizedBox(width: 3),
                                                  Text('${d['travelerCount'] ?? 0} going', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9))),
                                                ],
                                              ),
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
                  ],
                ),
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 1)),
        ],
      ),
    );
  }
}