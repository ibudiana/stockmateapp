import 'package:go_router/go_router.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/views/screens/screens.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/reports',
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
    ],
  );
}
