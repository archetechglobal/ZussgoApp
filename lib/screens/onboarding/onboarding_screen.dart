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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingPage(
      gradient: const LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF22D3EE)]),
      icon: Icons.luggage_rounded,
      title: 'Post Where\nYou\'re Going',
      subtitle: 'Share your destination & dates. Let other travelers find you and connect.',
    ),
    _OnboardingPage(
      gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]),
      icon: Icons.people_alt_rounded,
      title: 'Find Your\nPerfect Match',
      subtitle: 'Filter by age, mindset, travel style & budget. See compatibility scores.',
    ),
    _OnboardingPage(
      gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
      icon: Icons.chat_bubble_rounded,
      title: 'Solo or Group\n— You Choose',
      subtitle: 'Match 1-on-1 or join group trips with 3+ travelers. Chat, plan & go together.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
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
      backgroundColor: ZussGoTheme.scaffoldBg(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Image area
                        Expanded(
                          flex: 5,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: page.gradient,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Stack(
                              children: [
                                Center(child: Opacity(opacity: 0.12, child: Icon(page.icon, size: 120, color: Colors.white))),
                                Positioned(
                                  bottom: 20, left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                    child: Icon(page.icon, size: 24, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            child: Column(
                              children: [
                                // Dots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (j) {
                                    final isActive = j == _currentPage;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: isActive ? 24 : 8,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isActive ? context.colors.green : ZussGoTheme.borderDefault,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 20),
                                Text(page.title, style: context.textTheme.displayLarge!.copyWith(fontSize: 28), textAlign: TextAlign.center),
                                const SizedBox(height: 10),
                                Text(page.subtitle, style: context.textTheme.bodyMedium!, textAlign: TextAlign.center),
                                const Spacer(),
                                GradientButton(
                                  text: _currentPage == 2 ? 'Get Started' : 'Next →',
                                  onPressed: _next,
                                ),
                                if (_currentPage == 2) ...[
                                  const SizedBox(height: 14),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Already have an account? ',
                                        style: context.textTheme.bodySmall!.adaptive(context),
                                        children: [TextSpan(text: 'Sign In', style: TextStyle(color: context.colors.green, fontWeight: FontWeight.w600))],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingPage({required this.gradient, required this.icon, required this.title, required this.subtitle});
}