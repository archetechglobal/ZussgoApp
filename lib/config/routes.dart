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
import '../screens/home/see_all_travelers_screen.dart';
import '../screens/home/see_all_events_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/destination_detail_screen.dart';
import '../screens/search/browse_travelers_screen.dart';
import '../screens/matches/matches_screen.dart';
import '../screens/matches/traveler_profile_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/trips/my_trips_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/safety/active_trip_screen.dart';
import '../screens/feedback/trip_complete_screen.dart';
import '../screens/search/smart_matches_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/verify-otp', builder: (context, state) {
      final e = state.extra as Map<String, dynamic>? ?? {};
      return VerifyOtpScreen(email: e['email'] ?? '', type: e['type'] ?? 'signup', fullName: e['fullName']);
    }),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-password', builder: (context, state) {
      final e = state.extra as Map<String, dynamic>? ?? {};
      return ResetPasswordScreen(email: e['email'] ?? '');
    }),
    GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/see-all-travelers', builder: (context, state) => const SeeAllTravelersScreen()),
    GoRoute(path: '/see-all-events', builder: (context, state) => const SeeAllEventsScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/destination/:id', builder: (context, state) => DestinationDetailScreen(destinationId: state.pathParameters['id'] ?? '')),
    GoRoute(path: '/browse/:slug', builder: (context, state) {
      final e = state.extra as Map<String, dynamic>? ?? {};
      return BrowseTravelersScreen(
        destinationSlug: state.pathParameters['slug'] ?? '',
        destinationName: e['name'] ?? '',
        destinationId: e['destinationId'],
      );
    }),
    GoRoute(path: '/matches', builder: (context, state) => const MatchesScreen()),
    GoRoute(path: '/traveler/:id', builder: (context, state) => TravelerProfileScreen(travelerId: state.pathParameters['id'] ?? '')),
    GoRoute(path: '/chats', builder: (context, state) => const ChatListScreen()),
    GoRoute(path: '/chat/:matchId', builder: (context, state) => ChatScreen(matchId: state.pathParameters['matchId'] ?? '')),
    GoRoute(path: '/trips', builder: (context, state) => const MyTripsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/active-trip', builder: (context, state) => const ActiveTripScreen()),
    GoRoute(path: '/trip-complete', builder: (context, state) => const TripCompleteScreen()),
    GoRoute(
      path: '/smart-matches/:tripId',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return SmartMatchesScreen(
          tripId: state.pathParameters['tripId'] ?? '',
          destinationName: extra['destinationName'] ?? '',
          destinationEmoji: extra['destinationEmoji'] ?? '✈️',
        );
      },
    ),
  ],
);