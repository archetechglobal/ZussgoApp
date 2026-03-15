import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/logo_painter.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.elasticOut)),
    );

    _controller.forward();

    // Smart navigation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _navigate();
    });
  }

  // Decides where to send the user based on their state
  Future<void> _navigate() async {
    try {
      final hasSeenOnboarding = await AuthService.hasSeenOnboarding();
      final isLoggedIn = await AuthService.hasSession();

      if (!hasSeenOnboarding) {
        if (mounted) context.go('/onboarding');
      } else if (isLoggedIn) {
        final user = await AuthService.getSavedUser();
        final isProfileCompleted = user?['isProfileCompleted'] ?? false;
        if (mounted) {
          if (isProfileCompleted) {
            context.go('/home');
          } else {
            context.go('/profile-setup');
          }
        }
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      // If anything fails, just go to onboarding as safe default
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: -100, left: -80, child: _glow(280, ZussGoTheme.amber, 0.1)),
          Positioned(bottom: -80, right: -60, child: _glow(240, ZussGoTheme.rose, 0.08)),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35, right: -30,
            child: _glow(160, ZussGoTheme.mint, 0.05),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            gradient: ZussGoTheme.gradientPrimary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: ZussGoTheme.amber.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 10)),
                              BoxShadow(color: ZussGoTheme.rose.withValues(alpha: 0.15), blurRadius: 60, offset: const Offset(0, 20)),
                            ],
                          ),
                          child: CustomPaint(painter: ZussGoLogoPainter(), size: const Size(88, 88)),
                        ),
                        const SizedBox(height: 24),
                        Text('ZussGo', style: ZussGoTheme.displayLarge.copyWith(fontSize: 34)),
                        const SizedBox(height: 8),
                        Text('TOGETHER WE GO', style: ZussGoTheme.tagline),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ZussGoTheme.pillBadge,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: ZussGoTheme.mint)),
                              const SizedBox(width: 8),
                              Text('Find your travel companion', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textPrimary.withValues(alpha: 0.45))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 60, left: 0, right: 0,
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  Center(child: Container(width: 44, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: ZussGoTheme.gradientPrimary))),
                  const SizedBox(height: 16),
                  Text('v0.1', style: ZussGoTheme.bodySmall.copyWith(fontSize: 10, color: ZussGoTheme.textPrimary.withValues(alpha: 0.15))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)])),
    );
  }
}