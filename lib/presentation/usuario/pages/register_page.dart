import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';
import 'package:proyecto_movil/presentation/routes.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  static const primary = Color(0xFF4F46E5);

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({
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

  void _goBackToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.login);
    }
  }

  Future<void> _createAccount() async {
    final name    = nameCtrl.text.trim();
    final email   = emailCtrl.text.trim().toLowerCase();
    final pass    = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();
  
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
  
    setState(() => _loading = true);

    final dataSource = ref.read(supabaseDataSourceProvider);

    try {
      final existing = await dataSource.getUserByEmail(email);
      if (!mounted) return;
      if (existing != null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya existe una cuenta con ese correo')),
        );
        return;
      }

      final newUser = AdminUserEntity(
        id: '',
        name: name,
        email: email,
        password: pass,
        createdAt: DateTime.now(),
        status: AdminUserStatus.active,
        role: AdminUserRole.user,
      );

      final created = await dataSource.createUser(newUser);
      await dataSource.iniciarOnboarding(created.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la cuenta: $e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 900),
      ),
    );

    _goBackToLogin();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: _goBackToLogin,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 6),
              const Text(
                'Crear cuenta',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Comienza a gestionar tu dinero',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 26),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nombre completo',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: _dec(hint: 'Juan Perez', icon: Icons.person_outline),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Correo electronico',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec(hint: 'tu@email.com', icon: Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contrasena',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                obscureText: obscure1,
                decoration: _dec(
                  hint: '********',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => obscure1 = !obscure1),
                    icon: Icon(
                      obscure1 ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirmar contrasena',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                obscureText: obscure2,
                decoration: _dec(
                  hint: '********',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => obscure2 = !obscure2),
                    icon: Icon(
                      obscure2 ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ya tienes cuenta? '),
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: const Text(
                      'Inicia sesion',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
