import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardPage(emoji: '🗺️', title: 'Your Journey\nStarts Here', desc: 'Find kindred travelers heading your way. No more solo anxiety.'),
    _OnboardPage(emoji: '✨', title: 'Curated\nConnections', desc: 'We match you by destination, dates, and travel vibe. Not random — intentional.'),
    _OnboardPage(emoji: '🌅', title: 'Stories Worth\nTelling', desc: 'The best trips start with the right people. Let\'s find yours.'),
  ];

  // Mark onboarding as seen and navigate
  void _finish() async {
    await AuthService.markOnboardingSeen();
    if (mounted) context.go('/signup');
  }

  void _skip() async {
    await AuthService.markOnboardingSeen();
    if (mounted) context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text('Skip', style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => _pages[i],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentPage ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: i == _currentPage ? ZussGoTheme.gradientPrimary : null,
                      color: i == _currentPage ? null : const Color(0x0FFFFFFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: _currentPage == 2 ? 'Get Started' : 'Continue',
                onPressed: () {
                  if (_currentPage == 2) {
                    _finish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  const _OnboardPage({required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity, height: 240,
          margin: const EdgeInsets.only(bottom: 36),
          decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(28), border: Border.all(color: ZussGoTheme.borderDefault)),
          child: Stack(children: [
            Positioned(top: -30, right: -30, child: _orb(120, ZussGoTheme.amber, 0.1)),
            Positioned(bottom: -20, left: -20, child: _orb(100, ZussGoTheme.rose, 0.08)),
            Center(child: Text(emoji, style: const TextStyle(fontSize: 72))),
          ]),
        ),
        Text(title, textAlign: TextAlign.center, style: ZussGoTheme.displayLarge.copyWith(fontSize: 28, height: 1.15)),
        const SizedBox(height: 12),
        Text(desc, textAlign: TextAlign.center, style: ZussGoTheme.bodyLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w300)),
      ],
    );
  }

  static Widget _orb(double size, Color color, double opacity) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)])));
  }
}