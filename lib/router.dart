import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_transit/state/auth_provider.dart';
import 'package:smart_transit/screens/login_screen.dart';
import 'package:smart_transit/screens/signup_screen.dart';
import 'package:smart_transit/screens/welcome_screen.dart';
import 'package:smart_transit/screens/forgot_password_screen.dart';
import 'package:smart_transit/screens/reset_password_screen.dart';
import 'package:smart_transit/screens/home_shell.dart';
import 'package:smart_transit/screens/planner_screen.dart';
import 'package:smart_transit/screens/history_screen.dart';
import 'package:smart_transit/screens/profile_screen.dart';
import 'package:smart_transit/screens/tourist_screen.dart';
import 'package:smart_transit/screens/route_result_screen.dart';
import 'package:smart_transit/screens/booking_screen.dart';
import 'package:smart_transit/screens/payment_screen.dart';
import 'package:smart_transit/screens/ticket_screen.dart';
import 'package:smart_transit/screens/admin/admin_home_screen.dart';
import 'package:smart_transit/screens/admin/manage_stations_screen.dart';
import 'package:smart_transit/screens/admin/manage_pricing_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/planner',
    redirect: (context, state) {
      final loggedIn = authState != null;
      final loggingIn =
          state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/forgot_password' ||
          state.uri.path == '/reset_password' ||
          state.uri.path == '/welcome';

      // If not logged in and not on an auth screen, go to welcome
      if (!loggedIn && !loggingIn) return '/welcome';

      // If logged in and on an auth screen, go to planner
      if (loggedIn && loggingIn) return '/planner';

      // Admin Route Protection
      if (state.uri.path.startsWith('/admin')) {
        if (!loggedIn || authState.isAdmin != true) {
          return '/planner'; // Redirect non-admins to home
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/planner',
            builder: (context, state) => const PlannerScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/tourist',
            builder: (context, state) => const TouristScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/route_result',
        builder: (context, state) => const RouteResultScreen(),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/ticket',
        builder: (context, state) => const TicketScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: 'stations',
            builder: (context, state) => const ManageStationsScreen(),
          ),
          GoRoute(
            path: 'pricing',
            builder: (context, state) => const ManagePricingScreen(),
          ),
        ],
      ),
    ],
  );
});
