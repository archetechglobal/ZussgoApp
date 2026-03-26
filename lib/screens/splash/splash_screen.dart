import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final hasSeenOnboarding = await AuthService.hasSeenOnboarding();
      if (!hasSeenOnboarding) { if (mounted) context.go('/onboarding'); return; }

      final hasSession = await AuthService.hasSession();
      if (hasSession) {
        final user = await AuthService.getSavedUser();
        if (user != null && user['isProfileCompleted'] == true) {
          if (mounted) context.go('/home');
        } else {
          if (mounted) context.go('/profile-setup');
        }
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF059669), Color(0xFF34D399), Color(0xFF0891B2)],
              ),
            ),
          ),

          // Large faded emoji
          Center(
            child: Opacity(
              opacity: 0.08,
              child: Text('🌍', style: TextStyle(fontSize: 200)),
            ),
          ),

          // Dark gradient overlay at bottom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xCC000000)],
                stops: [0.3, 1.0],
              ),
            ),
          ),

          // Content
          FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Your\nFavorite Journey',
                      style: ZussGoTheme.displayLarge.copyWith(color: Colors.white, fontSize: 34),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Together We Go',
                      style: ZussGoTheme.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}