import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  final _pages = const [
    _OnboardingPage(
      imageUrl: 'assets/images/onboarding_share_travel.jpg',
      title: 'Share Your Travel Plan',
      subtitle: 'Connect with travelers going to the same destination',
    ),
    _OnboardingPage(
      imageUrl: 'assets/images/onboarding_find_match.jpg',
      title: 'Find the Right Companion',
      subtitle: 'Match with verified travelers by interests',
    ),
    _OnboardingPage(
      imageUrl: 'assets/images/onboarding_travel_way.jpg',
      title: 'Travel Your Way',
      subtitle: 'Choose solo or group trips',
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
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: page.imageUrl.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: page.imageUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, dynamic error) {
                                        return Container(
                                          color: ZussGoTheme.mutedBg(context),
                                          child: Center(
                                            child: Icon(Icons.image_not_supported, color: ZussGoTheme.mutedText(context)),
                                          ),
                                        );
                                      },
                                      placeholder: (context, url) => Container(
                                        color: ZussGoTheme.mutedBg(context),
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                    )
                                  : Image.asset(
                                      page.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: ZussGoTheme.mutedBg(context),
                                          child: Center(
                                            child: Icon(Icons.image_not_supported, color: ZussGoTheme.mutedText(context)),
                                          ),
                                        );
                                      },
                                    ),
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
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isActive ? context.colors.green : ZussGoTheme.border(context),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  page.title, 
                                  style: context.textTheme.displayLarge!.copyWith(fontSize: 30), 
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  page.subtitle, 
                                  style: context.textTheme.bodyMedium!.copyWith(fontSize: 15), 
                                  textAlign: TextAlign.center,
                                ),
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
                                        style: context.textTheme.bodySmall!.adaptive(context).copyWith(fontSize: 13),
                                        children: [
                                          TextSpan(
                                            text: 'Sign In', 
                                            style: TextStyle(
                                              color: context.colors.green, 
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
  final String imageUrl;
  final String title;
  final String subtitle;
  const _OnboardingPage({
    required this.imageUrl, 
    required this.title, 
    required this.subtitle,
  });
}