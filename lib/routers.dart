import 'package:go_router/go_router.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/views/screens/screens.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/settings',
    routes: [
      // --- AUTH ROUTES ---
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // --- PRODUCT ROUTES ---
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/products/form',
        builder: (context, state) {
          final product = state.extra as ProductModel?;
          return ProductFormScreen(product: product);
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportScreen(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'language',
            builder: (context, state) => const LanguageScreen(),
          ),
        ],
      ),
    ],
  );
}
