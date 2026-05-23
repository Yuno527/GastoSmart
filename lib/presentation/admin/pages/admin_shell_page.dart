import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proyecto_movil/application/providers/admin_controller.dart';
import 'package:proyecto_movil/presentation/admin/pages/admin_dashboard_page.dart';
import 'admin_users_page.dart' as users;
import 'package:proyecto_movil/presentation/admin/pages/admin_categories_page.dart';
import 'package:proyecto_movil/presentation/admin/pages/admin_reports_page.dart';
import 'package:proyecto_movil/presentation/admin/pages/admin_config_page.dart';

class AdminShellPage extends ConsumerStatefulWidget {
  const AdminShellPage({super.key});

  @override
  ConsumerState<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends ConsumerState<AdminShellPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);

    final pages = <Widget>[
      AdminDashboardPage(onNavigate: (i) => setState(() => index = i)),
      users.AdminUsersPage(), // ✅ sin const
      const AdminCategoriesPage(),
      const AdminReportsPage(),
      const AdminConfigPage(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}
