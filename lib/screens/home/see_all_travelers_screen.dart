import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SeeAllTravelersScreen extends StatefulWidget {
  const SeeAllTravelersScreen({super.key});
  @override
  State<SeeAllTravelersScreen> createState() => _SeeAllTravelersScreenState();
}

class _SeeAllTravelersScreenState extends State<SeeAllTravelersScreen> {
  List<Map<String, dynamic>> _travelers = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    final userId = u?['userId'];
    if (userId == null) { setState(() => _loading = false); return; }
    final r = await AuthService.getUsers(userId: userId);
    if (mounted) setState(() {
      _loading = false;
      if (r['success'] == true) _travelers = List<Map<String, dynamic>>.from(r['data'] ?? []);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13)),
                      child: Icon(Icons.arrow_back_rounded, color: c.text, size: 16)),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('All Companions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: c.text)),
                  Text('${_travelers.length} travelers near you', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
                  : _travelers.isEmpty
                  ? Center(child: Text('No travelers found', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.muted)))
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: _travelers.length,
                itemBuilder: (_, i) {
                  final t = _travelers[i];
                  final name = t['fullName'] ?? 'Traveler';
                  final age = t['age']?.toString() ?? '';
                  final city = t['city'] ?? '';
                  final style = t['travelStyle'] ?? 'Explorer';
                  final photo = t['profilePhotoUrl'];
                  final matchScore = 94 - (i * 3);

                  return GestureDetector(
                    onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Row(
                          children: [
                            // Photo
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.3), c.card]),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: photo != null
                                  ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(name[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.primary))))
                                  : Center(child: Text(name[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.primary))),
                            ),
                            const SizedBox(width: 14),

                            // Details
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
                              const SizedBox(height: 2),
                              Text('${age.isNotEmpty ? '$age · ' : ''}${city.isNotEmpty ? '$city · ' : ''}$style', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
                            ])),

                            // Match score
                            Text('$matchScore%', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: c.primary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}