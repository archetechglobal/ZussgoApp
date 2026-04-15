import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _breatheController;
  late AnimationController _loadController;
  late Animation<double> _fadeIn;
  late Animation<double> _breathe;
  late Animation<double> _loadProgress;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _breatheController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _breathe = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut));

    _loadController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _loadProgress = CurvedAnimation(parent: _loadController, curve: Curves.easeInOut);

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 400), () => _loadController.forward());
    });

    _navigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _breatheController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final hasSeenOnboarding = await AuthService.hasSeenOnboarding();
      if (!hasSeenOnboarding) {
        if (mounted) context.go('/onboarding');
        return;
      }

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
      backgroundColor: const Color(0xFF0D0B0E),
      body: Stack(
        children: [
          // Subtle radial glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.8,
                  colors: [Color(0x10FF6B4A), Colors.transparent],
                ),
              ),
            ),
          ),

          // Breathing glow circle
          Center(
            child: AnimatedBuilder(
              animation: _breathe,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathe.value,
                  child: Opacity(
                    opacity: 2.0 - _breathe.value, // 0.85 -> 0.4-ish
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0x15FF6B4A), Colors.transparent],
                          stops: [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Globe emoji
                  Text(
                    '🌍',
                    style: TextStyle(
                      fontSize: 64,
                      shadows: [
                        Shadow(color: const Color(0x50FF6B4A), blurRadius: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Brand name
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: const Color(0xFFF5F0EB)),
                      children: const [
                        TextSpan(text: 'Zuss'),
                        TextSpan(text: 'Go', style: TextStyle(color: Color(0xFFFF6B4A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tagline
                  Text(
                    'TRAVEL TOGETHER',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: const Color(0xFF7D7573),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading bar
                  SizedBox(
                    width: 100,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: AnimatedBuilder(
                        animation: _loadProgress,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Container(color: const Color(0xFF2A2530)),
                              FractionallySizedBox(
                                widthFactor: _loadProgress.value,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(99)),
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF6B4A), Color(0xFFFFBD3D)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}