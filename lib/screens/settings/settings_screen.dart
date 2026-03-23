import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
<<<<<<< HEAD
  String _userName = '';
  String _userInitial = '';
  String _userCity = '';

  static const _items = [
    {'icon': Icons.person_rounded, 'label': 'Edit Profile', 'sub': 'Photo, bio, vibes'},
    {'icon': Icons.notifications_rounded, 'label': 'Notifications', 'sub': 'Match alerts'},
    {'icon': Icons.shield_rounded, 'label': 'Safety', 'sub': 'Block, report'},
    {'icon': Icons.auto_awesome_rounded, 'label': 'ZussGo Pro', 'sub': 'Unlock premium'},
    {'icon': Icons.help_rounded, 'label': 'Support', 'sub': 'Help center'},
    {'icon': Icons.description_rounded, 'label': 'Legal', 'sub': 'Terms & privacy'},
=======
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
>>>>>>> 65df3af (Added the settings screen)
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getSavedUser();
    if (user != null && mounted) {
      setState(() {
<<<<<<< HEAD
        _userName = user['fullName'] ?? 'Traveler';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Z';
        _userCity = user['city'] ?? '';
=======
        _userName    = user['fullName'] ?? 'Traveler';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Z';
        _userCity    = user['city'] ?? '';
>>>>>>> 65df3af (Added the settings screen)
      });
    }
  }

  Future<void> _handleLogout() async {
<<<<<<< HEAD
    await AuthService.clearSession();
    if (mounted) context.go('/login');
=======
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
>>>>>>> 65df3af (Added the settings screen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),

<<<<<<< HEAD
                  // Profile header (dynamic)
=======
                  // Profile header
>>>>>>> 65df3af (Added the settings screen)
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
<<<<<<< HEAD
                        decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(18)),
                        alignment: Alignment.center,
                        child: Text(_userInitial, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Playfair Display')),
=======
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
>>>>>>> 65df3af (Added the settings screen)
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName, style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
<<<<<<< HEAD
                          Text(_userCity.isNotEmpty ? '$_userCity · 0 trips' : '0 trips', style: ZussGoTheme.bodySmall),
=======
                          Text(
                            _userCity.isNotEmpty ? '$_userCity · 0 trips' : '0 trips',
                            style: ZussGoTheme.bodySmall,
                          ),
>>>>>>> 65df3af (Added the settings screen)
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Settings items
                  ...List.generate(_items.length, (i) {
<<<<<<< HEAD
                    final item = _items[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: ZussGoTheme.borderDefault))),
                      child: Row(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(12)),
                            child: Icon(item['icon'] as IconData, size: 20, color: ZussGoTheme.textSecondary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['label'] as String, style: ZussGoTheme.labelBold.copyWith(fontSize: 14)),
                                Text(item['sub'] as String, style: ZussGoTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: ZussGoTheme.textMuted, size: 20),
                        ],
=======
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
>>>>>>> 65df3af (Added the settings screen)
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

<<<<<<< HEAD
                  // Logout — clears session then navigates
=======
                  // Sign Out
>>>>>>> 65df3af (Added the settings screen)
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
<<<<<<< HEAD
                      child: Text('Sign Out', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600, fontSize: 14)),
=======
                      child: Text(
                        'Sign Out',
                        style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
>>>>>>> 65df3af (Added the settings screen)
                    ),
                  ),
                ],
              ),
            ),
          ),

<<<<<<< HEAD
          // Fixed bottom nav
=======
>>>>>>> 65df3af (Added the settings screen)
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: ZussGoBottomNav(currentIndex: 4),
          ),
        ],
      ),
    );
  }
}