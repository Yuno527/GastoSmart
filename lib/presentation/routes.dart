import 'package:go_router/go_router.dart';

import 'package:proyecto_movil/presentation/admin/pages/admin_shell_page.dart';
import 'package:proyecto_movil/presentation/usuario/pages/home_shell_page.dart';
import 'package:proyecto_movil/presentation/usuario/pages/login_page.dart';
import 'package:proyecto_movil/presentation/usuario/pages/onboarding_page.dart';
import 'package:proyecto_movil/presentation/usuario/pages/register_page.dart';

class Routes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const admin = '/admin';
}

GoRouter buildRouter({required bool showOnboarding}) {
  return GoRouter(
    initialLocation: showOnboarding ? Routes.onboarding : Routes.login,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: Routes.register, builder: (_, __) => const RegisterPage()),
      GoRoute(path: Routes.home, builder: (_, __) => const HomeShellPage()),
      GoRoute(path: Routes.admin, builder: (_, __) => const AdminShellPage()),
    ],
  );
}
