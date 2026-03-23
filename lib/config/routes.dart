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
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/trips/my_trips_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/edit_profile/edit_profile_screen.dart';
import '../screens/settings/notifications/notifications_screen.dart';
import '../screens/settings/safety/safety_screen.dart';
import '../screens/settings/pro/pro_screen.dart';
import '../screens/settings/support/support_screen.dart';
import '../screens/settings/legal/legal_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return VerifyOtpScreen(
          email: extra['email'] ?? '',
          type: extra['type'] ?? 'signup',
          fullName: extra['fullName'],
        );
      },
    ),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ResetPasswordScreen(email: extra['email'] ?? '');
      },
    ),
    GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/destination/:id',
      builder: (context, state) => DestinationDetailScreen(
        destinationId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(path: '/matches', builder: (context, state) => const MatchesScreen()),
    GoRoute(
      path: '/traveler/:id',
      builder: (context, state) => TravelerProfileScreen(
        travelerId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(path: '/chats', builder: (context, state) => const ChatListScreen()),
    GoRoute(
      path: '/chat/:matchId',
      builder: (context, state) => ChatScreen(
        matchId: state.pathParameters['matchId'] ?? '',
      ),
    ),
    GoRoute(path: '/trips', builder: (context, state) => const MyTripsScreen()),

    // ── Settings ──────────────────────────────────────────────────────────────
    GoRoute(path: '/settings',              builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/settings/edit-profile', builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: '/settings/notifications',builder: (context, state) => const NotificationsScreen()),
    GoRoute(path: '/settings/safety',       builder: (context, state) => const SafetyScreen()),
    GoRoute(path: '/settings/pro',          builder: (context, state) => const ProScreen()),
    GoRoute(path: '/settings/support',      builder: (context, state) => const SupportScreen()),
    GoRoute(path: '/settings/legal',        builder: (context, state) => const LegalScreen()),
  ],
);