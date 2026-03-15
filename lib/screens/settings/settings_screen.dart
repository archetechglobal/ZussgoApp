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
        _userName = user['fullName'] ?? 'Traveler';
        _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'Z';
        _userCity = user['city'] ?? '';
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.clearSession();
    if (mounted) context.go('/login');
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

                  // Profile header (dynamic)
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(18)),
                        alignment: Alignment.center,
                        child: Text(_userInitial, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Playfair Display')),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName, style: ZussGoTheme.displaySmall.copyWith(fontSize: 18)),
                          Text(_userCity.isNotEmpty ? '$_userCity · 0 trips' : '0 trips', style: ZussGoTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Settings items
                  ...List.generate(_items.length, (i) {
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
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // Logout — clears session then navigates
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
                      child: Text('Sign Out', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom nav
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: ZussGoBottomNav(currentIndex: 4),
          ),
        ],
      ),
    );
  }
}