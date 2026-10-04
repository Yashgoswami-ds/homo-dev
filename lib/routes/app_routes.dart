import '../core/app_export.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/login/login_screen.dart';
import '../presentation/otp/otp_screen.dart';
import '../presentation/basic_details/basic_details_screen.dart';

class AppRoutes {
  static const String initial = '/'; // 🚨 CRITICAL: DO NOT REMOVE THIS ROUTE
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String basicDetails = '/basic-details';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  routes: [
    GoRoute(
      path: AppRoutes.initial,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final phone = extra?['phone'] as String? ?? '';
        return OtpScreen(phone: phone);
      },
    ),
    GoRoute(
      path: AppRoutes.basicDetails,
      builder: (context, state) => const BasicDetailsScreen(),
    ),
  ],
);
