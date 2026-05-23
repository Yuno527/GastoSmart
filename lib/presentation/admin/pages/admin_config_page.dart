import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:proyecto_movil/application/providers/admin_controller.dart';
import 'package:proyecto_movil/presentation/routes.dart';

class AdminConfigPage extends ConsumerStatefulWidget {
  const AdminConfigPage({super.key});

  @override
  ConsumerState<AdminConfigPage> createState() => _AdminConfigPageState();
}

class _AdminConfigPageState extends ConsumerState<AdminConfigPage> {
  static const primary = Color(0xFF4F46E5);
  final budgetCtrl = TextEditingController();

  @override
  void dispose() {
    budgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final ctrl = ref.read(adminControllerProvider.notifier);

    // mantener el input sincronizado
    budgetCtrl.text = state.budget.toString();
    budgetCtrl.selection = TextSelection.collapsed(
      offset: budgetCtrl.text.length,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _AdminHeader(
            title: 'Configuración',
            subtitle: 'Parámetros del sistema',
          ),
          const SizedBox(height: 14),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.brush_outlined,
                  title: 'Apariencia',
                ),
                const SizedBox(height: 10),
                _SwitchRow(
                  title: 'Modo Oscuro',
                  subtitle: 'Activa el tema oscuro del sistema',
                  value: state.darkMode,
                  onChanged: ctrl.toggleDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                ),
                const SizedBox(height: 10),
                _SwitchRow(
                  title: 'Notificaciones Globales',
                  subtitle: 'Enviar notificaciones a todos los usuarios',
                  value: state.notificationsEnabled,
                  onChanged: ctrl.toggleNotifications,
                ),
                const SizedBox(height: 10),
                _SwitchRow(
                  title: 'Alertas de Gasto',
                  subtitle: 'Avisar cuando se superen límites',
                  value: state.spendAlertsEnabled,
                  onChanged: ctrl.toggleSpendAlerts,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  icon: Icons.attach_money,
                  title: 'Presupuesto',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Presupuesto sugerido para Estudiantes',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: const Color(0xFFF6F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      final v = int.tryParse(budgetCtrl.text) ?? state.budget;
                      ctrl.setBudget(v);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Presupuesto guardado ✅')),
                      );
                    },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(icon: Icons.info_outline, title: 'Versión'),
                SizedBox(height: 10),
                _InfoRow(label: 'Versión', value: 'v1.0.0'),
                _InfoRow(label: 'Última actualización', value: '05/03/2026'),
                _InfoRow(label: 'Servidor', value: 'Activo', green: true),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => context.go(Routes.login),
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* UI */

class _AdminHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _AdminHeader({required this.title, required this.subtitle});

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primary, Color(0xFF6D5EF6)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PANEL ADMIN',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF111827)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
            ],
          ),
        ),
        Switch(value: value, activeColor: primary, onChanged: onChanged),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool green;
  const _InfoRow({
    required this.label,
    required this.value,
    this.green = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: green ? const Color(0xFF10B981) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
