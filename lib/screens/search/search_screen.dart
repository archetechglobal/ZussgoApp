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
  final _searchC = TextEditingController();
  List<Map<String, dynamic>> _destinations = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _searchC.dispose(); super.dispose(); }

  Future<void> _load() async {
    final r = await ApiService.getDestinations();
    if (mounted) setState(() { _isLoading = false; if (r["success"] == true && r["data"] != null) _destinations = List<Map<String, dynamic>>.from(r["data"]); });
  }

  Future<void> _search(String q) async {
    if (q.length < 2) { _load(); return; }
    setState(() => _isLoading = true);
    final r = await ApiService.searchDestinations(q);
    if (mounted) setState(() { _isLoading = false; if (r["success"] == true && r["data"] != null) _destinations = List<Map<String, dynamic>>.from(r["data"]); });
  }

  LinearGradient _dg(int i) {
    const gs = [LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF22D3EE)]), LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
      LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]), LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
      LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFF472B6)]), LinearGradient(colors: [Color(0xFF047857), Color(0xFF10B981)])];
    return gs[i % gs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: Stack(children: [
      SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.only(bottom: 90), child: Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => context.go('/home'), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: _searchC,
              decoration: InputDecoration(hintText: 'Search destinations...', prefixIcon: Icon(Icons.search_rounded, color: ZussGoTheme.textMuted, size: 18), filled: true, fillColor: ZussGoTheme.bgMuted, contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: ZussGoTheme.green.withValues(alpha: 0.3)))),
              style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), onChanged: _search)),
        ]),
        const SizedBox(height: 18),
        Text(_searchC.text.isEmpty ? 'All Destinations' : 'Search Results', style: ZussGoTheme.displaySmall),
        const SizedBox(height: 12),

        if (_isLoading) Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))),

        if (!_isLoading && _destinations.isEmpty) Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(children: [const Text('🔍', style: TextStyle(fontSize: 32)), const SizedBox(height: 8), Text('No destinations found', style: ZussGoTheme.labelBold)]))),

        if (!_isLoading && _destinations.isNotEmpty)
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82),
              itemCount: _destinations.length,
              itemBuilder: (_, i) {
                final d = _destinations[i];
                return GestureDetector(onTap: () => context.push('/destination/${d['slug']}'),
                  child: Container(decoration: BoxDecoration(gradient: _dg(i), borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))]),
                    child: Stack(children: [
                      Center(child: Opacity(opacity: 0.1, child: Text(d['emoji'] ?? '🌍', style: const TextStyle(fontSize: 50)))),
                      Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                          child: Text('⭐ 4.${8 - (i % 3)}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)))),
                      Positioned(bottom: 0, left: 0, right: 0, child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)]),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d['emoji'] ?? '🌍', style: const TextStyle(fontSize: 22)),
                          Text(d['name'] ?? '', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                          if (d['state'] != null) Text(d['state'], style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                          const SizedBox(height: 4),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 4, height: 4, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)), const SizedBox(width: 3),
                                Text('${d['travelerCount'] ?? 0} going', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.9)))])),
                        ]),
                      )),
                    ]),
                  ),
                );
              }),
      ])))),
      const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 1)),
    ]));
  }
}