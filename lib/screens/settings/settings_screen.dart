import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = '';
  String _userInitial = '';
  String _userCity = '';
  String _userBio = '';
  String? _profileImagePath;
  Map<String, dynamic> _user = {};

  int _tripCount = 0;
  int _matchCount = 0;
  double _avgRating = 0;
  int _totalRatings = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    if (u != null && mounted) {
      setState(() {
        _user = u;
        _userName = u['fullName'] ?? 'Traveler';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Z';
        _userCity = u['city'] ?? '';
        _userBio = u['bio'] ?? '';
      });
      final userId = u['userId'];
      if (userId != null) {
        _loadStats(userId);
        final prefs = await SharedPreferences.getInstance();
        final path = prefs.getString('localProfileImage_$userId');
        if (path != null && File(path).existsSync()) {
          setState(() => _profileImagePath = path);
        }
      }
    }
  }

  Future<void> _loadStats(String userId) async {
    setState(() => _statsLoading = true);
    try {
      final tripsRes = await http.get(Uri.parse('${ApiConfig.trips}?userId=$userId'));
      if (tripsRes.statusCode == 200) {
        final tData = jsonDecode(tripsRes.body);
        if (tData['success'] == true && tData['data'] != null) {
          final d = tData['data'];
          _tripCount = (d['upcoming'] as List).length + (d['past'] as List).length;
        }
      }
      final matchesRes = await http.get(Uri.parse('${ApiConfig.matches}?userId=$userId'));
      if (matchesRes.statusCode == 200) {
        final mData = jsonDecode(matchesRes.body);
        if (mData['success'] == true && mData['data'] != null) {
          _matchCount = (mData['data'] as List).length;
        }
      }
      final ratingsRes = await http.get(Uri.parse(ApiConfig.ratingsByUser(userId)));
      if (ratingsRes.statusCode == 200) {
        final rData = jsonDecode(ratingsRes.body);
        if (rData['success'] == true && rData['data'] != null) {
          final dataOrList = rData['data'];
          if (dataOrList is List && dataOrList.isNotEmpty) {
            _totalRatings = dataOrList.length;
            double sum = 0;
            for (var req in dataOrList) { sum += (req['score'] as num?)?.toDouble() ?? 0.0; }
            _avgRating = sum / _totalRatings;
          } else if (dataOrList is Map) {
            final stats = dataOrList['stats'];
            if (stats != null) {
              _avgRating = (stats['average'] as num).toDouble();
              _totalRatings = (stats['totalRatings'] as num).toInt();
            } else if (dataOrList['score'] != null) {
              _totalRatings = 1;
              _avgRating = (dataOrList['score'] as num).toDouble();
            }
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _statsLoading = false);
  }

  Future<void> _handleLogout() async {
    final c = context.colors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
        content: Text('Are you sure you want to sign out?', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out', style: GoogleFonts.plusJakartaSans(color: c.rose, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.clearSession();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratingStr = _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '–';

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
              child: Column(
                children: [
                  // ── PROFILE HEADER ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(colors: [Color(0xFF2A1810), Color(0xFF1E1420)]),
                                border: Border.all(color: c.primaryMid, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: _profileImagePath != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.file(File(_profileImagePath!), width: 76, height: 76, fit: BoxFit.cover))
                                  : Text('😎', style: const TextStyle(fontSize: 40)),
                            ),
                            // Ring
                            Positioned(
                              top: -5, left: -5, right: -5, bottom: -5,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: c.primary.withValues(alpha: 0.3), width: 1.5),
                                ),
                              ),
                            ),
                            // Pro badge
                            Positioned(
                              bottom: -4, right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8)),
                                child: Text('✓ Pro', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ),
                            // Edit icon
                            Positioned(
                              top: -4, right: -4,
                              child: GestureDetector(
                                onTap: () => context.push('/settings/edit-profile'),
                                child: Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
                                  child: Center(child: Text('✏️', style: const TextStyle(fontSize: 11))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Name
                        Text(_userName, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
                        const SizedBox(height: 2),
                        Text(
                          '🇮🇳 India${_userCity.isNotEmpty ? ' · $_userCity' : ''} · Member since 2025',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary),
                        ),
                        const SizedBox(height: 8),

                        // Tags
                        Wrap(
                          spacing: 6,
                          children: [
                            _ProfileTag(label: 'Adventure', color: c.primary, bgColor: c.primarySoft, borderColor: c.primaryMid),
                            _ProfileTag(label: 'Mountains', color: c.primary, bgColor: c.primarySoft, borderColor: c.primaryMid),
                            _ProfileTag(label: 'Budget', color: c.gold, bgColor: c.goldSoft, borderColor: c.goldMid),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── TRUST SCORE ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
                    child: Row(
                      children: [
                        // Score ring
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: c.sage.withValues(alpha: 0.3), width: 4),
                          ),
                          alignment: Alignment.center,
                          child: Text(ratingStr, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: c.sage)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Trust Score', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: c.text)),
                              const SizedBox(height: 2),
                              Text('Verified traveler', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.textSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _TrustBadgeChip(label: '✓ Verified', color: c.sage, bgColor: c.sageSoft),
                                  const SizedBox(width: 4),
                                  _TrustBadgeChip(label: '🪪 ID', color: c.lavender, bgColor: c.lavenderSoft),
                                  const SizedBox(width: 4),
                                  _TrustBadgeChip(label: '🗺️ $_tripCount trips', color: c.gold, bgColor: c.goldSoft),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── STATS ROW ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.border)),
                    child: Row(
                      children: [
                        _StatCell(value: '$_tripCount', label: 'Trips', color: c.primary),
                        _StatCell(value: '0', label: 'Trek Pts', color: c.gold, showDivider: true),
                        _StatCell(value: '$_matchCount', label: 'Companions', color: c.text, showDivider: true),
                        _StatCell(value: '$ratingStr★', label: 'Rating', color: c.sage, showDivider: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── BIO ──
                  if (_userBio.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                      child: Text(_userBio, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6)),
                    ),
                  if (_userBio.isNotEmpty) const SizedBox(height: 14),

                  // ── ACCOUNT MENU ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: Align(alignment: Alignment.centerLeft, child: Text('Account', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _MenuItem(icon: '⭐', label: 'Trek Points', value: '0', bgColor: c.goldSoft, onTap: () => context.push('/matches')),
                        const SizedBox(height: 6),
                        _MenuItem(icon: '🗺️', label: 'My Trips', value: '$_tripCount trips', bgColor: c.primarySoft, onTap: () => context.push('/trips')),
                        const SizedBox(height: 6),
                        _MenuItem(icon: '🛡️', label: 'Emergency SOS', value: '0 contacts', bgColor: c.roseSoft, onTap: () => context.push('/settings/safety')),
                        const SizedBox(height: 6),
                        _MenuItem(icon: '⚙️', label: 'Settings & Privacy', bgColor: const Color(0x08FFFFFF), onTap: () => context.push('/settings/edit-profile')),
                        const SizedBox(height: 14),
                        // Log out
                        GestureDetector(
                          onTap: _handleLogout,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: c.rose.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: c.roseSoft, borderRadius: BorderRadius.circular(11)),
                                  alignment: Alignment.center,
                                  child: const Text('🚪', style: TextStyle(fontSize: 17)),
                                ),
                                const SizedBox(width: 14),
                                Text('Log Out', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: c.rose)),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded, color: c.muted, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: const ZussGoBottomNav(currentIndex: 4),
          ),
        ],
      ),
    );
  }
}

// ── Profile Tag ──
class _ProfileTag extends StatelessWidget {
  final String label;
  final Color color, bgColor, borderColor;
  const _ProfileTag({required this.label, required this.color, required this.bgColor, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Trust Badge Chip ──
class _TrustBadgeChip extends StatelessWidget {
  final String label;
  final Color color, bgColor;
  const _TrustBadgeChip({required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Stat Cell ──
class _StatCell extends StatelessWidget {
  final String value, label;
  final Color color;
  final bool showDivider;
  const _StatCell({required this.value, required this.label, required this.color, this.showDivider = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: showDivider ? BoxDecoration(border: Border(left: BorderSide(color: c.border, width: 1))) : null,
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted)),
          ],
        ),
      ),
    );
  }
}

// ── Menu Item ──
class _MenuItem extends StatelessWidget {
  final String icon, label;
  final String? value;
  final Color bgColor;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, this.value, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: c.text))),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(value!, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
              ),
            Icon(Icons.chevron_right_rounded, color: c.muted, size: 18),
          ],
        ),
      ),
    );
  }
}