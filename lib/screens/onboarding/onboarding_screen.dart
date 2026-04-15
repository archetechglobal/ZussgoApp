import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _ringController;

  static const _slides = [
    _SlideData(emoji: '🗺️', title: 'Discover trips across\n', highlight: 'India', desc: 'Explore trending destinations across the country — from Himalayan peaks to coastal escapes.', color: Color(0xFFFF6B4A)),
    _SlideData(emoji: '🤝', title: 'Match with the\n', highlight: 'perfect companion', desc: 'Smart matching pairs you with travelers who share your style and pace.', color: Color(0xFFFFBD3D)),
    _SlideData(emoji: '🛡️', title: 'Travel safe with\n', highlight: 'built-in SOS', desc: 'One-tap emergency alerts with live location sharing.', color: Color(0xFFFF6B8A)),
    _SlideData(emoji: '⭐', title: 'Earn ', highlight: 'Trek Points', titleSuffix: '\non every trip', desc: 'Complete trips and match companions — earn points for cashback.', color: Color(0xFFA78BFA)),
  ];

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _getStarted();
    }
  }

  void _getStarted() async {
    await AuthService.markOnboardingSeen();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B0E),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 4,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _buildSlide(_slides[i]),
            ),
          ),

          // Dots
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFFF6B4A) : const Color(0xFF2A2530),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              children: [
                // Next / Get Started button
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B4A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0x40FF6B4A), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == 3 ? 'Get Started' : 'Next',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Login link
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF7D7573)),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(text: 'Log in', style: TextStyle(color: const Color(0xFFFF6B4A), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual with rings
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [slide.color.withValues(alpha: 0.1), Colors.transparent],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),

                // Outer dashed ring (rotating)
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _ringController.value * 2 * pi,
                      child: Container(
                        width: 216,
                        height: 216,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: slide.color.withValues(alpha: 0.15), width: 1),
                        ),
                      ),
                    );
                  },
                ),

                // Inner ring
                Container(
                  width: 184,
                  height: 184,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: slide.color.withValues(alpha: 0.3), width: 2),
                  ),
                ),

                // Emoji
                Text(slide.emoji, style: const TextStyle(fontSize: 72)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Title with highlight
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: const Color(0xFFF5F0EB), height: 1.25),
              children: [
                TextSpan(text: slide.title),
                TextSpan(text: slide.highlight, style: TextStyle(color: slide.color)),
                if (slide.titleSuffix != null) TextSpan(text: slide.titleSuffix),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Description
          SizedBox(
            width: 280,
            child: Text(
              slide.desc,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFFB8AFA6), height: 1.7),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String emoji;
  final String title;
  final String highlight;
  final String? titleSuffix;
  final String desc;
  final Color color;
  const _SlideData({required this.emoji, required this.title, required this.highlight, this.titleSuffix, required this.desc, required this.color});
}