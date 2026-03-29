import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _user = {};
  bool _editing = false, _saving = false;

  int _tripCount = 0;
  int _matchCount = 0;
  double _avgRating = 0.0;
  int _totalRatings = 0;
  bool _statsLoading = true;

  late TextEditingController _nameC, _bioC, _cityC, _ageC;
  String? _gender, _travelStyle, _schedule, _social, _planning, _energy, _priority;
  Set<String> _interests = {}, _values = {};

  final _styles = ['Backpacker', 'Explorer', 'Foodie', 'Photography', 'Luxury', 'Party', 'Spiritual', 'Adventure'];
  final _schedules = ['Early Bird', 'Night Owl'];
  final _socials = ['Social Butterfly', 'Ambivert', 'Introvert'];
  final _plannings = ['Planner', 'Spontaneous'];
  final _energies = ['Chill', 'Energetic', 'Depends'];
  final _valueOpts = ['Eco-conscious', 'Comfort-first', 'Non-smoker', 'Social drinker', 'Vegetarian', 'Pet friendly'];
  final _interestOpts = ['Photography', 'Music', 'Water Sports', 'Street Food', 'Yoga', 'Art', 'Reading', 'Trekking', 'Stargazing', 'Camping', 'Journaling', 'Gaming'];
  final _priorities = ['Foodie-first', 'Adventure', 'Creator', 'Wellness', 'Nightlife', 'Culture'];

  String? _profileImagePath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImagePath = image.path);
      final userId = _user['userId'];
      if (userId != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('localProfileImage_$userId', image.path);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController();
    _bioC = TextEditingController();
    _cityC = TextEditingController();
    _ageC = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _bioC.dispose();
    _cityC.dispose();
    _ageC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    if (u != null && mounted) {
      setState(() {
        _user = u;
        _nameC.text = u['fullName'] ?? '';
        _bioC.text = u['bio'] ?? '';
        _cityC.text = u['city'] ?? '';
        _ageC.text = (u['age'] ?? '').toString();
        if (_ageC.text == 'null') _ageC.text = '';
        _gender = u['gender'];
        _travelStyle = u['travelStyle'];
        _schedule = u['schedule'];
        _social = u['socialEnergy'];
        _planning = u['planningStyle'];
        _energy = u['energyLevel'];
        _interests = Set<String>.from(u['interests'] ?? []);
        _values = Set<String>.from(u['values'] ?? []);
        _priority = u['travelPriority'];
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
          final stats = rData['data']['stats'];
          if (stats != null) {
            _avgRating = (stats['average'] as num).toDouble();
            _totalRatings = (stats['totalRatings'] as num).toInt();
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _statsLoading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final userId = _user['userId'];
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.profileSetup),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'gender': _gender ?? 'Male',
          'age': int.tryParse(_ageC.text) ?? 0,
          'city': _cityC.text.trim(),
          'travelStyle': _travelStyle,
          'bio': _bioC.text.trim(),
          'schedule': _schedule,
          'socialEnergy': _social,
          'planningStyle': _planning,
          'energyLevel': _energy,
          'values': _values.toList(),
          'interests': _interests.toList(),
          'travelPriority': _priority,
        }),
      );
      final data = jsonDecode(response.body);
      setState(() => _saving = false);
      if (data['success'] == true) {
        final updated = data['data'];
        if (updated != null) {
          await AuthService.updateSavedUser({
            'userId': updated['userId'],
            'fullName': updated['fullName'] ?? _nameC.text,
            'email': updated['email'] ?? _user['email'],
            'gender': updated['gender'],
            'age': updated['age'],
            'city': updated['city'],
            'bio': updated['bio'],
            'travelStyle': updated['travelStyle'],
            'isProfileCompleted': true,
            'schedule': updated['schedule'],
            'socialEnergy': updated['socialEnergy'],
            'planningStyle': updated['planningStyle'],
            'energyLevel': updated['energyLevel'],
            'values': updated['values'],
            'interests': updated['interests'],
            'travelPriority': updated['travelPriority'],
          });
        }
        await _load();
        setState(() => _editing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated! ✓'), backgroundColor: context.colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Failed to save')),
          );
        }
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not connect to server')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ZussGoTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: context.textTheme.displaySmall!.adaptive(context)),
        content: Text('You\'ll need to sign in again.', style: context.textTheme.bodyMedium!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: ZussGoTheme.mutedText(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out', style: TextStyle(color: context.colors.rose, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.clearSession();
      if (mounted) context.go('/login');
    }
  }

  String get _name => _user['fullName'] ?? 'Traveler';
  String get _email => _user['email'] ?? '';
  String get _style => _user['travelStyle'] ?? '';
  String get _city => _user['city'] ?? '';
  String get _ratingDisplay {
    if (_statsLoading) return '...';
    if (_totalRatings == 0) return '—';
    return '${_avgRating.toStringAsFixed(1)} ($_totalRatings)';
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? context.colors.green : ZussGoTheme.mutedBg(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            color: sel ? Colors.white : ZussGoTheme.secondaryText(context),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    if (_editing) return _buildEditProfile();

    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDark;

    // ── Dark-aware colors ──
    final bgPage = isDark ? const Color(0xFF0F0F0F) : ZussGoTheme.bgPrimary;
    final bgCard = isDark ? const Color(0xFF1C1C1C) : ZussGoTheme.bgSecondary;
    final bgMuted = isDark ? const Color(0xFF2A2A2A) : ZussGoTheme.bgMuted;
    final borderColor = isDark ? const Color(0xFF2E2E2E) : ZussGoTheme.borderDefault;
    final textPrimary = isDark ? Colors.white : ZussGoTheme.textPrimary;
    final textSecondary = isDark ? const Color(0xFFAAAAAA) : ZussGoTheme.textSecondary;
    final textMuted = isDark ? const Color(0xFF666666) : context.colors.textMuted;

    return Scaffold(
      backgroundColor: bgPage,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 90),
              child: Column(children: [
                const SizedBox(height: 12),

                // ── AVATAR ──
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(
                          gradient: _profileImagePath == null ? ZussGoTheme.gradientPrimary : null,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: context.colors.green.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 4))],
                          image: _profileImagePath != null ? DecorationImage(image: FileImage(File(_profileImagePath!)), fit: BoxFit.cover) : null,
                        ),
                        alignment: Alignment.center,
                        child: _profileImagePath == null ? Text(
                          _name.isNotEmpty ? _name[0] : 'Z',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28, fontFamily: 'Playfair Display'),
                        ) : null,
                      ),
                      Positioned(
                        bottom: -4, right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), shape: BoxShape.circle, border: Border.all(color: ZussGoTheme.scaffoldBg(context), width: 2)),
                          child: Icon(Icons.edit_rounded, size: 14, color: context.colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(_name, style: context.textTheme.displayMedium!.copyWith(fontSize: 22, color: textPrimary)),
                Text(_email, style: context.textTheme.bodySmall!.copyWith(color: textMuted)),
                const SizedBox(height: 8),

                // ── TAGS ──
                Wrap(alignment: WrapAlignment.center, spacing: 6, children: [
                  if (_style.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(8)),
                      child: Text(_style, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.green)),
                    ),
                  if (_city.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: bgMuted, borderRadius: BorderRadius.circular(8)),
                      child: Text(_city, style: TextStyle(fontSize: 11, color: textMuted)),
                    ),
                  if (_user['schedule'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: bgMuted, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        _user['schedule'] as String,
                        style: TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ),
                ]),
                const SizedBox(height: 16),

                // ── STATS ──
                Row(children: [
                  _StatCard(value: _statsLoading ? '...' : '$_tripCount', label: 'Trips', color: context.colors.green, bgCard: bgCard, borderColor: borderColor),
                  const SizedBox(width: 8),
                  _StatCard(value: _statsLoading ? '...' : '$_matchCount', label: 'Matches', color: context.colors.amber, bgCard: bgCard, borderColor: borderColor),
                  const SizedBox(width: 8),
                  _StatCard(value: _ratingDisplay, label: 'Rating', color: context.colors.rose, bgCard: bgCard, borderColor: borderColor),
                ]),
                const SizedBox(height: 20),

                // ── MENU ITEMS ──
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ACCOUNT', style: TextStyle(fontSize: 10, color: context.colors.green, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.edit_rounded,
                  iconColor: context.colors.green,
                  bgColor: context.colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
                  label: 'Edit Profile',
                  isDark: isDark,
                  onTap: () => setState(() => _editing = true),
                ),
                _MenuItem(
                  icon: Icons.phone_rounded,
                  iconColor: context.colors.rose,
                  bgColor: context.colors.rose.withValues(alpha: isDark ? 0.2 : 0.08),
                  label: 'Emergency Contacts',
                  isDark: isDark,
                  onTap: () => context.push('/active-trip'),
                ),
                _MenuItem(
                  icon: Icons.notifications_rounded,
                  iconColor: context.colors.sky,
                  bgColor: context.colors.sky.withValues(alpha: isDark ? 0.2 : 0.08),
                  label: 'Notifications',
                  isDark: isDark,
                  onTap: () => context.push('/notifications'),
                ),
                _MenuItem(
                  icon: Icons.shield_rounded,
                  iconColor: context.colors.amber,
                  bgColor: context.colors.amber.withValues(alpha: isDark ? 0.2 : 0.08),
                  label: 'Privacy & Safety',
                  isDark: isDark,
                  onTap: () => context.push('/privacy'),
                ),
                _MenuItem(
                  icon: Icons.help_rounded,
                  iconColor: ZussGoTheme.lavender,
                  bgColor: ZussGoTheme.lavender.withValues(alpha: isDark ? 0.2 : 0.08),
                  label: 'Help & Support',
                  isDark: isDark,
                  onTap: () => context.push('/help-support'),
                ),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  iconColor: context.colors.rose,
                  bgColor: context.colors.rose.withValues(alpha: isDark ? 0.15 : 0.06),
                  label: 'Sign Out',
                  isDark: isDark,
                  isDestructive: true,
                  onTap: _logout,
                ),
                const SizedBox(height: 16),
                Text('ZussGo v1.0 • ArcheTech Global', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: textMuted)),
              ]),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 4)),
        ],
      ),
    );
  }

  Widget _buildEditProfile() {
    return Scaffold(
      backgroundColor: ZussGoTheme.scaffoldBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => setState(() => _editing = false),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 18),
                ),
              ),
              Text('Edit Profile', style: context.textTheme.displaySmall!.adaptive(context)),
              const SizedBox(width: 34),
            ]),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: ZussGoTheme.mutedBg(context),
                        borderRadius: BorderRadius.circular(28),
                        gradient: _profileImagePath == null ? ZussGoTheme.gradientPrimary : null,
                        image: _profileImagePath != null ? DecorationImage(image: FileImage(File(_profileImagePath!)), fit: BoxFit.cover) : null,
                      ),
                      alignment: Alignment.center,
                      child: _profileImagePath == null ? Text(
                        _nameC.text.isNotEmpty ? _nameC.text[0].toUpperCase() : 'Z',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 32, fontFamily: 'Playfair Display'),
                      ) : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: context.colors.green, shape: BoxShape.circle, border: Border.all(color: ZussGoTheme.scaffoldBg(context), width: 3)),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _editLabel('Full Name'),
            TextField(controller: _nameC, decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Your name'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context))),
            const SizedBox(height: 12),
            _editLabel('Bio'),
            TextField(controller: _bioC, decoration: ZussGoTheme.inputDecorationOf(context, hint: 'About yourself'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)), maxLines: 3),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _editLabel('City'),
                TextField(controller: _cityC, decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Mumbai'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context))),
              ])),
              const SizedBox(width: 10),
              SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _editLabel('Age'),
                TextField(controller: _ageC, decoration: ZussGoTheme.inputDecorationOf(context, hint: '24'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)), keyboardType: TextInputType.number),
              ])),
            ]),
            const SizedBox(height: 12),
            _editLabel('Gender'),
            Row(children: ['Male', 'Female', 'Other'].map((g) {
              final sel = _gender == g;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _gender = g),
                child: Container(
                  margin: EdgeInsets.only(right: g != 'Other' ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? (Theme.of(context).brightness == Brightness.dark ? context.colors.green.withValues(alpha: 0.2) : context.colors.greenLight) : ZussGoTheme.mutedBg(context),
                    borderRadius: BorderRadius.circular(10),
                    border: sel ? Border.all(color: context.colors.green, width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(g, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? context.colors.green : ZussGoTheme.secondaryText(context))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),
            _editLabel('Travel Style'),
            Wrap(spacing: 6, runSpacing: 6, children: _styles.map((s) => _chip(s, _travelStyle == s, () => setState(() => _travelStyle = s))).toList()),
            const SizedBox(height: 16),
            Text('MINDSET', style: TextStyle(fontSize: 11, color: context.colors.green, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 10),
            _editLabel('Schedule'),
            Wrap(spacing: 6, children: _schedules.map((s) => _chip(s, _schedule == s, () => setState(() => _schedule = s))).toList()),
            const SizedBox(height: 8),
            _editLabel('Social Energy'),
            Wrap(spacing: 6, children: _socials.map((s) => _chip(s, _social == s, () => setState(() => _social = s))).toList()),
            const SizedBox(height: 8),
            _editLabel('Planning Style'),
            Wrap(spacing: 6, children: _plannings.map((s) => _chip(s, _planning == s, () => setState(() => _planning = s))).toList()),
            const SizedBox(height: 8),
            _editLabel('Energy Level'),
            Wrap(spacing: 6, children: _energies.map((s) => _chip(s, _energy == s, () => setState(() => _energy = s))).toList()),
            const SizedBox(height: 16),
            Text('INTERESTS & VALUES', style: TextStyle(fontSize: 11, color: context.colors.green, fontWeight: FontWeight.w600, letterSpacing: 1)),
            const SizedBox(height: 10),
            _editLabel('Interests'),
            Wrap(spacing: 6, runSpacing: 6, children: _interestOpts.map((i) => _chip(i, _interests.contains(i), () => setState(() { _interests.contains(i) ? _interests.remove(i) : _interests.add(i); }))).toList()),
            const SizedBox(height: 8),
            _editLabel('Values'),
            Wrap(spacing: 6, runSpacing: 6, children: _valueOpts.map((v) => _chip(v, _values.contains(v), () => setState(() { _values.contains(v) ? _values.remove(v) : _values.add(v); }))).toList()),
            const SizedBox(height: 8),
            _editLabel('Travel Priority'),
            Wrap(spacing: 6, runSpacing: 6, children: _priorities.map((p) => _chip(p, _priority == p, () => setState(() => _priority = p))).toList()),
            const SizedBox(height: 20),
            GradientButton(text: 'Save Changes ✓', isLoading: _saving, onPressed: _save),
            const SizedBox(height: 10),
            Center(child: GestureDetector(onTap: () => setState(() => _editing = false), child: Text('Cancel', style: TextStyle(fontSize: 13, color: ZussGoTheme.mutedText(context))))),
          ]),
        ),
      ),
    );
  }

  Widget _editLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 12)),
  );
}

// ── STAT CARD ──
class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color, bgCard, borderColor;
  const _StatCard({required this.value, required this.label, required this.color, required this.bgCard, required this.borderColor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: ZussGoTheme.mutedText(context))),
      ]),
    ),
  );
}

// ── MENU ITEM ──
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor, bgColor;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive, isDark;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : ZussGoTheme.textPrimary;
    final borderColor = isDark ? const Color(0xFF2E2E2E) : ZussGoTheme.borderDefault;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isDestructive ? Colors.transparent : borderColor)),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? context.colors.rose : textPrimary))),
          if (!isDestructive) Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF555555) : context.colors.textMuted, size: 18),
        ]),
      ),
    );
  }
}