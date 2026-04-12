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
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName    = '';
  String _userInitial = '';
  String _userCity    = '';

  static const _items = [
    {'icon': Icons.person_rounded,        'label': 'Edit Profile',  'sub': 'Photo, bio, vibes',  'route': '/settings/edit-profile'},
    {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'sub': 'Match alerts',        'route': '/settings/notifications'},
    {'icon': Icons.shield_rounded,        'label': 'Safety',        'sub': 'Block, report',       'route': '/settings/safety'},
    {'icon': Icons.auto_awesome_rounded,  'label': 'ZussGo Pro',    'sub': 'Unlock premium',      'route': '/settings/pro'},
    {'icon': Icons.help_rounded,          'label': 'Support',       'sub': 'Help center',         'route': '/settings/support'},
    {'icon': Icons.description_rounded,   'label': 'Legal',         'sub': 'Terms & privacy',     'route': '/settings/legal'},
  ];

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
        _userName    = user['fullName'] ?? 'Traveler';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Z';
        _userCity    = user['city'] ?? '';
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
          if (dataOrList is List) {
            if (dataOrList.isNotEmpty) {
              _totalRatings = dataOrList.length;
              double sum = 0;
              for (var req in dataOrList) {
                sum += (req['score'] as num?)?.toDouble() ?? 0.0;
              }
              _avgRating = sum / _totalRatings;
            }
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

  /// Validation block for Profile Settings
  String? _validateProfile() {
    if (_nameC.text.trim().isEmpty) {
      return "Please enter your full name";
    }

    final ageText = _ageC.text.trim();
    if (ageText.isEmpty) {
      return "Please enter your age";
    }
    
    final age = int.tryParse(ageText);
    if (age == null || age < 18) {
      return "Age must be 18 or above";
    }

    if (_gender == null) return "Please select your gender";
    
    return null;
  }

  Future<void> _save() async {
    final validationError = _validateProfile();
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError), backgroundColor: context.colors.rose),
        );
      }
      return;
    }

    setState(() => _saving = true);
    final userId = _user['userId'];
    if (userId == null) {
      setState(() => _saving = false);
      return;
    }
    
    try {
      final response = await AuthService.profileSetup(
        userId: userId,
        fullName: _nameC.text.trim(),
        gender: _gender,
        age: int.tryParse(_ageC.text),
        city: _cityC.text.trim(),
        travelStyle: _travelStyle,
        bio: _bioC.text.trim(),
        schedule: _schedule,
        socialEnergy: _social,
        planningStyle: _planning,
        energyLevel: _energy,
        values: _values.toList(),
        interests: _interests.toList(),
        travelPriority: _priority,
      );

      setState(() => _saving = false);
      
      if (response['success'] == true) {
        final updated = response['data'];
        if (updated != null) {
          // Flatten structure if backend returns nested user object
          final userData = updated['user'] ?? updated;
          await AuthService.updateSavedUser({
            'userId': userData['userId'] ?? userData['id'] ?? userId,
            'fullName': userData['fullName'] ?? _nameC.text,
            'email': userData['email'] ?? _user['email'],
            'gender': userData['gender'],
            'age': userData['age'],
            'city': userData['city'],
            'bio': userData['bio'],
            'travelStyle': userData['travelStyle'],
            'isProfileCompleted': true,
            'schedule': userData['schedule'],
            'socialEnergy': userData['socialEnergy'],
            'planningStyle': userData['planningStyle'],
            'energyLevel': userData['energyLevel'],
            'values': userData['values'],
            'interests': userData['interests'],
            'travelPriority': userData['travelPriority'],
          });
        }
        await _load();
        setState(() => _editing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Profile updated! ✓'), backgroundColor: context.colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Failed to save')),
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZussGoTheme.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
        content: Text('Are you sure you want to sign out?', style: ZussGoTheme.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: ZussGoTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.clearSession();
      if (mounted) context.go('/login');
    }
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

                  // Profile header
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          gradient: ZussGoTheme.gradientPrimary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _userInitial,
                          style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: Colors.white, fontFamily: 'Playfair Display',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName, style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
                          Text(
                            _userCity.isNotEmpty ? '$_userCity · 0 trips' : '0 trips',
                            style: ZussGoTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Settings items
                  ...List.generate(_items.length, (i) {
                    final item  = _items[i];
                    final isPro = item['label'] == 'ZussGo Pro';
                    return GestureDetector(
                      onTap: () => context.push(item['route'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: isPro
                                    ? ZussGoTheme.rose.withValues(alpha: 0.12)
                                    : ZussGoTheme.bgSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 20,
                                color: isPro ? ZussGoTheme.rose : ZussGoTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label'] as String,
                                    style: ZussGoTheme.labelBold.copyWith(
                                      fontSize: 14,
                                      color: isPro ? ZussGoTheme.rose : null,
                                    ),
                                  ),
                                  Text(item['sub'] as String, style: ZussGoTheme.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: ZussGoTheme.textMuted, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Sign Out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ZussGoTheme.rose.withValues(alpha: 0.15)),
                        backgroundColor: ZussGoTheme.rose.withValues(alpha: 0.05),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
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
  final int? badgeCount;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
    this.badgeCount,
  });

          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: ZussGoBottomNav(currentIndex: 4),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? context.colors.rose : textPrimary))),
          if (badgeCount != null && badgeCount! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: context.colors.rose, borderRadius: BorderRadius.circular(10)),
              child: Text(badgeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          if (!isDestructive) Icon(Icons.chevron_right_rounded, color: isDark ? const Color(0xFF555555) : context.colors.textMuted, size: 18),
        ]),
      ),
    );
  }
}