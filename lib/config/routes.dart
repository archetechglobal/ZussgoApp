import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/verify_otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/destination_detail_screen.dart';
import '../screens/matches/matches_screen.dart';
import '../screens/matches/traveler_profile_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/trips/my_trips_screen.dart';
import '../screens/settings/settings_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // Onboarding
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

    // Auth
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // OTP Verification — receives email + type via "extra"
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VerifyOtpScreen(
          email: extra['email'] ?? '',
          type: extra['type'] ?? 'signup',
        );
      },
    ),

    // Forgot Password
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

    // Reset Password — receives email + otp via "extra"
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ResetPasswordScreen(
          email: extra['email'] ?? '',
          otp: extra['otp'] ?? '',
        );
      },
    ),

    // Profile Setup
    GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),

    // Home
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Search
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/destination/:id', builder: (context, state) => DestinationDetailScreen(destinationId: state.pathParameters['id'] ?? '')),

    // Matches
    GoRoute(path: '/matches', builder: (context, state) => const MatchesScreen()),
    GoRoute(path: '/traveler/:id', builder: (context, state) => TravelerProfileScreen(travelerId: state.pathParameters['id'] ?? '')),

    // Chat
    GoRoute(path: '/chat/:matchId', builder: (context, state) => ChatScreen(matchId: state.pathParameters['matchId'] ?? '')),

    // Trips
    GoRoute(path: '/trips', builder: (context, state) => const MyTripsScreen()),

    // Settings
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);