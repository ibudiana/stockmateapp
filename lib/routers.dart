import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stockmateapp/models/product_model.dart';
import 'package:stockmateapp/utils/helpers/session_service.dart';
import 'package:stockmateapp/viewmodels/auth/auth.dart';
import 'package:stockmateapp/views/screens/screens.dart';

class AppRouter {
  // Ubah menjadi fungsi yang menerima context agar bisa membaca AuthViewModel
  static GoRouter createRouter(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return GoRouter(
      initialLocation: '/home',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        // Cek sesi secara instan menggunakan SessionService
        final loggedIn = SessionService.isLoggedInSync;

        final isAuthRoute = state.uri.path.startsWith('/auth');

        // Daftar rute yang harus dilindungi (wajib login)
        final isProtectedRoute =
            state.uri.path.startsWith('/home') ||
            state.uri.path.startsWith('/products') ||
            state.uri.path.startsWith('/reports') ||
            state.uri.path.startsWith('/settings') ||
            state.uri.path.startsWith('/notifications');

        if (!loggedIn && isProtectedRoute) {
          return '/auth/login';
        }

        if (loggedIn && isAuthRoute) {
          return '/home';
        }

        return null;
      },

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

        // --- MAIN ROUTES ---
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

        // --- REPORT ROUTES ---
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportScreen(),
        ),

        // --- SETTINGS ROUTES ---
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
}
