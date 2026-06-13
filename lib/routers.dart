import 'package:go_router/go_router.dart';
import 'package:stockmateapp/views/screens/screens.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth/login',
    routes: [
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
