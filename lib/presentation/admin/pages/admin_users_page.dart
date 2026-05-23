import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/admin_controller.dart';
import 'package:proyecto_movil/domain/entities/admin_entity.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  static const primary = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(adminControllerProvider.notifier);
    final state = ref.watch(adminControllerProvider);
    final users = ctrl.filteredUsers();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _AdminHeader(
            title: 'Gestión de Usuarios',
            subtitle: '6 usuarios registrados',
          ),
          const SizedBox(height: 14),

          // Search
          TextField(
            onChanged: ctrl.setUsersQuery,
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ...users.map((u) => _UserCard(user: u)).toList(),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Center(
                child: Text(
                  'Sin resultados',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

          if (state.usersQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Filtro: "${state.usersQuery}"',
                style: const TextStyle(color: Colors.black45),
              ),
            ),
        ],
      ),
    );
  }
}

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

class _UserCard extends ConsumerWidget {
  final AdminUserEntity user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(adminControllerProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person_outline)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatusChip(status: user.status),
                    const SizedBox(width: 8),
                    Text(
                      'Registrado: ${_fmt(user.createdAt)}',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'activar')
                ctrl.setUserStatus(user.id, AdminUserStatus.active);
              if (v == 'desactivar')
                ctrl.setUserStatus(user.id, AdminUserStatus.inactive);
              if (v == 'bloquear')
                ctrl.setUserStatus(user.id, AdminUserStatus.blocked);
              if (v == 'eliminar') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Eliminar (demo)')),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'activar', child: Text('Activar')),
              PopupMenuItem(value: 'desactivar', child: Text('Desactivar')),
              PopupMenuItem(value: 'bloquear', child: Text('Bloquear')),
              PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusChip extends StatelessWidget {
  final AdminUserStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case AdminUserStatus.active:
        text = 'Activo';
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF10B981);
        break;
      case AdminUserStatus.inactive:
        text = 'Inactivo';
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF6B7280);
        break;
      case AdminUserStatus.blocked:
        text = 'Bloqueado';
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFEF4444);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
