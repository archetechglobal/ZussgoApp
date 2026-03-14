import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/login_screen.dart';
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
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(path: '/destination/:id', builder: (context, state) => DestinationDetailScreen(destinationId: state.pathParameters['id'] ?? '')),
    GoRoute(path: '/matches', builder: (context, state) => const MatchesScreen()),
    GoRoute(path: '/traveler/:id', builder: (context, state) => TravelerProfileScreen(travelerId: state.pathParameters['id'] ?? '')),
    GoRoute(path: '/chat/:matchId', builder: (context, state) => ChatScreen(matchId: state.pathParameters['matchId'] ?? '')),
    GoRoute(path: '/trips', builder: (context, state) => const MyTripsScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);
