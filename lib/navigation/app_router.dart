import 'package:go_router/go_router.dart';
import '../repositories/auth_repository.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  AppRouter({required this.authRepository})
      : router = GoRouter(
          initialLocation: '/',
          routes: <GoRoute>[
            GoRoute(
              path: '/',
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => LoginScreen(authRepository: authRepository),
            ),
            GoRoute(
              path: '/register',
              builder: (context, state) => RegisterScreen(authRepository: authRepository),
            ),
            GoRoute(
              path: '/home',
              builder: (context, state) => const MainShell(),
            ),
          ],
        );

  final AuthRepository authRepository;
  final GoRouter router;
}
