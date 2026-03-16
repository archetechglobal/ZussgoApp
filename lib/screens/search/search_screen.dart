import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    final result = await ApiService.getDestinations();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result["success"] == true && result["data"] != null) {
          _destinations = List<Map<String, dynamic>>.from(result["data"]);
        }
      });
    }
  }

  Future<void> _search(String query) async {
    if (query.length < 2) {
      _loadDestinations();
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.searchDestinations(query);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result["success"] == true && result["data"] != null) {
          _destinations = List<Map<String, dynamic>>.from(result["data"]);
        }
      });
    }
  }

  // Gradient for each destination card
  LinearGradient _cardGradient(int index) {
    final gradients = [
      const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)]),
      const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFFA78BFA)]),
      const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF38BDF8)]),
      const LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFA78BFA)]),
      const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFF22C55E)]),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search destinations...',
                              prefixIcon: Icon(Icons.search, color: ZussGoTheme.textMuted.withValues(alpha: 0.5), size: 20),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: ZussGoTheme.amber.withValues(alpha: 0.3)),
                              ),
                            ),
                            style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                            onChanged: _search,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      _searchController.text.isEmpty ? 'All Destinations' : 'Search Results',
                      style: ZussGoTheme.displaySmall,
                    ),
                    const SizedBox(height: 14),

                    // Loading
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5))),
                      ),

                    // Empty
                    if (!_isLoading && _destinations.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(children: [
                            const Text('🔍', style: TextStyle(fontSize: 36)),
                            const SizedBox(height: 12),
                            Text('No destinations found', style: ZussGoTheme.labelBold),
                          ]),
                        ),
                      ),

                    // Grid
                    if (!_isLoading && _destinations.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
                        ),
                        itemCount: _destinations.length,
                        itemBuilder: (context, i) {
                          final d = _destinations[i];
                          return GestureDetector(
                            onTap: () => context.push('/destination/${d['slug']}'),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: _cardGradient(i),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Color(0x99000000)], stops: [0.3, 1.0],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(d['emoji'] ?? '🌍', style: const TextStyle(fontSize: 30)),
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(d['name'] ?? '', style: ZussGoTheme.labelBold.copyWith(fontSize: 16)),
                                        if (d['state'] != null)
                                          Text(d['state'], style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
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