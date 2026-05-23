import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:proyecto_movil/application/providers/app_providers.dart';
import 'package:proyecto_movil/application/providers/profile_controller.dart';
import 'package:proyecto_movil/presentation/routes.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  static const primary = Color(0xFF4F46E5);
  static const pageBg = Color(0xFFF6F7FB);

  final budgetCtrl = TextEditingController(text: '500000');
  final goalCtrl = TextEditingController(text: '200000');

  bool notifications = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFromDb);
  }

  Future<void> _loadFromDb() async {
    await ref.read(profileControllerProvider.notifier).load();
    if (!mounted) return;
    final profile = ref.read(profileControllerProvider);
    if (profile.presupuesto != null) {
      budgetCtrl.text = profile.presupuesto!.montoLimite.toString();
    }
    if (profile.metaAhorro != null) {
      goalCtrl.text = profile.metaAhorro!.montoObjetivo.toString();
    }
    setState(() {});
  }

  Future<void> _saveBudget() async {
    final monto = int.tryParse(budgetCtrl.text) ?? 0;
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }
    final ok =
        await ref.read(profileControllerProvider.notifier).savePresupuesto(monto);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Presupuesto guardado ✅' : 'Error al guardar presupuesto'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveGoal() async {
    final monto = int.tryParse(goalCtrl.text) ?? 0;
    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }
    final ok =
        await ref.read(profileControllerProvider.notifier).saveMetaAhorro(monto);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Meta guardada ✅' : 'Error al guardar meta'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    budgetCtrl.dispose();
    goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(sessionServiceProvider).logout();
    if (!mounted) return;

    context.go(Routes.login);

    // (Opcional) si quieres ver el mensaje, déjalo así:
    // OJO: en algunos casos al navegar se pierde el SnackBar, por eso es opcional.
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Sesión cerrada ✅'),
    //     behavior: SnackBarBehavior.floating,
    //     duration: Duration(milliseconds: 900),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final sessionService = ref.watch(sessionServiceProvider);
    final profile = ref.watch(profileControllerProvider);
    final isAdmin = sessionService.isAdmin;
    final presupuesto = profile.presupuesto?.montoLimite ?? 500000;
    final meta = profile.metaAhorro;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Header morado
            Container(
              height: 210,
              decoration: const BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
            ),

            ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                const SizedBox(height: 10),

                // Avatar + nombre + rol
                Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sessionService.currentUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAdmin ? 'Administrador' : 'Estudiante universitario',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Admin button (solo para admin)
                if (isAdmin)
                  _Card(
                    child: _SettingTile(
                      icon: Icons.admin_panel_settings,
                      title: 'Panel de Administración',
                      subtitle: 'Gestionar usuarios y configuración',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(Routes.admin),
                    ),
                  ),

                if (isAdmin) const SizedBox(height: 14),

                // Saldo actual (cuentas.saldo_actual)
                _Card(
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo actual',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '\$ ${_money(profile.saldoActual)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Metas financieras
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.adjust_rounded, color: primary),
                          SizedBox(width: 10),
                          Text(
                            'Metas financieras',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Presupuesto mensual',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _Input(
                              controller: budgetCtrl,
                              hint: '500000',
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniButton(text: 'Guardar', onTap: _saveBudget),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Monto máximo: \$ ${_money(presupuesto)}',
                        style: const TextStyle(color: Colors.black45, fontSize: 12.5),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Meta de ahorro mensual',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _Input(controller: goalCtrl, hint: '200000'),
                          ),
                          const SizedBox(width: 10),
                          _MiniButton(text: 'Guardar', onTap: _saveGoal),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meta != null
                            ? 'Progreso: \$ ${_money(meta.montoActual)} / \$ ${_money(meta.montoObjetivo)}'
                            : 'Define tu objetivo de ahorro del mes',
                        style: const TextStyle(color: Colors.black45, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Configuración
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuración',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _SettingTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notificaciones',
                        subtitle: 'Recibir alertas de gastos',
                        trailing: Switch(
                          value: notifications,
                          activeColor: primary,
                          onChanged: (v) => setState(() => notifications = v),
                        ),
                      ),

                      const SizedBox(height: 10),

                      _SettingTile(
                        icon: Icons.nightlight_outlined,
                        title: 'Modo oscuro',
                        subtitle: 'Tema de la aplicación',
                        trailing: Switch(
                          value: darkMode,
                          activeColor: primary,
                          onChanged: (v) => setState(() => darkMode = v),
                        ),
                      ),

                      const SizedBox(height: 10),

                      _SettingTile(
                        icon: Icons.person_outline,
                        title: 'Información personal',
                        subtitle: 'Editar perfil',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Editar perfil próximamente'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Acerca de
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Acerca de',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'GastoSmart v1.0.0',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Una aplicación diseñada para ayudarte a gestionar tus finanzas personales de manera simple y efectiva.',
                        style: TextStyle(color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cerrar sesión (✅ funcional)
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _money(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    b.write(s[i]);
    if (pos > 1 && pos % 3 == 1) b.write('.');
  }
  return b.toString();
}

/* ---------------- Widgets ---------------- */

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _Input({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _MiniButton({required this.text, required this.onTap});

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
