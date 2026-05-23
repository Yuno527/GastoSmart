import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';
import 'package:proyecto_movil/presentation/routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const primary = Color(0xFF4F46E5);

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool obscure = true;
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.black45),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF6F7FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _login() async {
    final email = emailCtrl.text.trim().toLowerCase();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa correo y contraseña'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => loading = true);

    await Future.delayed(const Duration(milliseconds: 450));

    setState(() => loading = false);

    final dataSource = ref.read(localDataSourceProvider);
    final users = dataSource.getUsers();

    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == email && u.password == pass,
      orElse: () => users.firstWhere(
        (u) => u.email.toLowerCase() == email,
        orElse: () => users.isNotEmpty ? users.first : users.first,
      ),
    );

    if (user.email.toLowerCase() != email || user.password != pass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (user.status != AdminUserStatus.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario inactivo o bloqueado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sessionService = ref.read(sessionServiceProvider);
    final role = user.role.name;
    await sessionService.login(user.id, user.name, user.email, role);

    if (role == 'admin') {
      context.go(Routes.admin);
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 8),

              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Accede a tu cuenta para continuar\ngestionando tus gastos.',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Correo electrónico',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(
                  hint: 'ej: usuario@gmail.com',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Contraseña',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: _decoration(
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recuperación próximamente'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primary.withValues(alpha: 0.55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? '),
                  TextButton(
                    onPressed: () => context.push(Routes.register),
                    style: TextButton.styleFrom(
                      foregroundColor: primary,
                      backgroundColor: const Color(0xFFEDE9FE),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Usa tu email y contraseña registrados',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
